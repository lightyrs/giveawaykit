SG.UI.ZClip =

  _sg: _SG

  initialize: ->
    @initZClip(el) for el in @zClipEls()

  initZClip: (el) ->
    $el = $(el)
    clip = @clip($el)
    @attachZClipEvents($el, clip)

  attachZClipEvents: ($el, clip) ->
    clip.on 'dataRequested', (client, args) ->
      client.setText $el.data('clipboard-text')
    clip.on 'complete', ->
      $('body').trigger('click')

  clip: ($el) ->
    new ZeroClipboard $el,
      moviePath: "//#{@_sg.Config.SG_DOMAIN}/assets/ZeroClipboard.swf"
      trustedOrigins: [window.location.protocol + "//" + window.location.host]
      allowScriptAccess: 'always'

  zClipEls: -> $('a.zclip-trigger')



