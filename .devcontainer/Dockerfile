FROM mcr.microsoft.com/vscode/devcontainers/cpp:ubuntu-24.04

RUN sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources && \
    apt update && apt install -y git python3 python-is-python3 alsa-utils acl

RUN ln -fs /usr/share/zoneinfo/Europe/Stockholm /etc/localtime && \
    DEBIAN_FRONTEND=noninteractive apt build-dep -y --no-install-recommends ardour

RUN groupmod -g 1001 vscode && \
    usermod -u 1001 -g 1001 vscode

ARG REMOTE_USER
ARG REMOTE_UID
ARG REMOTE_GID
RUN addgroup --gid ${REMOTE_GID} ${REMOTE_USER} && \
    adduser --disabled-password --gecos "" --uid ${REMOTE_UID} --gid ${REMOTE_GID} ${REMOTE_USER} && \
    mkdir -p /home/${REMOTE_USER} && \
    chown -R ${REMOTE_UID}:${REMOTE_GID} /home/${REMOTE_USER}

RUN apt-get update && \
    apt-get install -y sudo && \
    echo ${REMOTE_USER} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${REMOTE_USER} && \
    chmod 0440 /etc/sudoers.d/${REMOTE_USER}

ENV HOME=/home/${REMOTE_USER}

USER ${REMOTE_USER}
