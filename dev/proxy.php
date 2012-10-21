<?php

// Detect the URL
$url = null;
if ( isset($_GET['url']) )
    $url = $_GET['url'];
else if ( isset($_SERVER['PATH_INFO']) )
    $url = $_SERVER['PATH_INFO'];

// about:blank if passed no URL
if ( !$url ) {
    header('Location: about:blank');
    exit();
}

// Request the URL. Return 404 always if failed
if ( false === ( $content = @file_get_contents($_GET['url']) ) ) {
    header('404 Not Found');
    exit();
}

// Supply base element to resolve relative path
if ( !preg_match('/<base\s/i', $content) ) {
    $base = '<base href="' . $url . '">';
    $content = str_replace('</head>', $base . '</head>', $content);
}

// Supply protocol and domain before absolute path
if ( preg_match('!^https?://[^/]+!', $url, $matches) ) {
    $stem = $matches[0];
    $content = preg_replace('!(\s)(src|href)(=")/!i', "\\1\\2\\3$stem/", $content);
    $content = preg_replace('!(\s)(url)(\s*\(\s*["\']?)/!i', "\\1\\2\\3$stem/", $content);
}

echo $content;
