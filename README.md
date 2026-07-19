# claude-code-plugins

> LeoHui 的 [Claude Code](https://claude.com/claude-code) 插件集合（marketplace）。一个仓库，装一次 marketplace，按需安装里面的插件。

## 快速开始

```
/plugin marketplace add LeoHuiAI/claude-code-plugins
```

然后安装需要的插件：

```
/plugin install <插件名>@leohuiai-plugins
```

## 插件列表

| 插件 | 说明 | 平台 |
|------|------|------|
| [**sound-notifications**](plugins/sound-notifications) | 🔊 需要你确认时响一声，任务完成再响一声。 | macOS / Linux / WSL |

```
/plugin install sound-notifications@leohuiai-plugins
```

> 更多插件会陆续加进这个集合。每个插件的详细说明见各自目录下的 README。

## 目录结构

```
.claude-plugin/
  marketplace.json          # marketplace 清单，列出所有插件
plugins/
  sound-notifications/
    .claude-plugin/plugin.json
    hooks/hooks.json
    scripts/play-sound.sh
    README.md
```

## License

[MIT](LICENSE) © LeoHuiAI
