#!/bin/bash
#for use: 构建全架构的iOS静态库
#author: guomiaoyou
#version: 1.0
#history:


set -e
set +u
### Avoid recursively calling this script.
if [[ $UF_MASTER_SCRIPT_RUNNING ]]
then
    exit 0
fi
set -u
export UF_MASTER_SCRIPT_RUNNING=1

### Constants.
FRAMEWORK_TARGET=${PROJECT_NAME}
FRAMEWORK_VERSION="1.0"
UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-universal
# temporary local project build folder
IPHONE_DEVICE_FRAMEWORK=./build/${CONFIGURATION}-iphoneos/${FRAMEWORK_TARGET}.framework
IPHONE_SIMULATOR_FRAMEWORK=./build/${CONFIGURATION}-iphonesimulator/${FRAMEWORK_TARGET}.framework


### Functions
## List files in the specified directory, storing to the specified array.
#
# @param $1 The path to list
# @param $2 The name of the array to fill
#
##
list_files (){
    filelist=$(ls "$1")
    while read line
    do
        eval "$2[\${#$2[*]}]=\"\$line\""
    done <<< "$filelist"
}

clean_up_build (){
    if [ -d ./build ]
    then
        rm -rf ./build/
    fi
}

clean_up_univerasl (){
    if [ -d "${UNIVERSAL_OUTPUTFOLDER}" ]
    then
        rm -rf "${UNIVERSAL_OUTPUTFOLDER}"
    fi
    mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"
}


clean_up_build
xcodebuild -configuration "${CONFIGURATION}" -target "${FRAMEWORK_TARGET}" -sdk iphoneos -arch armv7 -arch armv7s -arch arm64 clean $ACTION
xcodebuild -configuration "${CONFIGURATION}" -target "${FRAMEWORK_TARGET}" -sdk iphonesimulator -arch x86_64 -arch i386 clean $ACTION

clean_up_univerasl
cp -R "${IPHONE_DEVICE_FRAMEWORK}" "${UNIVERSAL_OUTPUTFOLDER}"
lipo -create "${IPHONE_DEVICE_FRAMEWORK}/${FRAMEWORK_TARGET}" "${IPHONE_SIMULATOR_FRAMEWORK}/${FRAMEWORK_TARGET}" -output "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_TARGET}.framework/${FRAMEWORK_TARGET}"



### Create standard structure for framework.
# If we don't have "Info.plist -> Versions/Current/Resources/Info.plist", we may get error when use this framework.
# MyFramework.framework
# |-- MyFramework -> Versions/Current/MyFramework
# |-- Headers -> Versions/Current/Headers
# |-- Resources -> Versions/Current/Resources
# |-- Info.plist -> Versions/Current/Resources/Info.plist
# `-- Versions
#     |-- A
#     |   |-- MyFramework
#     |   |-- Headers
#     |   |   `-- MyFramework.h
#     |   `-- Resources
#     |       |-- Info.plist
#     |       |-- MyViewController.nib
#     |       `-- en.lproj
#     |           `-- InfoPlist.strings
#     `-- Current -> A


mkdir -p "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_TARGET}.framework/Versions/${FRAMEWORK_VERSION}/"
mv "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_TARGET}.framework/${FRAMEWORK_TARGET}" "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_TARGET}.framework/Versions/${FRAMEWORK_VERSION}/"
mv "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_TARGET}.framework/Headers" "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_TARGET}.framework/Versions/${FRAMEWORK_VERSION}/"
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_TARGET}.framework/Resources"
declare -a UF_FILE_LIST
list_files "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_TARGET}.framework/" UF_FILE_LIST
for file_name in "${UF_FILE_LIST[@]}"
do
if [[ "${file_name}" == "Info.plist" ]] || [[ "${file_name}" =~ .*\.lproj$ ]]
then
    mv "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_TARGET}.framework/${file_name}" "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_TARGET}.framework/Resources/"
fi
done
mv "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_TARGET}.framework/Resources" "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_TARGET}.framework/Versions/${FRAMEWORK_VERSION}/"
ln -sfh "Versions/Current/Resources/Info.plist" "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_TARGET}.framework/Info.plist"
ln -sfh "${FRAMEWORK_VERSION}" "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_TARGET}.framework/Versions/Current"
ln -sfh "Versions/Current/${FRAMEWORK_TARGET}" "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_TARGET}.framework/${FRAMEWORK_TARGET}"
ln -sfh "Versions/Current/Headers" "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_TARGET}.framework/Headers"
ln -sfh "Versions/Current/Resources" "${UNIVERSAL_OUTPUTFOLDER}/${FRAMEWORK_TARGET}.framework/Resources"


open "${UNIVERSAL_OUTPUTFOLDER}"
clean_up_build