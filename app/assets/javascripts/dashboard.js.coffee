SG.Dashboard =

  initialize: ->
    @initPagesPoller() if @pagesPollerEl().length

  initPagesPoller: ->
    SG.UI.Loader.createOverlay(true)
    @pollTimer = setInterval (=> @pollPages()), 2250

  pollPages: ->
    $.ajax
      url: _SG.paths.userPages
      dataType: 'json'
      data: "pids=#{@getPids()}&bust=#{new Date().getTime()}"
      error: (response) =>
        @pollPagesError()
      success: (response, status) =>
        @pollPagesSuccess(response, status)

  pollPagesSuccess: (response, status) ->
    @pagesTargetEl().data('pids', response.pids) if response.pids
    @appendPage($(page), i) for page, i in $(response.html)
    @pollPagesComplete(response) if response.complete

  pollPagesError: ->
    clearInterval(@pollTimer)
    SG.UI.Loader.onError()

  pollPagesComplete: (response) ->
    clearInterval(@pollTimer)
    @pagesTargetEl().data('pids', response.pids)
    if response.header_nav_html.length
      @headerNavTargetEl().replaceWith(response.header_nav_html)
    if response.sidebar_nav_html.length
      @sidebarNavTargetEl().replaceWith(response.sidebar_nav_html)
    if response.new_giveaway_html.length
      @newGiveawayTargetEl().replaceWith(response.new_giveaway_html)
    SG.UI.Loader.onSuccess()

  appendPage: ($page, i) ->
    if $page.is('li')
      setTimeout (=> $page.appendTo(@pagesTargetEl())), (200 * i)

  getPids: ->
    @pagesTargetEl().data('pids')

  newGiveawayTargetEl: -> $('#new_giveaway_dropdown')

  sidebarNavTargetEl: -> $('#facebook_pages_nav')

  headerNavTargetEl: -> $('#my_pages_dropdown')

  pagesTargetEl: -> $('#user_facebook_pages')

  pagesPollerEl: -> $('#pages_poller')
