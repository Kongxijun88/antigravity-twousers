<p align="center">
  <img src="../assets/banner.png" alt="Antigravity TwoUsers — Multi-Instance Manager for macOS" width="100%">
</p>

<h1 align="center">Antigravity TwoUsers</h1>

<p align="center">
  <b>Sandboxed Dual &amp; Triple Instance Manager for Google Antigravity on macOS (Pro 1 · Pro 2 · Ultra)</b><br>
  Bypass 5-hour rate limits · 256-Bit Dynamic Keychain · Smart OAuth Callback Router · Concurrent Multi-Window Workflows
</p>

<p align="center">
  <a href="../README.md">简体中文</a> ·
  <b>English</b> ·
  <a href="README.ja.md">日本語</a> ·
  <a href="README.ko.md">한국어</a> ·
  <a href="README.es.md">Español</a> ·
  <a href="README.fr.md">Français</a> ·
  <a href="README.pt.md">Português</a>
</p>

<p align="center">
  <a href="https://apple.com"><img src="https://img.shields.io/badge/macOS-14%2B%20(Apple%20Silicon%20%26%20Intel)-000000?style=flat-square&logo=apple&logoColor=white" alt="macOS"></a>
  <img src="https://img.shields.io/badge/Instances-Pro%201%20%7C%20Pro%202%20%7C%20Ultra-6366F1?style=flat-square" alt="Instances">
  <img src="https://img.shields.io/badge/OAuth%20Router-Smart%20Callback%20Routing-EC4899?style=flat-square" alt="Smart Router">
  <img src="https://img.shields.io/badge/Keychain-256--Bit%20Dynamic%20Secret-10B981?style=flat-square&logo=letsencrypt&logoColor=white" alt="Security">
  <img src="https://img.shields.io/badge/Stack-Swift%20%7C%20Bash%20%7C%20AppleScript-22D3EE?style=flat-square&logo=swift&logoColor=black" alt="Stack">
  <a href="../LICENSE"><img src="https://img.shields.io/badge/License-MIT-F59E0B?style=flat-square" alt="License"></a>
</p>

<p align="center">
  <a href="#-key-highlights">✨ Highlights</a> •
  <a href="#-comparison">⚖️ Comparison</a> •
  <a href="#-physical-sandbox-architecture">🏗️ Architecture</a> •
  <a href="#-smart-oauth-callback-router">🧭 Smart Router</a> •
  <a href="#-quick-start">🚀 Quick Start</a> •
  <a href="#-multi-agent-relay-protocol">🔄 Relay Protocol</a> •
  <a href="#-security--privacy">🛡️ Security</a> •
  <a href="#-faq">❓ FAQ</a>
</p>

---

## ✨ Key Highlights

<table>
  <tr>
    <td width="33%" valign="top">
      <h3>🧊 100% Physical Sandbox</h3>
      Redirects both <code>$HOME</code> and Electron <code>--user-data-dir</code>, completely isolating the UI cache and Go <code>language_server</code> backend with zero crosstalk.
    </td>
    <td width="33%" valign="top">
      <h3>🧭 Smart OAuth Callback Router</h3>
      Native Swift <b>Antigravity Router</b> intercepts <code>antigravity://</code> clicks after browser login and returns you directly to the exact Pro 2 / Ultra window that started sign-in.
    </td>
    <td width="33%" valign="top">
      <h3>🔐 256-Bit Dynamic Keychain</h3>
      Generates a unique per-install 256-bit cryptographic secret via <code>openssl rand -hex 32</code> stored with <code>chmod 600</code>. Zero hardcoded passwords.
    </td>
  </tr>
  <tr>
    <td width="33%" valign="top">
      <h3>♾️ Silent Token Auto-Refresh</h3>
      Eliminates macOS CLI Keychain's 5-minute idle auto-lock so hourly Google OAuth refreshes succeed reliably 24/7.
    </td>
    <td width="33%" valign="top">
      <h3>🚀 Dual &amp; Triple Instances</h3>
      One-click installers for <b>Pro 2</b> and <b>Ultra (Instance 3)</b> with native Dock icons and auto-symlinked Desktop, Documents, and Downloads.
    </td>
    <td width="33%" valign="top">
      <h3>🧹 Zero-Footprint &amp; Reversible</h3>
      Shares the single official app binary, never mutates your host default Keychain, and leaves your primary Antigravity 100% untouched on uninstall.
    </td>
  </tr>
</table>

---

## ⚖️ Comparison

| Feature | Native Single App | `--user-data-dir` Only | **Antigravity TwoUsers** |
| :--- | :---: | :---: | :---: |
| Concurrent multi-account windows (2× / 3×) | ❌ | ❌ (Backend collides) | ✅ **Pro 1 + Pro 2 + Ultra** |
| Browser "Open Antigravity" returns to exact instance | — | ❌ (Always jumps to Primary) | ✅ **Native Swift Smart URL Router** |
| Switch accounts without re-authenticating | ❌ | ❌ | ✅ **Persistent isolated sessions** |
| Continuous background OAuth token refresh | ✅ | ❌ (Keychain locks) | ✅ **No-timeout refresh, 24/7 uptime** |
| Zero hardcoded credentials | ✅ | — | ✅ **256-bit random secret (`chmod 600`)** |
| Host default macOS Keychain untouched | ✅ | ⚠️ | ✅ **Subprocess-scoped isolation only** |

