#!/usr/bin/env bash
#
# Play a short sound for Claude Code hook events.
#
#   Usage: play-sound.sh notify   # 需要你确认 / 输入时
#          play-sound.sh done     # 一轮任务完成时
#
# 跨平台：macOS 用 afplay + 系统内置音；Linux 用 paplay/ffplay + freedesktop 音；
# 其它平台退化为终端响铃。任何失败都静默，绝不阻塞 Claude Code。

kind="${1:-notify}"
os="$(uname -s)"

case "$os" in
  Darwin)
    case "$kind" in
      notify) sound="/System/Library/Sounds/Submarine.aiff" ;;
      done)   sound="/System/Library/Sounds/Glass.aiff" ;;
      *)      sound="/System/Library/Sounds/Submarine.aiff" ;;
    esac
    [ -f "$sound" ] && afplay "$sound" 2>/dev/null &
    ;;

  Linux)
    case "$kind" in
      notify) name="dialog-information" ;;
      done)   name="complete" ;;
      *)      name="bell" ;;
    esac
    played=0
    for f in \
      "/usr/share/sounds/freedesktop/stereo/${name}.oga" \
      "/usr/share/sounds/freedesktop/stereo/bell.oga"; do
      [ -f "$f" ] || continue
      if command -v paplay >/dev/null 2>&1; then
        paplay "$f" 2>/dev/null & played=1; break
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
