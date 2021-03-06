# -*- mode: ruby -*-
# vi: set ft=ruby :

# Plugins (required)
plugins = { 'vagrant-bindfs' => nil, 'vagrant-reload' => nil }
plugins.each do |plugin, version|
  unless Vagrant.has_plugin? plugin
    error = "Required plugin '#{plugin}' not installed. Install with: 'vagrant plugin install #{plugin}'"
    error += " --plugin-version #{version}" if version
    raise error
  end
end

# Boxes
vb_box_url            = "~/Machines/Boxes/ubuntu-14-04-x64-virtualbox.box"
vm_box_url            = "~/Machines/Boxes/ubuntu-14-04-x64-vmware.box"

# Server
boxname               = "trusty64"
guestname             = "trusty"
hostname              = "trusty.dev"
synced_folder         = "/Users/nketchum/Sites"
vagrant_folder        = "/vagrant"
public_folder         = "/var/www"
server_ip             = "192.168.44.99"
server_timezone       = "UTC"

# Github
github_pat            = "7ae6592c6da0055e094b5c53533733b47c34e7b0"
github_username       = "nketchum"
github_repo           = "Vaprobash"
github_branch         = "nketchum/master"
github_url            = "https://raw.githubusercontent.com/#{github_username}/#{github_repo}/#{github_branch}"

# Databases
mysql_version         = "5.6"
mysql_root_password   = "123"
mysql_enable_remote   = "true"
pgsql_version         = "9.5"
pgsql_root_password   = "123"
mongo_version         = "3.0"
mongo_enable_remote   = "true"

# Packages
hhvm                  = "false"
php_version           = "7.0"
php_timezone          = server_timezone
composer_packages     = ["phpunit/phpunit:4.0.*", "drush/drush:dev-master", "drush/config-extra:dev-master"]
nodejs_version        = "latest"
nodejs_packages       = ["grunt-cli", "gulp", "bower", "pm2", "nginx-generator"]
ruby_version          = "latest"
ruby_gems             = []
rabbitmq_user         = "rabbitmq"
rabbitmq_password     = "123"

###
# Experts-only starting here...
###

host_os = RbConfig::CONFIG['host_os']
if host_os =~ /darwin/
  server_cpus = `sysctl -n hw.ncpu`.to_i
  server_memory = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 8
elsif host_os =~ /linux/
  server_cpus = `nproc`.to_i
  server_memory = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 8
else
  server_cpus = 1
  server_memory = 512
end
server_swap = server_memory

if php_version == "7.0"
  php_path   = "/etc/php/7.0"
  php_cmd    = "php7.0-fpm"
  php_enmod  = "phpenmod"
  php_apache = "php7.0"
else
  php_path   = "/etc/php5"
  php_cmd    = "php5-fpm"
  php_enmod  = "php5enmod"
  php_apache = "php5"
end

Vagrant.configure("2") do |config|
  config.vm.box = boxname
  config.vm.hostname = hostname
  config.vm.define guestname do |the_tango|
  end

  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = false
  end

  if Vagrant.has_plugin?("vagrant-auto_network")
    config.vm.network :private_network, :ip => "0.0.0.0", :auto_network => true
  else
    config.vm.network :private_network, ip: server_ip
    config.vm.network :forwarded_port, guest: 3000, host: 3000 # Node
    config.vm.network :forwarded_port, guest: 3306, host: 3307 # MySQL
  end

  config.ssh.forward_agent = true

  config.vm.synced_folder synced_folder, vagrant_folder,
    id: "core",
    :nfs => true

  if Vagrant.has_plugin?("vagrant-bindfs")
    config.bindfs.bind_folder vagrant_folder, public_folder,
      after: :provision,
      force_user: "www-data",
      force_group: "www-data",
      perms: "u=rwX:g=rwX:o=rD",
      o: 'nonempty'
  end

  if File.file?(File.expand_path("~/.gitconfig"))
    config.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"
  end

  config.vm.provider :virtualbox do |vb, override|
    vb.name = hostname
    vb.customize ["modifyvm", :id, "--cpus", server_cpus]
    vb.customize ["modifyvm", :id, "--memory", server_memory]
    vb.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    override.vm.box_url = vb_box_url
  end

  config.vm.provider "vmware_fusion" do |vb, override|
    vb.vmx["memsize"]   = server_memory
    override.vm.box_url = vm_box_url
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    config.cache.synced_folder_opts = { type: :nfs }
  end

  # Remote Scripts
  config.vm.provision "shell", path: "#{github_url}/scripts/base.sh", args: [github_url, server_swap, server_timezone], run: "once"
  config.vm.provision "shell", path: "#{github_url}/scripts/php.sh", args: [php_timezone, hhvm, php_version, php_path, php_cmd], run: "once"
  config.vm.provision "shell", path: "#{github_url}/scripts/vim.sh", args: github_url, run: "once"
  config.vm.provision "shell", path: "#{github_url}/scripts/docker.sh", args: "permissions", run: "once"
  config.vm.provision "shell", path: "#{github_url}/scripts/nginx.sh", args: [server_ip, public_folder, hostname, github_url, php_path, php_cmd], run: "once"
  config.vm.provision "shell", path: "#{github_url}/scripts/mysql.sh", args: [mysql_root_password, mysql_version, mysql_enable_remote], run: "once"
  config.vm.provision "shell", path: "#{github_url}/scripts/pgsql.sh", args: [pgsql_root_password, pgsql_version], run: "once"
  config.vm.provision "shell", path: "#{github_url}/scripts/sqlite.sh", run: "once"
  config.vm.provision "shell", path: "#{github_url}/scripts/mongodb.sh", args: [mongo_enable_remote, mongo_version, php_path, php_cmd], run: "once"
  config.vm.provision "shell", path: "#{github_url}/scripts/redis.sh", run: "once"
  config.vm.provision "shell", path: "#{github_url}/scripts/memcached.sh", run: "once"
  config.vm.provision "shell", path: "#{github_url}/scripts/rabbitmq.sh", args: [rabbitmq_user, rabbitmq_password], run: "once"
  config.vm.provision "shell", path: "#{github_url}/scripts/nodejs.sh", privileged: false, args: nodejs_packages.unshift(nodejs_version, github_url), run: "once"
  config.vm.provision "shell", path: "#{github_url}/scripts/rvm.sh", privileged: false, args: ruby_gems.unshift(ruby_version), run: "once"
  config.vm.provision "shell", path: "#{github_url}/scripts/composer.sh", privileged: false, args: [github_pat, composer_packages.join(" ")], run: "once"
  config.vm.provision "shell", path: "#{github_url}/scripts/mailcatcher.sh", privileged: false, args: [php_path, php_cmd, php_enmod], run: "once"

  # Local Scripts
  config.vm.provision "shell", path: "./local/local.sh", privileged: false, args: [php_path, php_cmd], run: "once"

  # System Restart
  if Vagrant.has_plugin?("vagrant-reload")
    config.vm.provision :reload
  end

  # Cleanup
  config.vm.provision "shell", path: "#{github_url}/scripts/cleanup.sh"

  # Install Sites
  config.vm.provision "shell", path: "./local/sites.sh", privileged: false, run: "once"

end
