$(function(){
 //  function initToolbarBootstrapBindings() {
 //    var fonts = ['Serif', 'Sans', 'Arial', 'Arial Black', 'Courier',
 //          'Courier New', 'Comic Sans MS', 'Helvetica', 'Impact', 'Lucida Grande', 'Lucida Sans', 'Tahoma', 'Times',
 //          'Times New Roman', 'Verdana'],
 //          fontTarget = $('[title=Font]').siblings('.dropdown-menu');
 //    $.each(fonts, function (idx, fontName) {
 //        fontTarget.append($('<li><a data-edit="fontName ' + fontName +'" style="font-family:\''+ fontName +'\'">'+fontName + '</a></li>'));
 //    });
 //    $('a[title]').tooltip({container:'body'});
 //   $('.dropdown-menu input').click(function() {return false;})
  //     .change(function () {$(this).parent('.dropdown-menu').siblings('.dropdown-toggle').dropdown('toggle');})
 //      .keydown('esc', function () {this.value='';$(this).change();});

 //    $('[data-role=magic-overlay]').each(function () {
 //      var overlay = $(this), target = $(overlay.data('target'));
 //      overlay.css('opacity', 0).css('position', 'absolute').offset(target.offset()).width(target.outerWidth()).height(target.outerHeight());
 //    });
 //    if ("onwebkitspeechchange" in document.createElement("input")) {
 //      var editorOffset = $('#editor').offset();
 //      // $('#voiceBtn').css('position','absolute').offset({top: editorOffset.top, left: editorOffset.left+$('#editor').innerWidth()-35});
 //    } else {
 //      $('#voiceBtn').hide();
 //    }
  // };
  // function showErrorAlert (reason, detail) {
  //  var msg='';
  //  if (reason==='unsupported-file-type') { msg = "Unsupported format " +detail; }
  //  else {
  //    console.log("error uploading file", reason, detail);
  //  }
  //  $('<div class="alert"> <button type="button" class="close" data-dismiss="alert">&times;</button>'+
  //   '<strong>File upload error</strong> '+msg+' </div>').prependTo('#alerts');
  // };
 //  initToolbarBootstrapBindings();
  var tpl = {
    "font-styles": function(locale, options) {
      var size = (options && options.size) ? ' btn-'+options.size : '';
      return "<li class='dropdown'>" +
        "<a class='btn btn-default btn-sm dropdown-toggle" + size + "' data-toggle='dropdown' href='#'>" +
        "<i class='fa fa-font'></i>&nbsp;<span class='current-font'>" + locale.font_styles.normal + "</span>&nbsp;<b class='caret'></b>" +
        "</a>" +
        "<ul class='dropdown-menu'>" +
          "<li><a data-wysihtml5-command='formatBlock' data-wysihtml5-command-value='div' tabindex='-1'>" + locale.font_styles.normal + "</a></li>" +
          "<li><a data-wysihtml5-command='formatBlock' data-wysihtml5-command-value='h1' tabindex='-1'>" + locale.font_styles.h1 + "</a></li>" +
          "<li><a data-wysihtml5-command='formatBlock' data-wysihtml5-command-value='h2' tabindex='-1'>" + locale.font_styles.h2 + "</a></li>" +
          "<li><a data-wysihtml5-command='formatBlock' data-wysihtml5-command-value='h3' tabindex='-1'>" + locale.font_styles.h3 + "</a></li>" +
          "<li><a data-wysihtml5-command='formatBlock' data-wysihtml5-command-value='h4'>" + locale.font_styles.h4 + "</a></li>" +
          "<li><a data-wysihtml5-command='formatBlock' data-wysihtml5-command-value='h5'>" + locale.font_styles.h5 + "</a></li>" +
          "<li><a data-wysihtml5-command='formatBlock' data-wysihtml5-command-value='h6'>" + locale.font_styles.h6 + "</a></li>" +
        "</ul>" +
      "</li>";
    },

    "emphasis": function(locale, options) {
      var size = (options && options.size) ? ' btn-'+options.size : '';
      return "<li>" +
        "<div class='btn-group'>" +
          "<a class='btn btn-default btn-sm" + size + "' data-wysihtml5-command='bold' title='CTRL+B' tabindex='-1'>" + locale.emphasis.bold + "</a>" +
          "<a class='btn btn-default btn-sm" + size + "' data-wysihtml5-command='italic' title='CTRL+I' tabindex='-1'>" + locale.emphasis.italic + "</a>" +
          "<a class='btn btn-default btn-sm" + size + "' data-wysihtml5-command='underline' title='CTRL+U' tabindex='-1'>" + locale.emphasis.underline + "</a>" +
        "</div>" +
      "</li>";
    },

    "lists": function(locale, options) {
      var size = (options && options.size) ? ' btn-'+options.size : '';
      return "<li>" +
        "<div class='btn-group'>" +
          "<a class='btn btn-default btn-sm" + size + "' data-wysihtml5-command='insertUnorderedList' title='" + locale.lists.unordered + "' tabindex='-1'><i class='fa fa-list'></i></a>" +
          "<a class='btn btn-default btn-sm" + size + "' data-wysihtml5-command='insertOrderedList' title='" + locale.lists.ordered + "' tabindex='-1'><i class='fa fa-th-list'></i></a>" +
          "<a class='btn btn-default btn-sm" + size + "' data-wysihtml5-command='Outdent' title='" + locale.lists.outdent + "' tabindex='-1'><i class='fa fa-outdent'></i></a>" +
          "<a class='btn btn-default btn-sm" + size + "' data-wysihtml5-command='Indent' title='" + locale.lists.indent + "' tabindex='-1'><i class='fa fa-indent'></i></a>" +
        "</div>" +
      "</li>";
    },

    "link": function(locale, options) {
      var size = (options && options.size) ? ' btn-'+options.size : '';
      return "<li>" +
        "<div class='bootstrap-wysihtml5-insert-link-modal modal in fade'>" +
          "<div class='modal-dialog'>" +
            "<div class='modal-content'>" +
              "<div class='modal-header'>" +
                "<a class='close' data-dismiss='modal'>&times;</a>" +
                "<h4 class='modal-title'>" + locale.link.insert + "</h4>" +
              "</div>" +
              "<div class='modal-body'>" +
                "<input value='http://' class='bootstrap-wysihtml5-insert-link-url input-xlarge form-control'>" +
                "<label class='checkbox'> <input type='checkbox' class='bootstrap-wysihtml5-insert-link-target' checked>" + locale.link.target + "</label>" +
              "</div>" +
              "<div class='modal-footer'>" +
                "<a href='#' class='btn btn-default' data-dismiss='modal'>" + locale.link.cancel + "</a>" +
                "<a href='#' class='btn btn-primary' data-dismiss='modal'>" + locale.link.insert + "</a>" +
              "</div>" +
            "</div>" +
          "</div>" +
        "</div>" +
        "<a class='btn btn-default btn-sm" + size + "' data-wysihtml5-command='createLink' title='" + locale.link.insert + "' tabindex='-1'><i class='fa fa-share'></i></a>" +
      "</li>";
    },

    "html": function(locale, options) {
      var size = (options && options.size) ? ' btn-'+options.size : '';
      return "<li>" +
        "<div class='btn-group'>" +
          "<a class='btn btn-default btn-sm" + size + "' data-wysihtml5-action='change_view' title='" + locale.html.edit + "' tabindex='-1'><i class='fa fa-pencil'></i></a>" +
        "</div>" +
      "</li>";
    },

    "color": function(locale, options) {
      var size = (options && options.size) ? ' btn-'+options.size : '';
      return "<li class='dropdown'>" +
        "<a class='btn btn-default btn-sm dropdown-toggle" + size + "' data-toggle='dropdown' href='#' tabindex='-1'>" +
          "<span class='current-color'>" + locale.colours.black + "</span>&nbsp;<b class='caret'></b>" +
        "</a>" +
        "<ul class='dropdown-menu'>" +
          "<li><div class='wysihtml5-colors' data-wysihtml5-command-value='black'></div><a class='wysihtml5-colors-title' data-wysihtml5-command='foreColor' data-wysihtml5-command-value='black'>" + locale.colours.black + "</a></li>" +
          "<li><div class='wysihtml5-colors' data-wysihtml5-command-value='silver'></div><a class='wysihtml5-colors-title' data-wysihtml5-command='foreColor' data-wysihtml5-command-value='silver'>" + locale.colours.silver + "</a></li>" +
          "<li><div class='wysihtml5-colors' data-wysihtml5-command-value='gray'></div><a class='wysihtml5-colors-title' data-wysihtml5-command='foreColor' data-wysihtml5-command-value='gray'>" + locale.colours.gray + "</a></li>" +
          "<li><div class='wysihtml5-colors' data-wysihtml5-command-value='maroon'></div><a class='wysihtml5-colors-title' data-wysihtml5-command='foreColor' data-wysihtml5-command-value='maroon'>" + locale.colours.maroon + "</a></li>" +
          "<li><div class='wysihtml5-colors' data-wysihtml5-command-value='red'></div><a class='wysihtml5-colors-title' data-wysihtml5-command='foreColor' data-wysihtml5-command-value='red'>" + locale.colours.red + "</a></li>" +
          "<li><div class='wysihtml5-colors' data-wysihtml5-command-value='purple'></div><a class='wysihtml5-colors-title' data-wysihtml5-command='foreColor' data-wysihtml5-command-value='purple'>" + locale.colours.purple + "</a></li>" +
          "<li><div class='wysihtml5-colors' data-wysihtml5-command-value='green'></div><a class='wysihtml5-colors-title' data-wysihtml5-command='foreColor' data-wysihtml5-command-value='green'>" + locale.colours.green + "</a></li>" +
          "<li><div class='wysihtml5-colors' data-wysihtml5-command-value='olive'></div><a class='wysihtml5-colors-title' data-wysihtml5-command='foreColor' data-wysihtml5-command-value='olive'>" + locale.colours.olive + "</a></li>" +
          "<li><div class='wysihtml5-colors' data-wysihtml5-command-value='navy'></div><a class='wysihtml5-colors-title' data-wysihtml5-command='foreColor' data-wysihtml5-command-value='navy'>" + locale.colours.navy + "</a></li>" +
          "<li><div class='wysihtml5-colors' data-wysihtml5-command-value='blue'></div><a class='wysihtml5-colors-title' data-wysihtml5-command='foreColor' data-wysihtml5-command-value='blue'>" + locale.colours.blue + "</a></li>" +
          "<li><div class='wysihtml5-colors' data-wysihtml5-command-value='orange'></div><a class='wysihtml5-colors-title' data-wysihtml5-command='foreColor' data-wysihtml5-command-value='orange'>" + locale.colours.orange + "</a></li>" +
        "</ul>" +
      "</li>";
    }
  };

  $('#editor').wysihtml5({
    "stylesheets": ["/assets/wysiwyg/wysiwyg-color.css"],
    "customTemplates": tpl,
    "font-styles": true, //Font styling, e.g. h1, h2, etc. Default true
    "emphasis": true, //Italics, bold, etc. Default true
    "lists": true, //(Un)ordered lists, e.g. Bullets, Numbers. Default true
    "html": true, //Button which allows you to edit the generated HTML. Default false
    "link": true, //Button to insert a link. Default true
    "image": false, //Button to insert an image. Default true,
    "color": true //Button to change color of font
  });
});
