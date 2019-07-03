FROM kibatic/android-react-native:minimal
LABEL maintainer="system@kibatic.com"

# get more from `sdkmanager --list` (add '--verbose' to read long package names)
RUN yes | sdkmanager \
      'build-tools;25.0.3' \
      'build-tools;26.0.3' \
      'build-tools;27.0.3' \
      'build-tools;28.0.3' > /dev/null
