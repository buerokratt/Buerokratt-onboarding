Deployment structure includes vm-s:<br />
vm-Databases, vm-Bykstack
### 1. Checking Keys
Log in vm-Databases
```
ssh -A username@vm-Databases
```
Check, if other vm-s have access.<br />
This list, must include keys of other vm-s
```
cd
```
```
cat .ssh/authorized_keys
```
If neccesary key is not added, then to find it.<br />
Log in vm-Bykstack
```
ssh -A username@vm-Bykstack
```
location of key, that needs to be copied to vm-Databases
```
cd
```
```
cat .ssh/id_byk.pub
```
### 2. Editing config.txt
Download config.txt<br />
Add neccesary values. (those are used by script, to make deployment faster)<br />
Below can be seen example, how config.txt should look like:<br />
<br />
public_ruuter=https://ruuter.buerokratt.ee<br />
private_ruuter=https://priv-ruuter.buerokratt.ee<br />
tim=https://tim.buerokratt.ee<br />
widget=https://buerokratt.ee<br />
back_office=https://admin.buerokratt.ee<br />
username=ubuntu<br />
safe_tim_db=password1<br />
safe_byk_db=password2<br />
buildpath=/home/ubuntu/buerokratt<br />
timdb=0.0.0.0:5432<br />
taraid=buerokratt_public<br />
tarapass=abcdefg<br />
keytoolCN=abc<br />
keytoolOU=buerokratt<br />
keytoolC=ee<br />
keytoolpass=abcde<br />
dburl=0.0.0.0<br />
bot_url=0.0.0.0:5005<br />
training_url=0.0.0.0<br />
training_user=ubuntu<br />
training_prv_key=/home/.ssh/id_buerokratt<br />
training_bot_dir=buerokratt/chatbot

### 3. Setting up scripts
copy config.txt in all vm-s
```
scp config.txt username@vm-Databases:~/path/
```
Download scripts and copy to vm-s<br />
database_byk_build.sh -> vm-Databases<br />
byk_build.sh -> vm-Bykstack<br />
<br />
Edit scripts, to show path of config.txt file on the line, that looks like:
```
config=
```
Below can be seen example:<br />
config="/home/ubuntu/buerokratt/config.txt"<br />
<br />
Make sure, scripts have executable permissions in their vm-s
```
chmod +x database_byk_build.sh
```
```
chmod +x byk_build.sh
```
### 4. Running scripts
Run the scripts. NOTE. First run the database_byk_build.sh in vm-Databases, then run byk_build.sh in vm-Bykstack
```
./database_byk_build.sh
```
