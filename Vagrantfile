# -*- mode: ruby -*-
# vi: set ft=ruby :

# Github
github_username = "nketchum"
github_repo     = "Vaprobash"
github_branch   = "nketchum/master"
github_url      = "https://raw.githubusercontent.com/#{github_username}/#{github_repo}/#{github_branch}"

# Github OAuth Token
# See: https://github.com/settings/tokens
# See: https://developer.github.com/changes/2014-12-08-removing-authorizations-token/
github_pat      = "7ae6592c6da0055e094b5c53533733b47c34e7b0"

# Server
hostname        = "trusty.dev"

# Resources
host_os = RbConfig::CONFIG['host_os']
if host_os =~ /darwin/
  # Mac OS Darwin
  server_cpus         = `sysctl -n hw.ncpu`.to_i # 100% host cores
  server_memory       = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 8 # 12.5% host memory
elsif host_os =~ /linux/
  # Linux-compatible
  server_cpus         = `nproc`.to_i
  server_memory       = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 8
else
  # Windows etc
  server_cpus         = 1
  server_memory       = 512
end
server_swap = server_memory

# Local Network
server_ip             = "192.168.44.99"
server_timezone       = "UTC"

# Database Configuration
mysql_root_password   = "123"
mysql_version         = "5.6"
mysql_enable_remote   = "false"
pgsql_root_password   = "123"
mongo_version         = "3.0"
mongo_enable_remote   = "false"

# Languages and Packages
php_timezone          = server_timezone
php_version           = "5.6"
ruby_version          = "latest"
ruby_gems             = [
  "sass",
  "compass"
]
go_version            = "latest"
hhvm                  = "false"

# PHP Options
composer_packages     = [
  "phpunit/phpunit:4.0.*",
  "drush/drush:master-dev"
]

# Webroot
public_folder         = "/vagrant"
nodejs_version        = "latest"
nodejs_packages       = [
  "grunt-cli",
  "gulp",
  "bower",
  "pm2",
]
rabbitmq_user         = "rabbitmq"
rabbitmq_password     = "123"
sphinxsearch_version  = "rel22"

