#!/bin/bash

# Installation de drumservice sur Ubuntu
# en mode sudo

# Variables
app=drumservice
final_path=/var/www/$app
user_name=billerot

# Dépendances système
apt install virtualenv python3-dev python3-virtualenv python3-pip

# Copie de l'application
if [ -d "$final_path" ]; then
  rm -r "$final_path"
fi
mkdir -p $final_path
cp -r * $final_path/
pushd $final_path

# Virtualenv
virtualenv -p python3.6 venv
set +o nounset 
source venv/bin/activate
set -o nounset 
pip install flask
pip install gunicorn
pip install pygame

# gunicorn
sed -i -e "s/__APP_NAME__/$app/g" -e "s/__USER_NAME__/$user_name/g" gunicorn.py

# Set permissions
chown -R $user_name:www-data $final_path

# Log folder
if [ -d "/var/log/$app" ]; then
  rm -r "/var/log/$app"
fi
mkdir -p /var/log/$app
chown -R $app:www-data /var/log/$app

# Systemd config
sed -i -e "s/__APP_NAME__/$app/g" -e "s/__USER_NAME__/$user_name/g" ../scripts/app.service
cp ../scripts/app.service >/etc/systemd/system/$app.service

systemctl daemon-reload
systemctl enable $app
service add $app -l /var/log/$app/access.log

# démarrage
systemctl start $app

popd
