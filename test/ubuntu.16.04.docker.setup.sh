sed -i 's/archive.ubuntu.com/cn.archive.ubuntu.com/g' /etc/apt/sources.list
apt-get update && apt-get install -y git sudo whiptail apt-transport-https
useradd -s /bin/bash -m -U admin
