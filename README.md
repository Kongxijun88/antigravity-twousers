<p align="center">
  <img src="assets/banner.png" alt="Antigravity TwoUsers — Multi-Instance Manager for macOS" width="100%">
</p>

<h1 align="center">Antigravity TwoUsers</h1>

<p align="center">
  <b>macOS 专属 Google Antigravity 双开 / 三开全物理沙盒管理器（Pro 1 · Pro 2 · Ultra）</b><br>
  告别 5 小时速率限制 · 256 位动态密钥守护 · 智能 OAuth 回调路由 · 多窗口同时在线开发
</p>

<p align="center">
  <b>简体中文</b> ·
  <a href="docs/README.en.md">English</a> ·
  <a href="docs/README.ja.md">日本語</a> ·
  <a href="docs/README.ko.md">한국어</a> ·
  <a href="docs/README.es.md">Español</a> ·
  <a href="docs/README.fr.md">Français</a> ·
  <a href="docs/README.pt.md">Português</a>
</p>

<p align="center">
  <a href="https://apple.com"><img src="https://img.shields.io/badge/macOS-14%2B%20(Apple%20Silicon%20%26%20Intel)-000000?style=flat-square&logo=apple&logoColor=white" alt="macOS"></a>
  <img src="https://img.shields.io/badge/Instances-Pro%201%20%7C%20Pro%202%20%7C%20Ultra-6366F1?style=flat-square" alt="Instances">
  <img src="https://img.shields.io/badge/OAuth%20Router-Smart%20Callback%20Routing-EC4899?style=flat-square" alt="Smart Router">
  <img src="https://img.shields.io/badge/Keychain-256--Bit%20Dynamic%20Secret-10B981?style=flat-square&logo=letsencrypt&logoColor=white" alt="Security">
  <img src="https://img.shields.io/badge/Stack-Swift%20%7C%20Bash%20%7C%20AppleScript-22D3EE?style=flat-square&logo=swift&logoColor=black" alt="Stack">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-F59E0B?style=flat-square" alt="License"></a>
</p>

<p align="center">
  <a href="#-核心亮点">✨ 核心亮点</a> •
  <a href="#-方案对比">⚖️ 方案对比</a> •
  <a href="#-物理沙盒隔离架构">🏗️ 隔离架构</a> •
  <a href="#-智能-oauth-回调路由smart-url-router">🧭 智能回调路由</a> •
  <a href="#-快速安装">🚀 快速安装</a> •
  <a href="#-多-agent-黄金接力工作流">🔄 接力工作流</a> •
  <a href="#-安全与隐私保障">🛡️ 安全机制</a> •
  <a href="#-常见问题-faq">❓ FAQ</a>
</p>

---

## ✨ 核心亮点

<table>
  <tr>
    <td width="33%" valign="top">
      <h3>🧊 100% 物理沙盒隔离</h3>
      同时重定向 <code>$HOME</code> 与 Electron <code>--user-data-dir</code>，前端缓存与 Go 后端 <code>language_server</code> 彻底分离，永不串号。
    </td>
    <td width="33%" valign="top">
      <h3>🧭 智能 OAuth 回调路由</h3>
      内置原生 Swift 编写的 <b>Antigravity Router</b>，点击浏览器「打开 Antigravity」后精准跳回发起授权的分身窗口（Pro 2 / Ultra），不再误跳主客户端。
    </td>
    <td width="33%" valign="top">
      <h3>🔐 256 位动态加密密钥</h3>
      安装时通过 <code>openssl rand -hex 32</code> 为每个实例生成独一无二的 256 位随机钥匙串密码，<code>chmod 600</code> 严格保护，代码零硬编码。
    </td>
  </tr>
  <tr>
    <td width="33%" valign="top">
      <h3>♾️ 后台无感自动续期</h3>
      彻底根治命令行钥匙串 5 分钟自动锁定导致的 1 小时后 OAuth 失效问题，全天候稳定在线、模型不掉线。
    </td>
    <td width="33%" valign="top">
      <h3>🚀 支持双开与三开</h3>
      内置 <b>Pro 2</b> 与 <b>Ultra（第 3 实例）</b>一键脚本，原生集成程序坞（Dock）图标并自动软链接桌面/文档/下载目录。
    </td>
    <td width="33%" valign="top">
      <h3>🧹 无侵入、一键还原</h3>
      共享官方主程序二进制文件不占额外体积，绝不修改宿主系统默认钥匙串，卸载后原版 Antigravity 100% 保持原样。
    </td>
  </tr>
