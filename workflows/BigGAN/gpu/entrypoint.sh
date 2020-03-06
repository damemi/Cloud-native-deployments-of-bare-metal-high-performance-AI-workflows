#!/usr/bin/env bash

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/usr/sbin/nologin" >> /etc/passwd
  fi
fi

HOME=/home/pwrai
su pwrai

echo 1 > bash accept-powerai-license.sh

bash $HOME/atlas/workflows/BigGAN/gpu/run.sh
