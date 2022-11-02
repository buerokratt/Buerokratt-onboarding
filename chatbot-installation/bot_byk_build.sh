#!/bin/bash
alias bot_byk_build="./bot_byk_build.sh"
#check prerequisites
command -v python3 >/dev/null 2>&1 || { echo >&2 "python is required but it's not installed. "; echo "Installation guide: https://docs.python-guide.org/starting/install3/linux/"; prereq="null"; } && command -v docker >/dev/null 2>&1 || { echo >&2 "docker is required but it's not installed. "; echo "Installation guide: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04"; prereq="null"; } && command -v docker-compose >/dev/null 2>&1 || { echo >&2 "docker-compose is required but it's not installed. "; echo "Installation guide: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-20-04"; prereq="null"; }
if [ "$prereq" == "null" ]; then
    echo "Aborting"; exit 1
fi
#show path of config
config=""
#import $vars from config
buildpath=$(sed 's/buildpath=//g;9q;d' $config)
cd $buildpath
git clone https://github.com/buerokratt/Installation-Guides.git
cd Installation-Guides
cd $buildpath/Installation-Guides/default-setup/chatbot-and-training/bot/
docker-compose up -d

cd
exec bash
