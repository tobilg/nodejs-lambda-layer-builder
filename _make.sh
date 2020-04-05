#!/usr/bin/env bash

set -e

# Credits for initial version: https://github.com/robertpeteuil/build-lambda-layer-NODEJS

# AWS Lambda Layer Zip Builder for Node libraries
#   This script is executed inside a docker container by the "build_layer.sh" script

scriptname=$(basename "$0")
scriptbuildnum="1.0.0"
scriptbuilddate="2020-04-05"

### Variables
CURRENT_DIR=$(reldir=$(dirname -- "$0"; echo x); reldir=${reldir%?x}; cd -- "$reldir" && pwd && echo x); CURRENT_DIR=${CURRENT_DIR%?x}
NODEJS="node${NODEJS_RUNTIME_VERSION}"
ZIP_FILE="${NAME}_${NODEJS}.zip"

echo "Building layer: ${NAME} for ${NODEJS}"

# Delete build dir
rm -rf /tmp/build

# Create build dir
mkdir -p /tmp/build

# Install requirements
cp /temp/build/package.json /tmp/build
cd /tmp/build
npm i

# Remove unused stuff
echo "Original layer size: $(du -sh . | cut -f1)"
rm package.json
rm package-lock.json
if [[ -f "/temp/build/_clean.sh" ]]; then
    echo "Running custom cleaning script"
    source /temp/build/_clean.sh $PWD
fi
echo "Final layer size: $(du -sh . | cut -f1)"

# Produce output
if [[ "$RAW_MODE" = true ]]; then
    # Copy raw files to layer directory
    rm -rf "${CURRENT_DIR}/layer"
    mkdir -p "${CURRENT_DIR}/layer"
    cp -R /tmp/base/. "${CURRENT_DIR}/layer"
    echo "Raw layer contents have been copied to the 'layer' subdirectory"
else
    # Add files from staging area to zip
    cd /tmp/build
    zip -q -r "${CURRENT_DIR}/${ZIP_FILE}" .
    echo "Zipped layer size: $(ls -s --block-size=1048576 ${CURRENT_DIR}/${ZIP_FILE} | cut -d' ' -f1)M"
fi

echo -e "\n${NAME} layer creation finished"