FROM mcr.microsoft.com/vscode/devcontainers/cpp:ubuntu-24.04

RUN sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources && \
    apt update && apt install -y \
    git \
    python3 \
    python-is-python3 \
    alsa-utils \
    acl \
    bubblewrap \
    socat \
    libjack-jackd2-dev \
    libasound2-dev \
    libpulse-dev \
    pipewire-audio-client-libraries \
    lsp-plugins-lv2 \
    x42-plugins

RUN ln -fs /usr/share/zoneinfo/Europe/Stockholm /etc/localtime && \
    DEBIAN_FRONTEND=noninteractive apt build-dep -y --no-install-recommends ardour

USER vscode