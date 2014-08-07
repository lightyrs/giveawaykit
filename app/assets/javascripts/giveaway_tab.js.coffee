jQuery ->

  giveaway_hash = _SG.currentGiveaway.table
  giveaway_object = giveaway_hash.giveaway.table
  paths = _SG.paths

  $like_id = null
  $authed = null
  $email = null
  $new_session = null
  $entry_id = null
  $request_count = 0
  $wall_post_count = 0
  $shortlink = null
  $just_liked = false
  $referrer_id = "#{giveaway_hash.referrer_id}" or ""
  $modal = $("#giveaway_modal")
  $form = $modal.find(".form")
  $form_submit = $form.find("a.btn.btn-primary.submit")
  $auth = $modal.find(".auth")
  $auth_button = $auth.find("a.btn.btn-primary.auth")
  $loader = $modal.find(".loader")

  $auth_required = () ->
    val = giveaway_object.auth_required
    val == "1" || val == "true"
  $autoshow = () ->
    val = giveaway_object.autoshow_share
    val == "1" || val == "true"

  $("#giveaway_image").click ->
    Giveaway.modal.hide()

  fb_init_options =
    status: true
    cookie: true
    xfbml: true
    channelUrl: "//#{_SG.global.SG_SSL_DOMAIN}/channel.html"

  $(document).fb _SG.global.FB_APP_ID, fb_init_options

  $(document).on 'fb:initialized', ->

    if $auth_required()
      FB.getLoginStatus (response) ->
        Giveaway.init()
    else
      Giveaway.init()

  Giveaway =

    init: ->
      FB.Canvas.setSize height: "#{giveaway_hash.tab_height}"

      FB.Event.subscribe 'edge.create', (href, widget) ->
        $just_liked = true
        Giveaway.step.one.hide()
        Giveaway.step.two.show()
        Giveaway.onLike()

      $("#enter_giveaway a").on "click", (e) ->
        if Giveaway.eligible()
          Giveaway.entry.eligible()
        else
          Giveaway.modal.show()
          Giveaway.step.one.show()
        e.preventDefault()

      Giveaway.step.two.find("a").on "click", (e) ->
        e.preventDefault()
        Giveaway.entry.statusCheck()

      Giveaway.termsLink()

    modal: $modal

    step:
      one: $modal.find(".step.one")
      two: $modal.find(".step.two")
      three: $modal.find(".step.three")

    loader: $loader

    termsLink: ->
      $("a.terms-link.terms-text").click (e) ->
        $(".terms-text.hidden").show()
        FB.Canvas.setSize(height: ($("#tab_container").height() + 40))
        e.preventDefault()

    eligible: ->
      (("#{giveaway_hash.has_liked}" == "true") || $just_liked) ? true : false

    onLike: ->
      $.ajax
        type: "POST"
        url: "#{paths.likes}"
        dataType: "json"
        data: "like[giveaway_id]=#{giveaway_object.id}"
        success: (data, textStatus, jqXHR) ->
          $like_id = data
          return true

    entry:

      loader: ->
        $modal.find(".step").hide()
        $loader.show()
        $modal.show()

      form: ->
        $loader.hide()
        $form.show()
        $form_submit.click (e) ->
          $email = $form.find("input").val()
          $new_session = "auth_disabled"
          Giveaway.entry.eligible()
          e.preventDefault()
        $(document).keypress (e) ->
          if (e.which == 13) && $form.is(':visible')
            $form_submit.click()

      error: (error) ->
        $loader.hide()
        $form.hide()
        $auth.hide()
        Giveaway.step.two.hide()
        Giveaway.step.three.show().find(".entry-status").html "<p>" + error + "</p>"
        Giveaway.share.listener()

      success: ->
        $loader.hide()
        $form.hide()
        $auth.hide()
        Giveaway.step.two.hide()
        Giveaway.step.three.show()
        Giveaway.share.listener()
        if $autoshow()
          $("a.app-request").click()

      submit: (access_token, json) ->
        Giveaway.entry.loader()
        if json?
          access_token = eval("(" + access_token + ")")
        $.ajax
          type: "POST"
          url: "#{paths.giveawayEntries}"
          dataType: "json"
          data: "access_token=" + access_token + "&has_liked=" + Giveaway.eligible() + "&ref_id=" + $referrer_id + "&email=" + $email + "&like_id=" + $like_id
          statusCode:
            201: (response) ->
              $entry = response
              $entry_id = $entry.id
              $shortlink = $entry.shortlink
              Giveaway.entry.success()

            406: (response) ->
              $entry = jQuery.parseJSON(response.responseText)
              $entry_id = $entry.id
              $wall_post_count = parseInt($entry.wall_post_count)
              $request_count = parseInt($entry.request_count)
              $shortlink = $entry.shortlink
              Giveaway.entry.error "You have already entered the giveaway.<br />Entry is limited to one per person."

            412: ->
              $loader.hide()
              Giveaway.step.one.show()

            404: ->
              Giveaway.entry.error "There was an unexpected error.<br />Please reload the page and try again."

            424: ->
              Giveaway.entry.error "There was an unexpected error.<br />Please reload the page and try again."

      statusCheck: ->
        FB.getLoginStatus (response) ->
          if response.authResponse && response.authResponse.accessToken
            $new_session = response.authResponse.accessToken
            Giveaway.entry.eligible()
          else if $auth_required()
            Giveaway.entry.auth(response)
          else
            Giveaway.entry.form()

      eligible: ->
        Giveaway.entry.loader()
        if $new_session?
          Giveaway.entry.submit $new_session
        else
          Giveaway.entry.statusCheck()

      auth: (response) ->
        FB.login (response) ->
          if response.authResponse && response.authResponse.accessToken
            $new_session = response.authResponse.accessToken
            Giveaway.entry.eligible()
          else
            Giveaway.modal.show()
            Giveaway.entry.error "You must grant permissions in order to enter the giveaway."
          $auth.hide()
        , scope: "email, user_location, user_birthday, user_likes"
        e.preventDefault()

    share:
      listener: ->
        $("a.wall-post").click (e) ->
          Giveaway.share.as_wall_post()
          e.preventDefault()

        $("a.app-request").click (e) ->
          Giveaway.share.as_app_request()
          e.preventDefault()

        Giveaway.initZClip()

      callback: (json) ->
        $.ajax
          type: "PUT"
          url: "#{paths.giveawayEntries}/#{$entry_id}"
          dataType: "text"
          data: json
          statusCode:
            202: ->
            406: ->
            404: ->
              Giveaway.entry.error "There was an unexpected error.<br />Please reload the page and try again."

      dialog: (data) ->
        FB.ui data, (response) ->
          if response and response.post_id
            json = entry:
              wall_post_count: $wall_post_count + 1
            Giveaway.share.callback json
          else if response and response.to
            json = entry:
              request_count: $request_count + response.to.length
            Giveaway.share.callback json
          else
            return true

      as_wall_post: ->
        Giveaway.share.dialog
          method: "feed"
          name: "#{giveaway_hash.current_page.name}"
          link: "#{giveaway_object.giveaway_url}" + "&app_data=ref_" + $entry_id
          picture: "#{giveaway_object.feed_image_url}"
          caption: "#{giveaway_object.title}"
          description: "#{giveaway_object.description}"

      as_app_request: ->
        Giveaway.share.dialog
          title: "Share this giveaway to receive a bonus entry."
          method: "apprequests"
          message: "#{giveaway_object.description_text.slice(0, 250)}..."
          data:
            referrer_id: "#{$entry_id}"
            giveaway_id: "#{giveaway_object.id}"

    initZClip: ->
      $el = $('a.zclip-trigger')

      client = new ZeroClipboard $el,
        moviePath: "//#{_SG.global.SG_SSL_DOMAIN}/assets/ZeroClipboard.swf"
        trustedOrigins: [window.location.protocol + "//" + window.location.host]
        allowScriptAccess: 'always'

      client.on 'ready', (event) =>

        client.on 'copy', (event) ->
          event.clipboardData.setData 'text/plain', $shortlink

        client.on 'aftercopy', (event) ->
          $el.addClass('hide')
          $('a.raw-shortlink.btn-success').removeClass('hide')
          $('body').trigger('click')
