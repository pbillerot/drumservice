#!/bin/bash

### Abandon du script

# Installation de drumservice sur Ubuntu
# Rester à la racine du projet
# en mode sudo ./scripts/install.sh

# Variables
app=drumservice
final_path=/var/www/$app
user_name=billerot

# Dépendances système
echo --- Installation des dépendances système
echo --- Répertoire courant : 
pwd

read -rsp $"--- Dépendances système..." -n1 key
apt install virtualenv python3-dev python3-virtualenv python3-pip

# Copie de l'application
read -rsp $"--- Copie de l'application..." -n1 key
if [ -d "$final_path" ]; then
  echo --- Suppression de $final_path
  rm -r "$final_path"
fi
ls -l /var/www

read -rsp $"--- Copie dans $final_path..." -n1 key
mkdir -p $final_path
cp -r * $final_path/
ls -l $final_path

pushd $final_path
echo --- Répertoire courant :
pwd

# Virtualenv
read -rsp $"--- Installation de venv..." -n1 key
virtualenv -p python3.6 venv
set +o nounset 
source venv/bin/activate
set -o nounset 
pip install flask
pip install gunicorn
pip install pygame

# gunicorn
read -rsp $"--- Installation de gunicorn..." -n1 key
sed -i -e "s/__APP_NAME__/$app/g" -e "s/__USER_NAME__/$user_name/g" gunicorn.py

# Set permissions
read -rsp $"--- Permissions sur $final_path..." -n1 key
chown -R $user_name:www-data $final_path
ls -l $final_path

# Log folder
read -rsp $"--- Log..." -n1 key
if [ -d "/var/log/$app" ]; then
  echo --- Suppression de /var/log/$app
  rm -r "/var/log/$app"
fi
mkdir -p /var/log/$app
chown -R $user_name:www-data /var/log/$app
ls -l /var/log

# Systemd config
read -rsp $"--- Systemd config..."  -n1 key
sed -i -e "s/__APP_NAME__/$app/g" -e "s/__USER_NAME__/$user_name/g" ./scripts/app.service
cp ./scripts/app.service /etc/systemd/system/$app.service

read -rsp $"--- Systemctl reload..." -n1 key
systemctl daemon-reload
systemctl enable $app
service add $app.service -l /var/log/$app/access.log

# démarrage
read -rsp $"--- Systemctl reload..." -n1 key
systemctl start $app

popd
