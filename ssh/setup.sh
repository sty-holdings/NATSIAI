#!/bin/bash
#
# Description: This will set up a NATS server.
#
# Installation:
#   None required
#
# Copyright (c) 2022 STY-Holdings Inc
# MIT License
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the “Software”), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to
# do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

set -eo pipefail

# script variables
FILENAME=$(basename "$0")

# Private Variables
ACTION="none"
export IDENTITY          # This is set by calling build-ssh-identity.sh function build_ssh_identity.
export IDENTITY_FILENAME # This is set by calling build-ssh-identity_filename.sh function build_ssh_identity_filename.
WAIT="yes"
DISPLAY_EXPORTS="yes"

function init_script() {
  echo "Remove existing core-devops directory, if any."
  rm -rf core-devops
  echo "Cloning Core DevOps scripts"
  git clone https://github.com/sty-holdings/core-devops
  #  Core
  . core-devops/scripts/0-initialize-core-scripts.sh
  #
  display_spacer
  #
  # Pulling configuration from Github
  #
  display_info "Remove existing configurations directory, if any."
  rm -rf configurations
  display_info "Cloning configurations"
  git clone https://github.com/sty-holdings/configurations
  display_spacer
  display_info "Configuration is available."
  display_spacer
  display_info "Script has been initialized."
}

# shellcheck disable=SC2028
function print_exports() {
  echo "IDENTITY_FILENAME:\t\t$IDENTITY_FILENAME"
  echo "LOCAL_USER_HOME_DIRECTORY:\t$LOCAL_USER_HOME_DIRECTORY"
  echo "NATSCLI_INSTALL_URL:\t\t$NATSCLI_INSTALL_URL"
  echo "NATS_ACCOUNT:\t\t\t$NATS_ACCOUNT"
  echo "NATS_BIN:\t\t\t$NATS_BIN"
  echo "NATS_CONF_NAME:\t\t\tnats.conf"
  echo "NATS_INSTALL_DIRECTORY:\t\t$NATS_INSTALL_DIRECTORY"
  echo "NATS_OPERATOR:\t\t\t$NATS_OPERATOR"
  if [ -z "$NATS_PORT" ]; then
    echo "NATS_PORT:\t\t\tSet to Default: 4222"
  else
    echo "NATS_PORT:\t\t\t$NATS_PORT"
  fi
  echo "NATS_SERVER_INSTALL_URL:\t$NATS_SERVER_INSTALL_URL"
  echo "NATS_SERVER_NAME:\t\t$NATS_SERVER_NAME"
  echo "NATS_SYSTEM_USER:\t\t$NATS_SYSTEM_USER"
  echo "NATS TLS:"
  if [ -z "$CERT_DIRECTORY" ] || [ -z "$CA_BUNDLE_FILENAME" ] || [ -z "$CERT_FILENAME" ] || [ -z "$CERT_KEY_FILENAME" ]; then
    echo "\t is not being used. No certificate information was provides."
  else
    echo "\tCERT_DIRECTORY:\t\t$CERT_DIRECTORY"
    echo "\tCA_BUNDLE_FILENAME:\t$CA_BUNDLE_FILENAME"
    echo "\tCERT_FILENAME:\t\t$CERT_FILENAME"
    echo "\tCERT_KEY_FILENAME:\t$CERT_KEY_FILENAME"
  fi
  echo "NATS_URL:\t\t\t$NATS_URL"
  if [ -z "$NATS_WEBSOCKET_PORT" ]; then
    echo "NATS_WEBSOCKET_PORT: is not being used"
  else
    echo "NATS_WEBSOCKET_PORT:\t\t\t$NATS_WEBSOCKET_PORT"
  fi
  echo "NSC_BIN:\t\t\t$NSC_BIN"
  echo "NSC_INSTALL_URL:\t\t$NSC_INSTALL_URL"
  echo "ROOT_DIRECTORY:\t\t\t$ROOT_DIRECTORY"
  echo "SERVER_ENVIRONMENT:\t\t$SERVER_ENVIRONMENT"
  echo "SYSTEM_USER_PARENT_GROUP:\t\t$SYSTEM_USER_PARENT_GROUP"
  echo "SERVER_INSTANCE_IPV4:\t\t$SERVER_INSTANCE_IPV4"
  echo "TEMPLATE_DIRECTORY:\t\t$TEMPLATE_DIRECTORY"
  echo "WORKING_AS:\t\t\t$WORKING_AS"
  display_spacer
}

