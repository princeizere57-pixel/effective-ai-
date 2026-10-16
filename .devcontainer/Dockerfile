FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG FLUTTER_CHANNEL=stable
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${PATH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl git unzip xz-utils zip libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter and give the codespace user ownership so `flutter` can update its cache.
RUN git clone --depth 1 --branch ${FLUTTER_CHANNEL} https://github.com/flutter/flutter.git ${FLUTTER_HOME} \
    && chown -R vscode:vscode ${FLUTTER_HOME}

USER vscode
RUN flutter config --no-analytics --enable-web \
    && flutter precache --web \
    && flutter --version
