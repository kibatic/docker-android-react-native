FROM kibatic/android-react-native:base
LABEL maintainer="system@kibatic.com"

ARG latest_packages
RUN echo "Installing ${latest_packages}…"
# get more from `sdkmanager --list` (add '--verbose' to read long package names)
RUN yes | sdkmanager ${latest_packages} > /dev/null
