FROM mcr.microsoft.com/vscode/devcontainers/cpp:ubuntu-24.04

RUN sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources && \
    apt update && apt install -y git python3 python-is-python3

RUN ln -fs /usr/share/zoneinfo/Europe/Stockholm /etc/localtime && \
    DEBIAN_FRONTEND=noninteractive apt build-dep -y --no-install-recommends ardour

ARG CWD
ENV CWD=$CWD

COPY build.sh .

USER 1000
CMD cd $CWD && /build.sh
