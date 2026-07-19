#!/bin/bash
# पुरानी बची-कुची लॉक फाइल्स को पूरी तरह हटाना
rm -rf /var/run/xrdp/* /var/run/dbus/* /tmp/.X11-unix/X*

# DBus और XRDP को सीधे बाइनरी से शुरू करना (बिना किसी 'service start' के)
dbus-daemon --system --fork
xrdp-sesman
exec xrdp --nodaemon
