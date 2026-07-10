#!/bin/bash
set -e

# 1. CRITICAL: Ubuntu PAM Authentication फिक्स (इसके बिना पासवर्ड गलत बताएगा)
if [ -f /etc/pam.d/xrdp-sesman ]; then
    # यह लाइन XRDP को बिना किसी एरर के कंटेनर के अंदर पासवर्ड वेरीफाई करने देगी
    sed -i 's/@include common-auth/#@include common-auth/' /etc/pam.d/xrdp-sesman
fi

# 2. SSL Certificates और RSA Keys चेक (Missing होने पर जनरेट करेगा)
if [ ! -f /etc/ssl/private/ssl-cert-snakeoil.key ]; then
    make-ssl-cert generate-default-snakeoil --force-overwrite
fi

if [ ! -f /etc/xrdp/rsakeys.ini ]; then
    xrdp-keygen xrdp /etc/xrdp/rsakeys.ini
fi

# 3. पुरानी लॉक और PID फाइल्स को साफ करना (ताकि दोबारा स्टार्ट करने पर एरर न आए)
rm -f /var/run/xrdp*.pid
rm -f /var/run/secrets/xrdp/*
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# 4. D-Bus सिस्टम डेमन शुरू करें
mkdir -p /var/run/dbus
service dbus start

# 5. PulseAudio को बैकग्राउंड में चलाएं
pulseaudio --start --system --disallow-exit --disable-shm --realtime=no --exit-idle-time=-1 || true

# 6. XRDP Session Manager को बैकग्राउंड में चलाएं
xrdp-sesman --config /etc/xrdp/sesman.ini

# 7. XRDP Main Daemon को FOREGROUND में चलाएं (कंटेनर को चालू रखने के लिए)
echo "XRDP Server is ready! Connect using username 'ubuntu' and password 'ubuntu'."
exec xrdp --nodaemon --config /etc/xrdp/xrdp.ini
