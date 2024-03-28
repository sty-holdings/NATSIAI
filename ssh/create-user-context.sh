#!/bin/bash
#
# This will create the NATS user context
#

set -eo pipefail

# Main function of this script
function create_user_context() {
  local user=$1
  local home_directory=$2

  # shellcheck disable=SC2029
  if [ "$user" == "SYS" ] || [ "$user" == "sys" ]; then
    ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "nats context save ${NATS_OPERATOR}_sys --nsc nsc://$NATS_OPERATOR/SYS/sys"
    user=${NATS_OPERATOR}_sys
  else
    ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "nats context save $user"
  fi

  are_cert_settings_valid
  # shellcheck disable=SC2154
  if [ "$are_cert_settings_valid_result" == "no" ]; then
    echo "Creating NON-TLS context file"
    envsubst <$TEMPLATE_DIRECTORY/nats.context.template >/tmp/${user}_context.tmp
  else
    echo "Creating TLS context file"
    envsubst <$TEMPLATE_DIRECTORY/nats.context.tls.template >/tmp/${user}_context.tmp
  fi

  scp $IDENTITY /tmp/${user}_context.tmp $WORKING_AS@$INSTANCE_DNS_IPV4:$home_directory/.config/nats/context/$user.json
  scp $IDENTITY /tmp/${user}_context.tmp $WORKING_AS@$INSTANCE_DNS_IPV4:$home_directory/.config/nats/context/$user.json.bkup
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
