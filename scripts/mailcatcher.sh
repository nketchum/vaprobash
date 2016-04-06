#!/usr/bin/env bash

echo ">>> Installing Mailcatcher"

printf "whoami: %s\n" "$(whoami)" >> ~/test.txt
printf "sudo whoami: %s\n" "$(sudo whoami)" >> ~/test.txt
printf "groups: %s\n" "$(groups)" >> ~/test.txt
printf "sudo groups: %s\n" "$(sudo groups)" >> ~/test.txt
printf "which rvm: %s\n" "$(which rvm)" >> ~/test.txt
printf "sudo which rvm: %s\n" "$(sudo which rvm)" >> ~/test.txt
printf "rvm -v: %s\n" "$(rvm -v)" >> ~/test.txt
printf "sudo rvm -v: %s\n" "$(sudo rvm -v)" >> ~/test.txt
printf "rvm list: %s\n" "$(rvm list)" >> ~/test.txt
printf "sudo rvm list: %s\n" "$(sudo rvm list)" >> ~/test.txt
printf "which ruby: %s\n" "$(which ruby)" >> ~/test.txt
printf "sudo which ruby: %s\n" "$(sudo which ruby)" >> ~/test.txt
printf "ruby --version: %s\n" "$(ruby --version)" >> ~/test.txt
printf "sudo ruby --version: %s\n" "$(sudo ruby --version)" >> ~/test.txt
printf "which gem: %s\n" "$(which gem)" >> ~/test.txt
printf "sudo which gem: %s\n" "$(sudo which gem)" >> ~/test.txt
printf "gem -v: %s\n" "$(gem -v)" >> ~/test.txt
printf "sudo gem -v: %s\n" "$(sudo gem -v)" >> ~/test.txt
printf "gem list --local: %s\n" "$(gem list --local)" >> ~/test.txt
printf "sudo gem list --local: %s\n" "$(sudo gem list --local)" >> ~/test.txt
printf "rvm all do gem list --local: %s\n" "$(rvm all do gem list --local)" >> ~/test.txt
printf "sudo rvm all do gem list --local: %s\n" "$(sudo rvm all do gem list --local)" >> ~/test.txt

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$1

# Test if Apache is installed
apache2 -v > /dev/null 2>&1
APACHE_IS_INSTALLED=$?

if $(which rvm) -v > /dev/null 2>&1; then
	echo ">>>>Installing with RVM"
	$(which rvm) default@mailcatcher --create do gem install --no-rdoc --no-ri mailcatcher
	$(which rvm) wrapper default@mailcatcher --no-prefix mailcatcher catchmail
else
	# Gem check
	if ! gem -v > /dev/null 2>&1; then sudo aptitude install -y libgemplugin-ruby; fi

	# Install
	sudo gem install --no-rdoc --no-ri mailcatcher
fi

printf "which mailcatcher: %s\n" "$(which mailcatcher)" >> ~/test.txt
printf "sudo which mailcatcher: %s\n" "$(sudo which mailcatcher)" >> ~/test.txt
printf "which catchmail: %s\n" "$(which catchmail)" >> ~/test.txt
printf "sudo which catchmail: %s\n" "$(sudo which catchmail)" >> ~/test.txt

# Make it start on boot
sudo tee /etc/init/mailcatcher.conf <<EOL
description "Mailcatcher"

start on runlevel [2345]
stop on runlevel [!2345]

respawn

exec /usr/bin/env $(which mailcatcher) --foreground --http-ip=0.0.0.0
EOL

# Start Mailcatcher
sudo service mailcatcher start

if [[ $PHP_IS_INSTALLED -eq 0 ]]; then
	PHP_PATH=$1
	PHP_CMD=$2
	PHP_ENMOD=$3
	# Make php use it to send mail
  echo "sendmail_path = /usr/bin/env $(which catchmail)" | sudo tee "${PHP_PATH}/mods-available/mailcatcher.ini"
	sudo $PHP_ENMOD mailcatcher
	sudo service $PHP_CMD restart
fi

if [[ $APACHE_IS_INSTALLED -eq 0 ]]; then
	sudo service apache2 restart
fi
