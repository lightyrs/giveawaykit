SG.Giveaways.Form.WYSIWYG =

  initialize: (el) ->
    if el
      $(el).ckeditor().on 'getData.ckeditor', ( event, editor, data ) =>
        console.log event, editor, data 
    else
      @editorEl().ckeditor()

  editorEl: -> $("#editor")
