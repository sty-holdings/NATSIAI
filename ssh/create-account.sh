#!/bin/bash
#
# This will create the NATS account
#

set -eo pipefail

# Main function of this script
# shellcheck disable=SC2029
function create_account() {
  local keys=$1

  echo "Creating NSC account: $NATS_ACCOUNT"
  if [ "$keys" == "false" ]; then
    ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "nsc add account $NATS_ACCOUNT;"
  else
    ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "nsc add account $NATS_ACCOUNT;"
    echo "NSC account will require signed keys for accounts on $NATS_URL"
    ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "nsc edit account $NATS_ACCOUNT --sk generate;"
  fi
}

# Test
#. /Users/syacko/workspace/styh-dev/src/albert/savup-nats/build-deploy/ssh/build_NATS_URL.sh
#export IDENTITY="-i /Users/syacko/.ssh/savup-local-0030"
#export WORKING_AS=savup
#export INSTANCE_DNS_IPV4=154.12.225.56
#export NATS_ACCOUNT=test_1
#build_NATS_URL
#echo "Keys"
#echo
#create_account 'true'
#export NATS_ACCOUNT=test_2
#echo "NO Keys"
#echo
#create_account 'false'
#create_account 'false'