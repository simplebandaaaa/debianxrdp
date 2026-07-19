#!/bin/bash

# 1. पुरानी लॉक फाइल्स को पूरी तरह साफ करें
rm -f /var/run/xrdp/xrdp.pid
rm -f /var/run/xrdp/xrdp-sesman.pid
rm -f /var/run/dbus/pid
rm -rf /tmp/.X11-unix/X*

# 2. D-Bus सर्विस को शुरू करें
service dbus start

# 3. xrdp-sesman को पहले बैकग्राउंड में चलाएं
xrdp-sesman

# 4. xrdp को फ़ोरग्राउंड में चलाएं ताकि कंटेनर एक्टिव रहे और प्रॉक्सी ट्रैफिक ले सके
echo "Starting XRDP server on port 3389..."
exec xrdp --nodaemon
