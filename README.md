<img src="logo-text.png" alt="Cockpit Agent Logo" width="450" />

### An AI-powered terminal assistant plugin for [Cockpit](https://cockpit-project.org/), the web-based Linux server management interface.

[![Cockpit Plugin](https://img.shields.io/badge/Cockpit-Plugin-E00?style=flat-square&logo=linux&logoColor=white)](https://cockpit-project.org/)
[![Version](https://img.shields.io/badge/Version-1.0.0-8A2BE2?style=flat-square)](package.json)
[![License](https://img.shields.io/badge/License-LGPL--2.1-555555?style=flat-square)](LICENSE)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.9-3178C6?style=flat-square&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![React](https://img.shields.io/badge/React-18.3-61DAFB?style=flat-square&logo=react&logoColor=black)](https://react.dev/)
[![UI-PatternFly](https://img.shields.io/badge/UI-PatternFly-0066CC?style=flat-square&logo=redhat&logoColor=white)](https://www.patternfly.org/)

[🇨🇳 **中文**](README.zh-CN.md) | 🌐 **English**

## Features

- 🤖 **Multi-Provider AI Support** - Choose between top-tier models from OpenAI, Google Gemini, or compatible providers to suit your specific administration needs and budget.
- ⚡ **Autonomous Agentic Control** - Let the AI handle complex workflows by executing sequences of commands, analyzing outputs, and iterating until your goal is seamlessly achieved.
- 🛡️ **Intelligent Safety Controls** - Execute commands with confidence using customizable risk-based safety modes that prevent accidental or malicious system changes.
- 🔒 **Automatic Secret Protection** - Keep your sensitive data secure with automatic, on-the-fly detection and redaction of passwords, API keys, and private tokens.
- 💻 **Interactive Browser Terminal** - Interact directly with your server through a fully-featured terminal environment that natively supports interactive tools like vim, ssh, and sudo.

---

## Demo

https://github.com/user-attachments/assets/b480255c-60fb-48a2-ac13-9d84bee8d4a2

---

## Screenshots

### 1. Dashboard & Quick Actions
The agent landing screen provides interactive shortcuts to get started instantly with standard server operations.
![Dashboard UI](homescreen.png)

### 2. Autonomous Command Execution
A real-time, side-by-side view showing the AI executing disk partition checks, parsing results, and formatting a clear storage summary—all while syncing live outputs with a fully interactive terminal.
![Agent Execution UI](inuse.png)

## Installation

### ⚡ Quick System-Wide Installation (Recommended)

No Node.js, npm, or compilation is required! You can install the pre-compiled plugin directly onto your server with a single command:

```bash
curl -sSL https://raw.githubusercontent.com/ShaoRou459/CockpitServerAI/master/install.sh | sudo bash
```

This installer script will:
1. Query the GitHub API for the latest release tag.
2. Download the pre-compiled distribution bundle (`cockpit-ai-agent-dist.tar.xz`).
3. Safely install the files under `/usr/share/cockpit/cockpit-ai-agent` and set standard system-wide permissions.

#### Installation for a Specific User (Non-Root)
If you don't have root privileges or want to install it only for your current user, run the script without `sudo`:
```bash
curl -sSL https://raw.githubusercontent.com/ShaoRou459/CockpitServerAI/master/install.sh | bash
```
This will automatically target your local user path: `~/.local/share/cockpit/cockpit-ai-agent`.

## Security & Privacy

Since this tool has direct access to your server, we've built in multiple layers of security and privacy protections:

### 🛡️ Local & Private AI Options
You can configure the agent to use local AI models (via Ollama, vLLM, etc.) ensuring that your server's data never leaves your internal network.

### 🔒 Automatic Secret Redaction
The agent actively scans all command outputs and automatically redacts sensitive information on the fly. Passwords, API keys, and private tokens are replaced with referenceable placeholders (e.g., `<SECRET_1>`) before being sent to the AI provider. The AI can still write commands using these placeholders, and the agent will safely substitute the real secrets back in right before execution—meaning your credentials stay strictly local while the AI still gets the job done.

### 🚦 Risk Levels & YOLO Mode
Every generated command is evaluated for risk before execution. Users can choose from multiple execution modes (Paranoid, Cautious, Moderate, YOLO, and Full YOLO) depending on their security preferences:

![Mode Chooser](modechooser.png)

| Level | Examples | Default Behavior |
|-------|----------|------------------|
| 🟢 **Low** | `ls`, `cat`, `df`, `ps` | Auto-executed in YOLO mode |
| 🟡 **Medium** | `systemctl restart`, `apt install` | Always requires approval |
| 🔴 **High** | Config changes, user management | Always requires approval |
| ☠️ **Critical** | `rm -rf /`, disk formats, fork bombs | **Blocked entirely** by the internal Command Blocklist |

By default, **all** commands require explicit user approval. You can optionally enable **YOLO Mode** in the settings to bypass approval for **Low** risk commands.

### 📝 Audit Logging
Every command executed by the agent is logged, providing a clear paper trail of all system modifications.

## Configuration

1. Access Cockpit in your browser (usually `https://your-server:9090`)
2. Navigate to **AI Agent** in the sidebar
3. Click the ⚙️ settings button
4. Configure your AI provider:

| Provider | API Key Source | Notes |
|----------|---------------|-------|
| **OpenAI** | [platform.openai.com](https://platform.openai.com/api-keys) | Supports GPT-5.5, GPT-4o, o3-mini, etc. |
| **Google Gemini** | [AI Studio](https://makersuite.google.com/app/apikey) | Supports Gemini 3.5 Flash, 3.1 Pro, etc. |
| **Custom** | Your provider | Any OpenAI-compatible API |

## Usage

### Basic Commands

Simply type what you want to do in natural language:

- "Check disk space usage"
- "Show me the last 50 lines of /var/log/syslog"
- "Restart nginx"
- "What services are failing?"
- "Install htop"

## Architecture

![Architecture Diagram](architecture.png)

## 🛠️ Development & Source Setup

If you want to contribute, modify the code, or build the project from source, use the steps below:

### Prerequisites
- Cockpit installed on your Linux server
- Node.js 18+
- npm

### Build from Source
```bash
# Clone the repository
git clone https://github.com/ShaoRou459/CockpitServerAI.git
cd CockpitServerAI

# Install dependencies
npm install

# Build the plugin
npm run build

# Link for development (symlink to your user's local cockpit directory)
mkdir -p ~/.local/share/cockpit
ln -s $(pwd)/dist ~/.local/share/cockpit/cockpit-ai-agent

# Restart Cockpit or refresh your browser
```

### Watch Mode (Development)
```bash
npm run watch
```
This will automatically rebuild on file changes.

### Production Build
```bash
NODE_ENV=production npm run build
```

### Manual System-Wide Installation
If you want to build from source and manually copy the build to the system directory:
```bash
sudo cp -r dist /usr/share/cockpit/cockpit-ai-agent
```

## Project Structure

```
cockpit-ai-agent/
├── src/
│   ├── app.tsx                 # Main application component
│   ├── index.tsx               # Entry point
│   ├── app.scss                # Custom styles
│   ├── components/
│   │   ├── ChatPanel.tsx       # Chat interface
│   │   ├── TerminalView.tsx    # xterm.js terminal
│   │   ├── SettingsModal.tsx   # Configuration modal
│   │   └── ApprovalModal.tsx   # Command approval dialog
│   └── lib/
│       ├── ai-client.ts        # Multi-provider AI client
│       ├── agent.ts            # Agent controller
│       ├── settings.ts         # Settings management
│       └── types.ts            # TypeScript types
├── dist/                       # Built plugin (generated)
├── package.json
├── build.js                    # esbuild configuration
└── README.md
```


## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the LGPL-2.1 License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Cockpit Project](https://cockpit-project.org/) for the excellent server management platform
- [PatternFly](https://www.patternfly.org/) for the React component library
- [xterm.js](https://xtermjs.org/) for terminal emulation
