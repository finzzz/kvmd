#! /bin/bash

PYTHON_DIR="/usr/lib/python3.10/site-packages"

./prereq.sh

cat >/etc/modules <<EOF
libcomposite
dwc2
i2c-dev
EOF

# SSL
openssl ecparam -out /etc/kvmd/vnc/ssl/server.key -name prime256v1 -genkey
openssl req -new -x509 -sha256 -nodes -key /etc/kvmd/vnc/ssl/server.key -out /etc/kvmd/vnc/ssl/server.crt -days 3650 -subj "/CN=pikvm"
cp /etc/kvmd/vnc/ssl/server.key /etc/kvmd/nginx/ssl/
cp /etc/kvmd/vnc/ssl/server.crt /etc/kvmd/nginx/ssl/

# Udev Rules
cat >/etc/udev/rules.d/v2-hdmiusb-generic.rules <<EOF
SUBSYSTEM=="gpio*", GROUP="gpio", MODE="0660"
EOF

# Permissions
systemd-sysusers /usr/lib/sysusers.d/kvmd.conf
systemd-sysusers /usr/lib/sysusers.d/kvmd-webterm.conf
chown kvmd:kvmd /etc/kvmd/htpasswd
chown kvmd-ipmi:kvmd-ipmi /etc/kvmd/ipmipasswd
chown kvmd-vnc:kvmd-vnc /etc/kvmd/vncpasswd
chmod 600 /etc/kvmd/*passwd
chown kvmd /var/lib/kvmd/msd
chown kvmd-pst /var/lib/kvmd/pst
mkdir -p /home/kvmd-webterm && chown kvmd-webterm /home/kvmd-webterm

# Fix webterm MOTD
cp armbian/armbian-motd /usr/bin/
sed -i 's/cat \/etc\/motd/armbian-motd/g' /lib/systemd/system/kvmd-webterm.service
systemctl daemon-reload

# Symlinks
ln -s /usr/sbin/nginx /usr/bin/
ln -s /usr/bin/python3 /usr/sbin/python
ln -s /usr/sbin/iptables /usr/bin/iptables
ln -s "${PYTHON_DIR}/kvmd"* /usr/local/lib/python3.10/dist-packages
ln -s /usr/share/tesseract-ocr/*/tessdata /usr/share/tessdata

# MSD storage in root partititon
fallocate -l 8G /mnt/msd
mkfs.ext4 /mnt/msd
mkdir -p /var/lib/kvmd/msd/{images,meta}
chown kvmd -R /var/lib/kvmd/msd/
cp /etc/{fstab,fstab.bak}
[[ ! -f /etc/fstab.bak ]] || echo "/mnt/msd /var/lib/kvmd/msd ext4 defaults,X-kvmd.otgmsd-user=kvmd 0 0" >> /etc/fstab

# Patch OS not supporting force reject
cp patches/force_eject/kvmd/apps/otg/__init__.py "${PYTHON_DIR}/kvmd/apps/otg/"
cp patches/force_eject/kvmd/apps/otgmsd/__init__.py "${PYTHON_DIR}/kvmd/apps/otgmsd/"
cp patches/force_eject/kvmd/plugins/msd/otg/drive.py "${PYTHON_DIR}/kvmd/plugins/msd/otg/"

# Final steps
systemctl disable nginx
systemctl disable kvmd-tc358743 # disable while not using CSI
systemctl enable kvmd-nginx kvmd-webterm kvmd-otg kvmd 
reboot