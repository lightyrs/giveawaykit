SG.UI =

  initialize: ->
    SG.UI.FlashMessages.initialize()
    @initPagesFilter()
    @initReadmores()
    @initAutosize()
    @initPagination()
    @initFilestyles()
    SG.UI.ZClip.initialize()
    SG.UI.DatetimePickers.initialize()
    SG.UI.Editables.initialize()
    SG.UI.Charts.initialize()
    # @initSlimScrolls()

  initPagesFilter: ->
    new List('facebook_pages_list', valueNames: ['name'], listClass: 'list-group')
    
    $(document).off 'webkitAnimationStart mozAnimationStart oAnimationStart animationStart', '#facebook_pages_list'
    $(document).on 'webkitAnimationStart mozAnimationStart oAnimationStart animationStart', '#facebook_pages_list', (e) ->
      $(e.target).find('input').trigger 'focus'
    
    $(document).off 'keypress', '#facebook_pages_list input'
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

  initFilestyles: ->
    @initFilestyle(el) for el in @fileInputEls()

  initFilestyle: (el) ->
    $(el).filestyle
      buttonName: 'btn btn-default btn-lg'
      icon: true
      buttonText: 'Upload'
      input: false
      classIcon: 'fa fa-cloud-upload text'

  initSlimScrolls: ->
    $('.no-touch .slim-scroll').each ->
      $self = $(this)
      $data = $self.data()
      $slimResize = undefined
      $self.slimScroll $data
      $(window).resize (e) ->
        clearTimeout $slimResize
        $slimResize = setTimeout(-> $self.slimScroll $data, 500)

  readmoreEls: -> $('.readmore')

  paginationEls: -> $('ul.pagination')

  fileInputEls: -> $(':file')
