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

echo "Setting up everything for bykstack in '$buildpath'"
installationguides_dir="$buildpath/Installation-Guides/"
if [ -d "$installationguides_dir" ]; then
    echo "$installationguides_dir: directory exists, refreshing it"
    cd "$installationguides_dir" && \
        git fetch && \
        git pull
else
    git clone https://github.com/buerokratt/Installation-Guides.git "$installationguides_dir"
fi

bykstack_dir="$installationguides_dir/default-setup/backoffice-and-bykstack"

publicurls="$bykstack_dir/ruuter/public.urls.docker.json"
privateurls="$bykstack_dir/ruuter/private.urls.docker.json"
chatindex="$bykstack_dir/chat-widget/index.html"
chatnginx="$bykstack_dir/chat-widget/nginx.conf"
dmapperindex="$bykstack_dir/dmapper/index.html"
dmappernginx="$bykstack_dir/dmapper/nginx.conf"
envconfig="$bykstack_dir/customer-support/env-config.js"
customernginx="$bykstack_dir/customer-support/nginx.conf"
timdockercompose="$bykstack_dir/tim/docker-compose.yml"
backofficompose="$bykstack_dir/docker-compose.yml"

# replace in files placeholders with config values
sed -i "s|http://BOT_IP:5005|http://$bot_url|g;
    s|TRAINIG_BOT_PRIVATE_SSH_KEY_PATH|/home/ubuntu/.ssh/id_rsa|g;
    s|TRAINING_BOT_USERNAME|$training_user|g;
    s|TRAINING_DATA_DIRECTORY|$training_bot_data_dir|g;
    s|TRAINIG_BOT|$training_host|g" "$publicurls"
sed -i "s|http://BOT_IP:5005|$bot_url|g;
    s|TRAINIG_BOT_PRIVATE_SSH_KEY_PATH|/home/ubuntu/.ssh/id_rsa|g;
    s|TRAINING_BOT_USERNAME|$training_user|g;
    s|TRAINING_DATA_DIRECTORY|$training_bot_data_dir|g;
    s|TRAINIG_BOT|$training_host|g" "$privateurls"
sed -i "s|https://ruuter.test.buerokratt.ee|$public_ruuter_url|g;
    s|https://TIM_URL|$tim_url|g;
    s|https://URL_WHERE_TO_WIDGET_IS_INSTALLED|$widget_url|g" "$chatindex"
sed -i "s|https://URL_WHERE_TO_WIDGET_IS_INSTALLED|$widget_url|g" "$chatnginx"
sed -i "s|https://localhost PUBLIC-RUUTER_URL|$public_ruuter_url|g;
    s|https://localhost TIM_URL|$tim_url|g;
    s|https://localhost URL_WHERE_TO_WIDGET_IS_INSTALLED|$widget_url|g" "$dmapperindex"
sed -i "s|https://localhost FIRST_PAGE_WITH_WIDGET|$widget_url|g" "$dmappernginx"
sed -i "s|https://PRIVATE_RUUTER_URL|$private_ruuter_url|g;
    s|https://TIM_URL|$tim_url|g;
    s|https://CUSTOMER_SERVICE_URL|$backoffice_url|g" "$envconfig"
sed -i "s|https://RUUTER_URL|$public_ruuter_url|g;
    s|https://TIM_URL|$tim_url|g;
    s|https://CUSTOMER_SERVICE_URL|$backoffice_url|g;
    s|https://PRIV-RUUTER_URL|$private_ruuter_url|g" "$customernginx"
sed -i "s|\(spring.datasource.password\)=123|\1=$tim_db_password|g;
    s|\(POSTGRES_PASSWORD\)=123|\1=$byk_db_password|g" "$timdockercompose"
