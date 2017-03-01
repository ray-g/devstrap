sed -i 's/archive.ubuntu.com/cn.archive.ubuntu.com/g' /etc/apt/sources.list
apt-get update && apt-get install -y git sudo whiptail apt-transport-https
useradd -s /bin/bash -m -U admin
#/usr/sbin/useradd -p \`openssl passwd -1 $PASS\` $USER
# sudo visudo
# Defaults        env_reset,timestamp_timeout=30