#!/bin/bash
#
# Description: This will install the NATS HOME export.
#
# Installation:
#   None required
#
# Copyright (c) 2022 STY-Holdings Inc
# All Rights Reserved
#

set -eo pipefail

# Main function of this script
function install_server_NATS_export() {
  echo "Setting NATS_HOME export on the remote server."

#  echo "\$IDENTITY=$IDENTITY"
#  echo "\$WORKING_AS=$WORKING_AS"
#  echo "\$INSTANCE_DNS_IPV4=$INSTANCE_DNS_IPV4"
#  echo "\$WORKING_AS_HOME_DIRECTORY=$WORKING_AS_HOME_DIRECTORY"
#  echo "\$NATS_INSTALL_DIRECTORY=$NATS_INSTALL_DIRECTORY"

  # shellcheck disable=SC2086
  find_string_in_remote_file "$IDENTITY" $WORKING_AS $SERVER_INSTANCE_IPV4 'NATS_HOME' $WORKING_AS_HOME_DIRECTORY/.bash_exports
  # shellcheck disable=SC2154
  if [ "$find_string_in_remote_file_result" == "missing" ]; then
    # shellcheck disable=SC2029
    # shellcheck disable=SC2086
    ssh $IDENTITY $WORKING_AS@$SERVER_INSTANCE_IPV4 "echo export NATS_HOME=$NATS_INSTALL_DIRECTORY >>$WORKING_AS_HOME_DIRECTORY/.bash_exports"
  fi
}

# Test
#export IDENTITY="-i /Users/syacko/.ssh/savup-local-0030"
#export WORKING_AS=savup
#export INSTANCE_DNS_IPV4=154.12.225.56
#export WORKING_AS_HOME_DIRECTORY="/home/$WORKING_AS"
#export NATS_INSTALL_DIRECTORY=/home/NATS
#. /Users/syacko/workspace/styh-dev/src/albert/core/devops/scripts/find-string-in-file.sh
#install_server_nats_export
#install_server_nats_export
