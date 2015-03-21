#!/usr/bin/env bash

command -v nodejs > /dev/null && NODEJS=nodejs
command -v node > /dev/null && NODEJS=node
[ -z "$NODEJS" ] && echo "Node.js required" && exit 1

command -v mplayer > /dev/null && PLAYER=mplayer
command -v vlc > /dev/null && PLAYER=vlc
command -v totem > /dev/null && PLAYER=totem
[ -z "$PLAYER" ] && echo "totem or vlc or mplayer required" && exit 1

get_script_path() {
  pushd $(dirname "$0") > /dev/null
  echo $(pwd)
  popd > /dev/null
}

PATH_SCRIPT=$(get_script_path)
PATH_CACHE=$HOME/.cache/
PATH_INPUT_URL=$PATH_CACHE/input_url
PATH_JS_DATA=$PATH_CACHE/data.js

URL_ENCODE="$NODEJS $PATH_SCRIPT/encode.js"
RESULT_PARSE="python $PATH_SCRIPT/parse.py"
ZENITY="zenity --title="
INPUT_METHOD=dialog

[ -d $PATH_CACHE ] || mkdir $PATH_CACHE

get_raw_urls() {
  local url=https://www.flvxz.com/getFlv.php?url=$($URL_ENCODE "$1")
  local data=$(curl -s -H "referer: http://flv.cn" $url | grep -o "eval.*));")
  echo "function flvout (html) { console.log(html) } $data" > $PATH_JS_DATA
  $RESULT_PARSE "$($NODEJS $PATH_JS_DATA)"
}

implode() {
  echo ${@//[\[\]\",]/}
}

print_help() {
  cat << EOF
用法: $0 [-p player]

选项:
  -p player    指定播放器
EOF
}

input_text() {
  sl
}

main() {
  # 尝试从粘贴板获取视频地址
  command -v xclip > /dev/null && URL=$(xclip -selection clipboard -o)
  dialog --inputbox 视频地址 8 64 "$URL" 2> $PATH_INPUT_URL
  [ $? = 1 ] && exit 1
  URL=$(cat $PATH_INPUT_URL)
  echo 视频地址：$URL
  echo 正在获取播放地址……

  local urls=$(get_raw_urls $URL)
  [ "$(echo $urls | jq .fragments)" = {} ] && echo 获取播放地址失败 && exit 1

  printf "解析结果："
  echo $urls | jq .fragments
  printf "选择播放源："

  local qualitys=$(echo $urls | jq ".fragments | keys")
  local choice=$($ZENITY \
    --height=320 --list --column= --text=选择播放源： $(implode $qualitys))
  [ -z "$choice" ] && exit 1

  # 双击选择的时候，zenity 会返回两个相同的用“|”分隔的结果，
  # 如“分段_高清_FLV|分段_高清_FLV”，只需要保留一个。
  choice=${choice#*|}
  echo $choice

  $PLAYER $(implode $(echo $urls | jq .fragments[\"$choice\"])) 2> /dev/null
}

while getopts p:h opt; do
  case $opt in
    p) PLAYER=$OPTARG ;;
    h) print_help; exit ;;
  esac
done

main
