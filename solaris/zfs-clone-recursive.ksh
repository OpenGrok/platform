#!/usr/bin/ksh

# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# See LICENSE.txt included in this distribution for the specific
# language governing permissions and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at LICENSE.txt.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END

#
# Recursively clone zfs dataset, i.e. including sub-datasets, into new dataset
# with the specified postfix appended to the new dataset name.
# It assumes that all the datasets have a snapshot with given name.
#

if (( $# != 3 )); then
	print -u2 "usage: $0 <dataset> <dataset_postfix> <snapshot_name>"
	exit 1
fi

readonly top_level_dset="$1"
readonly postfix="$2"
readonly snapshot_name="$3"

# zfs clone is not recursive - does not create sub-datasets
# NOTE: the sorting will help to correctly create descendent datasets
zfs list -t snapshot -H -o name -r $top_level_dset | sort -r | \
    grep '@upgrade$' | while read snap
do
	dst=${top_level_dset}-${postfix}${snap#$top_level_dset}
	zfs clone $snap ${dst%%@$snapshot_name}
done
