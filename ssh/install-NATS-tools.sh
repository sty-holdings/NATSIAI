#!/bin/bash
#
# This will install NATS server, CLI, and NSC
#

set -eo pipefail

# Main function of this script
# shellcheck disable=SC2034
# shellcheck disable=SC2029
function install_NATS_tools() {
  local server_install_dir=/tmp/nats-server-install-dir.tmp
  local natscli_install_dir=/tmp/natscli-install-dir.tmp
  local nsc_install_dir=/tmp/nsc-install-dir.tmp

  echo "Installing nats-server."
  ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "sudo mkdir $NATS_INSTALL_DIRECTORY/install; sudo chown -R $NATS_SYSTEM_USER $NATS_INSTALL_DIRECTORY/install; sudo chmod -R 775 $NATS_INSTALL_DIRECTORY/install; curl -L $NATS_SERVER_INSTALL_URL -o $NATS_INSTALL_DIRECTORY/install/nats-server.zip;"
  ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "sudo unzip -o $NATS_INSTALL_DIRECTORY/install/nats-server.zip -d $NATS_INSTALL_DIRECTORY/install; find /home/$NATS_SYSTEM_USER/ -type d -name nats-server* > $server_install_dir;"
  ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "cd "'$(cat' "$server_install_dir"')'"; sudo cp nats-server $NATS_BIN;"

  echo "Installing natscli."
  ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "curl -L $NATSCLI_INSTALL_URL -o $NATS_INSTALL_DIRECTORY/install/nats-cli.zip;"
  ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "unzip -o $NATS_INSTALL_DIRECTORY/install/nats-cli.zip -d $NATS_INSTALL_DIRECTORY/install/.; find /home/$NATS_SYSTEM_USER/install -type d -name 'nats*' -not -name 'nats-server*' > $natscli_install_dir;"
  ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "cd "'$(cat' "$natscli_install_dir"')'"; sudo cp nats $NATSCLI_BIN;"

  echo "Installing natscli."
  ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "curl -L $NSC_INSTALL_URL -o $NATS_INSTALL_DIRECTORY/install/nsc.zip;"
  ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "unzip -o $NATS_INSTALL_DIRECTORY/install/nsc.zip -d $NATS_INSTALL_DIRECTORY/install/.;"
  ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "cd $NATS_INSTALL_DIRECTORY/install; sudo cp nsc $NSC_BIN;"

  echo "Installing generate_nats_creds.sh script."
  ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "mkdir $NATS_INSTALL_DIRECTORY/scripts; sudo chown -R $NATS_SYSTEM_USER $NATS_INSTALL_DIRECTORY/scripts; sudo chmod -R 775 $NATS_INSTALL_DIRECTORY/scripts;"
  scp $IDENTITY $ROOT_DIRECTORY/servers/savup-nats/scripts/generate-nats-creds.sh $WORKING_AS@$INSTANCE_DNS_IPV4:$NATS_INSTALL_DIRECTORY/scripts
  scp $IDENTITY $ROOT_DIRECTORY/servers/savup-nats/scripts/remove-NATS-from-users.sh $WORKING_AS@$INSTANCE_DNS_IPV4:$NATS_INSTALL_DIRECTORY/scripts
  ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "sudo chown -R $NATS_SYSTEM_USER $NATS_INSTALL_DIRECTORY/scripts/*; sudo chmod -R 775 $NATS_INSTALL_DIRECTORY/scripts/*;"

  echo "Creating the JWT directory"
  ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "mkdir $NATS_INSTALL_DIRECTORY/jwt; sudo chmod -R 775 $NATS_INSTALL_DIRECTORY/jwt; sudo chown -R $NATS_SYSTEM_USER $NATS_INSTALL_DIRECTORY/jwt"
}

# Test
#export IDENTITY="-i /Users/syacko/.ssh/savup-local-0030"
#export WORKING_AS=savup
#export INSTANCE_DNS_IPV4=154.12.225.56
#export NATS_INSTALL_DIRECTORY=/home/$NATS_SYSTEM_USER
#export NATS_SERVER_INSTALL_URL=https://github.com/nats-io/nats-server/releases/download/v2.9.22/nats-server-v2.9.22-linux-amd64.zip
#export NATS_BIN=/usr/bin/nats-server
#export NATSCLI_INSTALL_URL=https://github.com/nats-io/natscli/releases/download/v0.0.35/nats-0.0.35-linux-amd64.zip
#export NATSCLI_BIN=/usr/bin/nats
#export NSC_INSTALL_URL=https://github.com/nats-io/nsc/releases/download/v2.8.0/nsc-linux-amd64.zip
#export NSC_BIN=/usr/bin/nsc
#install_NATS_tools
