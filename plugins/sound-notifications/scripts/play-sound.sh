#!/usr/bin/env bash
#
# Play a short sound for a Claude Code lifecycle hook event.
#
#   Usage: play-sound.sh <event>
#   event: notification | stop     (aliases: notify | done)
#
# 跨平台：macOS 用 afplay + 系统内置音；Linux 用 paplay/ffplay + freedesktop 音；
# 其它平台退化为终端响铃。播放放到后台、始终 exit 0——绝不阻塞、绝不让 hook 失败。

event="${1:-notification}"
os="$(uname -s)"

case "$event" in
  notification|notify) role="notify" ;;
  stop|done)           role="done" ;;
  *)                   role="notify" ;;
esac

case "$os" in
  Darwin)
    case "$role" in
      notify) sound="/System/Library/Sounds/Submarine.aiff" ;;
      done)   sound="/System/Library/Sounds/Glass.aiff" ;;
    esac
    [ -f "$sound" ] && afplay "$sound" >/dev/null 2>&1 &
    ;;

  Linux)
    case "$role" in
      notify) name="dialog-information" ;;
      done)   name="complete" ;;
    esac
    played=0
    for f in \
      "/usr/share/sounds/freedesktop/stereo/${name}.oga" \
      "/usr/share/sounds/freedesktop/stereo/bell.oga"; do
      [ -f "$f" ] || continue
      if command -v paplay >/dev/null 2>&1; then
        paplay "$f" >/dev/null 2>&1 & played=1; break
      elif command -v ffplay >/dev/null 2>&1; then
        ffplay -nodisp -autoexit "$f" >/dev/null 2>&1 & played=1; break
      fi
    done
    [ "$played" = 0 ] && printf '\a'
    ;;

  *)
    printf '\a'
    ;;
esac

exit 0