---

## 🏗️ Physical Sandbox Architecture

<p align="center">
  <img src="../assets/architecture.png" alt="Physical Sandbox Isolation Architecture" width="100%">
</p>

<details>
<summary><b>📐 Expand Mermaid Process &amp; Data Flow Diagram</b></summary>

```mermaid
flowchart TD
    subgraph Original["Default Primary Instance (Account 1 · Pro 1)"]
        A1["Antigravity.app"] --> S1["Electron Data: ~/Library/Application Support/Antigravity"]
        A1 --> L1["language_server backend"]
        L1 --> G1["~/.gemini/ (OAuth Token)"]
        L1 --> K1["System Keychain: login.keychain-db"]
    end

    subgraph Pro2["Sandboxed Instance 2 (Account 2 · Pro 2)"]
        A2["Antigravity Pro 2.app"] --> S2["Electron Data: ~/.antigravity-pro2-home/..."]
        A2 --> L2["language_server backend (Isolated)"]
        L2 --> G2["~/.antigravity-pro2-home/.gemini/"]
        L2 --> K2["Dedicated Keychain 2 (256-bit Dynamic Secret, chmod 600)"]
    end

    subgraph Ultra["Sandboxed Instance 3 (Account 3 · Ultra)"]
        A3["Antigravity Ultra.app"] --> S3["Electron Data: ~/.antigravity-ultra-home/..."]
        A3 --> L3["language_server backend (Isolated)"]
        L3 --> G3["~/.antigravity-ultra-home/.gemini/"]
        L3 --> K3["Dedicated Keychain 3 (256-bit Dynamic Secret, chmod 600)"]
    end

    L2 -.-> Sym["Symlinks: Desktop / Documents / Downloads"]
    L3 -.-> Sym
```

</details>

---

## 🧭 Smart OAuth Callback Router

<p align="center">
  <img src="../assets/router-flow.png" alt="Smart OAuth Callback Router" width="100%">
</p>

On macOS, Launch Services binds `antigravity://` globally to `/Applications/Antigravity.app`. When you sign in from **Pro 2** or **Ultra** and click **"Open Antigravity"** in the browser, macOS normally jumps back to the Primary window.

Our lightweight native Swift **`Antigravity Router.app`** (background-only, 0 MB idle RAM) solves this cleanly via **Dual-Signal Precision Routing**:
1. **Signal 1 · Auth Write Timestamp**: Inspects each sandbox Keychain's `mtime` within the last 15 seconds to pinpoint which instance just persisted a fresh OAuth token;
2. **Signal 2 · macOS Window Z-Order**: Uses `CGWindowListCopyWindowInfo` (**zero TCC permission popups**) to find the frontmost Antigravity PID directly behind your browser;
3. **Precision Activation & Forwarding**: Immediately focuses the exact **Primary / Pro 2 / Ultra** window and forwards any deep-link payload directly to that PID.

---

## 🚀 Quick Start

### Prerequisites
* macOS 14+ (Apple Silicon M1–M4 or Intel)
* Official Google Antigravity installed at `/Applications/Antigravity.app`
* `swiftc` (Xcode Command Line Tools) for the Smart URL Router

### 1. Clone the Repository
```bash
git clone https://github.com/Kongxijun88/antigravity-twousers.git
cd antigravity-twousers
```

### 2. Install Instance 2 (`Antigravity Pro 2`)
```bash
chmod +x install.sh
./install.sh
```

### 3. Install Instance 3 (`Antigravity Ultra`, Optional)
```bash
chmod +x install-ultra.sh
./install-ultra.sh
```

### 4. Install Smart OAuth URL Router (Recommended)
```bash
chmod +x install-router.sh
./install-router.sh
```

> Run `"/Applications/Antigravity Router.app/Contents/MacOS/AntigravityRouter" --status` anytime to inspect live instances and active routing targets.

### 📋 Component Overview

| Component / Instance | Application Path | Isolated Sandbox | CLI / Script |
| :--- | :--- | :--- | :--- |
| **Primary (Pro 1)** | `/Applications/Antigravity.app` | `~/.gemini/` (System default) | — |
| **Instance 2 (Pro 2)** | `/Applications/Antigravity Pro 2.app` | `~/.antigravity-pro2-home/` | `./scripts/launch.sh` |
| **Instance 3 (Ultra)** | `/Applications/Antigravity Ultra.app` | `~/.antigravity-ultra-home/` | `./scripts/launch-ultra.sh` |
| **Smart Router** | `/Applications/Antigravity Router.app` | Stateless (exits immediately) | `./install-router.sh` |

---

## 📂 Project Structure

