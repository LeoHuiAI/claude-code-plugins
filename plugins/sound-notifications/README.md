# sound-notifications

> 🔊 给 [Claude Code](https://claude.com/claude-code) 加声音提醒：**需要你确认/输入时**响一声，**一轮任务跑完时**再响一声。

| 事件 | 触发时机 | macOS 默认音 |
|------|----------|--------------|
| `Notification` | 需要你确认权限、回答问题、等待输入 | `Submarine`（低沉、穿透力强） |
| `Stop` | Claude 完成一轮回复 | `Glass`（清脆、收尾感） |

一低一高，音色差异大，闭着眼也能分清「该我操作了」还是「跑完了」。

## 安装（推荐，插件方式）

```
/plugin marketplace add LeoHuiAI/claude-code-plugins
/plugin install sound-notifications@leohuiai-plugins
```

装完**免重启**即刻生效。用 `/plugin` → Installed 里能看到它挂了 `Notification` / `Stop` 两个 hook。

- **平台**：macOS / Linux / WSL / Git Bash（hook 通过 `bash` 调用打包脚本）。
- **原生 Windows**（无 bash）：hook 会静默跳过、不报错。请用下方手动 PowerShell 片段。
- 卸载：`/plugin uninstall sound-notifications@leohuiai-plugins`。

## 换成别的声音

macOS 系统音在 `/System/Library/Sounds/`，可先试听 `afplay /System/Library/Sounds/Ping.aiff`：

| 适合「确认」（醒目） | 适合「完成」（轻快） |
|----------------------|----------------------|
| `Submarine` · `Hero` · `Sosumi` · `Ping` | `Glass` · `Tink` · `Pop` · `Bottle` |

改 `scripts/play-sound.sh` 里 `Darwin` 分支的文件名即可（Linux 改 `name`，音源在 `/usr/share/sounds/freedesktop/stereo/*.oga`）。

## 手动配置（不走插件系统时的回退）

把对应片段合并进 `~/.claude/settings.json` 的 `hooks` 字段（是**合并**不是替换）：

**macOS**
```json
{
  "hooks": {
    "Notification": [ { "hooks": [ { "type": "command", "command": "afplay /System/Library/Sounds/Submarine.aiff", "async": true } ] } ],
    "Stop":         [ { "hooks": [ { "type": "command", "command": "afplay /System/Library/Sounds/Glass.aiff",     "async": true } ] } ]
  }
}
```

**Linux**
```json
{
  "hooks": {
    "Notification": [ { "hooks": [ { "type": "command", "command": "paplay /usr/share/sounds/freedesktop/stereo/dialog-information.oga", "async": true } ] } ],
    "Stop":         [ { "hooks": [ { "type": "command", "command": "paplay /usr/share/sounds/freedesktop/stereo/complete.oga",           "async": true } ] } ]
  }
}
```

**Windows（PowerShell 系统声音，无需音频文件）**
```json
{
  "hooks": {
    "Notification": [ { "hooks": [ { "type": "command", "shell": "powershell", "command": "[System.Media.SystemSounds]::Exclamation.Play()", "async": true } ] } ],
    "Stop":         [ { "hooks": [ { "type": "command", "shell": "powershell", "command": "[System.Media.SystemSounds]::Asterisk.Play()",    "async": true } ] } ]
  }
}
```

改完重启 Claude Code，或在会话里打开一次 `/hooks` 触发重载。

## 工作原理

用 Claude Code 的 [hooks](https://code.claude.com/docs/en/plugins-reference.md#hooks)：`Notification` 在需要用户介入时触发、`Stop` 在一轮回复结束时触发。脚本内部把播放丢到后台（`&`）并始终 `exit 0`，**不拖慢 Claude Code**；找不到播放器时静默退化为终端响铃。只播放本地系统声音，不联网、不采集数据。
