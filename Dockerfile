FROM openjdk:8-jdk

MAINTAINER Fred Cox "mcfedr@gmail.com"

ENV ANDROID_EMULATOR_DEPS "file qt5-default"

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs expect $ANDROID_EMULATOR_DEPS \
    && apt-get autoclean

# Install the SDK
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN cd /opt \
    && wget --output-document=android-sdk.zip --quiet $ANDROID_SDK_URL \
    && unzip android-sdk.zip -d android-sdk-linux \
    && rm -f android-sdk.zip \
    && chown -R root:root android-sdk-linux

ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${PATH}

# Install custom tools
COPY tools /opt/tools
ENV PATH /opt/tools:${PATH}
RUN license_accepter

# Install Android platform and things
ENV ANDROID_PLATFORM_VERSION 28
ENV ANDROID_BUILD_TOOLS_VERSION 28.0.3
ENV ANDROID_EXTRA_PACKAGES "build-tools;28.0.0" "build-tools;28.0.1" "build-tools;28.0.2"
ENV ANDROID_REPOSITORIES "extras;android;m2repository" "extras;google;m2repository"
ENV ANDROID_CONSTRAINT_PACKAGES "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.0"
ENV ANDROID_EMULATOR_PACKAGE "system-images;android-$ANDROID_PLATFORM_VERSION;google_apis_playstore;x86_64"
RUN android-accept-licenses "sdkmanager --verbose \"platform-tools\" \"emulator\" \"platforms;android-$ANDROID_PLATFORM_VERSION\" \"build-tools;$ANDROID_BUILD_TOOLS_VERSION\" $ANDROID_EXTRA_PACKAGES $ANDROID_REPOSITORIES $ANDROID_CONSTRAINT_PACKAGES $ANDROID_EMULATOR_PACKAGE"
RUN android-avdmanager-create "avdmanager create avd --package \"$ANDROID_EMULATOR_PACKAGE\" --name test --abi \"google_apis_playstore/x86_64\""
ENV PATH ${ANDROID_HOME}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}:${PATH}

# Fix for emulator detect 64bit
ENV SHELL /bin/bash
# https://www.bram.us/2017/05/12/launching-the-android-emulator-from-the-command-line/
ENV PATH $ANDROID_HOME/emulator:$PATH

# Install upload-apk helper
RUN npm install -g xcode-build-tools
