# claude-code-sound-notifications

> 🔊 给 [Claude Code](https://claude.com/claude-code) 加上声音提醒：**需要你确认/输入时**响一声，**一轮任务跑完时**再响一声。让你在 vibe coding 时不用一直盯着终端。
>
> Sound notifications for Claude Code — one cue when it needs your confirmation, another when a turn finishes.

跨平台支持 **macOS / Linux / Windows**，零依赖第三方库，用系统自带的声音播放能力。

---

## 它解决什么问题

用 Claude Code 时经常要 `yes` 确认，或者跑一长段任务等它完成。盯着屏幕很累，去干别的又怕错过。
这个工具用 Claude Code 的 **hooks** 机制，在两个关键时刻播放**不同的**声音：

| 事件 | 触发时机 | 默认声音 |
|------|----------|----------|
| `Notification` | 需要你确认权限、回答问题、等待输入 | macOS `Submarine`（低沉，穿透力强） |
| `Stop` | Claude 完成一轮回复 | macOS `Glass`（清脆，收尾感） |

一低一高，音色差异大，闭着眼睛也能分清「该我操作了」还是「跑完了」。

---

## 快速安装（macOS / Linux）

需要 [`jq`](https://jqlang.github.io/jq/)（macOS: `brew install jq`；Ubuntu/Debian: `sudo apt install jq`）。

```bash
git clone https://github.com/LeoHuiAI/claude-code-sound-notifications.git
cd claude-code-sound-notifications
./install.sh
```

安装脚本会：

1. 把 `play-sound.sh` 复制到 `~/.claude/hooks/cc-sound-notifications.sh`；
2. 把两个 hook 合并进 `~/.claude/settings.json`（**先自动备份**，不覆盖你已有的其它设置）；
3. 提示你重启 Claude Code，或在会话里打开一次 `/hooks` 让配置重新加载。

> 卸载：`./uninstall.sh`（同样先备份，只移除本工具写入的 hook）。

---

## 手动配置

如果你不想跑脚本，直接把对应平台的片段合并进 `~/.claude/settings.json` 的 `hooks` 字段即可。

- macOS → [`examples/settings.macos.json`](examples/settings.macos.json)
- Linux → [`examples/settings.linux.json`](examples/settings.linux.json)
- Windows → [`examples/settings.windows.json`](examples/settings.windows.json)

> ⚠️ `settings.json` 是**合并**不是替换——如果你已有 `hooks` 或其它设置，只把 `Notification` / `Stop` 两个键加进去，别整段覆盖。改完重启 Claude Code 或打开一次 `/hooks` 生效。

### Windows 原生

`install.sh` 走的是 bash，只覆盖 macOS / Linux（含 WSL、Git Bash）。Windows 原生用 PowerShell 系统声音，手动把 [`examples/settings.windows.json`](examples/settings.windows.json) 合并进设置即可——用的是 `[System.Media.SystemSounds]`，无需任何音频文件。

---

## 换成别的声音

### macOS

系统内置音在 `/System/Library/Sounds/`，可先试听：

```bash
afplay /System/Library/Sounds/Ping.aiff
```

| 适合「确认」（醒目） | 适合「完成」（轻快） |
|----------------------|----------------------|
| `Submarine` · `Hero` · `Sosumi` · `Ping` | `Glass` · `Tink` · `Pop` · `Bottle` |

改 `play-sound.sh` 里 `Darwin` 分支的文件名，或直接改 `~/.claude/hooks/cc-sound-notifications.sh`。

### Linux

freedesktop 音在 `/usr/share/sounds/freedesktop/stereo/*.oga`（如 `complete.oga`、`bell.oga`、`message.oga`）。改 `play-sound.sh` 里 `Linux` 分支的 `name` 即可。

---

## 工作原理

Claude Code 的 [hooks](https://docs.claude.com/en/docs/claude-code/hooks) 会在生命周期事件上运行你指定的命令。本工具只用两个事件：

- **`Notification`** —— Claude Code 需要用户介入（权限提示 / 提问）时触发；
- **`Stop`** —— 一轮助手回复结束时触发。

每个 hook 都设了 `"async": true`，播放在后台进行，**不会拖慢 Claude Code**。`play-sound.sh` 内部按 `uname` 分平台，找不到播放器时静默退化为终端响铃（`\a`），任何情况都不报错、不阻塞。

---

## FAQ

**装完没声音？**
这版配置若是在已运行的会话里写入，可能不会立刻生效——重启 Claude Code，或在会话里打开一次 `/hooks` 触发重载。也确认系统没静音、`jq` 已安装。

**会不会太吵？**
只有「等你操作」和「跑完一轮」两个时刻各响一声，都是短音。嫌吵可换更轻的音（见上），或只保留 `Notification` 一个 hook。

**安全吗？**
只往 `~/.claude/settings.json` 写两个播放本地系统声音的 hook，不联网、不采集任何数据。安装/卸载都会先备份。

---

## License

[MIT](LICENSE) © LeoHuiAI
