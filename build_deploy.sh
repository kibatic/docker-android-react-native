#!/bin/bash

# abort on errors and on unset variables
set -e -o nounset

BASEIMAGE="kibatic/android-react-native"
SDKS=$(echo {28..21})
LATEST_SDKS=$(echo {28..26})
LATEST_PACKAGES=''; for SDK in $LATEST_SDKS; do LATEST_PACKAGES="platforms;android-${SDK} $LATEST_PACKAGES"; done

echo "SDKS = $SDKS"
echo "LATEST_SDKS = $LATEST_SDKS"
echo "LATEST_PACKAGES = $LATEST_PACKAGES"

docker login --username $DOCKER_USERNAME --password $DOCKER_PASSWORD

build_deploy_minimal() {
    echo "Building 'minimal' image…"
    docker build --tag $BASEIMAGE:minimal --file minimal.Dockerfile .
    docker push $BASEIMAGE:minimal
    echo
}

build_deploy_base() {
    echo "Building 'base' image…"
    docker build --tag $BASEIMAGE:base --file base.Dockerfile .
    docker push $BASEIMAGE:base
    echo
}

build_deploy_base_ndk() {
    echo "Building 'base-ndk' image…"
    docker build --tag $BASEIMAGE:base-ndk --file base-ndk.Dockerfile .
    docker push $BASEIMAGE:base-ndk
    echo
}

build_deploy_latest() {
    echo "Building 'latest' image…"
    docker build --tag $BASEIMAGE:latest --build-arg "latest_packages=${LATEST_PACKAGES}" --file latest.Dockerfile .
    docker push $BASEIMAGE:latest
    echo
}

build_deploy_latest_ndk() {
    echo "Building 'latest-ndk' image…"
    docker build --tag $BASEIMAGE:latest-ndk --file latest-ndk.Dockerfile .
    docker push $BASEIMAGE:latest-ndk
    echo
}

build_deploy_sdk_and_system() {
    sdk=$1

    echo "Building '$sdk' image…"
    docker build --tag $BASEIMAGE:$sdk --build-arg android_sdk_version=$sdk --file sdk.Dockerfile .
    echo "Pushing '$sdk' image…"
    docker push $BASEIMAGE:$sdk
    echo

    echo "Building '$sdk-system' image…"
    docker build --tag $BASEIMAGE:$sdk-system --build-arg android_sdk_version=$sdk --file sdk-system.Dockerfile .
    echo "Pushing '$sdk-system' image…"
    docker push $BASEIMAGE:$sdk-system
    echo

    echo "Deleting images '$sdk' and '$sdk-system'"
    docker rmi $BASEIMAGE:$sdk $BASEIMAGE:$sdk-system
}

build_deploy_minimal
build_deploy_base
build_deploy_latest
build_deploy_base_ndk
build_deploy_latest_ndk

# remove some old images to save space on Travis CI
docker rmi \
    $BASEIMAGE:minimal \
    $BASEIMAGE:latest \
    $BASEIMAGE:base-ndk \
    $BASEIMAGE:latest-ndk

# build all sdk + system variants (in parallel because TravisCI has a 50m timeout)
export -f build_deploy_sdk_and_system
SHELL=$(type -p bash) parallel -j 2 --keep-order --line-buffer echo Building SDK {}\; build_deploy_sdk_and_system {} ::: $SDKS
