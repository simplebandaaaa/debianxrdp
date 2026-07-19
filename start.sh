#!/bin/bash

# 1. अगर पिछली बार क्रैश होने से कोई पुरानी PID फाइल बची हो, तो उसे साफ करें
rm -f /var/run/xrdp/xrdp.pid
rm -f /var/run/xrdp/xrdp-sesman.pid
rm -f /var/run/dbus/pid

# 2. DBus सर्विस को बैकग्राउंड में शुरू करें
service dbus start

# 3. XRDP मेन सर्विस को बैकग्राउंड में शुरू करें
xrdp

# 4. अब sesman को सीधे फ़ोरग्राउंड में चलाएं (बिना 'service xrdp start' के टकराव के)
echo "RDP Server is running safely on port 3389..."
exec xrdp-sesman --nodaemon
