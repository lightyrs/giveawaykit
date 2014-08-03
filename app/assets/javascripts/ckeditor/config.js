CKEDITOR.editorConfig = function(config) {
  config.toolbar_Basic = [
    { name: 'links', items : [ 'Link', 'Unlink' ] },
    { name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline', 'Strike', '-', 'RemoveFormat' ] },
    { name: 'colors', items : [ 'TextColor', 'BGColor' ] },
    { name: 'styles', items: [ 'Format', 'Font', 'FontSize' ] }
  ];
  config.toolbar = 'Basic';
  config.enterMode = CKEDITOR.ENTER_P;
  config.shiftEnterMode = CKEDITOR.ENTER_P;
  config.autoParagraph = false;
  config.fillEmptyBlocks = false;
  config.fullPage = false;
  config.forcePasteAsPlainText = true;
  config.contentsCss = "ckeditor/custom-contents.css";
}

CKEDITOR.on('instanceReady', function(ev) {
  ev.editor.dataProcessor.writer.setRules('p', {
    indent : false,
    breakBeforeOpen : false,
    breakAfterOpen : false,
    breakBeforeClose : false,
    breakAfterClose : false
  });
  if ($('#form-wizard').length) {
    SG.Giveaways.Form.initWYSIWYG(ev.editor);
  }
});