# Configure the Box
Vagrant.configure("2") do |config|
  # Specifiy the box
  config.vm.box = "trusty.dev"
  config.vm.define "trusty" do |the_tango|
  end
  # Assign hostname
  config.vm.hostname = hostname
  # Agent forwarding via SSH
  config.ssh.forward_agent = true

  # Vagrant Hostmanager
  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = false
  else
    warn "Recommended plugin 'vagrant-hostmanager' is not installed. Run 'vagrant plugin install vagrant-hostmanager' to install."
  end

  # Create a static IP
  if Vagrant.has_plugin?("vagrant-auto_network")
    config.vm.network :private_network, :ip => "0.0.0.0", :auto_network => true
  else
    config.vm.network :private_network, ip: server_ip
    config.vm.network :forwarded_port, guest: 80, host: 8000
    #config.vm.network :forwarded_port, guest: 3000, host: 3000   # Node
    #config.vm.network :forwarded_port, guest: 3306, host: 3306   # MySQL
    #config.vm.network :forwarded_port, guest: 5432, host: 5432   # PostgreSQL
    #config.vm.network :forwarded_port, guest: 5672, host: 5672   # RabbitMQ
    #config.vm.network :forwarded_port, guest: 6379, host: 6379   # Redis
    #config.vm.network :forwarded_port, guest: 27017, host: 27017 # MongoDB
  end

  # Use NFS for syncing
  config.vm.synced_folder "/var/www", "/vagrant",
    id: "core",
    :nfs => true,
    :mount_options => ['nolock,vers=3,udp,noatime,actimeo=2,fsc']

  # Customize Homedir
  if File.file?(File.expand_path("~/.gitconfig"))
    # Copy host .gitconfig (if any)
    config.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"
  end

  # VirtualBox Provider
  config.vm.provider :virtualbox do |vb|
    # Set box hostname
    vb.name = hostname
    # Set server cpus
    vb.customize ["modifyvm", :id, "--cpus", server_cpus]
    # Set server memory
    vb.customize ["modifyvm", :id, "--memory", server_memory]
    # Shorten timesync threshold to 10 sec to prevent rejected vendor requests.
    vb.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]
    # Prevent VMs running on Ubuntu to lose internet connection
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  # VMWare Fusion Provider
  config.vm.provider "vmware_fusion" do |vb, override|
    # Specify local or remote box url
    override.vm.box_url = "~/Boxes/ubuntu-14-04-x64-vmware.box"
    # Set server memory
    vb.vmx["memsize"] = server_memory
  end

  # Vagrant-Cachier
  if Vagrant.has_plugin?("vagrant-cachier")
    # Docs: http://fgrehm.viewdocs.io/vagrant-cachier
    config.cache.scope = :box
    config.cache.synced_folder_opts = {
        type: :nfs,
        mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
    }
  else
    warn "Recommeded plugin 'vagrant-cachier' is not installed. Run 'vagrant plugin install vagrant-cachier' to install."
  end

  # Digital Ocean (provider plugin)
  config.vm.provider :digital_ocean do |provider, override|
    # Docs: https://github.com/smdahlen/vagrant-digitalocean
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.ssh.username = 'vagrant'
    override.vm.box = 'digital_ocean'
    override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
    provider.token = 'YOUR TOKEN'
    provider.image = 'ubuntu-14-04-x64'
    provider.region = 'nyc2'
    provider.size = '512mb'
  end

  # Provision Base Packages
  config.vm.provision "shell", path: "#{github_url}/scripts/base.sh", args: [github_url, server_swap, server_timezone], run: "once"
  # Optimize Base Box
  config.vm.provision "shell", path: "#{github_url}/scripts/base_box_optimizations.sh", privileged: true, run: "once"
  # Provision PHP
  config.vm.provision "shell", path: "#{github_url}/scripts/php.sh", args: [php_timezone, hhvm, php_version], run: "once"
  # Provision Vim
  config.vm.provision "shell", path: "#{github_url}/scripts/vim.sh", args: github_url, run: "once"
  # Provision Docker
  config.vm.provision "shell", path: "#{github_url}/scripts/docker.sh", args: "permissions", run: "once"
  # Provision Nginx Base
  config.vm.provision "shell", path: "#{github_url}/scripts/nginx.sh", args: [server_ip, public_folder, hostname, github_url], run: "once"
  # Provision MySQL
  config.vm.provision "shell", path: "#{github_url}/scripts/mysql.sh", args: [mysql_root_password, mysql_version, mysql_enable_remote], run: "once"
  # Provision PostgreSQL
  config.vm.provision "shell", path: "#{github_url}/scripts/pgsql.sh", args: pgsql_root_password, run: "once"
  # Provision SQLite
  config.vm.provision "shell", path: "#{github_url}/scripts/sqlite.sh", run: "once"
  # Provision MongoDB
  config.vm.provision "shell", path: "#{github_url}/scripts/mongodb.sh", args: [mongo_enable_remote, mongo_version], run: "once"
  # Install Memcached
  config.vm.provision "shell", path: "#{github_url}/scripts/memcached.sh", run: "once"
  # Provision Redis (without journaling and persistence)
  config.vm.provision "shell", path: "#{github_url}/scripts/redis.sh", run: "once"
  # Install RabbitMQ
  config.vm.provision "shell", path: "#{github_url}/scripts/rabbitmq.sh", args: [rabbitmq_user, rabbitmq_password], run: "once"
  # Install Nodejs
  config.vm.provision "shell", path: "#{github_url}/scripts/nodejs.sh", privileged: false, args: nodejs_packages.unshift(nodejs_version, github_url), run: "once"
  # Provision Composer
  config.vm.provision "shell", path: "#{github_url}/scripts/composer.sh", privileged: false, args: [github_pat, composer_packages.join(" ")], run: "once"
  # Install Mailcatcher
  config.vm.provision "shell", path: "#{github_url}/scripts/mailcatcher.sh", run: "once"
  # Install git-ftp
  config.vm.provision "shell", path: "#{github_url}/scripts/git-ftp.sh", privileged: false, run: "once"

  ####
  # Local Scripts
  ##########

  # Miscellaneous Customizations
  config.vm.provision "shell", path: "./local-script.sh", run: "once"

end
