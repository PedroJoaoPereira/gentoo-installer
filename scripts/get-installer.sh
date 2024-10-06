#!/bin/bash

# gets installer from dotfiles repository
wget -qO- https://raw.githubusercontent.com/PedroJoaoPereira/dotfiles/refs/heads/main/.personal/installation-scripts/hosts/${HOST}/installer.sh >${STEPS_DIR}/09-installing-extras.sh

# removes file if empty
[[ ! -s ${STEPS_DIR}/09-installing-extras.sh ]] && rm ${STEPS_DIR}/09-installing-extras.sh
