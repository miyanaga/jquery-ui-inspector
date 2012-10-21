This is a jQuery UI widget to point a element in iframe like FireBug or DOM inspector.

* Really experimental
* Wittern in CoffeeScript, the source is jquery-inspector.js.coffee
* Requires jQuery and jQuery UI
 * Developed with jQuery 1.8.2 and jQuery UI 1.9.0 but not tested with others
* Currently not to support IE
* Requires server side script to proxy HTTP in order to avoid domain security

# Usage

<pre>
// Setup
$('iframe').inspector({
    proxyUrl: 'proxy.php',
    onPick: function(picked) {
        var path = this.selectorPath(picked, ' ');
        console.log(path);
        this.highlight(path);
    }
});

// Load. Do not use src attribute of iframe directly
$('iframe').inspector('load' 'http://example.com');

// Start to pick
$('iframe').inspector('pick');

// Suggest selector path of element
$('iframe').inspector('selectorPath', element);

// Highlight elements
$('iframe').inspector('highlight', selector);

// Add highlighted elements
$('iframe').inspector('highlight', selector, true);
</pre>

# Options

## proxyUrl - required

URL of HTTP proxy script.

See dev/proxy.php as reference.

## proxyUrlParam - default: url

Parameter to pass target URL to proxy URL.

## hoverStyle - default: see bellow

Style of hover element points element in iframe.

### Default

<pre>background-color:red;opacity:0.3;</pre>

## highlightStyle - default: see bellow

Style of highlighted element.

### Default

<pre>border:2px solid #f00 !important;opacity:0.3;</pre>

## blockTransitionMessage - default: see bellow

Message to show when a user moves to an another page.

Content of iframe needs same-origin proxyed URL, so prevent in beforeunload.

I want to know other ways.

## clickableSelector - default: a, input, button, area, select, textarea

Selector of clickable elements to stop 'click' events during picking.

## onBeforeLoad(url)

Callback before load URL.

## onAfterLoad(url)

Callback after load URL.

## onHover(element)

Callback when element hovered in picking.

## onPick(element)

Callback when element selected in picking.
