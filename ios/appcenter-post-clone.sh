#!/usr/bin/env bash
#Place this script in project/ios/

# fail if any command fails
set -e
# debug log
set -x

cd ..
git clone -b dev https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:$PATH

flutter doctor

echo "Installed flutter to `pwd`/flutter"

flutter test

if [ "$APPCENTER_BRANCH" == "master" ]
then
    flutter build ios --release --no-codesign
else
    flutter build ios --debug --no-codesign
fi