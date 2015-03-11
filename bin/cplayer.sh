#!/usr/bin/env bash

get_script_path() {
  pushd $(dirname "$0") > /dev/null
  echo $(pwd)
  popd > /dev/null
}

SCRIPT_PATH=$(get_script_path)
ENCODE=$SCRIPT_PATH/scripts/encode.js
PARSE=$SCRIPT_PATH/scripts/parse.js

get_raw_urls() {
  $PARSE "$(nodejs -e "
    function flvout (html) { console.log(html) }
    $(curl -s -H "referer: http://flv.cn" \
        https://www.flvxz.com/getFlv.php?url=$($ENCODE "$1") | grep -o "eval.*));")")"
}

get_raw_urls "http://v.youku.com/v_show/id_XOTA4MjY1ODI4.html"
