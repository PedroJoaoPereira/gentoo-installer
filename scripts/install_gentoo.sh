#!/bin/sh

# format disks
[ "$INSTALLATION_FORMAT" = true ] && . $THIS_DIR/prepare_disks/format_disk.sh || echo Skip formatting disk...
