#!/bin/bash

# gets this script directory for relative imports
export SCRIPT_ROOT_DIR=$(dirname $(readlink -f $0))
export STEPS_DIR=${SCRIPT_ROOT_DIR}/steps
export SCRIPTS_DIR=${SCRIPT_ROOT_DIR}/scripts

# runs installation
source ${STEPS_DIR}/00-intro.sh
source ${STEPS_DIR}/01-setup-system.sh
source ${STEPS_DIR}/02-prepare-disks.sh
source ${STEPS_DIR}/03-stage-setup.sh
source ${STEPS_DIR}/04-chroot.sh
