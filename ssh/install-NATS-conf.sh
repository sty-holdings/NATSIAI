#!/bin/bash
#
# This will create the NATS conf file.
#

set -eo pipefail

# Main function of this script
function install_NATS_conf() {
  local add_tls=$1

  if [ "$add_tls" == "false" ]; then
    echo "Installing NON-TLS NATS configuration file."
    envsubst <$TEMPLATE_DIRECTORY/nats-conf.template >/tmp/nats-conf-top.tmp
    envsubst <$TEMPLATE_DIRECTORY/nats-conf-websocket.template >/tmp/nats-conf-websocket.tmp
  else
    echo "Installing TLS NATS configuration file."
    envsubst <$TEMPLATE_DIRECTORY/nats-conf-tls.template >/tmp/nats-conf-top.tmp
    envsubst <$TEMPLATE_DIRECTORY/nats-conf-websocket-tls.template >/tmp/nats-conf-websocket.tmp
  fi

  if [ -n "$NATS_WEBSOCKET_PORT" ]; then
    cat /tmp/nats-conf-top.tmp > /tmp/nats-conf.tmp
    cat /tmp/nats-conf-websocket.tmp >> /tmp/nats-conf.tmp
  else
    cp /tmp/nats-conf-top.tmp /tmp/nats-conf.tmp
  fi

    scp $IDENTITY /tmp/nats-conf.tmp $WORKING_AS@$INSTANCE_DNS_IPV4:$NATS_INSTALL_DIRECTORY/nats.conf
    ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "sudo chown -R $NATS_SYSTEM_USER $NATS_INSTALL_DIRECTORY/nats.conf; sudo chmod -R 774 $NATS_INSTALL_DIRECTORY/nats.conf;"
}

# Test
#export IDENTITY="-i /Users/syacko/.ssh/savup-local-0030"
#export WORKING_AS=savup
#export INSTANCE_DNS_IPV4=154.12.225.56
#export NATS_WEBSOCKET_PORT
#export ROOT_DIRECTORY=/Users/syacko/workspace/styh-dev/src/albert
#export TEMPLATE_DIRECTORY=$ROOT_DIRECTORY/savup-nats/build-deploy/templates
#export NATS_INSTALL_DIRECTORY=/home/NATS
#export CERT_DIRECTORY=$ROOT_DIRECTORY/keys/$SERVER_ENVIRONMENT/.keys/savup/STAR_savup_com
#export CA_BUNDLE_FILENAME=CAbundle.crt
#export CERT_FILENAME=STAR_savup_com.crt
#export CERT_KEY_DIRECTORY=$ROOT_DIRECTORY/keys/$SERVER_ENVIRONMENT/.keys/savup
#export CERT_KEY_FILENAME=savup.com.key
#add_tls='false'
#install_NATS_conf $add_tls
#cat /tmp/nats.conf.tmp
#export NATS_WEBSOCKET_PORT=5555
#install_NATS_conf 'false'
#echo "cat /tmp/nats.conf.tmp"
#cat /tmp/nats.conf.tmp
#echo "===================================="
#export NATS_WEBSOCKET_PORT=5555
#install_NATS_conf 'true'
#cat /tmp/nats.conf.tmp
#export NATS_WEBSOCKET_PORT=
#install_NATS_conf 'true'
#cat /tmp/nats.conf.tmp