</table>

---

## ⚖️ 方案对比

| 特性对比 | 原生单账号 | 仅改 `--user-data-dir` | **Antigravity TwoUsers (本项目)** |
| :--- | :---: | :---: | :---: |
| 多账号同时在线（双开 / 三开） | ❌ | ❌（后端自动串号） | ✅ **完全支持（Pro 1 + Pro 2 + Ultra）** |
| 浏览器授权后精准跳回对应分身窗口 | — | ❌（强制跳回主客户端） | ✅ **原生 Swift 智能 URL 路由精准回跳** |
| 切换账号免登出 / 免重新授权 | ❌ | ❌ | ✅ **各自永久保持独立登录态** |
| OAuth 令牌后台自动刷新（不掉线） | ✅ | ❌（钥匙串锁定报错） | ✅ **禁用超时锁死，24h 稳定续期** |
| 密码安全（无硬编码明文密码） | ✅ | — | ✅ **本机 256 位随机密钥 + `chmod 600`** |
| 不污染宿主系统默认钥匙串 | ✅ | ⚠️ | ✅ **仅在独立子进程沙盒内生效** |

---

## 🏗️ 物理沙盒隔离架构

<p align="center">
  <img src="assets/architecture.png" alt="Physical Sandbox Isolation Architecture" width="100%">
</p>

<details>
<summary><b>📐 点击展开 Mermaid 底层进程与数据流向图</b></summary>

```mermaid
flowchart TD
    subgraph Original["原生主实例 (账号 1 · Pro 1)"]
        A1["Antigravity.app"] --> S1["Electron 数据: ~/Library/Application Support/Antigravity"]
        A1 --> L1["language_server 后端"]
        L1 --> G1["~/.gemini/ (OAuth Token)"]
        L1 --> K1["系统全局钥匙串: login.keychain-db"]
    end

    subgraph Pro2["沙盒隔离实例 2 (账号 2 · Pro 2)"]
        A2["Antigravity Pro 2.app"] --> S2["Electron 数据: ~/.antigravity-pro2-home/..."]
        A2 --> L2["language_server 后端 (隔离环境)"]
        L2 --> G2["~/.antigravity-pro2-home/.gemini/"]
        L2 --> K2["独立专用钥匙串 2 (256位动态密钥, chmod 600)"]
    end

    subgraph Ultra["沙盒隔离实例 3 (账号 3 · Ultra)"]
        A3["Antigravity Ultra.app"] --> S3["Electron 数据: ~/.antigravity-ultra-home/..."]
        A3 --> L3["language_server 后端 (隔离环境)"]
        L3 --> G3["~/.antigravity-ultra-home/.gemini/"]
        L3 --> K3["独立专用钥匙串 3 (256位动态密钥, chmod 600)"]
    end

    L2 -.-> Sym["软链接穿透: Desktop / Documents / Downloads"]
    L3 -.-> Sym
```

</details>

---

## 🧭 智能 OAuth 回调路由（Smart URL Router）

<p align="center">
  <img src="assets/router-flow.png" alt="Smart OAuth Callback Router" width="100%">
</p>

在 macOS 上，系统自定义协议 `antigravity://` 默认绑定到主客户端 `/Applications/Antigravity.app`。当你从 **Pro 2** 或 **Ultra** 发起登录并在浏览器点击 **「打开 Antigravity」** 时，macOS 会默认唤醒主客户端窗口。

本项目内置原生 Swift 轻量路由程序 **`Antigravity Router.app`**（后台静默运行、平时 0 内存占用），通过**双信号精准判定机制**彻底解决该痛点：
1. **信号 1 · 凭据落盘时间戳（最高精度）**：检测各隔离沙盒专属钥匙串最近 15 秒内的写入时间，谁刚刚完成 OAuth Token 写入，立即锁定谁；
2. **信号 2 · 窗口层叠顺序（实时兜底）**：通过 macOS 原生 `CGWindowListCopyWindowInfo`（**零权限弹窗**）读取浏览器正下方排在最前的 Antigravity 进程 PID；
3. **精准唤醒与透传**：毫秒级将对应的 **Primary / Pro 2 / Ultra** 窗口拉至前台，若 `antigravity://` 携带深链接参数还会一并精准透传给目标 PID。

