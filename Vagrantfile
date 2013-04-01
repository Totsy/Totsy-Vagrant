# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "centos"

  # VM is headless. Uncomment for dispaly.
  # config.vm.boot_mode = :gui
  config.vm.customize ["modifyvm", :id, "--memory", 6144]

  #config.vm.host_name = "www.totsy.local"
  config.vm.network :hostonly, "192.168.33.10"

  config.vm.forward_port 80, 80         #nginx
  config.vm.forward_port 3306, 3306     #mysql

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.module_path = "puppet/modules"
    puppet.options = ['--verbose']
  end

  # masking required for *nix system permission issues
  config.vm.share_folder "www", "/vagrant-www", "www", {:extra => 'dmode=777,fmode=777'}

  # allow symlinks in vm
  config.vm.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
end
