# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'


Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  WorkerNodes = 2
  config.ssh.forward_agent = true

  # Worker nodes
  (1..WorkerNodes).each do |i|
    config.vm.define "worker#{i}" do |node|
      node.vm.hostname = "worker#{i}.example.com"
      node.vm.network "private_network", ip: "172.42.42.10#{i}"
      node.vm.synced_folder ".", "/vagrant", disabled: true

      node.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
        v.name = "k3s-worker#{i}"
        v.memory = 1024
        v.cpus = 1
      end

    end
  end

  # Master node
  config.vm.define "master" do |master|
    master.vm.hostname = "master.example.com"
    master.vm.network "private_network", ip: "172.42.42.100"
    master.vm.synced_folder ".", "/vagrant"

    master.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
      v.name = "k3s-master"
      v.memory = 2048
      v.cpus = 1
    end

    # install ansible and run playbook
    master.vm.provision "shell", privileged: false, path: "ansible.sh"
  end

end

