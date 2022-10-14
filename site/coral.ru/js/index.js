window.ASAP || (window.ASAP = (function() {
  var callall, fns;
  fns = [];
  callall = function() {
    var f, results;
    results = [];
    while (f = fns.shift()) {
      results.push(f());
    }
    return results;
  };
  if (document.addEventListener) {
    document.addEventListener('DOMContentLoaded', callall, false);
    window.addEventListener('load', callall, false);
  } else if (document.attachEvent) {
    document.attachEvent('onreadystatechange', callall);
    window.attachEvent('onload', callall);
  }
  return function(fn) {
    fns.push(fn);
    if (document.readyState === 'complete') {
      return callall();
    }
  };
})());

window.log || (window.log = function() {
  if (window.console && window.DEBUG) {
    if (typeof console.group === "function") {
      console.group(window.DEBUG);
    }
    if (arguments.length === 1 && Array.isArray(arguments[0]) && console.table) {
      console.table.apply(window, arguments);
    } else {
      console.log.apply(window, arguments);
    }
    return typeof console.groupEnd === "function" ? console.groupEnd() : void 0;
  }
});

window.trouble || (window.trouble = function() {
  var ref;
  if (window.console) {
    if (window.DEBUG) {
      if (typeof console.group === "function") {
        console.group(window.DEBUG);
      }
    }
    if ((ref = console.warn) != null) {
      ref.apply(window, arguments);
    }
    if (window.DEBUG) {
      return typeof console.groupEnd === "function" ? console.groupEnd() : void 0;
    }
  }
});

window.preload || (window.preload = function(what, fn) {
  var lib;
  if (!Array.isArray(what)) {
    what = [what];
  }
  return $.when.apply($, (function() {
    var j, len, results;
    results = [];
    for (j = 0, len = what.length; j < len; j++) {
      lib = what[j];
      results.push($.ajax(lib, {
        dataType: 'script',
        cache: true
      }));
    }
    return results;
  })()).done(function() {
    return typeof fn === "function" ? fn() : void 0;
  });
});

window.queryParam || (window.queryParam = function(p, nocase) {
  var k, params, params_kv;
  params_kv = location.search.substr(1).split('&');
  params = {};
  params_kv.forEach(function(kv) {
    var k_v;
    k_v = kv.split('=');
    return params[k_v[0]] = k_v[1] || '';
  });
  if (p) {
    if (nocase) {
      for (k in params) {
        if (k.toUpperCase() === p.toUpperCase()) {
          return decodeURIComponent(params[k]);
        }
      }
      return void 0;
    } else {
      return decodeURIComponent(params[p]);
    }
  }
  return params;
});

ASAP(function() {
  var $ctx, libs, selector_attrs, selector_attrs_string, selector_from_predicate, selector_predicate;
  libs = ['https://cdnjs.cloudflare.com/ajax/libs/jquery.isotope/3.0.6/isotope.pkgd.min.js'];
  $ctx = $('#hotels-set');
  selector_attrs = ['data-group', 'data-year-month'];
  selector_attrs_string = (selector_attrs.map(function(attr) {
    return ".filters-wrap [" + attr + "]";
  })).join(',');
  selector_predicate = function() {
    var predicate;
    predicate = {};
    $('.filters-wrap *.selected', $ctx).each(function(idx, button) {
      return selector_attrs.forEach(function(attr_name) {
        var attr_value;
        attr_value = $(button).attr(attr_name);
        if (attr_value) {
          return predicate[attr_name] = attr_value;
        }
      });
    });
    return predicate;
  };
  selector_from_predicate = function(predicate) {
    var k, selector, v;
    selector = '';
    for (k in predicate) {
      v = predicate[k];
      selector += (v === '*' ? '*' : "[" + k + "='" + v + "']");
    }
    return selector || '*';
  };
  preload(libs, function() {
    var $grid, initial_selector;
    initial_selector = selector_from_predicate(selector_predicate());
    $grid = $('.cards-grid', $ctx).on('layoutComplete', function(e, items) {
      var by_top, els, max_height, results, row, t, tallest_item;
      els = items.map(function(i) {
        return i.element;
      });
      by_top = _.groupBy(els, function(el) {
        return $(el).css('top');
      });
      results = [];
      for (t in by_top) {
        row = by_top[t];
        tallest_item = _.maxBy(row, function(el) {
          return $(el).outerHeight();
        });
        max_height = $(tallest_item).outerHeight();
        results.push($(row).css({
          minHeight: max_height
        }));
      }
      return results;
    }).isotope({
      itemSelector: '.card-cell',
      layoutMode: 'fitRows',
      stagger: 30,
      filter: initial_selector
    });
    $(selector_attrs_string, $ctx).on('click', function() {
      var $this;
      $this = $(this);
      $grid.find('.card-cell').css({
        minHeight: 0
      });
      $this.addClass('selected').siblings('.selected').removeClass('selected');
      return $grid.isotope({
        filter: selector_from_predicate(selector_predicate())
      });
    });
    return setTimeout(function() {
      return $ctx.addClass('shown');
    }, 0);
  });
  return true;
});
