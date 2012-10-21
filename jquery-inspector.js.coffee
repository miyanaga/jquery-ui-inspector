
$.widget 'ui.inspector',
    options:
        # proxyUrl: ''   # required
        proxyUrlParam: 'url'
        blankUrl: 'about:blank'
        hoverId: '-inspector-hover'
        hoverStyle: 'background-color:red;opacity:0.3;'
        highlightClass: '-inspector-highlight'
        highlightStyle: 'border:2px solid #f00 !important;opacity:0.3;'
        blockTransition: true
        blockTransitionMessage: 'If you move from this page but please stay because inspection will be disabled.'
        clickable: 'a, input, button, area, select, textarea'
        cancelingDelay: 500
        # onBeforeLoad: function(url) {}
        # onAfterLoad: function(url) {}
        # onHover: function(element) {}
        # onPick: function(element) {}

        # Selector builder
        selectorBuilder: (el) ->
            $el = $(el)
            $body = $('body')

            # Tag name
            tag = el.tagName.toLowerCase()
            sel = tag

            # Has id?
            if $el.attr('id')?
                by_id = '#' + $el.attr('id')
                return by_id if $body.find(by_id).length is 1

            # Has class?
            if $el.attr('class')?
                $.each $el.attr('class').split(/\s+/), (i, c) =>
                    c = c.replace /\s/g, ''
                    if c isnt @options.highlightClass
                        sel += '.' + c

            sel

        # Selector path builder
        selectorPathBuilder: (el, delimiter) ->
            paths = []
            $el = $(el)
            elements = []
            $body = $('body')

            # Default delimiter
            if delimiter is undefined
                delimiter = ' '

            # Get parent elements until body
            $el.parentsUntil('body').andSelf().each ->
                elements.push @

            # Join selector of parents
            $.each elements, (i, e) =>
                sel = @options.selectorBuilder.call @, e, $body
                # If the selector has id or is unique, make it origin
                if sel.indexOf('#') >= 0 and $body.find(sel).length is 1
                    paths = []
                paths.push sel

            paths.join delimiter

        # Proxy URL builder
        proxiedUrlBuilder: (url) ->
            # If proxyUrlParam is empty, join a URL as the path
            if @options.proxyUrlParam?
                return @options.proxyUrl + '?' + @options.proxyUrlParam + '=' + encodeURI(url)
            else
                return @options.proxyUrl + '/' + encodeURI(url)

    _create: ->
        # iframe Element
        @iframe = @element
        @$iframe = $(@iframe)

        # Status
        @loading = false
        @loaded = true
        @pick_on_load = false
        @highlight_on_load = null
        @picking = false

        # Load handler
        @$iframe.load =>
            # Status
            @loding = false
            @loaded = true

            # DOM
            @$doc = @$iframe.contents()
            @doc = @$doc[0]
            @$body = @$doc.find 'body'

            # Disable clickable
            @$body.find(@options.clickable).click (ev) =>
                if @picking is true
                    ev.stopPropagation()
                    ev.preventDefault()
                    return false
                else
                    return undefined

            # Block transition
            if @options.blockTransition is true
                self = @
                @$iframe.each ->
                    $(@contentWindow).unbind('beforeunload')
                    .bind 'beforeunload', (ev) ->
                        return undefined if @document.hasFocus() isnt true or self.inFrame isnt true
                        ev.returnValue = self.options.blockTransitionMessage


            # Hover element
            @$hover = $("<div id='#{@options.hoverId}' />")
                .hide()
                .attr('style', @options.hoverStyle)
                .attr('pointer-events', 'none')
                .css
                    display: 'block'
                    position: 'absolute'
                    left: '0px'
                    top: '0px'
                    width: '0px'
                    height: '0px'
                    'z-index': 99999
                    'pointer-events': 'none'

            # Hover visibility
            @$iframe.bind 'mouseenter', =>
                @inFrame = true
                if @picking is true
                    @$hover.show()
            .bind 'mouseout', =>
                @inFrame = false
                if @picking is true
                    @$hover.hide()

            # Highlight style definition
            $highlight = $("<style type='text/css'> .#{@options.highlightClass} { #{@options.highlightStyle} } </style>")
            @$body.append $highlight

            # Callback onAfterLoad
            if @options.onAfterLoad?
                @options.onAfterLoad.call @

            # Picking and highlight requested
            if @pick_on_load is true
                @pick()
                @pick_on_load = false

            if @highlight_on_load?
                @highlight @highlight_on_load
                @highlight_on_load = null

    proxiedUrl: (url) ->
        # Make proxied url
        @options.proxiedUrlBuilder.call @, url

    selectorPath: (el, delimiter) ->
        # Make selector path of a element
        @options.selectorPathBuilder.call @, el, delimiter

    load: (url) ->
        # Status
        @loading = true
        @loaded = false
        @pick_on_load = false
        @highlight_on_load = null
        @picking = false

        # Start to load
        @url = url

        # Unblock transition
        @$iframe.each ->
            $(@contentWindow).unbind 'beforeunload'

        # Callback before load
        if @options.onBeforeLoad?
            @options.onBeforeLoad.call @, url

        # Load on iframe
        @$iframe.attr 'src', @options.blankUrl
        @$iframe.attr 'src', @proxiedUrl(url)

        @

    pick: (continues, onPick) ->
        # If not loaded, reserve to pick after load
        if @loaded isnt true
            @pick_on_load = true
            return

        @$body.append @$hover

        # Hovering and picking
        @$body.bind 'mousemove', (ev) =>
            @hovering = @doc.elementFromPoint(ev.clientX, ev.clientY)
            @$hovering = $(@hovering)
            @$hover.offset(@$hovering.offset())
                .width(@$hovering.width())
                .height(@$hovering.height())

            # Callback onHover
            if @options.onHover?
                @options.onHover.call @, @hovering

            ev.preventDefault()
            ev.stopPropagation()
            false
        .bind 'mouseup', (ev) =>
            # Callback onPick
            cb = onPick or @options.onPick
            if cb?
                cb.call @, @hovering, @selector

            # Continue to pick?
            if not continues?
                # Reset events and hide hover
                # FIXME: 'click' event will be fired after mouse events so canceling delayed.
                setTimeout =>
                    @cancelPicking()
                , @options.cancelingDelay

            ev.preventDefault()
            ev.stopPropagation()
            false
        .bind 'mousedown', (ev) =>
            ev.preventDefault()
            ev.stopPropagation()
            false

        @picking = true
        @

    cancelPicking: ->
        return if @picking isnt true

        # Remove events and hover
        if @clickBlocker?
            @$body.find(@options.clickable).unbind 'click', @clickBlocker
        @clickBlocker = null
        @$body.unbind 'mousemove mouseup mousedown'
        @$hover.hide()
        @picking = false
        @

    highlight: (selector, addition) ->
        # If not loaded, reserve to highlight
        if @loaded isnt true
            @highlight_on_load = selector

        # Reset highlight if needed
        @resetHighlight() if addition isnt true

        # Add highlight class to elements
        @$doc.find(selector).addClass @options.highlightClass
        @

    resetHighlight: ->
        return if @loaded isnt true

        # Remove highlight class from current
        @$doc.find(".#{@options.highlightClass}")
            .removeClass @options.highlightClass
        @
