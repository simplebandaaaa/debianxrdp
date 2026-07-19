#!/bin/bash
# पुरानी लॉक फाइल्स हटाना
rm -rf /var/run/xrdp/* /var/run/dbus/* /tmp/.X11-unix/X*

# DBus और दोनों सर्विसेस को सीधे बाइनरी से चलाना बिना किसी 'service start' के
dbus-daemon --system --fork

# xrdp-sesman को बैकग्राउंड में चलाना
xrdp-sesman

# xrdp को फ़ोरग्राउंड में चलाना ताकि कंटेनर चालू रहे
echo "RDP running..."
exec xrdp --nodaemon
