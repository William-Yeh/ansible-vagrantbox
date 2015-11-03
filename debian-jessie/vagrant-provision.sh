#!/bin/bash
#
# provision script; install Docker engine & some handy tools.
#
# @see https://docs.docker.com/installation/debian/
#


export DEBIAN_FRONTEND=noninteractive
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

readonly ANSIBLE_VERSION=1.9.4
readonly ZSH_FULLPATH=/usr/bin/zsh
readonly ZSHRC_FULLPATH=/home/vagrant/.zshrc
readonly OHMYZSH_FULLPATH=/home/vagrant/.oh-my-zsh


#==========================================================#

#
# error handling
#

do_error_exit() {
    echo { \"status\": $RETVAL, \"error_line\": $BASH_LINENO }
    exit $RETVAL
}

trap 'RETVAL=$?; echo "ERROR"; do_error_exit '  ERR
trap 'RETVAL=$?; echo "received signal to stop";  do_error_exit ' SIGQUIT SIGTERM SIGINT


#---------------------------------------#
# fix base box
#

cat <<-HOSTNAME > /etc/hostname
ANSIBLE
HOSTNAME

sed -i -e  's/127.0.0.1\s.*/127.0.0.1\tlocalhost ANSIBLE/' /etc/hosts


cat <<-EOBASHRC  >> /home/vagrant/.bashrc
  export PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
  export LC_CTYPE=C.UTF-8

  #-- disable "host key checking" for convenience;
  #-- @see http://docs.ansible.com/ansible/intro_getting_started.html#host-key-checking
  #export ANSIBLE_HOST_KEY_CHECKING=false
EOBASHRC


# update packages
sudo apt-get update


#==========================================================#

echo "===> Installing required Python stuff..."
DEBIAN_FRONTEND=noninteractive         \
apt-get install -y                     \
    python-pip python-dev python-yaml  \
    sshpass git

echo "===> Installing Ansible..."
pip install ansible==$ANSIBLE_VERSION

echo "===> Installing other interesting stuff..."
apt-get install -y libxml2-dev libxslt1-dev zlib1g-dev
pip install apache-libcloud boto docker-py shade PyVmomi

#==========================================================#

echo "===> Installing handy utilities..."
apt-get install -y htop ack-grep


echo "===> Installing Zsh..."
apt-get install -y zsh
chsh -s $ZSH_FULLPATH root
chsh -s $ZSH_FULLPATH vagrant


echo "===> Installing Oh My Zsh..."
apt-get install -y curl wget
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"  || true

sed -i -e 's/plugins\=.*/plugins=\(git systemd zsh_reload ansible ssh-agent sublime\)/'   $ZSHRC_FULLPATH
sed -i -e 's/ZSH_THEME\=.*/ZSH_THEME="kolo"/'   $ZSHRC_FULLPATH


cat <<-EOZSHCUSTOM  >> $ZSHRC_FULLPATH

#-----
# customize for this Ansible control machine
#-----

  export PROMPT='%B%F{magenta}%c%B%F{green}\${vcs_info_msg_0_}%B%F{magenta} %{\$reset_color%}\$ '
  export LC_CTYPE=C.UTF-8

  #-- disable "host key checking" for convenience;
  #-- @see http://docs.ansible.com/ansible/intro_getting_started.html#host-key-checking
  #export ANSIBLE_HOST_KEY_CHECKING=false
EOZSHCUSTOM


chown -R vagrant $ZSHRC_FULLPATH $OHMYZSH_FULLPATH
chgrp -R vagrant $ZSHRC_FULLPATH $OHMYZSH_FULLPATH

echo "===> Done!"



# clean up
sudo apt-get clean
sudo rm -f \
  /var/log/messages   \
  /var/log/lastlog    \
  /var/log/auth.log   \
  /var/log/syslog     \
  /var/log/daemon.log \
  /home/vagrant/.bash_history \
  /var/mail/vagrant           \
  || true
