Giveaway =

  initialize: ->
    console.log 'Giveaway.initialize'

    @giveawayHash = _SG.currentGiveaway.table
    @giveawayObject = @giveawayHash.giveaway.table
    @paths = _SG.paths

    @likeId = null
    @authed = null
    @email = null
    @newSession = null
    @entryId = null
    @requestCount = 0
    @wallPostCount = 0
    @shortlink = null
    @justLiked = false
    @referrerId = "#{@giveawayHash.referrer_id}" or ""
    @giveawayImage = $('#giveaway_image')
    @enterButton = $('#enter_giveaway')
    @ladda = Ladda.create(@enterButton[0])
    @termsTextLink = $('a.terms-link.terms-text')
    @modal = $('#giveaway_modal')
    @form = @modal.find('.form')
    @formSubmit = @form.find('a.btn.btn-primary.submit')
    @auth = @modal.find('.auth')
    @authButton = @auth.find('a.btn.btn-primary.auth')
    @loader = @modal.find('.loader')

    @authRequired = do =>
      val = @giveawayObject.auth_required
      val == '1' || val == 'true'

    @autoshow = do =>
      val = @giveawayObject.autoshow_share
      val == '1' || val == 'true'

    @fbInitOptions =
      status: true
      cookie: true
      xfbml: true
      channelUrl: "//#{_SG.global.SG_SSL_DOMAIN}/channel.html"

    $(document).fb _SG.global.FB_APP_ID, @fbInitOptions

    $(document).on 'fb:initialized', =>
      @onFbInitialized()

  onFbInitialized: ->
    console.log 'Giveaway.onFbInitialized'

    FB.Canvas.setSize height: $('#gk_giveaway').outerHeight(true)
    if @authRequired then @login() else @attachEvents()

  login: ->
    console.log 'Giveaway.login'

    FB.getLoginStatus (response) =>
      @attachEvents()

  attachEvents: ->
    console.log 'Giveaway.attachEvents'

    _.bindAll(@, 'onEnterButtonClick', 'onGiveawayImageClick', 'onTermsTextLinkClick', 'onLike', 'submitEntry')

    @enterButton.on 'click', @onEnterButtonClick

    @giveawayImage.on 'click', @onGiveawayImageClick

    @termsTextLink.on 'click', @onTermsTextLinkClick

    FB.Event.subscribe 'edge.create', @onLike

  onEnterButtonClick: (e) ->
    @ladda.start()
    if @eligible()
      @doEligibleEntryFlow()
    else
      console.log 'not eligible'
    e?.preventDefault()

  onGiveawayImageClick: ->
    console.log 'onGiveawayImageClick'

  onTermsTextLinkClick: (e) ->
    $('.terms-text.hidden').show()
    FB.Canvas.setSize(height: ($('#gk_giveaway').outerHeight(true) + 40))
    e.preventDefault()

  onLike: (href, widget) ->
    @justLiked = true
    $.ajax
      type: 'POST'
      url: "#{@paths.likes}"
      dataType: 'json'
      data: "like[giveaway_id]=#{@giveawayObject.id}"
      success: (data, textStatus, jqXHR) =>
        @likeId = data
        true

  eligible: ->
    (("#{@giveawayHash.has_liked}" == 'true') || @justLiked) ? true : false

  doEligibleEntryFlow: ->
    if @newSession?
      @submitEntry @newSession
    else
      @checkEntryStatusAndRespond()

  checkEntryStatusAndRespond: ->
    FB.getLoginStatus (response) =>
      if response.authResponse && response.authResponse.accessToken
        @newSession = response.authResponse.accessToken
        @doEligibleEntryFlow()
      else if @authRequired
        @authenticateUser(response)
      else
        @initializeForm()

  authenticateUser: (response) ->
    FB.login (response) =>
      if response.authResponse && response.authResponse.accessToken
        @newSession = response.authResponse.accessToken
        @onEnterButtonClick()
      else
        @onEntryError "You must grant permissions in order to enter the giveaway."
    , scope: "email, user_location, user_birthday, user_likes"

  initializeForm: ->
    @ladda.stop()
    @form.show()
    @attachFormEvents()

  attachFormEvents: ->
    @formSubmit.on 'click', @onFormSubmitClick
    $(document).on 'keypress', @onFormKeypress

  onFormSubmitClick: (e) =>
    @email = @form.find('input').val()
    @newSession = 'auth_disabled'
    @doEligibleEntryFlow()
    e.preventDefault()

  onFormKeypress: (e) =>
    @formSubmit.click() if (e.which == 13) && @form.is(':visible')

  submitEntry: (accessToken, json) ->
    if json?
      access_token = eval("(" + accessToken + ")")
    $.ajax
      type: "POST"
      url: "#{@paths.giveawayEntries}"
      dataType: "json"
      data: "access_token=#{accessToken}&has_liked=#{@eligible()}&ref_id=#{@referrerId}&email=#{@email}&like_id=#{@like_id}"
      statusCode:
        201: (response) =>
          @entry = response
          @onEntrySuccess()

        406: (response) =>
          @entry = jQuery.parseJSON(response.responseText)
          @onEntryError "You have already entered the giveaway.<br /><span class='f-w-300'>Entry is limited to one per person.</span>"

        412: =>
          @ladda.stop()

        404: =>
          @onEntryError "There was an unexpected error.<br /><span class='f-w-300'>Please reload the page and try again.</span>"

        424: =>
          @onEntryError "There was an unexpected error.<br /><span class='f-w-300'>Please reload the page and try again.</span>"

  onEntrySuccess: ->
    console.log 'onEntrySuccess'
    console.log @entry

    @onEntryComplete("Congratulations! You have successfully entered the giveaway.")
    $('a.app-request').click() if @autoshow

  onEntryError: (message) ->
    console.log 'onEntryError'
    console.log @entry

    @onEntryComplete(message)

  onEntryComplete: (message) ->
    @ladda.stop()
    $('.giveaway-actions').find('p.message').html(message).end()
      .find('.points strong').text("#{@entry.total_points}").end()
      .find('.rank strong').text("#{@entry.overall_rank}").end()
      .find('.days-left strong').text("#{@entry.days_left}").end()
      .addClass('entry-complete')
    @initializeSharing()

  initializeSharing: ->
    _.bindAll(@, 'onWallPostButtonClick', 'onAppRequestButtonClick')

    $('a.wall-post').on 'click', @onWallPostButtonClick

    $('a.app-request').on 'click', @onAppRequestButtonClick

    @initZClip()

  onWallPostButtonClick: (e) ->
    @triggerWallPost()
    e.preventDefault()

  onAppRequestButtonClick: (e) ->
    @triggerAppRequest()
    e.preventDefault()

  triggerWallPost: ->
    data =
      method: "share"
      href: "#{@giveawayObject.canonical_url}?referral_id=#{@entry.id}"

    @shareDialog(data)

  triggerFeedPost: ->
    data =
      method: "feed"
      name: "#{@giveawayHash.current_page.name}"
      link: "#{@giveawayObject.giveaway_url}&app_data=ref_#{@entry.id}"
      picture: "#{@giveawayObject.feed_image_url}"
      caption: "#{@giveawayObject.title}"
      description: "#{@giveawayObject.description}"

    @shareDialog(data)

  triggerAppRequest: ->
    data =
      title: "Share this giveaway to receive a bonus entry."
      method: "apprequests"
      message: "#{@giveawayObject.description_text.slice(0, 250)}..."
      data:
        referrer_id: "#{@entry.id}"
        giveaway_id: "#{@giveawayObject.id}"

    @shareDialog(data)

  shareDialog: (data) ->
    FB.ui data, (response) =>
      if response and response.post_id
        json = entry:
          wall_post_count: @entry.wall_post_count + 1
        @shareCallback json
      else if response and response.to
        json = entry:
          request_count: @entry.request_count + response.to.length
        @shareCallback json
      else
        true

  shareCallback: (json) ->
    console.log json
    $.ajax
      type: 'PUT'
      url: "#{@paths.giveawayEntries}/#{@entry.id}"
      dataType: 'text'
      data: json

  initZClip: ->
    $el = $('a.zclip-trigger')

    client = new ZeroClipboard $el,
      moviePath: "//#{_SG.global.SG_SSL_DOMAIN}/assets/ZeroClipboard.swf"
      trustedOrigins: [window.location.protocol + "//" + window.location.host]
      allowScriptAccess: 'always'

    client.on 'ready', (event) =>

      client.on 'copy', (event) =>
        event.clipboardData.setData 'text/plain', @entry.shortlink

      client.on 'aftercopy', (event) ->
        $el.addClass('success')
        $('body').trigger('click')

jQuery ->

  Giveaway.initialize()
