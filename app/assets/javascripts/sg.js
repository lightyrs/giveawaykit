function deepFreeze (o) {
  var prop, propKey;
  Object.freeze(o);
  for (propKey in o) {
    prop = o[propKey];
    if (!o.hasOwnProperty(propKey) || !(typeof prop === "object") || Object.isFrozen(prop)) {
      continue;
    }
    deepFreeze(prop);
  }
}

SG = {
  UI: {},
  Graphs: {},
  Dashboard: {},
  StripeClient: {},
  Giveaways: {}
};

_SG = {
  Config: {},
  CurrentUser: {},
  CurrentGiveaway: {},
  CurrentPage: {},
  Paths: {}
}

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
