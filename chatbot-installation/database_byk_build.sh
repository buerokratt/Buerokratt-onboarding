#!/bin/bash
#check prerequisites
command -v python3 >/dev/null 2>&1 || { echo >&2 "python is required but it's not installed. "; echo "Installation guide: https://docs.python-guide.org/starting/install3/linux/"; prereq="null"; } && command -v docker >/dev/null 2>&1 || { echo >&2 "docker is required but it's not installed. "; echo "Installation guide: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04"; prereq="null"; } && command -v docker-compose >/dev/null 2>&1 || { echo >&2 "docker-compose is required but it's not installed. "; echo "Installation guide: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-20-04"; prereq="null"; } && command -v psql >/dev/null 2>&1 || { echo >&2 "psql is required but it's not installed. To install use commands"; echo "sudo apt install postgresql-client-common && sudo apt-get install postgresql-client"; prereq="null"; }
if [ "$prereq" == "null" ]; then
    echo "Aborting"; exit 1
fi
#show path of config
config=""
#import $vars from config
safe_tim_db=$(sed 's/safe_tim_db=//g;7q;d' $config)
safe_byk_db=$(sed 's/safe_byk_db=//g;8q;d' $config)
buildpath=$(sed 's/buildpath=//g;9q;d' $config)
dburl=$(sed 's/dburl=//g;17q;d' $config)
bot_name=$(sed 's/bot_name=//g;23q;d' $config)
cd $buildpath
#clone buerokratt repo
git clone https://github.com/buerokratt/Installation-Guides.git
sqlcompose="$buildpath/Installation-Guides/default-setup/backoffice-and-bykstack/sql-db/docker-compose.yml"
backofficompose="$buildpath/Installation-Guides/default-setup/backoffice-and-bykstack/docker-compose.yml"
#replace in files placeholders with $vars
sed -i "s|POSTGRES_PASSWORD=123|POSTGRES_PASSWORD=$safe_tim_db|g;s|POSTGRES_PASSWORD=01234|POSTGRES_PASSWORD=$safe_byk_db|g;s|POSTGRES_PASSWORD=01234|POSTGRES_PASSWORD=$safe_byk_db|g" $sqlcompose
sed -i "s|users-db|$dburl|g" $backofficompose
cd $buildpath
cd Installation-Guides/default-setup/backoffice-and-bykstack/sql-db/
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

give_ownership = """
sudo chown 999:999 cert.crt 
sudo chmod 0600 cert.crt 
 https://stackoverflow.com/questions/55072221/deploying-postgresql-docker-with-ssl-certificate-and-key-with-volumes """

directories = ["users-db", "tim-db"]
 
for directory in directories:
    os.chdir(directory)
    subprocess.check_output(create_cert, shell=True, executable='/bin/bash')
    #give_ownership
    os.chdir("..")
EOF
    )

    python3 -c "$PYCMD"
}
generate-certs
cd tim-db
sudo chown 999:999 key.key
sudo chmod 0600 key.key
sudo chown 999:999 cert.crt
sudo chmod 0600 cert.crt
cd ../users-db
sudo chown 999:999 key.key
sudo chmod 0600 key.key
sudo chown 999:999 cert.crt
sudo chmod 0600 cert.crt
cd ../
docker-compose up -d
if [ $( docker ps -a -f name=users-db | wc -l ) -eq 2 ]; then
  status=$( docker ps -a -f name=users-db | grep users-db 2> /dev/null )
  output=$( echo ${status} | awk '{ print $7}' )
  echo "$output"
  if [ $output == "Up" ]; then
    docker exec users-db bash -c "createdb -O byk -e -U byk byk" #ilma creatimata
    docker run --network=bykstack riaee/byk-users-db:liquibase20220615 bash -c "sleep 5 && liquibase --url=jdbc:postgresql://$dburl:5433/byk?user=byk --password=$safe_byk_db --changelog-file=/master.yml update"
    psqlcommand="insert into configuration(key, value) values ('bot_institution_id', '$bot_name');"
    psqlcommand2='"'$psqlcommand'"'
    docker run --network=bykstack ubuntu:latest bash -c "apt-get -y update && apt-get -y install postgresql-client && PGPASSWORD=$safe_byk_db psql -d byk -U byk -h users-db -p 5432 -c $psqlcommand2 -c 'CREATE EXTENSION hstore;'"
  else
   echo "users-db exists, but is not Up"
  fi

else
  echo "users-db does not exist"
  exit 1 
fi
if [ $( docker ps -a -f name=tim-postgresql | wc -l ) -eq 2 ]; then
  status=$( docker ps -a -f name=tim-postgresql | grep tim-postgresql 2> /dev/null )
  output=$( echo ${status} | awk '{ print $7}' )
  echo "$output"
  if [ $output == "Up" ]; then
    docker exec tim-postgresql bash -c "createdb -O tim -e -U tim tim" # ilma creatimata
  else
   echo "tim-postgresql exists, but is not Up"
  fi
  
else
  echo "tim-postgresql does not exist"
  exit 1 
fi
cd