# shellcheck disable=SC2028
function print_usage() {
  display_info "This will install NATS on an existing instance accessible by SSH."
  echo
  echo "Usage: $FILENAME -h | -I | -y yaml <filename> <action> [-W | -D]"
  echo
  echo "Global flags:"
  echo "  -h\t\t\t Display help."
  echo "  -I\t\t\t Prints additional information for savup-nats."
  echo "  -y yaml filename\t The FQN of the yaml file containing all the needed settings."
  echo "  -W\t\t\t Do not wait to review the yaml and export settings."
  echo "  -D\t\t\t Do not display the export and yaml settings."
  echo
  echo "Actions (Listing in order of recommended execution)"
  echo "  -S\t Scrub NATS from the system. Executables, users, and directories."
  echo "  -U\t Create the NATS system user ($NATS_SYSTEM_USER). User can not login."
  echo "  -i\t (Skip -T) Installing nats-server, natscli, nsc and create nats.conf with TLS."
  echo "  -T\t (Skip -i) Installing nats-server, natscli, nsc and create nats.conf without TLS."
  echo "  -o\t Create an operator with a key and make signing keys required."
  echo "  -a\t (Skip -A) Create an account with a key and make signing keys required."
  echo "  -A\t (Skip -a) Create an account without a key and signing keys are unnecessary."
  echo "  -r\t Generate and install the resolver.conf file."
  echo "  -P\t Push the operator, account, user and resolver to the running NATS server without TLS."
  echo "  -n\t (Skip -N) Installing nats.conf with TLS settings. Make sure to also run -C."
  echo "  -N\t (Skip -n) Installing nats.conf without TLS settings."
  echo "  -C\t Installing TLS certificates for NATS."
  echo "  -O\t Create an operator without a key and signing keys are not needed."
  echo "  -m\t Create a NATS account user and NATS context on server."
  echo
}

# shellcheck disable=SC2029
function set_NATS_group_permissions() {
  echo "Setting NATS group permissions."
  # shellcheck disable=SC2034
  set_NATS_group_permissions_result=$(ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "sudo chmod -R 775 $NATS_INSTALL_DIRECTORY")
  echo "Permissions are set."
}

function set_NATS_port() {
  if [ -z "$NATS_PORT" ]; then
    export NATS_PORT=4222
  fi
}

function validate_arguments() {
  if [ $ACTION == "none" ]; then
    local Failed="true"
    display_error "You have to provide an action."
  fi
  if [ -z "$YAML_FILENAME" ]; then
    local Failed="true"
    display_error "The yaml filename was not provided."
  fi

  if [ "$Failed" == "true" ]; then
    print_usage
    exit 99
  fi
}

