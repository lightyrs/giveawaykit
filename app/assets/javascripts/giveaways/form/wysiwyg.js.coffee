SG.Giveaways.Form.WYSIWYG =

  initialize: (el) ->
    if el
      $(el).ckeditor()
    else
      @editorEl().ckeditor()

  editorEl: -> $("#editor")
