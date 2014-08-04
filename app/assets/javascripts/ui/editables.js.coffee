SG.UI.Editables =

  initialize: ->
    if @editableEls().length && @isNotCompleted()
      console.log 'SG.UI.Editables.initialize'
      console.log _SG.currentGiveaway.status
      @initEditables()
      @checkSchedule(el) for el in @editableDatetimeEls()

  initEditables: ->
    $.fn.editableform.buttons = '<button type="submit" class="editable-submit btn btn-xs btn-primary"><i class="fa fa-check"></i></button><button type="button" class="editable-cancel btn btn-xs btn-default"><i class="fa fa-times"></i></button>'
    @initEditable(el) for el in @editableEls()
    @initEditableUploads(el) for el in @editableUploadEls()
    @initEditableTrigger(el) for el in @editableTriggerEls()
    @initEditableUploadTrigger(el) for el in @editableUploadTriggerEls()

  checkSchedule: (el) ->
    $el = $(el)
    if SG.UI.DatetimePickers.isStart($el)
      SG.UI.DatetimePickers.conflictContainerEl($el).find('.conflict').remove()
      SG.UI.DatetimePickers.checkSchedule($el.text(), $el)

  initEditable: (el) ->
    @initReadmoreEditables(el)
    $(el).editable
      mode: $(el).data('editable-mode') || 'inline'
      autotext: 'always'
      escape: false
      success: (response, newValue) =>
        if response.errors?
          setTimeout (=> @onEditableError(el, response.errors)), 1000
        else
          @onEditableSuccess(el, newValue)
    @initEditableShown(el)
    @initEditableHidden(el)

  onEditableSuccess: (el, newValue) ->
    if $(el).hasClass('editable-datetime')
      $(el).parents('.date-container').data('date', newValue)
    $(el).parents('.editable-parent').find('.editable-label').removeClass('error').end().find('.editable-error').text('')

  onEditableError: (el, errors) ->
    $(el).parents('.editable-parent').find('.editable-label').addClass('error').end().find('.editable-error').text(errors[0])

  initReadmoreEditables: (el) ->
    $(el).on 'init', (e, editable) ->
      if editable.$element.length && editable.$element.hasClass('editable-readmore')
        SG.UI.initReadmore($(this))

  initEditableShown: (el) ->
    $(el).on 'shown', (e, editable) ->
      if editable.$element.length
        if editable.$element.hasClass('editable-datetime')
          SG.UI.DatetimePickers.initialize editable.input.$input
          setTimeout (=> editable.input.$input.trigger('click')), 0
        else if editable.$element.hasClass('editable-wysiwyg')
          SG.Giveaways.Form.WYSIWYG.initialize editable.input.$input
        else if editable.$element.hasClass('editable-textarea')
          SG.UI.initAutosize()

  initEditableHidden: (el) ->
    $el = $(el)
    $el.on 'hidden', (e, reason) =>
      @checkSchedule($el) if $el.hasClass('editable-datetime')

  initEditableUploads: (el) ->
    $(el).on 'change', ->
      $form = $(this).parents('form')
      $form.find('label.btn').text('Uploading...').addClass('disabled')
        .end().submit()

  initEditableUploadTrigger: (el) ->
    $(el).on 'click', (e) ->
      $(el).parents('section').toggleClass('edit-mode')
      return false
    $('form .form-group').on 'click', (e) ->
      e.stopPropagation()

  initEditableTrigger: (el) ->
    $(el).on 'click', (e) =>
      e.stopPropagation()
      $(el).next('.editable').editable('toggle')
      return false

  editableDatetimeEls: -> $('.editable-datetime')

  editableUploadTriggerEls: -> $('.editable-upload-trigger')

  editableTriggerEls: -> $('.editable-trigger')

  editableUploadEls: -> $('form input[type="file"]')

  editableEls: -> $('.editable')

  isNotCompleted: -> _SG.currentGiveaway.status != 'Completed'
