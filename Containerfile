ARG GODOT_VERSION="4.5.1"
ARG GODOT_RELEASE="stable"
ARG GODOT_PLATFORM="linux.x86_64"
ARG ANDROID_SDK_VERSION="13114758"
ARG JAVA_VERSION=17


FROM docker.io/library/alpine:3.23 AS downloads

ARG GODOT_VERSION
ARG GODOT_RELEASE
ARG GODOT_PLATFORM
ARG ANDROID_SDK_VERSION

RUN apk add --no-cache \
    curl \
    unzip

ARG GODOT_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-${GODOT_RELEASE}"
ARG GODOT_BASE_FILENAME="Godot_v${GODOT_VERSION}-${GODOT_RELEASE}"

WORKDIR /downloads

# download godot
RUN curl -L -O "${GODOT_URL}/${GODOT_BASE_FILENAME}_${GODOT_PLATFORM}.zip" \
    && unzip "${GODOT_BASE_FILENAME}_${GODOT_PLATFORM}.zip" \
    && rm -f "${GODOT_BASE_FILENAME}_${GODOT_PLATFORM}.zip" \
    && mv "${GODOT_BASE_FILENAME}_${GODOT_PLATFORM}" "godot" \
    && ls -lhAF "godot"

# download export templates
RUN echo "${GODOT_URL}/${GODOT_BASE_FILENAME}_export_templates.tpz"
RUN curl -L -O "${GODOT_URL}/${GODOT_BASE_FILENAME}_export_templates.tpz" \
    && unzip "${GODOT_BASE_FILENAME}_export_templates.tpz" \
    && rm -f "${GODOT_BASE_FILENAME}_export_templates.tpz" \
    && ls -lhAF "templates"

# download android SDK
RUN curl -L -O "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip" \
    && unzip "commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip" -d "cmdline-tools" \
    && rm -f "commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip" \
    && ls -lhAF "cmdline-tools"


FROM docker.io/library/ubuntu:22.04

ARG GODOT_VERSION
ARG GODOT_RELEASE
ARG GODOT_PLATFORM
ARG JAVA_VERSION

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=US/Eastern

ENV JAVA_HOME="/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64"
ENV PATH="${PATH}:${JAVA_HOME}/bin"

RUN apt-get update && apt-get install -y --no-install-recommends \
    "openjdk-${JAVA_VERSION}-jdk-headless"

ENV ANDROID_HOME="/usr/lib/android-sdk"
ENV PATH="${PATH}:${ANDROID_HOME}/cmdline-tools/cmdline-tools/bin"

COPY --from=downloads "/downloads/cmdline-tools" "${ANDROID_HOME}/cmdline-tools"

RUN yes | sdkmanager --licenses \
    && sdkmanager \
        "platform-tools" \
        "build-tools;35.0.0" \
        "platforms;android-35" \
        "cmdline-tools;latest" \
        "cmake;3.10.2.4988404" \
        "ndk;28.1.13356709"

ARG ANDROID_DIR="/root/.android"
ARG ANDROID_DEBUG_KEYSTORE="${ANDROID_DIR}/debug.keystore"

RUN echo "Generating Android debug key" \
    && mkdir -p "$ANDROID_DIR" \
    && keytool \
        -genkeypair \
        -alias "androiddebugkey" \
        -keyalg "RSA" \
        -keypass "android" \
        -keystore "$ANDROID_DEBUG_KEYSTORE" \
        -storepass "android" \
        -dname "CN=Android Debug,O=Android,C=US" \
        -validity 36525

COPY --from=downloads "/downloads/godot" "/usr/local/bin/"

RUN godot --headless --editor --quit

RUN for f in "${HOME}"/.config/godot/editor_settings-*.tres; do \
        echo "export/android/android_sdk_path = \"${ANDROID_HOME}\"" >> "$f"; \
    done

ENV GODOT_ANDROID_KEYSTORE_DEBUG_PATH="${ANDROID_DEBUG_KEYSTORE}"
ENV GODOT_ANDROID_KEYSTORE_DEBUG_USER="androiddebugkey"
ENV GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD="android"

COPY entrypoint.sh /entrypoint.sh

VOLUME /project
VOLUME /keys

WORKDIR /project

ENTRYPOINT [ "/entrypoint.sh" ]
