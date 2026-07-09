#!/bin/bash
set -e

# 1. SSL Certificates और RSA Keys चेक करें (अगर गायब हैं तो जनरेट करें)
if [ ! -f /etc/ssl/private/ssl-cert-snakeoil.key ]; then
    echo "Generating SSL certificates..."
    make-ssl-cert generate-default-snakeoil --force-overwrite
fi

if [ ! -f /etc/xrdp/rsakeys.ini ]; then
    echo "Generating XRDP RSA keys..."
    xrdp-keygen xrdp /etc/xrdp/rsakeys.ini
fi

# 2. पुराने अनक्लीन शटडाउन के लॉक और PID फाइल्स साफ करें
rm -f /var/run/xrdp*.pid
rm -f /var/run/secrets/xrdp/*
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# 3. D-Bus सिस्टम डेमन शुरू करें (GUI ऐप्स के लिए ज़रूरी है)
mkdir -p /var/run/dbus
service dbus start

# 4. PulseAudio को सही परमिशन के साथ बैकग्राउंड में चलाएं
# --realtime=no Docker कंटेनर में कैप एरर (capabilities error) से बचाता है
pulseaudio --start --system --disallow-exit --disable-shm --realtime=no --exit-idle-time=-1 || true

# 5. XRDP Session Manager को बैकग्राउंड में चलाएं
echo "Starting XRDP Session Manager..."
xrdp-sesman --config /etc/xrdp/sesman.ini

# 6. XRDP Main Daemon को FOREGROUND में चलाएं
# '--nodaemon' का इस्तेमाल करने से Docker कंटेनर एक्टिव रहेगा और बंद नहीं होगा
echo "Starting XRDP Server..."
exec xrdp --nodaemon --config /etc/xrdp/xrdp.ini