function validate_parameters() {
  if [ -z "$IDENTITY_FILENAME" ]; then
    local Failed="true"
    display_error "Your ssh IDENTITY_FILENAME must be provided."
  fi
  if [ -z "$LOCAL_USER_HOME_DIRECTORY" ]; then
    local Failed="true"
    display_error "The local users home directory (FQN) must be provided."
  fi
  if [ -z "$NATS_BIN" ]; then
    local Failed="true"
    display_error "The NATS bin must be provided."
  fi
  if [ -z "$NATSCLI_BIN" ]; then
    local Failed="true"
    display_error "The NATS CLI bin must be provided."
  fi
  if [ -z "$NATS_SERVER_NAME" ]; then
    local Failed="true"
    display_error "The NATS server name must be provided."
  fi
  if [ -z "$NATS_SYSTEM_USER" ]; then
    local Failed="true"
    display_error "The NATS system user must be provided."
  fi
  if [ -z "$NSC_BIN" ]; then
    local Failed="true"
    display_error "The NSC bin must be provided."
  fi
  validate_server_environment
  # shellcheck disable=SC2154
  if [ "$validate_server_environment_result" == "failed" ]; then
    exit 99
  fi
  if [ -z "$SERVER_INSTANCE_IPV4" ]; then
    local Failed="true"
    display_error "The IPV4 address or DNS entry must be provided."
  fi
  if [ -z "$SYSTEM_USER" ]; then
    local Failed="true"
    display_error "The system user must be provided."
  fi
  if [ -z "$SYSTEM_USER_HOME_DIRECTORY" ]; then
    local Failed="true"
    display_error "The system users home directory (FQN) must be provided."
  fi
  if [ -z "$WORKING_AS" ]; then
    local Failed="true"
    display_error "The working as users must be provided."
  fi

  if [ "$Failed" == "true" ]; then
    print_usage
    exit 99
  fi
}

# shellcheck disable=SC2034
function validate_natscli_install_url() {
  if [ -z "$NATSCLI_INSTALL_URL" ]; then
    validate_natscli_install_url_result='failed'
    display_error "The NATSCLI_INSTALL_URL must be provided."
  fi
}

# shellcheck disable=SC2034
function validate_NATS_account() {
  if [ -z "$NATS_ACCOUNT" ]; then
    validate_NATS_account_result='failed'
    display_error "The NATS_ACCOUNT must be provided."
  fi
}

# shellcheck disable=SC2034
function validate_NATS_account_user() {
  if [ -z "$NATS_ACCOUNT_USER" ]; then
    validate_NATS_account_user_result='failed'
    display_error "The NATS_ACCOUNT_USER must be provided."
  fi
}

# shellcheck disable=SC2034
function validate_NATS_install_directory() {
  if [ -z "$NATS_INSTALL_DIRECTORY" ]; then
    validate_NATS_install_directory_result="failed"
    display_error "The NATS_INSTALL_DIRECTORY must be provided."
  fi
}

# shellcheck disable=SC2034
function validate_NATS_operator() {
  if [ -z "$NATS_OPERATOR" ]; then
    validate_NATS_operator_result="failed"
    display_error "The $NATS_OPERATOR must be provided."
  fi
}

# shellcheck disable=SC2034
function validate_nats_server_install_url() {
  if [ -z "$NATS_SERVER_INSTALL_URL" ]; then
    validate_nats_server_install_url_result="failed"
    display_error "The NATS_SERVER_INSTALL_URL must be provided."
  fi
}

# shellcheck disable=SC2034
function validate_nsc_install_url() {
  if [ -z "$NSC_INSTALL_URL" ]; then
    validate_nsc_install_url_result="failed"
    display_error "The NSC_INSTALL_URL must be provided."
  fi
}

# shellcheck disable=SC2034
function validate_template_directory() {
  if [ -z "$TEMPLATE_DIRECTORY" ]; then
    validate_template_directory_result="failed"
    display_error "The TEMPLATE_DIRECTORY must be provided."
  fi
}

# Main function of this script
function run_script() {
  if [ "$#" == "0" ]; then
    display_error "No parameters where provided."
    print_usage
    exit 99
  fi

  while getopts 'Wy:aACDiImnNoOPrStUh' OPT; do # see print_usage
    case "$OPT" in
    a)
      ACTION="ACCOUNT"
      ;;
    A)
      ACTION="ACCOUNTNOKEYS"
      ;;
    C)
      ACTION="CERTS"
      ;;
    D)
      DISPLAY_EXPORTS="no"
      ;;
    i)
      ACTION="INSTALL"
      ;;
    I)
      display_info "ACTION: -I Print action variable usage."
      # shellcheck disable=SC2086
      print_additional_info $FILENAME
      display_spacer
      exit 0
      ;;
    m)
      ACTION="MEMBER"
      ;;
    n)
      ACTION="NATSCONF"
      ;;
    N)
      ACTION="NATSCONFNOTLS"
      ;;
    o)
      ACTION="OPER"
      ;;
    O)
      ACTION="OPERNOKEYS"
      ;;
    P)
      ACTION="PUSH"
      ;;
    r)
      ACTION="RESOLVER"
      ;;
    S)
      ACTION="SCRUB"
      ;;
    U)
      ACTION="SYSTEMUSER"
      ;;
    W)
      WAIT="no"
      ;;
    y)
      set_variable YAML_FILENAME "$OPTARG"
      ;;
    h)
      print_usage
      exit 0
      ;;
    *)
      display_error "Please review the usage printed below:" >&2
      print_usage
      exit 99
      ;;
    esac
  done