---

## 🚀 快速安装

### 前置要求
* macOS 14+（支持 Apple Silicon M1–M4 与 Intel Mac）
* 已在 `/Applications/Antigravity.app` 安装官方 Google Antigravity 客户端
* 如需安装智能回调路由，需系统具备 `swiftc`（Xcode Command Line Tools）

### 1. 克隆项目
```bash
git clone https://github.com/Kongxijun88/antigravity-twousers.git
cd antigravity-twousers
```

### 2. 一键安装第 2 实例（`Antigravity Pro 2`）
```bash
chmod +x install.sh
./install.sh
```

### 3. 一键安装第 3 实例（`Antigravity Ultra`，可选）
```bash
chmod +x install-ultra.sh
./install-ultra.sh
```

### 4. 一键安装智能 OAuth 回调路由（推荐）
```bash
chmod +x install-router.sh
./install-router.sh
```

> 可随时运行 `"/Applications/Antigravity Router.app/Contents/MacOS/AntigravityRouter" --status` 查看当前运行实例与智能路由目标诊断。

### 📋 实例与组件总览

| 组件 / 实例 | 应用程序路径 | 隔离沙盒目录 | 命令行脚本 |
| :--- | :--- | :--- | :--- |
| **主实例 (Pro 1)** | `/Applications/Antigravity.app` | `~/.gemini/`（系统默认） | — |
| **实例 2 (Pro 2)** | `/Applications/Antigravity Pro 2.app` | `~/.antigravity-pro2-home/` | `./scripts/launch.sh` |
| **实例 3 (Ultra)** | `/Applications/Antigravity Ultra.app` | `~/.antigravity-ultra-home/` | `./scripts/launch-ultra.sh` |
| **智能路由 (Router)** | `/Applications/Antigravity Router.app` | 无（按需触发，静默退出） | `./install-router.sh` |

---

## 📂 项目结构

```text
antigravity-twousers/
├── install.sh                 # 一键安装实例 2 (Antigravity Pro 2)
├── uninstall.sh               # 一键安全卸载实例 2
├── install-ultra.sh           # 一键安装实例 3 (Antigravity Ultra)
├── uninstall-ultra.sh         # 一键安全卸载实例 3
├── install-router.sh          # 编译并注册原生 Swift 智能 OAuth 回调路由
├── uninstall-router.sh        # 卸载路由并一键恢复官方默认 antigravity:// 协议
├── router/
│   └── AntigravityRouter.swift # 原生 macOS 双信号智能 URL 路由源码
├── scripts/
│   ├── launch.sh              # 实例 2 命令行独立启动器
│   └── launch-ultra.sh        # 实例 3 命令行独立启动器
├── assets/
│   ├── banner.png             # 项目旗舰视觉横幅
│   ├── architecture.png       # 物理沙盒隔离架构图
│   ├── router-flow.png        # 智能 OAuth 回调路由流程图
│   └── workflow-showcase.png  # 24/7 多 Agent 接力工作流展示图
├── docs/                      # 多语言文档 (EN / JA / KO / ES / FR / PT)
└── LICENSE                    # MIT 开源协议
```

---

## 🔄 多 Agent 黄金接力工作流

<p align="center">
  <img src="assets/workflow-showcase.png" alt="24/7 Multi-Agent Relay Workflow" width="100%">
</p>

拥有多个账号（如 **2 个 Pro + 1 个 Ultra**）时，推荐使用**任务分级 + 上下文无损接力协议（Relay Protocol）**，实现 24 小时不间断开发：

| 账号分工 | 推荐场景 |
| :--- | :--- |
| **Antigravity (Pro 1)** | 日常功能开发、页面微调、单元测试与常规 Bug 修复 |
| **Antigravity Pro 2** | Pro 1 触发 5 小时速率限制时的无缝接力替补 |
| **Antigravity Ultra** | 复杂系统架构重构、高难度全栈排障与重度推理任务 |

### 两步无损交接协议

