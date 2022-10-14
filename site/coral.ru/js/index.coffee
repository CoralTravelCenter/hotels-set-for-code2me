window.ASAP ||= (->
    fns = []
    callall = () ->
        f() while f = fns.shift()
    if document.addEventListener
        document.addEventListener 'DOMContentLoaded', callall, false
        window.addEventListener 'load', callall, false
    else if document.attachEvent
        document.attachEvent 'onreadystatechange', callall
        window.attachEvent 'onload', callall
    (fn) ->
        fns.push fn
        callall() if document.readyState is 'complete'
)()

window.log ||= () ->
    if window.console and window.DEBUG
        console.group? window.DEBUG
        if arguments.length == 1 and Array.isArray(arguments[0]) and console.table
            console.table.apply window, arguments
        else
            console.log.apply window, arguments
        console.groupEnd?()
window.trouble ||= () ->
    if window.console
        console.group? window.DEBUG if window.DEBUG
        console.warn?.apply window, arguments
        console.groupEnd?() if window.DEBUG

window.preload ||= (what, fn) ->
    what = [what] unless  Array.isArray(what)
    $.when.apply($, ($.ajax(lib, dataType: 'script', cache: true) for lib in what)).done -> fn?()

window.queryParam ||= (p, nocase) ->
    params_kv = location.search.substr(1).split('&')
    params = {}
    params_kv.forEach (kv) -> k_v = kv.split('='); params[k_v[0]] = k_v[1] or ''
    if p
        if nocase
            return decodeURIComponent(params[k]) for k of params when k.toUpperCase() == p.toUpperCase()
            return undefined
        else
            return decodeURIComponent params[p]
    params

ASAP ->
    libs = ['https://cdnjs.cloudflare.com/ajax/libs/jquery.isotope/3.0.6/isotope.pkgd.min.js']

    $ctx = $('#hotels-set')

    selector_attrs = ['data-group','data-year-month']
    selector_attrs_string = (selector_attrs.map (attr) -> ".filters-wrap [#{ attr }]").join ','

    selector_predicate = () ->
        predicate = {}
        $('.filters-wrap *.selected', $ctx).each (idx, button) ->
            selector_attrs.forEach (attr_name) ->
                attr_value = $(button).attr attr_name
                predicate[attr_name] = attr_value if attr_value
        predicate

    selector_from_predicate = (predicate) ->
        selector = ''
        selector += (if v == '*' then '*' else "[#{ k }='#{ v }']") for k,v of predicate
        selector or '*'

    preload libs, ->
        initial_selector = selector_from_predicate selector_predicate()
        $grid = $('.cards-grid', $ctx)
        .on 'layoutComplete', (e, items) ->
            els = items.map (i) -> i.element
            by_top = _.groupBy els, (el) -> $(el).css('top')
            for t, row of by_top
                tallest_item = _.maxBy row, (el) -> $(el).outerHeight()
                max_height = $(tallest_item).outerHeight()
                $(row).css minHeight: max_height
        .isotope
            itemSelector: '.card-cell'
            layoutMode: 'fitRows'
            stagger: 30
            filter: initial_selector
        $(selector_attrs_string, $ctx).on 'click', ->
            $this = $(this)
            $grid.find('.card-cell').css minHeight: 0
            $this.addClass('selected').siblings('.selected').removeClass('selected')
            $grid.isotope filter: selector_from_predicate(selector_predicate())

        setTimeout ->
            $ctx.addClass('shown')
        , 0
    yes