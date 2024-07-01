#!/bin/sh
# <https://xgqt.gitlab.io/spywarewatchdog/articles/tbb.html>

cd "$1"/Browser/ || exit
mkdir unpack
mv omni.ja unpack
cd unpack || exit
unzip omni.ja
cd "$1"/Browser/browser/ || exit
mkdir unpack
mv omni.ja unpack
cd unpack || exit
unzip omni.ja
cd "$1" || exit
find ./Browser/ -type f -print0 | xargs -0 sed -i 's/https\:\/\/firefox\.settings\.services\.mozilla\.com\/v1\/buckets\/main\/collections\/nimbus-desktop-experiments\/records//g'
find ./Browser/ -type f -print0 | xargs -0 sed -i 's/https\:\/\/firefox\.settings\.services\.mozilla\.com\/v1\/buckets\/main-preview\/collections\/search-config\/records//g'
find ./Browser/ -type f -print0 | xargs -0 sed -i 's/https\:\/\/firefox\.settings\.services\.mozilla\.com\/v1\/buckets\/main\/collections\/search-config\/records//g'
find ./Browser/ -type f -print0 | xargs -0 sed -i 's/https\:\/\/firefox\.settings\.services\.mozilla\.com\/v1//g'
find ./Browser/ -type f -print0 | xargs -0 sed -i 's/onecrl\.content-signature\.mozilla\.org//g'
find ./Browser/ -type f -print0 | xargs -0 sed -i 's/remote-settings\.content-signature\.mozilla\.org//g'
find ./Browser/ -type f -print0 | xargs -0 sed -i 's/normandy\.content-signature\.mozilla\.org//g'
cd "$1"/Browser/browser/unpack || exit
rm omni.ja
zip -0DXqr omni.ja ./*
mv omni.ja ..
cd ..
rm -r unpack
cd "$1"/Browser/unpack || exit
rm omni.ja
zip -0DXqr omni.ja ./*
mv omni.ja ..
cd ..
rm -r unpack
cd "$1 || exit" || exit
mkdir -p Browser/distribution/
printf "{\n\"policies\": {\n\"DisableAppUpdate\": true\n}\n}" >Browser/distribution/policies.json
