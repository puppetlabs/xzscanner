#!/usr/bin/env bash

set -e

declare PT__installdir
source "$PT__installdir/bash_task_helper/files/task_helper.sh"

result=$(${PT__installdir}/xzscanner/files/detect.sh 2>&1)
task-output-json "vulnerable?" $result
