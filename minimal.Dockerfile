FROM openjdk:8
LABEL maintainer="system@kibatic.com"

ENV ANDROID_SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip" \
    ANT_HOME="/usr/share/ant" \
    MAVEN_HOME="/usr/share/maven" \
    GRADLE_HOME="/usr/share/gradle" \
    ANDROID_HOME="/opt/android" \
    ANDROID_NDK_HOME="/opt/android/ndk-bundle"

ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$ANT_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin:${ANDROID_NDK_HOME}

WORKDIR /opt

# Install some dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update -qq && \
    apt-get install -qq -y wget curl maven ant git gradle libncurses5:i386 libstdc++6:i386 zlib1g:i386 file libpulse0 qt5-default > /dev/null 2>&1

# Download emulator script
RUN wget --quiet --output-document=android-wait-for-emulator https://raw.githubusercontent.com/travis-ci/travis-cookbooks/0f497eb71291b52a703143c5cd63a217c8766dc9/community-cookbooks/android-sdk/files/default/android-wait-for-emulator && \
    chmod +x android-wait-for-emulator

# Install Android SDK tools
RUN mkdir android && cd android && \
    wget --quiet --output-document=tools.zip ${ANDROID_SDK_URL} && \
    unzip -qq tools.zip && \
    rm tools.zip

# Install Node.JS
RUN echo "Installing Node"&&\
    apt-get install -qqq -y gnupg2 &&\
    curl -sL https://deb.nodesource.com/setup_10.x | bash - &&\
    apt-get install -qqq -y nodejs &&\
    # Cleanup
    apt-get purge -qqq -y gnupg2 &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN yes | sdkmanager 'tools' 'platform-tools' > /dev/null

RUN export LD_LIBRARY_PATH=$ANDROID_HOME/emulator/lib64/qt/lib/
