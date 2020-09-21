#!/bin/sh

set -e

FRAMEWORK_NAME=$1
DEVELOPMENT_TEAM=$2

xcodebuild
-target "${FRAMEWORK_NAME}"
-configuration Release
-arch arm64
-arch armv7
-arch armv7s
only_active_arch=no defines_module=yes
-sdk "iphoneos" archive
DEVELOPMENT_TEAM = $DEVELOPMENT_TEAM

xcodebuild
-target "${FRAMEWORK_NAME}"
-configuration Release
-arch x86_64
-arch i386
only_active_arch=no
defines_module=yes
-sdk "iphonesimulator" archive
DEVELOPMENT_TEAM = $DEVELOPMENT_TEAM