sed -i "s|\(sessionCookieDomain\)=buerokratt.ee|\1=$domain|g;
    s|https://buerokratt.ee|$backoffice_url|g;
    s|https://buerokratt.ee|$backoffice_url|g;
    s|https://admin.buerokratt.ee|$widget_url|g;
    s|https://tim.buerokratt.ee|$tim_url|g;
    s|postgresql://tim-postgresql:5432/tim|$tim_db_uri|g;
    s|\(spring.datasource.password\)=123|\1=$tim_db_password|g;
    s|postgresql://users-db:5433/byk|$byk_db_uri|g;
    s|\(security.oauth2.client.user-authorization-uri\)=https://tara-test.ria.ee/oidc/authorize|\1=$tara_client_user_authorization_uri|g;
    s|\(security.oauth2.client.access-token-uri\)=https://tara-test.ria.ee/oidc/token|\1=$tara_client_access_token_uri|g;
    s|\(security.oauth2.resource.jwk.key-set-uri\)=https://tara-test.ria.ee/oidc/jwks|\1=$tara_client_jwk_key_set_uri|g;
    s|tara_client_id|$tara_client_id|g;
    s|tara_client_secret|$tara_client_secret|g;
    s|https://tim.byk.buerokratt.ee|$tim_url|g;
    s|https://admin.byk.buerokratt.ee|$backoffice_url|g;
    s|https://byk.buerokratt.ee|$widget_url|g;
    s|https://ruuter.byk.buerokratt.ee|$public_ruuter_url|g;
    s|https://priv-ruuter.byk.buerokratt.ee|$private_ruuter_url|g;
    s|https://priv-ruuter.buerokratt.ee|$private_ruuter_url|g;
    s|- /home/ubuntu/.ssh/id_rsa|- $training_prv_key|g;
    s|\(jwt-integration.signature.issuer\)=byk.buerokratt.ee|\1=$keytoolCN.$keytoolOU.$keytoolC|g;
    s|safe_keystore_password|$keytoolpass|g;
    s|\(password\)=01234|\1=$byk_db_password|g" "$backofficompose"

# tim_keys
cd "$bykstack_dir/tim"
tim_container="tim_byk-tim_1"
if [ -f jwtkeystore.jks ] && [ "$(cat "jwtkeystore.jks")" ]; then
    echo "jwtkeystore.jks: file exists, skipping creating it in $tim_container"
else
    dname="'CN=$keytoolCN, OU=$keytoolOU, O=PLACEHOLDER, L=PLACEHOLDER, S=PLACEHOLDER, C=$keytoolC'"
    docker-compose up -d && \
        docker exec $tim_container bash \-c "keytool -genkeypair -alias jwtsign -keyalg RSA -keysize 2048 -keystore 'jwtkeystore.jks' -validity 3650 -noprompt -dname $dname -storepass $keytoolpass" && \
        docker cp $tim_container:/usr/local/tomcat/jwtkeystore.jks jwtkeystore.jks && \
        # sudo chown $username jwtkeystore.jks
        docker-compose down
fi

cd "$bykstack_dir"
for dir in customer-support ruuter dmapper chat-widget tim resql; do
    cert="$bykstack_dir/$dir/cert.crt"
    key="$bykstack_dir/$dir/key.key"
    if [ -r "$cert" ] && [ "$(cat "$cert")" ]; then
        echo "$cert: certificate file exists, skipping"
        continue
    fi
    eval cert_config="\$$(echo "$dir" | sed 's/-/_/g')_cert"
    eval key_config="\$$(echo "$dir" | sed 's/-/_/g')_key"
    if [ "$cert_config" ]; then
        if [ ! -f "$cert_config" ]; then
            echo "$cert_config: file does not exist, but is configured to be used for '$cert'! Aborting."
            exit 1
        fi
        cp -pv "$cert_config" "$cert"
        cp -pv "$key_config" "$key"
    else
        openssl req -out "$cert" -keyout "$key" -newkey rsa:4096 -x509 -sha256 -days 3980 -nodes -subj "$default_cert_subj"
    fi
done

# bykstack
docker-compose up -d
