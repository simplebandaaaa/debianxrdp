#!/bin/bash

# अगर आपने कंटेनर रन करते समय CODE एनवायरनमेंट वेरिएबल दिया है तो यह उसे चालू करेगा
if [ -z "$CHROME_CODE" ]; then
    echo "--------------------------------------------------------"
    echo "ERROR: कृपया CHROME_CODE वेरिएबल के साथ रन करें।"
    echo "कोड यहाँ से लें: https://remotedesktop.google.com/headless"
    echo "--------------------------------------------------------"
    exit 1
fi

# Chrome Remote Desktop सर्विस शुरू करना
/opt/google/chrome-remote-desktop/start-host \
    --code="$CHROME_CODE" \
    --redirect-url="https://remotedesktop.google.com/_/oauthredirect" \
    --name="Chromebook-Docker" \
    --pin="123456" # आपका RDP पासवर्ड (6 अंकों का)

# कंटेनर को चालू रखने के लिए
tail -f /dev/null