**第一步：当前账号额度见底前（存档交棒）**
```text
我马上要切换到另一个账号接手这个项目。请帮我把目前的代码修改全部保存并做一次 git commit 存档；在根目录生成 HANDOVER.md 记录已完成事项、关键设计与下一步待办清单；并写一段简短的交接提示词，方便我直接发给下一个 Agent 无缝接手。
```

**第二步：切换至下一个实例（读档接棒）**
在 **Antigravity Pro 2** 或 **Antigravity Ultra** 中通过 `File -> Open Folder` 打开同一项目目录，发送交接提示词：
```text
请阅读项目根目录的 HANDOVER.md 和最新 git commit，掌握当前进度后，继续完成下一步待办任务。
```

---

## 🛡️ 安全与隐私保障

| 安全维度 | 实现方式 |
| :--- | :--- |
| **零硬编码密码** | 代码与 Git 历史中绝无写死密码，每次安装现场调用 `openssl rand -hex 32` 生成独立 256 位随机密钥 |
| **文件权限隔离** | 密钥文件 `.keychain_secret` 与钥匙串数据库 `login.keychain-db` 均强制设置为 `chmod 600`（仅限本机当前用户读写） |
| **宿主零污染** | 启动器仅在子进程中通过 `export HOME` 隔离环境，**绝不修改** macOS 宿主用户的默认登录钥匙串 |
| **零遥测 / 纯本地** | 全部脚本与 Swift 路由均为透明可读的开源代码，无任何网络上传、无第三方闭源依赖 |

---

## 🗑️ 安全卸载

```bash
# 卸载实例 2 (Antigravity Pro 2)
./uninstall.sh

# 卸载实例 3 (Antigravity Ultra)
./uninstall-ultra.sh

# 卸载智能路由并恢复官方默认 antigravity:// 协议
./uninstall-router.sh
```

卸载脚本将自动终止对应分身进程、移除 `/Applications` 内的 `.app` 与程序坞图标，并询问是否彻底销毁对应的沙盒目录与专属钥匙串（若保留数据，将自动对钥匙串执行上锁保护）。**原版 Antigravity 与主账号 100% 不受任何影响。**

---

## ❓ 常见问题 (FAQ)

<details>
<summary><b>Q1: 为什么在分身实例中可以直接打开桌面和下载目录的项目？</b></summary>
<br>
安装脚本在每个沙盒目录中自动创建了指向 <code>~/Desktop</code>、<code>~/Documents</code> 与 <code>~/Downloads</code> 的软链接，确保你可以像原版一样零障碍访问所有本地代码仓库。
</details>

<details>
<summary><b>Q2: Mac 重启后会不会串号或需要重新登录？</b></summary>
<br>
<b>绝对不会。</b> 每个实例的 OAuth 凭据分别固化在各自的沙盒目录与独立钥匙串中，重启电脑后各自读取独立保险箱，互不干扰。
</details>

<details>
<summary><b>Q3: 安装智能回调路由后，浏览器提示“要打开 Antigravity Router 吗？”是否正常？</b></summary>
<br>
<b>完全正常！</b> 这是因为 <code>Antigravity Router.app</code> 已成功接管 <code>antigravity://</code> 协议。勾选「始终允许」后，今后从任何客户端发起授权都会自动无感跳回正确的窗口。
</details>

<details>
<summary><b>Q4: 3 个实例同时运行，Mac 内存和性能吃得消吗？</b></summary>
<br>
<b>非常轻松。</b> 三个实例共享同一份官方客户端二进制文件，几乎不额外占用硬盘空间；每个实例运行内存约 500MB–800MB，3 开总计约 2GB–2.5GB，16GB 及以上内存的 Apple Silicon Mac 可全天候流畅并行。
</details>

<details>
<summary><b>Q5: 扩展插件、主题与快捷键配置是共享还是独立的？</b></summary>
<br>
<b>完全独立。</b> 每个实例拥有专属的插件目录与偏好设置，强烈建议为主力、Pro 2 与 Ultra 分别设置不同颜色主题，一眼即可区分窗口！
</details>

---

## 📄 License

本项目基于 [MIT License](LICENSE) 开源。如果这个项目帮到了你，欢迎点一颗 **Star ⭐️** 支持！
