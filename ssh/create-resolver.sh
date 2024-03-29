#!/bin/bash
#
# This will create the NATS resolver file.
#

set -eo pipefail

# Main function of this script
# shellcheck disable=SC2029
function create_resolver() {

  # shellcheck disable=SC2086
  find_remote_file "$IDENTITY" $WORKING_AS $SERVER_INSTANCE_IPV4 $NATS_INSTALL_DIRECTORY 'resolver.conf'
  # shellcheck disable=SC2154
  if [ "$find_remote_file" == "found" ]; then
    echo "Moving existing resolver.conf file to resolver.conf.orig"
    # shellcheck disable=SC2086
    ssh $IDENTITY $WORKING_AS@$SERVER_INSTANCE_IPV4 "mv $NATS_INSTALL_DIRECTORY/includes/resolver.conf $NATS_INSTALL_DIRECTORY/includes/resolver.conf.orig;"
  fi

  echo "Creating NATS resolver configuration file."
  # shellcheck disable=SC2086
  ssh $IDENTITY $WORKING_AS@$SERVER_INSTANCE_IPV4 "mkdir $NATS_INSTALL_DIRECTORY/includes; nsc env -o $NATS_OPERATOR; nsc generate config --nats-resolver --sys-account SYS --config-file $NATS_INSTALL_DIRECTORY/includes/resolver.conf;"
  # shellcheck disable=SC2086
  ssh $IDENTITY $WORKING_AS@$SERVER_INSTANCE_IPV4 "sudo chmod -R 774 $NATS_INSTALL_DIRECTORY/includes; sudo chown -R $NATS_SYSTEM_USER $NATS_INSTALL_DIRECTORY/includes;"

  echo "Editing JWT setting" # This is needed because NSC doesn't support changing the directory setting. I looked at the code and felt this was easier then modifying NSC code.
  # shellcheck disable=SC2086
  ssh $IDENTITY $WORKING_AS@$SERVER_INSTANCE_IPV4 "b=\$(grep -n \"dir: './jwt'\" $NATS_INSTALL_DIRECTORY/includes/resolver.conf | cut -d ':' -f 1); top=\$((b-1)); cat $NATS_INSTALL_DIRECTORY/includes/resolver.conf | head -n \$top > /tmp/nats-resolver-top.tmp"
  # shellcheck disable=SC2086
  ssh $IDENTITY $WORKING_AS@$SERVER_INSTANCE_IPV4 "b=\$(grep -n \"dir: './jwt'\" $NATS_INSTALL_DIRECTORY/includes/resolver.conf | cut -d ':' -f 1); total=\$(wc -l $NATS_INSTALL_DIRECTORY/includes/resolver.conf | echo \$(cut -d ' ' -f 1)); bottom=\$((total-b)); cat $NATS_INSTALL_DIRECTORY/includes/resolver.conf | tail -n \$bottom > /tmp/nats-resolver-bottom.tmp;"
  # shellcheck disable=SC2086
  ssh $IDENTITY $WORKING_AS@$SERVER_INSTANCE_IPV4 "newline=\$(echo \"dir: '$NATS_INSTALL_DIRECTORY/jwt'\"); cat /tmp/nats-resolver-top.tmp > $NATS_INSTALL_DIRECTORY/includes/resolver.conf; echo \$newline >> $NATS_INSTALL_DIRECTORY/includes/resolver.conf; cat /tmp/nats-resolver-bottom.tmp >> $NATS_INSTALL_DIRECTORY/includes/resolver.conf;"
}

# Test
#. /Users/syacko/workspace/styh-dev/src/albert/core/devops/scripts/find-file.sh
#export IDENTITY="-i /Users/syacko/.ssh/savup-local-0030"
#export WORKING_AS=savup
#export INSTANCE_DNS_IPV4=154.12.225.56
#export NATS_INSTALL_DIRECTORY=/home/NATS
#export NATS_OPERATOR=styh
#create_resolver
