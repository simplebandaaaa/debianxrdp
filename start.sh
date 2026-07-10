#!/bin/bash

# किसी भी पुराने बचे हुए सॉकेट या PID फाइलों को डिलीट करना (ताकि रीस्टार्ट में एरर न आए)
rm -f /var/run/xrdp/xrdp.pid
rm -f /var/run/xrdp/xrdp-sesman.pid
rm -f /var/run/xrdp/xrdp_sesman.socket

# D-Bus और मशीन आईडी को सही से कॉन्फ़िगर और स्टार्ट करना
mkdir -p /var/run/dbus
dbus-uuidgen --ensure
dbus-daemon --system --fork

# XRDP सेशन मैनेजर (sesman) को स्टार्ट करना
xrdp-sesman --nodaemon &

# थोड़ा रुकना ताकि sesman पूरी तरह चालू हो जाए
sleep 2

# मुख्य XRDP सर्वर को फोरग्राउंड में चलाना ताकि कंटेनर बंद न हो
exec xrdp --nodaemon
