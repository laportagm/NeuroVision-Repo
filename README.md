# NeuroVis - AI-Powered Neuroanatomy Learning Application

An educational neuroanatomy application built with Godot 4.3 LTS that provides interactive 3D brain exploration for students and AI-assisted teaching tools for educators.

## 🎯 Project Vision

NeuroVis aims to transform neuroanatomy education by providing:
- **Interactive 3D brain models** with detailed anatomical structures
- **AI-powered teacher assistance** using Google Gemini
- **Offline-first design** for accessibility in all environments
- **Privacy-focused** with anonymous usage by default
- **Cross-platform support** for Windows, macOS, and Linux

## 🚀 Getting Started

### Prerequisites

- Git with LFS support
- VS Code or Cursor IDE
- Docker (for DevContainer development)
- Godot 4.3 LTS (if not using DevContainer)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/NeuroVision-Repo.git
   cd NeuroVision-Repo
   ```

2. **Install Git LFS**
   ```bash
   git lfs install
   git lfs pull
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your API keys
   ```

4. **Open in VS Code with DevContainer**
   - Open the project in VS Code
   - When prompted, select "Reopen in Container"
   - Wait for the container to build

5. **Run the setup script**
   ```bash
   ./setup.sh
   ```

## 📁 Project Structure

```
NeuroVision-Repo/
├── .devcontainer/     # Development container configuration
├── .vscode/           # VS Code workspace settings
├── docs/              # Project documentation
├── prompts/           # AI development prompts
├── scripts/           # Build and utility scripts
├── src/               # Source code
│   └── autoload/      # Godot autoload scripts
└── sqlite_mcp_server.db  # Local database
```

## 🛠️ Development Workflow

### Using Claude Code

This project is designed for AI-assisted development using Claude Code:

1. Read `docs/CLAUDE.md` for AI development guidelines
2. Use the prompt templates in `prompts/` for consistent AI interactions
3. Follow the coding standards in `docs/PROJECT_OUTLINE.md`

### Key Development Principles

- **Offline-First**: Core functionality must work without internet
- **Privacy-First**: Anonymous usage by default, optional authentication
- **Accessibility-First**: WCAG AAA compliance for all features
- **Performance-First**: 30+ FPS on minimum hardware (Intel UHD 620)

## 🧪 Testing

Run the test suite:
```bash
./scripts/run_tests.sh
```

## 📦 Building

Build for all platforms:
```bash
./scripts/build/export_all_platforms.sh
```

## 🤝 Contributing

Please read `CONTRIBUTING.md` for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the `LICENSE` file for details.

## 🙏 Acknowledgments

- Built with [Godot Engine](https://godotengine.org/)
- AI assistance by [Claude Code](https://claude.ai/code)
- Educational content validation by neuroanatomy experts

## 📞 Support

For questions or issues:
- Create an issue on GitHub
- Check the documentation in `docs/`
- See troubleshooting guide in `docs/developer_guide/troubleshooting.md`