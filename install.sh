#!/bin/bash

# gets this script directory for relative imports
export SCRIPT_ROOT_DIR=$(dirname $(readlink -f $0))
export HOSTS_DIR=${SCRIPT_ROOT_DIR}/hosts
export STEPS_DIR=${SCRIPT_ROOT_DIR}/steps

# gets host setup file, if it exists
export HOST_SETUP=${HOSTS_DIR}/$1.props

# runs installation
if [[ ! -f ${HOST_SETUP} ]]; then
  source ${STEPS_DIR}/00-intro.sh
  source ${STEPS_DIR}/01-configuring-system.sh
else
  source ${STEPS_DIR}/01-configuring-system.sh ${HOST_SETUP}
fi
source ${STEPS_DIR}/02-preparing-disks.sh
source ${STEPS_DIR}/03-installing-stage.sh
source ${STEPS_DIR}/04-chroot.sh
