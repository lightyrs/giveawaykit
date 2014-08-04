SG.Giveaways.Form =

  initialize: ->
    if @wizardEl().length
      @initWizard()
      @initBonusEntriesToggle()
      @checkSchedule(el) for el in SG.UI.DatetimePickers.dateTimePickerEls()
    @processServerErrors() if @serverErrors().length

  initWYSIWYG: ->
    CKEDITOR.instances.editor.on 'blur', =>
      CKEDITOR.instances.editor.updateElement()

  initWizard: ->
    @wizardEl().wizard()
    @wizardEl().on 'change', (e, data) => @onWizardChange(e, data)
    @wizardEl().on 'changed', (e, data) => @onWizardChanged(e, data)
    @wizardEl().on 'finished', (e, data) => @onWizardFinished(e, data)

  checkSchedule: (el) ->
    $el = $(el)
    if SG.UI.DatetimePickers.isStart($el)
      SG.UI.DatetimePickers.conflictContainerEl($el).find('.conflict').remove()
      SG.UI.DatetimePickers.checkSchedule($el.val(), $el)

  onWizardChange: (e, data) ->
    @validateSteps(data.step)
    if data.direction == 'next' && not @validated
      @processParsleyErrors()
      false

  onWizardChanged: (e, data) ->
    if CKEDITOR.instances.editor.length
      $(CKEDITOR.instances.editor).trigger 'resize'

  onWizardFinished: (e, data) ->
    @validateSteps()
    if not @validated && @parsleyErrors().length
      @processParsleyErrors()
      false
    else
      @containerEl().find('form').submit()

  validateSteps: (step) ->
    $panes = @containerEl().find(".step-pane")
    $panes = $panes.slice(0, step) if step?
    @doValidations $("[data-required='true']", $panes)

  doValidations: ($steps) ->
    @validated = true
    CKEDITOR.instances.editor.updateElement()
    @errorStepEls().removeClass('error')
    $steps.each (i,el) =>
      @validated = $(el).parsley('validate')

  initBonusEntriesToggle: ->
    $('#giveaway_allow_multi_entries').on 'change', =>
      @toggleBonusEntries()

  toggleBonusEntries: ->
    $('#bonus_value_wrapper').toggle()

  processServerErrors: ->
    @wizardEl().find("li[data-target='##{@firstServerErrorStep()}']").addClass('server-error').trigger 'click'

  processParsleyErrors: ->
    @wizardEl().find("li[data-target='##{@firstParsleyErrorStep()}']").addClass('error').trigger 'click'

  serverErrors: -> @containerEl().find('.has-error')

  parsleyErrors: -> @containerEl().find('.parsley-error')

  firstServerErrorStep: -> @serverErrors().first().parents('.step-pane').attr('id')

  firstParsleyErrorStep: -> @parsleyErrors().first().parents('.step-pane').attr('id')

  containerEl: -> @wizardEl().parents('.wizard-container')

  formErrorsEl: -> @containerEl().find('.error-messages')

  wizardEl: -> $('#form-wizard')

  errorStepEls: -> @wizardEl().find('ul.steps .error')

  basicInfoStepEl: -> @wizardEl().find('li[data-target="#step1"]')

  scheduleStepEl: -> @wizardEl().find('li[data-target="#step2"]')

  imagesStepEl: -> @wizardEl().find('li[data-target="#step3"]')

  termsStepEl: -> @wizardEl().find('li[data-target="#step4"]')

  optionsStepEl: -> @wizardEl().find('li[data-target="#step5"]')

  editorEl: -> $('#editor')
