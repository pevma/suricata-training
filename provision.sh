#!/bin/bash
# Author: Jon Schipp <jonschipp@gmail.com>
# Written for Ubuntu Saucy and Trusty, should be adaptable to other distros.

## Variables
CONFIG=/home/vagrant/suricata.conf
HOME=/root
cd $HOME

# Installation notification
COWSAY=/usr/games/cowsay
IRCSAY=/usr/local/bin/ircsay
IRC_CHAN="#replace_me"
HOST=$(hostname -s)
LOGFILE=/root/islet_install.log
EMAIL=user@company.com

function die {
  if [ -f ${COWSAY:-none} ]; then
      $COWSAY -d "$*"
  else
      echo "$*"
  fi
  if [ -f $IRCSAY ]; then
      ( set +e; $IRCSAY "$IRC_CHAN" "$*" 2>/dev/null || true )
  fi
  echo "$*" | mail -s "[vagrant] Bro Sandbox install information on $HOST" $EMAIL
  exit 1
}

function hi {
  if [ -f ${COWSAY:-none} ]; then
      $COWSAY "$*"
  else
      echo "$*"
  fi
  if [ -f $IRCSAY ]; then
      ( set +e; $IRCSAY "$IRC_CHAN" "$*" 2>/dev/null || true )
  fi
  echo "$*" | mail -s "[vagrant] Bro Sandbox install information on $HOST" $EMAIL
}

install_dependencies(){
  apt-get update -qq
  apt-get install -yq cowsay git make sqlite pv linux-tools-3.13.0-33-generic
  [[ -d /exercises ]] || mkdir /exercises
}

install_islet(){
  if ! [ -d islet ]
  then
    git clone http://github.com/jonschipp/islet || die "Clone of islet repo failed"
    cd islet
    make install-docker && ./configure && make logo &&
    make install && make user-config
  fi
}

install_environment(){
  [[ -f $CONFIG ]] && install -o root -g root -m 0644 $CONFIG /etc/islet/environments
  sysctl kernel.perf_event_paranoid=1
  echo "kernel.perf_event_paranoid = 1" > /etc/sysctl.d/10-perf.conf
}

install_dependencies "1.)"
install_islet "2.)"
install_environment "3.)"

echo -e "\nTry it out: ssh -p 2222 demo@127.0.0.1 -o UserKnownHostsFile=/dev/null"
