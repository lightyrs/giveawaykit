//= require lodash/lodash.underscore
//= require ../../../vendor/assets/javascripts/jquery.noisy
//= require ui/loader
//= require ui/flash_messages

$(function() {

  $('body').noisy({
    'intensity' : 0.061,
    'size' : '300',
    'opacity' : 0.08,
    'fallback' : '#DFE3E8',
    'monochrome' : false
  }).css('background-color', '#DFE3E8');

  SG.UI.FlashMessages.initialize();
});
