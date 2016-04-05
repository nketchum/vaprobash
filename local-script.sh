#!/usr/bin/env bash

PHP_PATH=$1
PHP_CMD=$2

echo ">>> Installing Additional Packages"
sudo apt-get install htop iotop

echo ">>> Installing Drush Utility"
sudo composer global require drush/drush:dev-master

echo ">>> Installing Drupal Console"
curl https://drupalconsole.com/installer -L -o drupal.phar
sudo mv drupal.phar /usr/local/bin/drupal
sudo chmod +x /usr/local/bin/drupal
drupal init --override
printf "\n\n#Drupal Console\nsource \"\$HOME/.console/console.rc\"" >> ~/.profile

echo ">>> Configuring Environment"
printf "\n\n# Export Misc. Binaries\nexport PATH=\"\$PATH:./bin:./.bin:\$HOME/bin:\$HOME/.bin\"" >> ~/.profile
sudo sed -i "s/;always_populate_raw_post_data = .*/always_populate_raw_post_data = -1/" "${PHP_PATH}/fpm/php.ini"
sudo service $PHP_CMD restart

echo ">>> Configuring Home Directory"
touch ~/.hushlogin
ln -sf /vagrant ~/www
ln -sf /vagrant/scripts/bin ~/.bin
if [ -e ~/.bash_profile ]; then sudo rm ~/.bash_profile; fi
if [ -e ~/.zlogin ]; then sudo rm ~/.zlogin; fi