FROM kibatic/android-react-native:latest
LABEL maintainer="system@kibatic.com"

RUN echo "Installing Android NDK…"
# get more from `sdkmanager --list` (add '--verbose' to read long package names)
RUN yes | sdkmanager ndk-bundle > /dev/null
