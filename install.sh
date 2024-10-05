#!/bin/bash

# gets this script directory for relative imports
export SCRIPT_ROOT_DIR=$(dirname $(readlink -f $0))
export HOSTS_DIR=${SCRIPT_ROOT_DIR}/hosts
export SCRIPTS_DIR=${SCRIPT_ROOT_DIR}/scripts
export STEPS_DIR=${SCRIPT_ROOT_DIR}/steps

# reads from arguments
export HOST_DIR=${HOSTS_DIR}/$1
export HOST_INSTALLER=${HOST_DIR}/installer.sh
export HOST_SETUP=${HOST_DIR}/setup.props

# runs installation
if [[ ! -f ${HOST_SETUP} ]]; then
  source ${STEPS_DIR}/00-intro.sh
  source ${STEPS_DIR}/01-configuring-system.sh
else
  source ${STEPS_DIR}/01-configuring-system.sh ${HOST_SETUP}
fi
source ${STEPS_DIR}/02-preparing-disks.sh
source ${STEPS_DIR}/03-installing-stage.sh
if [[ ! -f ${HOST_INSTALLER} ]]; then
  source ${STEPS_DIR}/04-chroot.sh
else
  source ${STEPS_DIR}/04-chroot.sh ${HOST_INSTALLER}
fi
