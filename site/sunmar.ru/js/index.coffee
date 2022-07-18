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

    preload libs, ->
        # Remove/hide group selector(s) that has no cards
#        $('.group-filters > *').each (idx, el) ->
#            $el = $(el)
#            group2check = $el.attr 'data-group'
#            if group2check != '*'
#                unless $(".card-cell[data-group*='#{ group2check }']").length
#                    default_group_removed = $el.hasClass('selected') or default_group_removed
#                    $el.remove()
#            if default_group_removed
#                $('.group-filters [data-group="*"]').addClass 'selected'

        initial_selector = '*'
        if group2select = $('.group-filters > *.selected').attr('data-group')
            initial_selector = if group2select != '*' then "[data-group*='#{ group2select }']" else '*'

        $grid = $('.cards-grid').isotope
            itemSelector: '.card-cell'
            layoutMode: 'fitRows'
            stagger: 30
            filter: initial_selector
        $('.group-filters > [data-group]').on 'click', ->
            $this = $(this)
            group = $this.attr('data-group')
            selector = if group != '*' then "[data-group*='#{ group }']" else '*'
            $grid.isotope filter: selector
            $this.addClass('selected').siblings('.selected').removeClass('selected')

        setTimeout ->
            $('#hotels-set').addClass('shown')
        , 0
