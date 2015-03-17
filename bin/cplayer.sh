#!/usr/bin/env bash

get_script_path() {
  pushd $(dirname "$0") > /dev/null
  echo $(pwd)
  popd > /dev/null
}

SCRIPT_PATH=$(get_script_path)
URL_ENCODE=$SCRIPT_PATH/nodejs/encode.js
RESULT_PARSE=$SCRIPT_PATH/nodejs/parse.js
ZENITY="zenity --title="

command -v nodejs > /dev/null && NODEJS=nodejs
command -v node > /dev/null && NODEJS=node
[ -z "$NODEJS" ] && echo "Node.js required" && exit 1

command -v mplayer > /dev/null && PLAYER=mplayer
command -v vlc > /dev/null && PLAYER=vlc
command -v totem > /dev/null && PLAYER=totem
[ -z "$PLAYER" ] && echo "totem or vlc or mplayer required" && exit 1

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

print_help() {
  cat << EOF
用法: $0 [-p player | -u url]

选项:
  -p player    指定播放器
  -u url       要播放的视频地址 
EOF
}

main() {
  [ -z "$URL" ] && URL=$($ZENITY --entry --text=视频地址：)
  echo 视频地址：$URL
  echo 正在获取播放地址……

  local urls=$(get_raw_urls $URL)
  [ "$(echo $urls | jq .fragments)" = {} ] && echo 获取播放地址失败 && exit 1

  printf "解析结果："
  echo $urls | jq .fragments
  printf "选择播放源："

  local qualitys=$(echo $urls | jq ".fragments | keys")
  local choice=$($ZENITY --height=320 --list --column= $(implode $qualitys))
  [ -z "$choice" ] && echo -e "\n取消选择。" && exit 1

  # 双击选择的时候，zenity 会返回两个相同的用“|”分隔的结果，
  # 如“分段_高清_FLV|分段_高清_FLV”，只需要保留一个。
  choice=${choice#*|}
  echo $choice

  $PLAYER $(implode $(echo $urls | jq .fragments[\"$choice\"]))
}

while getopts p:u:h opt; do
  case $opt in
    p) PLAYER=$OPTARG ;;
    u) URL=$OPTARG ;;
    h) print_help; exit ;;
  esac
done

main
