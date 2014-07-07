SG.Giveaways.Active =

  initialize: ->
    @initTabListeners() if @tabsContainerEl().length
    SG.Giveaways.Active.Graphs.initialize()
    @initEndGiveawayListener()
    @initPopoverClose()

  initTabListeners: ->
    $(document).on 'ajax:beforeSend', '#details_tab_trigger', (xhr, data, s) =>
      return false if @detailsTabTriggerEl().hasClass('loaded')

    $(document).on 'ajax:success', '#details_tab_trigger', (xhr, data, s) =>
      @initDetailsTab(data)

    $(document).on 'ajax:beforeSend', '#entries_tab_trigger', (xhr, data, s) =>
      return false if @entriesTabTriggerEl().hasClass('loaded')

    $(document).on 'ajax:success', '#entries_tab_trigger', (xhr, data, s) =>
      @initEntriesTab(data)

    @tabEls().on 'shown.bs.tab', (e) =>
      if $(e.target).is @detailsTabTriggerEl()
        @detailsTabEl().find('.sg-progress-block .bar').addClass('loading')
      else if $(e.target).is @entriesTabTriggerEl()
        @entriesTabEl().find('.sg-progress-block .bar').addClass('loading')

  initEndGiveawayListener: ->
    $(document).on 'click', '.end-giveaway-button', (e) =>
      if confirm @endGiveawayConfirmation
        SG.UI.Loader.createOverlay(true)
      else
        return false

  initDetailsTab: (data) ->
    @detailsTabEl().html(data) if data
    @detailsTabTriggerEl().addClass('loaded')
    SG.Giveaways.Details.reinitialize()

  initEntriesTab: (data) ->
    @entriesTabEl().html(data) if data
    @entriesTabTriggerEl().addClass('loaded')
    SG.UI.DataTables.initialize('entries')

  endGiveawayConfirmation: "Are you sure you want to end the giveaway right now? If you decide to continue, it will be removed from your Facebook Page immediately."

  initPopoverClose: ->
    $(document).on 'show.bs.popover', (event) ->
      $('.popover-active').popover('toggle')
      $(event.target).addClass('popover-active')
    $(document).on 'hide.bs.popover', (event) ->
      $(event.target).removeClass('popover-active')
    $(document).on 'mouseup', '.popover-container, .popover-active', ->
      return false
    $(document).on 'mouseup', ->
      $('.popover-active').popover('toggle') if $('.popover-active').length

  detailsTabTriggerEl: -> $('#details_tab_trigger')

  detailsTabEl: -> $('#details_tab')

  entriesTabTriggerEl: -> $('#entries_tab_trigger')

  entriesTabEl: -> $('#entries_tab')

  overviewTabTriggerEl: -> $('#overview_tab_trigger')

  overviewTabEl: -> $('#overview_tab')

  tabEls: -> @tabsContainerEl().find('a[data-toggle="tab"]')

  tabsContainerEl: -> $('#active_giveaway_tabs')
