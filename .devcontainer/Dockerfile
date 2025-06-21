# Use Ubuntu 22.04 LTS as base for stability
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV GODOT_VERSION=4.4.1
ENV GODOT_PATH=/usr/local/bin/godot

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Build essentials
    build-essential \
    cmake \
    pkg-config \
    # Network tools
    wget \
    curl \
    ca-certificates \
    # Compression tools
    unzip \
    zip \
    # Python development
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    # Godot dependencies
    libxcursor1 \
    libxinerama1 \
    libxrandr2 \
    libxi6 \
    libgl1 \
    libglu1-mesa \
    libx11-6 \
    libxext6 \
    libxfixes3 \
    libxrender1 \
    libasound2 \
    libpulse0 \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    # Graphics and GPU support
    mesa-utils \
    vulkan-tools \
    libvulkan1 \
    libvulkan-dev \
    # Performance monitoring
    htop \
    iotop \
    sysstat \
    # Development tools
    git \
    git-lfs \
    vim \
    nano \
    jq \
    # Accessibility testing tools
    at-spi2-core \
    && rm -rf /var/lib/apt/lists/*

# Install optional packages (may not be available in all environments)
RUN apt-get update && apt-get install -y libopencv-dev || true && rm -rf /var/lib/apt/lists/*

# Install Git LFS
RUN git lfs install --system

# Install Godot 4.4.1 from GitHub releases
RUN wget --progress=dot:mega -O godot.zip https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip \
    && unzip -q godot.zip -d /tmp \
    && mv /tmp/Godot_v${GODOT_VERSION}-stable_linux.x86_64 ${GODOT_PATH} \
    && chmod +x ${GODOT_PATH} \
    && rm godot.zip

# Install Godot export templates
RUN wget --progress=dot:mega -O templates.tpz https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_export_templates.tpz \
    && mkdir -p /opt/godot/export_templates/${GODOT_VERSION}.stable \
    && unzip -q templates.tpz -d /opt/godot/export_templates/${GODOT_VERSION}.stable \
    && rm templates.tpz

# Install Python packages for development and testing
RUN pip3 install --upgrade pip setuptools wheel && \
    pip3 install \
    # GDScript development
    gdtoolkit==4.* \
    # Python formatting and linting
    black \
    pylint \
    mypy \
    flake8 \
    # Testing frameworks
    pytest \
    pytest-cov \
    pytest-xdist \
    # Data analysis for educational metrics
    numpy \
    pandas \
    matplotlib \
    scikit-learn \
    # Performance profiling
    memory-profiler \
    # Documentation
    sphinx \
    sphinx-rtd-theme

# Install Node.js for MCP servers and modern tooling
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g \
    npm-check-updates \
    && rm -rf /var/lib/apt/lists/*

# Create directories for Godot configuration
RUN mkdir -p /home/vscode/.config/godot \
    && mkdir -p /home/vscode/.cache/godot \
    && mkdir -p /home/vscode/.local/share/godot/export_templates

# Copy export templates to user directory
RUN cp -r /opt/godot/export_templates/* /home/vscode/.local/share/godot/export_templates/

# Set up proper permissions
RUN chown -R vscode:vscode /home/vscode/.config \
    && chown -R vscode:vscode /home/vscode/.cache \
    && chown -R vscode:vscode /home/vscode/.local

# Create workspace directory
WORKDIR /workspace

# Switch to non-root user
USER vscode

# Set up Python virtual environment for user
RUN python3 -m venv /home/vscode/.venv \
    && /home/vscode/.venv/bin/pip install --upgrade pip

# Add virtual environment to PATH
ENV PATH="/home/vscode/.venv/bin:${PATH}"

# Health check for container
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD godot --version || exit 1

# Labels for container metadata
LABEL maintainer="Gage LaPorta"
LABEL project="NeuroVision Educational Platform"
LABEL version="2.1.0"
LABEL description="Development container for NeuroVision medical education platform with Godot 4.4.1"