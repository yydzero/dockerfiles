#!/bin/bash

setup_ssh_for_user() {
  local user="${1}"
  local home_dir
  home_dir=$(eval echo "~${user}")

  mkdir -p "${home_dir}"/.ssh || return 1
  touch "${home_dir}/.ssh/authorized_keys" "${home_dir}/.ssh/known_hosts" "${home_dir}/.ssh/config" || return 1
  ssh-keygen -t rsa -N "" -f "${home_dir}/.ssh/id_rsa" || return 1
  cat "${home_dir}/.ssh/id_rsa.pub" >> "${home_dir}/.ssh/authorized_keys" || return 1
  chmod 0600 "${home_dir}/.ssh/authorized_keys" || return 1
  cat << EOF >> "${home_dir}/.ssh/config" || return 1
Host *
  UseRoaming no
  StrictHostKeyChecking no
EOF
  chown -R "${user}" "${home_dir}/.ssh" || return 1
}

ssh_keyscan_for_user() {
  local user="${1}"
  local home_dir
  home_dir=$(eval echo "~${user}")

  {
    ssh-keyscan localhost || return 1
    ssh-keyscan 0.0.0.0 || return 1
    ssh-keyscan github.com || return 1
  } >> "${home_dir}/.ssh/known_hosts"
}

setup_sshd() {
  test -e /etc/ssh/ssh_host_key || ssh-keygen -f /etc/ssh/ssh_host_key -N '' -t rsa1 || return 1
  test -e /etc/ssh/ssh_host_rsa_key || ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa || return 1
  test -e /etc/ssh/ssh_host_dsa_key || ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa || return 1
  test -e /etc/ssh/ssh_host_ecdsa_key || ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa || return 1
  test -e /etc/ssh/ssh_host_ed25519_key || ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519 || return 1

  # See https://gist.github.com/gasi/5691565
  # comment out below otherwise it report warning on RHEL7
  # sed -ri 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config || return 1
  # Disable password authentication so builds never hang given bad keys
  sed -ri 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config || return 1

  setup_ssh_for_user root || return 1
  setup_ssh_for_user test || return 1
}

setup_sshd

