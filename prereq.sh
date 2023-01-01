#! /bin/bash

apt update && apt upgrade -y
apt install -y  bc \
                dialog \
                expect \
                gpiod \
                iptables \
                jq \
                nginx \
                python3 \
                python3-aiofiles \
                python3-appdirs \
                python3-asn1crypto \
                python3-async-timeout \
                python3-bottle \
                python3-cffi \
                python3-chardet \
                python3-click \
                python3-colorama \
                python3-cryptography \
                python3-dateutil \
                python3-dbus \
                python3-hidapi \
                python3-idna \
                python3-libgpiod \
                python3-marshmallow \
                python3-more-itertools \
                python3-multidict \
                python3-netifaces \
                python3-packaging \
                python3-passlib \
                python3-pillow \
                python3-pip \
                python3-ply \
                python3-psutil \
                python3-pycparser \
                python3-pyelftools \
                python3-pyghmi \
                python3-pygments \
                python3-pyparsing \
                python3-requests \
                python3-semantic-version \
                python3-setproctitle \
                python3-setuptools \
                python3-six \
                python3-systemd \
                python3-tabulate \
                python3-urllib3 \
                python3-wrapt \
                python3-xlib \
                python3-yaml \
                python3-yarl \
                python3-zstd \
                tesseract-ocr \
                ttyd \
                ustreamer \
                v4l-utils \
                vim

pip3 install    aiohttp==3.8.3 \
                dbus_next==0.2.3 \
                pyserial==3.5 \
                zstandard

# for armbian
mkdir -p /opt/vc/bin/
cp -rf armbian/* /opt/vc/bin

# uncompress platform package first
tar -C / -xf files/kvmd-platform-v2-hdmiusb-generic-3.191-1-any.pkg.tar.xz
ls files/*xz | xargs -I% tar -C / -xf %
