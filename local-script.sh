#!/usr/bin/env bash

echo ">>> Installing Xtra Apt Packages"
sudo apt-get install htop iotop

echo ">>> Installing Drush"
composer global require drush/drush:dev-master

echo ">>> Installing Drupal Console"
curl https://drupalconsole.com/installer -L -o drupal.phar
sudo mv drupal.phar /usr/local/bin/drupal
sudo chmod +x /usr/local/bin/drupal
drupal init --override

echo ">>> Configuring Environments"
printf "\n\n# Miscellaneous binaries\nexport PATH=\"\$PATH:\$HOME/bin:\$HOME/.bin:./bin:./.bin\"" >> /home/vagrant/.profile
sudo sed -i "s/;always_populate_raw_post_data = .*/always_populate_raw_post_data = -1/" /etc/php5/fpm/php.ini
sudo service php5-fpm restart

echo ">>> Customizing Homedir"
touch ~/.hushlogin
ln -svf /vagrant ~/www
ln -svf /vagrant/scripts/bin ~/.bin