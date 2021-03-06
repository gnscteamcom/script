<?php
function getLinkFilm($html) {
    if (strpos($html, '-146')) {
        preg_match("/(\&token\=)(.*)(\",\"vplugin.host\")/",$html,$matches);
        $matches[2] = current(explode('","', $matches[2]));
        $token = current(explode(".split('", $matches[2]));
        $tokens = explode('-', $token);
        $token = $tokens[0];
        $time = $tokens[1];
    } else {
        preg_match("/(eval\(function\(p,a,c,k,e,d\)\{e)(.*)(split\(\'\|\'\)\,0\,\{\}\)\))/",$html,$matches);
        $htmlTokens = explode('|', $matches[0]);
        $token = null;
        $time = null;
        foreach ($htmlTokens as $htmlToken) {
            if (strlen($htmlToken) == 96 || strlen($htmlToken) == 86) {
                $token = $htmlToken;
            }

            if (strpos($htmlToken, '146') !== false) {
                $time = $htmlToken;
            }
        }
    }
    return $token . '-' . $time;
}

$htmlDetail = file_get_contents($argv[1]);
$data = getLinkFilm($htmlDetail);
if ($data) {
    die(json_encode($data));
}
die(json_encode(array()));
