ARG android_sdk_version
FROM kibatic/android-react-native:${android_sdk_version}
LABEL maintainer="system@kibatic.com"

ARG android_sdk_version
# get more from `sdkmanager --list` (add '--verbose' to read long package names)
RUN yes | sdkmanager \
    'emulator' \
    "system-images;android-${android_sdk_version};default;x86" > /dev/null
