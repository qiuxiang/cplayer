#!/usr/bin/env bash

get_script_path() {
  pushd $(dirname "$0") > /dev/null
  echo $(pwd)
  popd > /dev/null
}

SCRIPT_PATH=$(get_script_path)
URL_ENCODE=$SCRIPT_PATH/scripts/encode.js
RESULT_PARSE=$SCRIPT_PATH/scripts/parse.js
NODEJS=nodejs
PLAYER=totem

get_raw_urls() {
  local url=https://www.flvxz.com/getFlv.php?url=$($URL_ENCODE "$1")
  local code=$(curl -s -H "referer: http://flv.cn" $url | grep -o "eval.*));")
  local result=$($NODEJS -e "
    function flvout (html) { console.log(html) } $code")
  $RESULT_PARSE "$result"
}

implode() {
  echo ${@//[\[\]\",]/}
}

urls=$(get_raw_urls $1)
[ "$(echo $urls | jq .fragments)" = {} ] && echo 无法获取播放地址 && exit 1
qualitys=$(echo $urls | jq ".fragments | keys")
choice=$(zenity --height=320 --list --column= $(implode $qualitys))
$PLAYER $(implode $(echo $urls | jq .fragments[\"${choice#*|}\"]))
