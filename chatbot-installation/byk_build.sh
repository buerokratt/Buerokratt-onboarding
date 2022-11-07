#!/bin/bash
#check prerequisites
command -v python3 >/dev/null 2>&1 || { echo >&2 "python is required but it's not installed. "; echo "Installation guide: https://docs.python-guide.org/starting/install3/linux/"; prereq="null"; } && command -v docker >/dev/null 2>&1 || { echo >&2 "docker is required but it's not installed. "; echo "Installation guide: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04"; prereq="null"; } && command -v docker-compose >/dev/null 2>&1 || { echo >&2 "docker-compose is required but it's not installed. "; echo "Installation guide: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-20-04"; prereq="null"; }
if [ "$prereq" == "null" ]; then
    echo "Aborting"; exit 1
fi
#show path of config
config=""
#import $vars from config
public_ruuter=$(sed 's/public_ruuter=//g;1q;d' $config)
private_ruuter=$(sed 's/private_ruuter=//g;2q;d' $config)
tim=$(sed 's/tim=//g;3q;d' $config)
widget=$(sed 's/widget=//g;4q;d' $config)
back_office=$(sed 's/back_office=//g;5q;d' $config)
username=$(sed 's/username=//g;6q;d' $config)
safe_tim_db=$(sed 's/safe_tim_db=//g;7q;d' $config)
safe_byk_db=$(sed 's/safe_byk_db=//g;8q;d' $config)
buildpath=$(sed 's/buildpath=//g;9q;d' $config)
timdb=$(sed 's/timdb=//g;10q;d' $config)
taraid=$(sed 's/taraid=//g;11q;d' $config)
tarapass=$(sed 's/tarapass=//g;12q;d' $config)
keytoolCN=$(sed 's/keytoolCN=//g;13q;d' $config)
keytoolOU=$(sed 's/keytoolOU=//g;14q;d' $config)
keytoolC=$(sed 's/keytoolC=//g;15q;d' $config)
keytoolpass=$(sed 's/keytoolpass=//g;16q;d' $config)
bot_url=$(sed 's/bot_url=//g;18q;d' $config)
training_url=$(sed 's/training_url=//g;19q;d' $config)
training_user=$(sed 's/training_user=//g;20q;d' $config)
training_prv_key=$(sed 's/training_prv_key=//g;21q;d' $config)
training_bot_dir=$(sed 's/training_bot_dir=//g;22q;d' $config)
cd $buildpath
#clone buerokratt repo
git clone https://github.com/buerokratt/Installation-Guides.git
publicurls="$buildpath/Installation-Guides/default-setup/backoffice-and-bykstack/ruuter/public.urls.docker.json"
privateurls="$buildpath/Installation-Guides/default-setup/backoffice-and-bykstack/ruuter/private.urls.docker.json"
index="$buildpath/Installation-Guides/default-setup/backoffice-and-bykstack/chat-widget/index.html"
chatnginx="$buildpath/Installation-Guides/default-setup/backoffice-and-bykstack/chat-widget/nginx.conf"
envconfig="$buildpath/Installation-Guides/default-setup/backoffice-and-bykstack/customer-support/env-config.js"
customernginx="$buildpath/Installation-Guides/default-setup/backoffice-and-bykstack/customer-support/nginx.conf"
timdockercompose="$buildpath/Installation-Guides/default-setup/backoffice-and-bykstack/tim/docker-compose.yml"
backofficompose="$buildpath/Installation-Guides/default-setup/backoffice-and-bykstack/docker-compose.yml"
#replace in files placeholders with $vars
sed -i "s|http://BOT_IP:5005|http://$bot_url|g;s|TRAINIG_BOT_PRIVATE_SSH_KEY_PATH|$training_prv_key|g;s|TRAINIG_BOT|$training_url|g;s|TRAINING_BOT_USERNAME|$training_user|g;s|TRAINING_DATA_DIRECTORY|$training_bot_dir|g" $publicurls
sed -i "s|http://BOT_IP:5005|http://$bot_url|g;s|TRAINIG_BOT_PRIVATE_SSH_KEY_PATH|$training_prv_key|g;s|TRAINIG_BOT|$training_url|g;s|TRAINING_BOT_USERNAME|$training_user|g;s|TRAINING_DATA_DIRECTORY|$training_bot_dir|g" $privateurls
sed -i "s|https://ruuter.test.buerokratt.ee|$public_ruuter|g;s|https://TIM_URL|$tim|g;s|https://URL_WHERE_TO_WIDGET_IS_INSTALLED|$widget|g" $index
sed -i "s|https://URL_WHERE_TO_WIDGET_IS_INSTALLED|$widget|g" $chatnginx
sed -i "s|https://PRIVATE_RUUTER_URL|$private_ruuter|g;s|https://TIM_URL|$tim|g;s|https://CUSTOMER_SERVICE_URL|$back_office|g" $envconfig
sed -i "s|https://RUUTER_URL|$public_ruuter|g;s|https://TIM_URL|$tim|g;s|https://CUSTOMER_SERVICE_URL|$back_office|g;s|https://PRIV-RUUTER_URL|$private_ruuter|g" $customernginx
sed -i "s|spring.datasource.password=123|spring.datasource.password=$safe_tim_db|g;s|POSTGRES_PASSWORD=123|POSTGRES_PASSWORD=$safe_byk_db|g" $timdockercompose
sed -i "s|spring.datasource.password=123|spring.datasource.password=$safe_tim_db|g;s|https://buerokratt.ee|$back_office|g;s|https://admin.buerokratt.ee|$widget|g;s|https://tim.buerokratt.ee|$tim|g;s|tim-postgresql:5432|$timdb|g;s|tara_client_id|$taraid|g;s|tara_client_secret|$tarapass|g;s|https://tim.byk.buerokratt.ee|$tim|g;s|https://admin.byk.buerokratt.ee|$back_office|g;s|https://byk.buerokratt.ee|$widget|g;s|https://ruuter.byk.buerokratt.ee|$public_ruuter|g;s|https://priv-ruuter.byk.buerokratt.ee|$private_ruuter|g;s|https://priv-ruuter.buerokratt.ee|$private_ruuter|g;s|jwt-integration.signature.issuer=byk.buerokratt.ee|jwt-integration.signature.issuer=$keytoolCN.$keytoolOU.$keytoolC|g;s|safe_keystore_password|$keytoolpass|g;s|password=01234|password=$safe_byk_db|g" $backofficompose
cd Installation-Guides
cd default-setup
cd backoffice-and-bykstack
#tim_keys
cd tim
docker-compose up -d
docker ps -a
keytools="'CN=$keytoolCN, OU=$keytoolOU, O=PLACEHOLDER, L=PLACEHOLDER, S=PLACEHOLDER, C=$keytoolC'"
docker exec tim-byk-tim-1 bash -c "keytool -genkeypair -alias jwtsign -keyalg RSA -keysize 2048 -keystore 'jwtkeystore.jks' -validity 3650 -noprompt -dname $keytools -storepass $keytoolpass"
docker cp tim-byk-tim-1:/usr/local/tomcat/jwtkeystore.jks jwtkeystore.jks
sudo chown $username jwtkeystore.jks
docker-compose down
cd ../
#generate_certs
generate-certs (){
    PYCMD=$(cat <<EOF
import os
import subprocess

create_cert = """openssl req -newkey rsa:4096 \
            -x509 \
            -sha256 \
            -days 3980 \
            -nodes \
            -out cert.crt \
            -keyout key.key \
            -subj "/C=oo/ST=Create/L=your/O=certs/OU=lazy IT Department/CN=default.value"   """

give_ownership = """ https://stackoverflow.com/questions/55072221/deploying-postgresql-docker-with-ssl-certificate-and-key-with-volumes """

directories = ["customer-support", "ruuter", "dmapper", "chat-widget", "tim", "resql"]
 
for directory in directories:
    os.chdir(directory)
    subprocess.check_output(create_cert, shell=True, executable='/bin/bash')
    os.chdir("..")

EOF
    )

    python3 -c "$PYCMD"
}
generate-certs
#bykstack
docker-compose up -d
cd
