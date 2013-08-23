#!/bin/sh
set -e

# make sure $HOME/.ssh exists
if [ ! -d "$HOME/.ssh" ]; then
  debug "$HOME/.ssh does not exists, creating it"
  mkdir -p $HOME/.ssh
fi

known_hosts_path="$HOME/.ssh/known_hosts"

if [ ! -f "$known_hosts_path" ]; then
  debug "$known_hosts_path does not exists, touching it and chmod it to 600"
  touch $known_hosts_path
  chmod 600 $known_hosts_path
fi

if [ ! -w "$known_hosts_path" ]; then
  fail "$known_hosts_path exists, but it not writeable"
fi

# validate <hostname> exists
if [ ! -n "$WERCKER_ADD_TO_KNOWN_HOSTS_HOSTNAME" ]
then
  fail "missing or empty hostname, please check your wercker.yml"
fi

ssh_keyscan_result=`mktemp`

# get host information using ssh-keyscan <hostname>
# write content to a <temporary_file1>
ssh-keyscan $WERCKER_ADD_TO_KNOWN_HOSTS_HOSTNAME > ssh_keyscan_result

if [ ! -n "$WERCKER_ADD_TO_KNOWN_HOSTS_FINGERPRINT" ] ; then
  cat $ssh_keyscan_result >> $HOME/.ssh/known_hosts
  warn "Skipped checking public key with fingerprint, this setup is vulnerable to man in the middle attack"
  success "Successfully added host $WERCKER_ADD_TO_KNOWN_HOSTS_HOSTNAME to known_hosts"
else
  fail "Checking fingerprint not supported yet"
  # split <temporary_file1> by enters into <lines>
  # foreach line in <lines>
  # write to <temporary_file2>
  # use ssh-keygen -l -f <temporary_file2> to calculate fingerprint
  # verify output contains <fingerprint>
  # if it does, append <temporary_file2> to ~/.ssh/known_hosts
  # end foreach
fi