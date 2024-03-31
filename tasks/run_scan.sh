#!/usr/bin/env bash

set -e

declare PT__installdir
echo "Command: ${PT__installdir}/xzscanner/files/detect.sh"
${PT__installdir}/xzscanner/files/detect.sh 2>&1