# Setup
#
# Validating inputs to the script
#
  validate_arguments
#
# Display yaml settings
#
  display_spacer
  if [ "$DISPLAY_EXPORTS" == "yes" ]; then
    display_info "YAML file values:"
    # shellcheck disable=SC2086
    print_formatted_yaml $YAML_FILENAME
  fi
  display_spacer
#
# Adding yaml setting as exports
#
  get_now_formatted '%Y-%m-%d-%H-%M-%S'
  # shellcheck disable=SC2086
  # shellcheck disable=SC2154
  parse_export_yaml_filename_prefix $YAML_FILENAME $now
  # shellcheck disable=SC2086
  myExports=$(cat /tmp/$now-exports.sh)
  # shellcheck disable=SC2086
  eval $myExports
  exit
  rm /tmp/*-exports.sh
#
# Validate yaml file parameters
#
  validate_parameters
  if [ "$DISPLAY_EXPORTS" == "yes" ]; then
    display_info "YAML values exported"
    print_exports
    if [ "$WAIT" == "yes" ]; then
      display_info "Waiting 8 seconds to allow review of setting. Ctrl+c to abort."
      sleep 8
      display_spacer
    fi
  fi
  display_spacer
#
# Building ssh identity file for the server user
#
  IDENTITY_FILENAME="$LOCAL_USER_HOME_DIRECTORY/.ssh/$IDENTITY_FILENAME"
  # shellcheck disable=SC2086
  build_ssh_identity $IDENTITY_FILENAME
#
# Processing Action
#
  case "$ACTION" in
  ACCOUNT)
    display_info "ACTION: -a Create an account with a key and make signing keys required."
    action_if=running
    check_server_running $SERVER_NAME $action_if
    # shellcheck disable=SC2181
    if [ "$?" -ne 0 ]; then
      exit 99
    fi
    are_cert_settings_valid
    validate_NATS_account
    if [ "$are_cert_settings_valid_result" == "no" ] || [ "$validate_NATS_account_result" == "failed" ]; then
      display_error "One or more of the following are not set: CA_BUNDLE_FILENAME, CERT_DIRECTORY, CERT_FILENAME, CERT_KEY_FILENAME, NATS_ACCOUNT."
      exit 99
    fi
    keys='true'
    create_account $keys
    display_spacer
    ;;
  ACCOUNTNOKEYS)
    display_info "ACTION: -A Create an account without a key and signing keys are not needed."
    action_if=running
    check_server_running $SERVER_NAME $action_if
    # shellcheck disable=SC2181
    if [ "$?" -ne 0 ]; then
      exit 99
    fi
    validate_NATS_account
    if [ "$validate_NATS_account_result" == "failed" ]; then
      exit 99
    fi
    keys='false'
    create_account $keys
    display_spacer
    ;;
  CERTS)
    display_info "ACTION: -C Installing TLS certificates for NATS."
    are_cert_settings_valid
    validate_NATS_install_directory
    validate_server_environment
    # shellcheck disable=SC2154
    if [ "$are_cert_settings_valid_result" == "no" ] || [ "$validate_NATS_install_directory_result" == "failed" ] || [ "$validate_server_environment_result" == "failed" ]; then
      display_error "One or more of the following are not set: CA_BUNDLE_FILENAME, CERT_DIRECTORY, CERT_FILENAME, CERT_KEY_FILENAME, NATS_INSTALL_DIRECTORY, SERVER_ENVIRONMENT."
      exit 99
    fi
    install_tls_certs_key $NATS_INSTALL_DIRECTORY $NATS_SYSTEM_USER
    display_spacer
    ;;
  INSTALL)
    display_info "ACTION: -i Installing nats-server, natscli, nsc and create nats.conf."
    action_if=running
    check_server_running $SERVER_NAME $action_if
    # shellcheck disable=SC2181
    if [ "$?" -ne 0 ]; then
      exit 99
    fi
    validate_NATS_install_directory
    validate_nats_server_install_url
    validate_natscli_install_url
    validate_nsc_install_url
    if [ "$validate_NATS_install_directory_result" == "failed" ] || [ "$validate_nats_server_install_url_result" == "failed" ] || [ "$validate_natscli_install_url_result" == "failed" ] || [ "$validate_nsc_install_url_result" == "failed" ]; then
      display_error "One or more of the following are not set: NATS_INSTALL_DIRECTORY, NATSCLI_INSTALL_URL, NATS_SERVER_INSTALL_URL, NSC_INSTALL_URL."
      exit 99
    fi
    install_NATS_tools
    display_spacer
    ;;
  MEMBER)
    display_info "ACTION: -m Create a NATS account user and NATS context on server."
    are_cert_settings_valid
    validate_NATS_account
    validate_NATS_account_user
    validate_NATS_install_directory
    validate_template_directory
    if [ "$are_cert_settings_valid_result" == "no" ] || [ "$validate_NATS_account_result" == "failed" ] || [ "$validate_NATS_account_user_result" == "failed" ] || [ "$validate_template_directory_result" == "failed" ] || [ "$validate_NATS_install_directory_result" == "failed" ]; then
      display_error "One or more of the following are not set: CA_BUNDLE_FILENAME, CERT_DIRECTORY, CERT_FILENAME, CERT_KEY_FILENAME, NATS_ACCOUNT, NATS_ACCOUNT_USER, NATS_INSTALL_DIRECTORY, TEMPLATE_DIRECTORY."
      exit 99
    fi
    process_running "$IDENTITY" $WORKING_AS $INSTANCE_DNS_IPV4 'nats-server' '^journalctl' # Check to see if NATS is running on remote server
    # shellcheck disable=SC2154
    if [ "$process_running_result" == 'found' ]; then
      echo "nats-server is running."
    else
      display_warning "A NATS Server is not running on this system!! "
      echo "Starting the server, now."
      ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "sudo systemctl start nats-server.service"
      process_running "$IDENTITY" $WORKING_AS $INSTANCE_DNS_IPV4 'nats-server' '^journalctl' # Check to see if NATS is running on remote server
      # shellcheck disable=SC2154
      if [ "$process_running_result" == 'found' ]; then
        echo "nats-server is running."
      else
        display_warning "A NATS Server is STILL NOT running on this system!! INVESTIGATE - THERE ARE ISSUES."
        exit 99
      fi
    fi
    # shellcheck disable=SC2029
    ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "nsc add user --account $NATS_ACCOUNT $NATS_ACCOUNT_USER"
    user=$NATS_ACCOUNT_USER
    home_directory=/home/$NATS_ACCOUNT_USER
    create_user_context $user $home_directory
    display_spacer
    ;;
  NATSCONF)
    display_info "ACTION: -n Installing nats.conf with TLS settings. Make sure to also run -C."
    action_if=running
    check_server_running $SERVER_NAME $action_if
    # shellcheck disable=SC2181
    if [ "$?" -ne 0 ]; then
      exit 99
    fi
    are_cert_settings_valid
    validate_NATS_install_directory
    validate_template_directory
    if [ "$are_cert_settings_valid_result" == "no" ] || [ "$validate_NATS_install_directory_result" == "failed" ] || [ "$validate_template_directory_result" == "failed" ]; then
      display_error "One or more of the following are not set: CA_BUNDLE_FILENAME, CERT_DIRECTORY, CERT_FILENAME, CERT_KEY_FILENAME, NATS_INSTALL_DIRECTORY, TEMPLATE_DIRECTORY."
      exit 99
    fi
    set_NATS_port
    add_tls='true'
    install_NATS_conf $add_tls
    display_spacer
    ;;
  NATSCONFNOTLS)
    display_info "ACTION: -N Installing nats.conf without TLS settings."
    action_if=running
    check_server_running $SERVER_NAME $action_if
    # shellcheck disable=SC2181
    if [ "$?" -ne 0 ]; then
      exit 99
    fi
    validate_template_directory
    validate_NATS_install_directory
    if [ "$validate_template_directory_result" == "failed" ] || [ "$validate_NATS_install_directory_result" == "failed" ]; then
      display_error "One or more of the following are not set: NATS_INSTALL_DIRECTORY, TEMPLATE_DIRECTORY."
      exit 99
    fi
    set_NATS_port
    add_tls='false'
    install_NATS_conf $add_tls
    display_spacer
    ;;
  OPER)
    display_info "ACTION: -o Create an operator with a key and make signing keys required."
    action_if=running
    check_server_running $SERVER_NAME $action_if
    # shellcheck disable=SC2181
    if [ "$?" -ne 0 ]; then
      exit 99
    fi
    are_cert_settings_valid
    validate_NATS_operator
    validate_template_directory
    if [ "$are_cert_settings_valid_result" == "no" ] || [ "$validate_NATS_operator_result" == "failed" ] || [ "$validate_template_directory_result" == "failed" ]; then
      display_error "One or more of the following are not set: CA_BUNDLE_FILENAME, CERT_DIRECTORY, CERT_FILENAME, CERT_KEY_FILENAME, NATS_OPERATOR, TEMPLATE_DIRECTORY."
      exit 99
    fi
    keys='true'
    create_operator $keys
    user='SYS'
    home_directory=$WORKING_AS_HOME_DIRECTORY
    create_user_context $user $home_directory
    display_spacer
    ;;
  OPERNOKEYS)
    display_info "ACTION: -o Create an operator without a key and signing keys are not required."
    action_if=running
    check_server_running $SERVER_NAME $action_if
    # shellcheck disable=SC2181
    if [ "$?" -ne 0 ]; then
      exit 99
    fi
    validate_NATS_operator
    if [ "$validate_NATS_operator_result" == "failed" ]; then
      display_error "One or more of the following are not set: NATS_OPERATOR."
      exit 99
    fi
    keys='true'
    create_operator $keys
    user='SYS'
    home_directory=$WORKING_AS_HOME_DIRECTORY
    create_user_context $user $home_directory
    display_spacer
    ;;
  PUSH)
    display_info "ACTION: -P Push the operator, account, user, and resolver."
    action_if=running
    check_server_running $SERVER_NAME $action_if
    # shellcheck disable=SC2181
    if [ "$?" -ne 0 ]; then
      exit 99
    fi
    set_NATS_port
    validate_NATS_install_directory
    validate_template_directory
    # shellcheck disable=SC2154
    if [ "$validate_NATS_install_directory_result" == "failed" ] || [ "$validate_template_directory_result" == "failed" ]; then
      display_error "One or more of the following are not set: NATS_INSTALL_DIRECTORY, TEMPLATE_DIRECTORY."
      exit 99
    fi
    add_tls='false'
    install_NATS_conf $add_tls
    install_systemd_service "$IDENTITY" $WORKING_AS $INSTANCE_DNS_IPV4 'nats-server' $NATS_INSTALL_DIRECTORY $NATS_SYSTEM_USER $TEMPLATE_DIRECTORY 'nats-server-servicefile.template' 'nats-server.service'
    echo "Starting nats-server via systemd."
    ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "sudo systemctl start nats-server.service"
    action_if=stopped
    check_server_running $SERVER_NAME $action_if
    # shellcheck disable=SC2181
    if [ "$?" -ne 0 ]; then
      exit 99
    fi
    echo "Pushing to nats-server."
    ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "nsc push -A"
    echo "Stopping nats-server via systemd."
    ssh $IDENTITY $WORKING_AS@$INSTANCE_DNS_IPV4 "sudo systemctl stop nats-server.service"
    display_spacer
    ;;
  RESOLVER)
    display_info "ACTION: -r Generate and install the resolver.conf file."
    validate_NATS_install_directory
    validate_NATS_operator
    if [ "$validate_NATS_install_directory_result" == "failed" ] || [ "$validate_NATS_operator_result" == "failed" ]; then
      display_error "One or more of the following are not set: NATS_INSTALL_DIRECTORY, NATS_OPERATOR."
      exit 99
    fi
    create_resolver
    display_spacer
    ;;
  SCRUB)
    display_info "ACTION: -S Scrub $NATS_SYSTEM_USER from the system."
    action_if=running
    # shellcheck disable=SC2086
    check_server_running $NATS_SERVER_NAME $action_if
    # shellcheck disable=SC2181
    if [ "$?" -ne 0 ]; then
      exit 99
    fi
    echo "Scrubbing .config/nats and .local/share/nats from all server users."
    # shellcheck disable=SC2086
    scp $IDENTITY remove-NATS-from-users.sh $WORKING_AS@$SERVER_INSTANCE_IPV4:/tmp
    # shellcheck disable=SC2086
    ssh $IDENTITY $WORKING_AS@$SERVER_INSTANCE_IPV4 "sudo sh /tmp/remove-NATS-from-users.sh"
    echo "Scrubbing $NATS_SYSTEM_USER user."
    # shellcheck disable=SC2086
    find_string_in_remote_file "$IDENTITY" $WORKING_AS $SERVER_INSTANCE_IPV4 $NATS_SYSTEM_USER /etc/passwd
    # shellcheck disable=SC2154
    if [ "$find_string_in_remote_file_result" == "found" ]; then
      # shellcheck disable=SC2029
    # shellcheck disable=SC2086
      ssh $IDENTITY $WORKING_AS@$SERVER_INSTANCE_IPV4 "sudo userdel --remove $NATS_SYSTEM_USER;"
    fi
    echo "Scrubbing executables, nats-server, natscli, and nsc."
    # shellcheck disable=SC2086
    find_remote_file "$IDENTITY" $WORKING_AS $SERVER_INSTANCE_IPV4 /usr/bin nats-server
    # shellcheck disable=SC2154
    if [ "$find_remote_file_result" == "found" ]; then
      # shellcheck disable=SC2029
      # shellcheck disable=SC2086
      ssh $IDENTITY $WORKING_AS@$SERVER_INSTANCE_IPV4 "sudo rm $NATS_BIN $NATSCLI_BIN $NSC_BIN;"
    fi
    display_spacer
    ;;
  SYSTEMUSER)
    display_info "ACTION: -U Create the $NATS_SYSTEM_USER system user. User can not login."

    echo "x=$SYSTEM_USER_PARENT_GROUP"

    validate_system_user_parent_group
    validate_working_as_home_directory
    if [ "$validate_server_user_parent_group_result" == "failed" ] || [ "$validate_working_as_home_directory_result" == "failed" ]; then
      exit
    fi
    # shellcheck disable=SC2086
    build_ssh_identity $IDENTITY_FILENAME
    login_allowed='false'
    install_server_user "$IDENTITY" $WORKING_AS $INSTANCE_DNS_IPV4 $NATS_SYSTEM_USER $SERVER_USER_PARENT_GROUP $login_allowed
    # shellcheck disable=SC2154
    if [ "$install_server_user_result" == "failed" ]; then
      exit 99
    else
      echo "$install_server_user_result"
      set_NATS_group_permissions
      install_server_NATS_export
      display_spacer
    fi
    ;;
  esac

  echo Done
}

init_script
run_script "$@"
