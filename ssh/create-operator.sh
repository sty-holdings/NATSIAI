#!/bin/bash
#
# This will create the NATS operator.
#

set -eo pipefail

# Main function of this script
function create_operator() {
  local keys=$1

  if [ "$keys" == "false" ]; then
    display_info "Creating NSC operator: $NATS_OPERATOR and SYS without keys."
    # shellcheck disable=SC2029
    # shellcheck disable=SC2086
    ssh $IDENTITY $WORKING_AS@$SERVER_INSTANCE_IPV4 "nsc add operator --sys --name $NATS_OPERATOR;"
  else
    display_info "Creating NSC operator: $NATS_OPERATOR and SYS with keys."
    # shellcheck disable=SC2029
    # shellcheck disable=SC2086
    ssh $IDENTITY $WORKING_AS@$SERVER_INSTANCE_IPV4 "nsc add operator --generate-signing-key --sys --name $NATS_OPERATOR;"
    display_info "NSC operator will require signed keys for accounts on $NATS_URL"
    # shellcheck disable=SC2029
    # shellcheck disable=SC2086
    ssh $IDENTITY $WORKING_AS@$SERVER_INSTANCE_IPV4 "nsc edit operator --require-signing-keys --account-jwt-server-url $NATS_URL;"
  fi
}

# Test
#. /Users/syacko/workspace/styh-dev/src/albert/savup-nats/build-deploy/ssh/build_NATS_URL.sh
#export IDENTITY="-i /Users/syacko/.ssh/savup-local-0030"
#export WORKING_AS=savup
#export SERVER_INSTANCE_IPV4=154.12.225.56
#export NATS_OPERATOR=test_1
#build_NATS_URL
#echo "Keys"
#echo
#create_operator 'true'
#export NATS_OPERATOR=test_2
#echo "NO Keys"
#echo
#create_operator 'false'
#create_operator 'false'
