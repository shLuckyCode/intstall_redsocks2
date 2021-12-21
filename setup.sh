#!/bin/bash

sudo apt-get update
sudo apt-get install -y build-essential
set -e

proxy_folder="${HOME}/proxy"

mk_folder(){
  if [ ! -d "$proxy_folder" ]; then
      mkdir "$proxy_folder"
  fi
}

intstall_redsocks2(){
    sudo apt-get install -y libevent-dev libssl-dev
    git clone https://github.com/semigodking/redsocks.git
    cd ./redsocks
    make DISABLE_SHADOWSOCKS=true
    sudo cp -rf ./redsocks2 /usr/sbin/redsocks2
    chmod 755 /usr/sbin/redsocks2
    cd ../
}

create_service(){
  sudo touch /etc/default/redsocks2
  chmod 644 /etc/default/redsocks2
  sudo tee /etc/default/redsocks2 <<<"CONFFILE=\"/etc/redsocks2.conf\""

  sudo cp ./redsocks2.service /lib/systemd/system/redsocks2.service
  sudo cp ./redsocks2.conf /etc/redsocks2.conf
  sudo cp ./iptables.sh /usr/sbin/iptables.sh

  chmod 644 /lib/systemd/system/redsocks2.service
  chmod 644 /etc/redsocks2.conf
  sudo chmod 755 /usr/sbin/iptables.sh

  sudo systemctl daemon-reload
	sudo systemctl enable redsocks2
}

mk_folder
intstall_redsocks2
create_service
read -p "input your socks5 proxy{example: 192.168.10.1:10808}:" proxy_server
sudo sed -i -e "s/0.0.0.0:88888/${proxy_server}/g" /etc/redsocks2.conf

sudo systemctl start redsocks2
echo "install redsocks2 success"
echo "start proxy: sudo iptables.sh start"
echo "stop proxy: sudo iptables.sh stop"








