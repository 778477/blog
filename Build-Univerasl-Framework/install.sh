#!/bin/bash


TEMPLATES_DIR=~/Library/Developer/Xcode/Templates/


if [ ! -d "${TEMPLATES_DIR}" ]
then
    mkdir -p "${TEMPLATES_DIR}"
fi


cp -R ./Univerasl\ Framewrok\ Templates/ "${TEMPLATES_DIR}"

echo "🍺🍺Install Success! Please Restart Your Xcode😊"



