# NeuroVision DevContainer Setup

This devcontainer provides a complete development environment for the NeuroVision educational platform.

## Features

- **Godot 4.4.1** - Full engine with export templates
- **GDScript Tools** - Linting, formatting, and language server
- **Python Development** - For testing and scripting
- **GPU Support** - Hardware acceleration for 3D rendering
- **VS Code Extensions** - Pre-configured for Godot development
- **MCP Integration** - Model Context Protocol servers

## Usage

1. **Open in DevContainer**:
   - Open VS Code
   - Install "Dev Containers" extension
   - Press F1 → "Dev Containers: Open Folder in Container"
   - Select the NeuroVision-Repo folder

2. **Wait for Setup**:
   - Container will build (first time ~5 minutes)
   - Extensions will install automatically
   - Post-create script configures environment

3. **Start Development**:
   - Godot projects open automatically
   - Language server connects on port 6008
   - GPU acceleration enabled (if available)

## Port Forwarding

- **6007**: Godot Editor
- **6008**: GDScript Language Server
- **6009**: Debug Adapter

## Included Tools

- **gdformat**: GDScript formatter
- **gdtoolkit**: GDScript linting
- **pytest**: Python testing
- **git-lfs**: Large file support
- **GitHub CLI**: PR management

## Troubleshooting

### GPU Not Working
```bash
# Check GPU availability
nvidia-smi  # or
glxinfo | grep "OpenGL renderer"
```

### Language Server Issues
```bash
# Restart language server
pkill -f "godot.*--lsp"
```

### Permission Errors
```bash
# Fix workspace permissions
sudo chown -R vscode:vscode /workspace
```