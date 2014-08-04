SG.Subscriptions =

  initialize: ->
    if @stripeEl().length
      @configureHandler()
      @attachListener()
      @initRadios()

  configureHandler: ->
    @handler = StripeCheckout.configure
      key: "#{_SG.global.STRIPE_KEY}"
      token: (data, args) =>
        @createSubscription(data.id)

  attachListener: ->
    @planContainerEls().click (e) =>
      if @pageSelectorVisible(e)
        @handlePageSelectorClick(e)
      else
        @planEl = $(e.target).hasClass('subscription-plan') && $(e.target) || $(e.target).parents('.subscription-plan')
        @handleClick(e)

  initRadios: ->
    $('input[type="radio"]').each ->
      label = $(this).next()
      label_text = label.text()
      label.remove()
      $(this).iCheck
        radioClass: 'iradio_line-aero'
        insert: "<div class='icheck_line-icon'></div><span class='label-text'>#{label_text}</span>"

  handleClick: (event) ->
    @closePageSelector()
    if $(event.target).hasClass('cancel-subscription')
      @handleCancelPlan event
    else if $(@planEl).data('is-single-page')
      @openPageSelector()
    else
      if $(@planEl).data('is-current-plan') || $(@planEl).data('is-next-plan')
        @openPageSelector()
      else
        @openStripeCheckout()

  handlePageSelectorClick: (event) ->
    if $(event.target).hasClass('remove')
      @closePageSelector()
    else if $(event.target).hasClass('check')
      if @mapPageIds().length
        @handleFormSubmit()
      else
        $(@planEl).find('legend').css('font-weight', 'bold')

  handleFormSubmit: ->
    if $(@planEl).data('is-current-plan') || $(@planEl).data('is-next-plan')
      @handleCurrentOrNextPlan()
    else
      @handleNewPlan()

  handleCurrentOrNextPlan: ->
    if @pageChangeWarning?
      @createSubscription('page_change') if confirm @pageChangeWarning
    else
      @createSubscription('page_change')

  handleNewPlan: ->
    if @pageChangeWarning?
      @openStripeCheckout() if confirm @pageChangeWarning
    else
      @openStripeCheckout()

  handleCancelPlan: (event) ->
    if confirm @cancelPlanConfirm
      SG.UI.Loader.createOverlay(true)
    else
      return false

  cancelPlanConfirm: "Are you sure you want to cancel your subscription? If you decide to continue, you will still be able to enjoy the benfits of your subscription until the end of the current billing cycle."

  openPageSelector: ->
    $(@planEl).addClass('page-selector')

  closePageSelector: ->
    @openPlanContainerEls().find('.resetable input').iCheck('uncheck')
    @openPlanContainerEls().find('.default input').iCheck('check')
    @openPlanContainerEls().removeClass('page-selector')

  pageSelectorVisible: (event) ->
    $(event.target).parents('.page-selector').length ||
    $(event.target).hasClass('page-selector')

  openStripeCheckout: ->
    amount = $(@planEl).data('checkout-amount')
    unless amount is 0
      @handler.open
        name: 'Giveaway Kit'
        description: $(@planEl).data('description')
        amount: amount
        email: _SG.currentUser.email

  createSubscription: (token) ->
    SG.UI.Loader.createOverlay(true)
    $.form @formPath(),
      stripe_token: token
      subscription_plan_id: $(@planEl).data('subscription-plan-id')
      facebook_page_ids: @mapPageIds()
    .submit()

  mapPageIds: ->
    _.map $(@planEl).find('input:checked'), (input) =>
      @pageChangeWarning = $(input).hasClass('page-change-warning') && "#{$(input).data('page-change-warning')}" || null
      $(input).val()

  openPlanContainerEls: -> $('.subscription-plan.page-selector')

  planContainerEls: -> $('.subscription-plan')

  plansContainerEl: -> $('#plan_columns')

  isUserCentric: ->
    @plansContainerEl().data('is-user-centric')

  formPath: ->
    @isUserCentric() && _SG.paths.userSubscribe || _SG.paths.pageSubscribe

  stripeEl: -> $('#stripe_page')
