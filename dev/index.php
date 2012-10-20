<html>
    <head>
        <title>jQuery inspector development</title>
        <link rel="stylesheet" href="jq/jquery-ui-1.9.0.no-theme.min.css">
    </head>
    <body>

        <form onsubmit="return false">
            <label>url</label>
            <input type="text" size="40" data-bind="value:url">
            <a href="#" data-bind="click:load">Load</a>
            <span data-bind="visible:loading">Loading...</span>
            <label>selector</label>
            <input type="text" size="60" data-bind="value:selector">
            <a href="#" data-bind="click:pick">Pick</a>
        </form>

        <p data-bind="text:hovering"></p>
        <iframe src="about:blank" id="subframe" style="width: 100%; height: 100%"></iframe>

        <script src="jq/jquery-1.8.2.min.js"></script>
        <script src="jq/jquery-ui-1.9.0.core-widget.min.js"></script>
        <script src="jq/knockout-2.1.0.js"></script>
        <script src="../jquery-inspector.js"></script>
        <script>
            jQuery(function($) {
                var model = {
                    url: ko.observable('http://www.livedoor.co.jp/'),
                    hovering: ko.observable(''),
                    selector: ko.observable(''),
                    loading: ko.observable(false),
                };

                var $iframe = $('#subframe');
                $iframe.inspector({
                    proxyUrl: 'proxy.php',
                    onBeforeLoad: function(url) {
                        model.loading(true);
                    },
                    onAfterLoad: function(url) {
                        model.loading(false);
                    },
                    onHover: function(hovering) {
                        model.hovering($iframe.inspector('selectorPath', hovering, ' > '));
                    },
                    onPick: function(hovering) {
                        model.selector($iframe.inspector('selectorPath', hovering));
                    }
                });

                model.load = function() {
                    if ( model.url() )
                        $iframe.inspector('load', this.url()).inspector('pick');
                    else
                        alert('Enter URL');
                };

                model.pick = function() {
                    $iframe.inspector('pick');
                };

                model.selector.subscribe(function(selector) {
                    $iframe.inspector('highlight', selector, true);
                });

                ko.applyBindings(model);

                if ( model.url() )
                    model.load();

                $('iframe').bind('beforeunload', function(ev) {
                    return ev.returnValue = 'OK?';
                });
            });
        </script>
    </body>
</html>
