FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
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
    && rm -rf /var/lib/apt/lists/*

# Install Godot 4.4.1 (headless version for CI/CD)
RUN wget -q -O godot.zip https://downloads.tuxfamily.org/godotengine/4.4/4.4.1/Godot_v4.4.1-stable_linux.x86_64.zip \
    && unzip -q godot.zip -d /tmp \
    && mv /tmp/Godot_v4.4.1-stable_linux.x86_64 /usr/local/bin/godot \
    && chmod +x /usr/local/bin/godot \
    && rm godot.zip

# Install Git LFS
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash \
    && apt-get install -y git-lfs \
    && git lfs install

# Create workspace directory
WORKDIR /workspace