#!/bin/bash

# 1. DBus सर्विस को शुरू करें (GUI ऐप्स और सिस्टम फंक्शन्स के लिए ज़रूरी है)
service dbus start

# 2. XRDP सर्विस को शुरू करें
service xrdp start

# 3. कंटेनर को एक्टिव रखने और क्रैश से बचाने के लिए xrdp-sesman को फ़ोरग्राउंड में चलाएं
echo "RDP Server is running on port 3389..."
exec xrdp-sesman --nodaemon
