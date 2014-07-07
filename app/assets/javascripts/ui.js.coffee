SG.UI =

  initialize: ->
    SG.UI.FlashMessages.initialize()
    @initPagesFilter()
    @initReadmores()
    @initAutosize()
    @initPagination()
    SG.UI.ZClip.initialize()
    SG.UI.DatetimePickers.initialize()
    SG.UI.Editables.initialize()

  initPagesFilter: ->
    new List('facebook_pages_list', valueNames: ['name'], listClass: 'list-group')
    $(document).on 'webkitAnimationStart mozAnimationStart oAnimationStart animationStart', '#facebook_pages_list', (e) ->
      $(e.target).find('input').trigger 'focus'
    $(document).on 'keypress', '#facebook_pages_list input', (e) ->
      if e.which == 13
        window.location.href = $('#facebook_pages_list').find('li:visible a').attr('href')
    $('#my_pages_dropdown').on 'click', '.dropdown.open header', (e) ->
      return false

  initReadmores: ->
    @initReadmore(el) for el in @readmoreEls()

  initAutosize: ->
    $('textarea').autosize()

  initPagination: ->
    @paginationEls().rPage()

  initReadmore: (el) ->
    $(el).jTruncate()

  initFilestyle: ->
    @fileInputEls().filestyle
      classButton: 'btn btn-default btn-lg'
      classInput: 'form-control inline input-s'
      icon: true
      buttonText: 'Upload'
      input: false
      classIcon: 'fa fa-cloud-upload text'

  readmoreEls: -> $('.readmore')

  paginationEls: -> $('ul.pagination')

  fileInputEls: -> $(':file')
