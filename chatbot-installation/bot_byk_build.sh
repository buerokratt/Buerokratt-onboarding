#!/bin/bash

# check prerequisites
for cmd in git docker docker-compose git; do
    if ( ! which "$cmd" > /dev/null 2>&1 ); then
        echo "Command '$cmd' is required, but not installed! Aborting."
        exit 1
    fi
done

if [ "$1" ]; then
    config="$1"
else
    config=config.txt
fi

# read config values
. "$config"

if [ ! "$buildpath" ]; then
    echo "buildpath not set! Make sure you have configured all values in the specified configuration file."
    exit 1
fi

if [ ! -d "$buildpath" ]; then
    mkdir -pv "$buildpath"
fi

cd "$buildpath"
git clone https://github.com/buerokratt/Installation-Guides.git
cd "$buildpath/Installation-Guides/default-setup/chatbot-and-training/bot/"
docker-compose up -d
