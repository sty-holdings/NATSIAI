#!/bin/bash
#
# This will create the NATS user context
#

set -eo pipefail

# Main function of this script
function create_user_context() {
  local user=$1
  local remote_home_directory=$2
  local home_directory=$3

  # shellcheck disable=SC2029
  if [ "$user" == "SYS" ] || [ "$user" == "sys" ]; then
    display_info "Creating SYS context."
    # shellcheck disable=SC2086
    ssh $IDENTITY $WORKING_AS@$SERVER_INSTANCE_IPV4 "nats context save ${NATS_OPERATOR}_sys --nsc nsc://$NATS_OPERATOR/SYS/sys"
    user=${NATS_OPERATOR}_sys
  else
    # shellcheck disable=SC2086
    ssh $IDENTITY $WORKING_AS@$SERVER_INSTANCE_IPV4 "nats context save $user"
  fi

  # shellcheck disable=SC2155
  export TLS_CA_BUNDLE_FILENAME=$(basename "$TLS_CA_BUNDLE_FQN")
  # shellcheck disable=SC2155
  export TLS_CERT_FILENAME=$(basename "$TLS_CERT_FQN")
  # shellcheck disable=SC2155
  export TLS_CERT_KEY_FILENAME=$(basename "$TLS_CERT_KEY_FQN")

  # shellcheck disable=SC2086
  are_cert_settings_valid $TLS_CA_BUNDLE_FQN $TLS_CERT_FQN $TLS_CERT_KEY_FQN
  # shellcheck disable=SC2154
  if [ "$are_cert_settings_valid_result" == "no" ]; then
    display_info "Creating NON-TLS context file"
    # shellcheck disable=SC2086
    envsubst <../templates/nats.context.template >/tmp/${user}_context.tmp
  else
    # shellcheck disable=SC2086
    display_info "Creating TLS context file"
    # shellcheck disable=SC2086
    envsubst <../templates/nats.context.tls.template >/tmp/${user}_context.tmp
  fi

  # shellcheck disable=SC2086
  scp $IDENTITY /tmp/${user}_context.tmp $WORKING_AS@$SERVER_INSTANCE_IPV4:$remote_home_directory/.config/nats/context/$user.json
  # shellcheck disable=SC2086
  scp $IDENTITY /tmp/${user}_context.tmp $WORKING_AS@$SERVER_INSTANCE_IPV4:$remote_home_directory/.config/nats/context/$user.json.bkup
}

# Test
#export IDENTITY="-i /Users/syacko/.ssh/savup-local-0030"
#export WORKING_AS=savup
#export INSTANCE_DNS_IPV4=154.12.225.56
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
