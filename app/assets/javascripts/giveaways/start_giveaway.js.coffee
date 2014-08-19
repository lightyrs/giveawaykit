SG.Giveaways.Start =

  initialize: ->
    if @modalEl().length
      @attachButtonEvents()
      if @justSubscribed()
        @triggerStartModal()
      else
        @initStartModal()

  initStartModal: ->
    $(document).off 'hidden.bs.modal', '#start_giveaway_modal'
    $(document).on 'hidden.bs.modal', '#start_giveaway_modal', ->
      $('#start_giveaway_modal').removeData('bs.modal')

    $(document).off 'ajaxSuccess'
    $(document).on 'ajaxSuccess', (response) =>
      @attachModalEvents()

  attachModalEvents: ->
    if @modalEl().find('.datetime-picker-input').length
      SG.UI.DatetimePickers.initialize @modalEl().find('.datetime-picker-input')

  attachButtonEvents: ->
    $(document).off 'click', '#start_giveaway_modal .approve.btn'
    $(document).on 'click', '#start_giveaway_modal .approve.btn', (e) =>
      @moveForward()

  triggerStartModal: ->
    $(document).off 'ajaxSuccess'
    $(document).on 'ajaxSuccess', =>
      @modalEl().find(".modal-step[data-modal-step='1']").hide()
      @modalEl().find(".modal-step[data-modal-step='2']").show()
      $('#start_giveaway_end_date').val _SG.currentGiveaway.proposedEndDate
      $('#start_giveaway_tab_name').val _SG.currentGiveaway.proposedTabName
      @attachModalEvents()
    $('#start_giveaway').trigger 'click'

  justSubscribed: ->
    _SG.currentUser.justSubscribed?.length && _SG.currentPage.isSubscribed?

  moveForward: ->
    current = @currentStepEl()
    next = @nextStepEl()
    if next.find('#no_subscription').length
      SG.UI.Loader.createOverlay(true)
      @redirectToSubPlans()
    else if next.find("#trigger_start_giveaway").length
      SG.UI.Loader.createOverlay(true)
      @startGiveaway()
    else
      current.hide()
      next.show()

  redirectToSubPlans: ->
    $.ajax
      url: _SG.paths.subscriptionPlans
      type: 'POST'
      data:
        starting: true
        end_date: $('#start_giveaway_end_date').val()
        custom_tab_name: $('#start_giveaway_tab_name').val()
      success: =>
        top.location.href = _SG.paths.subscriptionPlans

  startGiveaway: ->
    $('#step_one form').submit()

  currentStep: ->
    @currentStepEl().data('modal-step')

  currentStepEl: ->
    @modalEl().find('.modal-step:visible')

  nextStep: ->
    parseInt(@currentStep()) + 1

  nextStepEl: ->
    @modalEl().find(".modal-step[data-modal-step='#{@nextStep()}']").first()

  denyButtonEl: -> @modalEl().find('.deny.btn')

  approveButtonEl: -> @modalEl().find('.approve.btn')

  modalEl: -> $('#start_giveaway_modal')
