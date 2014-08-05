SG.UI.Loader =

  getOverlay: -> @overlay

  attachAjaxSuccess: ->
    $(document).off 'ajaxSuccess'
    $(document).on 'ajaxSuccess', (e) =>
      @onSuccess() unless @override

  attachAjaxError: ->
    $(document).off 'ajaxError'
    $(document).on 'ajaxError', (e) =>
      @onError() unless @override

  attachAjaxStop: ->
    $(document).off 'ajaxStop'
    $(document).on 'ajaxStop', (e) =>
      @onStop() unless @override

  createOverlay: (manual) ->
    @spinner ||= new Spinner(@spinnerOptions).spin(@spinnerTargetEl())
    @overlay ||= iosOverlay(text: "Loading", spinner: @spinner)
    unless manual?
      @attachAjaxSuccess()
      @attachAjaxError()
      @attachAjaxStop()

  onSuccess: ->
    setTimeout (=> @showSuccess()), 1000
    setTimeout (=> @hideOverlay()), 2000

  onError: ->
    setTimeout (=> @showError()), 1000
    setTimeout (=> @hideOverlay()), 2000

  onStop: ->
    setTimeout (=> @hideOverlay()), 3000

  showSuccess: ->
    @updateOverlay(text: "Success!", icon: "/assets/check.png")

  showError: ->
    @updateOverlay(text: "Error!", icon: "/assets/cross.png")

  updateOverlay: (opts) ->
    @overlay.update(opts)

  hideOverlay: ->
    @overlay.hide()

  spinnerTargetEl: ->
    $('#spinner_target')

  spinnerOptions:
    lines: 13
    length: 11
    width: 5
    radius: 17
    corners: 1
    rotate: 0
    color: '#FFF'
    speed: 1
    trail: 60
    shadow: false
    hwaccel: false
    className: 'spinner'
    zIndex: 2e9
    top: 'auto'
    left: 'auto'