```text
antigravity-twousers/
├── install.sh                  # One-click installer for Instance 2 (Pro 2)
├── uninstall.sh                # Clean uninstaller for Instance 2
├── install-ultra.sh            # One-click installer for Instance 3 (Ultra)
├── uninstall-ultra.sh          # Clean uninstaller for Instance 3
├── install-router.sh           # Compiles & registers native Swift Smart URL Router
├── uninstall-router.sh         # Restores stock antigravity:// URL scheme handler
├── router/
│   └── AntigravityRouter.swift # Dual-signal macOS URL router source
├── scripts/
│   ├── launch.sh               # Standalone CLI runner for Instance 2
│   └── launch-ultra.sh         # Standalone CLI runner for Instance 3
├── assets/
│   ├── banner.png              # Hero cover banner
│   ├── architecture.png        # Sandbox isolation architecture infographic
│   ├── router-flow.png         # Smart OAuth callback router visual
│   └── workflow-showcase.png   # 24/7 multi-agent relay workflow visual
├── docs/                       # Localized READMEs (EN / JA / KO / ES / FR / PT)
└── LICENSE                     # MIT License
```

---

## 🔄 Multi-Agent Relay Protocol

<p align="center">
  <img src="../assets/workflow-showcase.png" alt="24/7 Multi-Agent Relay Workflow" width="100%">
</p>

Maximize multiple accounts (**2× Pro + 1× Ultra**) using **Tiered Routing + Context-Preserving Handover**:

| Instance | Recommended Role |
| :--- | :--- |
| **Antigravity (Pro 1)** | Daily feature work, UI polish, unit tests, and routine fixes |
| **Antigravity Pro 2** | Seamless relay backup whenever Pro 1 hits its 5-hour quota |
| **Antigravity Ultra** | Complex architecture refactors, deep debugging, and heavy reasoning |

### 2-Step Seamless Handover

**Step 1 — Save & Hand Off (Active Window):**
```text
I will shortly switch to another account to continue this project. Please save all changes, create a clean git commit checkpoint, write a HANDOVER.md summarizing completed work, key decisions, and next tasks, and provide a brief handoff prompt I can paste to the next agent.
```

**Step 2 — Resume Instantly (Next / Ultra Window):**
Open the same repository via `File -> Open Folder` in **Antigravity Pro 2** or **Antigravity Ultra** and paste:
```text
Please read HANDOVER.md and the latest git commit to understand current project state, then continue with the next pending task.
```

---

## 🛡️ Security & Privacy

| Control | Implementation |
| :--- | :--- |
| **Zero Hardcoded Passwords** | Each installation generates a fresh 256-bit cryptographic password locally via `openssl rand -hex 32` |
| **Strict File Permissions** | Both `.keychain_secret` and `login.keychain-db` are locked down to `chmod 600` (owner read/write only) |
| **Host Keychain Untouched** | Subprocess `export HOME` isolates macOS Keychain routing without mutating your system default Keychain |
| **100% Local & Auditable** | Pure open-source Swift, Bash, and Python scripts with zero telemetry or external network calls |

---

## 🗑️ Clean Uninstallation

```bash
# Uninstall Instance 2 (Antigravity Pro 2)
./uninstall.sh

# Uninstall Instance 3 (Antigravity Ultra)
./uninstall-ultra.sh

# Uninstall Smart URL Router & restore stock antigravity:// handler
./uninstall-router.sh
```

**Your original Antigravity app and primary account remain 100% intact.**

---

## ❓ FAQ

<details>
<summary><b>Q1: Can the extra instances access files on my Desktop or Downloads?</b></summary>
<br>
Yes. Each sandbox automatically symlinks <code>~/Desktop</code>, <code>~/Documents</code>, and <code>~/Downloads</code> so you can open any local repository effortlessly.
</details>

<details>
<summary><b>Q2: Will rebooting macOS mix up accounts or sign me out?</b></summary>
<br>
<b>Never.</b> Each instance stores its credentials strictly inside its own isolated home directory and dedicated Keychain.
</details>

<details>
<summary><b>Q3: My browser asks "Open Antigravity Router?" after OAuth — is this expected?</b></summary>
<br>
<b>Yes!</b> That confirms <code>Antigravity Router.app</code> is handling <code>antigravity://</code> callbacks. Check "Always allow" so future logins jump straight back to the exact initiating window.
</details>

<details>
<summary><b>Q4: Can my Mac run all 3 instances smoothly at the same time?</b></summary>
<br>
<b>Yes.</b> All instances share one single app binary on disk. Running memory is ~500MB–800MB per instance (~2GB–2.5GB total for 3 instances), running smoothly on any 16GB+ Apple Silicon Mac.
</details>

<details>
<summary><b>Q5: Are extensions, themes, and settings shared or independent?</b></summary>
<br>
<b>Completely independent.</b> Tip: Give each instance a distinct color theme so you can tell Pro 1, Pro 2, and Ultra apart at a glance!
</details>

---

## 📄 License

Licensed under the [MIT License](../LICENSE). If you find this project helpful, consider giving it a **Star ⭐️**!
