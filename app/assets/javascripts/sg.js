SG = {
  UI: {},
  Graphs: {},
  Dashboard: {},
  StripeClient: {},
  Giveaways: {}
};

$(function() {

  $.ajaxSetup({ cache: false });

  if (typeof(SG.UI) !== 'undefined' && typeof(SG.UI.initialize) === 'function') {
    SG.UI.initialize();
  }

  if (typeof(SG.Dashboard) !== 'undefined' && typeof(SG.Dashboard.initialize) === 'function') {
    SG.Dashboard.initialize();
  }

  if (typeof(SG.Giveaways) !== 'undefined' && typeof(SG.Giveaways.initialize) === 'function') {
    SG.Giveaways.initialize();
  }

  if (typeof(SG.Subscriptions) !== 'undefined' && typeof(SG.Subscriptions.initialize) === 'function') {
    SG.Subscriptions.initialize();
  }
});
