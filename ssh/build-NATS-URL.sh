#!/bin/bash
#
# This will build the NATS URL
#

set -eo pipefail

# Main function of this script
function build_NATS_URL() {
  if [ -z "$NATS_PORT" ]; then
    export NATS_URL="nats://$INSTANCE_DNS_IPV4:4222"
  else
    export NATS_URL="nats://$INSTANCE_DNS_IPV4:$NATS_PORT"
  fi
}

# Test
#export NATS_PORT
#export INSTANCE_DNS_IPV4='0.0.0.0'
#build_NATS_URL
#echo "TEST \$INSTANCE_DNS_IPV4=$INSTANCE_DNS_IPV4"
#export CA_BUNDLE_FILENAME="populated"
#export CERT_FILENAME="populated"
#export CERT_KEY_FILENAME="populated"
#export NATS_PORT=5555
#export INSTANCE_DNS_IPV4='0.0.0.0'
#build_NATS_URL
#echo "TEST \$INSTANCE_DNS_IPV4=$INSTANCE_DNS_IPV4"
