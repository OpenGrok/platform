#!/usr/bin/ksh
#
# Project management (addition/deletion)
#

if (( $# < 2 )); then
	print -u2 "usage: $0 <add|delete> project1 [project2 ..]"
	exit 1
fi

case $1 in
	add)
		cmd="-a"
		shift
		;;
	delete)
		cmd="-d"
		shift
		;;
	*)
		print -u2 "unknown command $1"
		exit 1
		;;
esac

typeset -r OPENGROK_BASE="/opengrok"
typeset -r OPENGROK_VENV_BIN="$OPENGROK_BASE/dist/bin/venv/bin"
typeset -r PROJADM="$OPENGROK_VENV_BIN/opengrok-projadm"
typeset -r SYNC="$OPENGROK_VENV_BIN/opengrok-sync"
typeset -r CONFIG_DIR=$OPENGROK_BASE/etc
typeset -r SYNC_CONF=$CONFIG_DIR/sync-config.yml

if [[ ! -x $PROJADM ]]; then
	print -u2 "$PROJADM is not executable"
	exit 1
fi

# Backup the configuration
typeset -r dataset=$( zfs list -H -o name $CONFIG_DIR )
if [[ -z $dataset ]]; then
	print -u2 "Cannot get dataset for $CONFIG_DIR"
	exit 1
fi
print "Snapshotting dataset with OpenGrok configuration"
zfs snapshot $dataset@`date '+%y-%m-%dT%H:%M:%S'`
if (( $? != 0 )); then
	print -u2 "Failed to backup configuration"
	exit 1
fi

typeset -r ROCONFIG="$CONFIG_DIR/readonly_configuration.xml"
$PROJADM -b "$OPENGROK_BASE" -R "$ROCONFIG" $cmd "$@"
if (( $? != 0 )); then
	print -u2 "Adding of the projects failed"
	exit 1
fi
if [[ $cmd == "-a" ]]; then
	typeset proj_args=""
	for proj in $@; do
		proj_args="$proj_args -P $proj"
	done
	print "Syncing + indexing projects"
	$SYNC -c "$SYNC_CONF" $proj_args
fi

# Store current configuration (so that indexed projects are marked).
# The merge with the read-only configuration is done as a workaround
# for https://github.com/oracle/opengrok/issues/2002
LANG="en_US.UTF-8" LC_ALL="en_US.UTF-8" \
    $PROJADM -b "$OPENGROK_BASE" -r -R "$ROCONFIG" \
    -c $OPENGROK_VENV_BIN/opengrok-config-merge --jar $OPENGROK_BASE/dist/lib/opengrok.jar
