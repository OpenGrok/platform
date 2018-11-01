#!/usr/bin/ksh

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8" 

OPENGROK_BASE="/opengrok"

# Synchronize and reindex everything.
# The number of workers is set to match the Memory of the machine.
# (rather than the number of CPUs ! indexer can get quite big in terms of both RSS/VMEM)
$OPENGROK_BASE/dist/bin/venv/bin/opengrok-sync --indexed --workers 16 \
    --config /opengrok/etc/sync-config.yml

# Refresh the date displayed on the index web page.
# See https://github.com/oracle/opengrok/issues/1670
touch $OPENGROK_BASE/data/timestamp

# Make the new configuration (includes latest repository info) persistent.
# This assumes that UTF-8 packages are installed.
$OPENGROK_BASE/dist/bin/venv/bin/opengrok-projadm \
    -R $OPENGROK_BASE/etc/readonly_configuration.xml -r -b "$OPENGROK_BASE" \
    -c $OPENGROK_BASE/dist/bin/venv/bin/opengrok-config-merge \
    --jar $OPENGROK_BASE/dist/lib/opengrok.jar
