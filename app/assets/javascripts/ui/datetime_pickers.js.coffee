SG.UI.DatetimePickers =

  initialize: (el) ->
    if el?
      @attachDatetimePicker(el)
    else
      @attachDatetimePicker(el) for el in @dateTimePickerEls()

  attachDatetimePicker: (el) ->
    $el = $(el)
    $container = $el.parents('.date-container')

    $outlet = if $el.hasClass('modal-pickadate')
      $('#modal_pickadate_outlet')
    else
      $container.find('.pickadate-outlet')

    $dateTriggerEl = $container.find('.date-trigger')
    $timeTriggerEl = $container.find('.time-trigger')

    datepicker = @attachDatepicker($el, $outlet, $dateTriggerEl)
    timepicker = @attachTimepicker($el, $outlet, $timeTriggerEl)

    @initDatepicker($el, $dateTriggerEl, datepicker, timepicker)
    @initTimepicker($el, $timeTriggerEl, datepicker, timepicker)

    @initPickerTrigger($el, datepicker)

  attachDatepicker: ($el, $outlet, $dateTriggerEl) ->
    $dateTriggerEl.pickadate
      container: $outlet
      format: 'dddd, mmmm dd, yyyy'
      today: 'Today'
      clear: ''
    .pickadate('picker')

  initDatepicker: ($el, $dateTriggerEl, datepicker, timepicker) ->
    datepicker.on
      open: => datepicker.set(min: @setMinDate($el))
      set: (item) -> setTimeout timepicker.open, 0  if 'select' of item

  attachTimepicker: ($el, $outlet, $timeTriggerEl) ->
    $timeTriggerEl.pickatime
      container: $outlet
      clear: ''
    .pickatime('picker')

  initTimepicker: ($el, $timePickerEl, datepicker, timepicker) ->
    unless timepicker.$root.find('#back_to_date').length
      $('<span id="back_to_date" class="btn btn-default btn-block">Back to Date</span>').on 'click', ->
        timepicker.close()
        datepicker.open()
      .prependTo timepicker.$root.find('.picker__box')

    timepicker.on
      set: (item) =>
        if 'select' of item
          setTimeout (=> @onDateTimeSet($el, datepicker, timepicker)), 0

  initPickerTrigger: ($el, datepicker) ->
    $el.on('focus', datepicker.open).on 'click', (event) ->
      event.stopPropagation()
      datepicker.open()

  onDateTimeSet: ($el, datepicker, timepicker) ->
    newVal = "#{datepicker.get()} @ #{timepicker.get()}"
    $el.off('focus').val(newVal).focus()
    unless $el.hasClass('datetime-picker-input') or $el.parents('.editable-input').length
      datepicker.stop()
      timepicker.stop()
    if @isStart($el)
      @conflictContainerEl($el).find('.conflict').remove()
      @checkSchedule(newVal, $el)

  onDateTimeClear: ($el, datepicker, timepicker) ->
    $el.off('focus').val('').focus()
    unless $el.hasClass('datetime-picker-input') or $el.parents('.editable-input').length
      datepicker.stop()
      timepicker.stop()

  dateType: ($el) ->
    ($el.parents('#giveaway_start_date').length && 'start') || ($el.parents('#giveaway_end_date').length && 'end')

  isStart: ($el) ->
    @dateType($el) == 'start'

  isEnd: ($el) ->
    @dateType($el) == 'end'

  startDate: ($el) ->
    if $el.hasClass('datetime-picker-input')
      $('#giveaway_start_date').find('.datetime-picker-input').val()
    else
      $('#giveaway_start_date').data('date')? && $('#giveaway_start_date').data('date')

  endDate: ->
    $('#giveaway_end_date').data('date')? && $('#giveaway_end_date').data('date')

  checkSchedule: (datetime, $el) ->
    $.ajax
      url: _SG.paths.checkSchedule
      dataType: 'json',
      data:
        giveaway_id: _SG.currentGiveaway.id
        facebook_page_id: _SG.currentPage.id
        date: datetime
        date_type: @dateType($el)
      success: (conflicts, status) =>
        if conflicts.length
          @showConflictMessage($el, conflict) for conflict in conflicts
        else
          @conflictContainerEl($el).hide()

  setMinDate: ($el) ->
    if @isEnd($el) && (start = @startDate($el))
      moment(start).toDate()
    else
      moment().add('minutes', 10).toDate()

  showConflictMessage: ($el, conflict) ->
    @conflictContainerEl($el).show().append("<div class='conflict'>#{@conflictLink(conflict)}<br />#{moment(conflict.start_date).format('M/D/YYYY')} - #{moment(conflict.end_date).format('M/D/YYYY')}</div>")

  conflictContainerEl: ($el) ->
    $el.parents('.date-container').children('.conflicts-container')

  conflictLink: (conflict) ->
    "<a href='#{_SG.paths.giveaways}/#{conflict.slug}'>#{conflict.title}</a>"

  dateTimePickerEls: -> $('.datetime-picker-input')
