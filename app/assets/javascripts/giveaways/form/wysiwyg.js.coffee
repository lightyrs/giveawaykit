SG.Giveaways.Form.WYSIWYG =

  initialize: (el) ->
    el ?= $("#editor")
    $(el).ckeditor()
