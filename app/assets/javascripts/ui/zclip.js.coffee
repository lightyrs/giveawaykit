SG.UI.ZClip =

  initialize: ->
    @initZClip(el) for el in @zClipEls()

  initZClip: (el) ->
    $el = $(el)
    client = @client($el)
    @attachZClipEvents($el, client)

  attachZClipEvents: ($el, client) ->
    client.on 'ready', (event) =>
      client.on 'copy', (event) ->
        event.clipboardData.setData 'text/plain', $el.data('clipboard-text')
      client.on 'aftercopy', (event) ->
        $('body').trigger('click')

  client: ($el) ->
    new ZeroClipboard $el,
      moviePath: "//#{_SG.global.SG_DOMAIN}/assets/ZeroClipboard.swf"
      trustedOrigins: [window.location.protocol + "//" + window.location.host]
      allowScriptAccess: 'always'

  zClipEls: -> $('a.zclip-trigger')



