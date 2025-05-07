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
      node.vm.network "private_network", ip: "172.42.42.10#{i+1}"
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
    master.vm.synced_folder ".", "/vagrant", disabled: true

    master.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
      v.name = "k3s-master"
      v.memory = 2048
      v.cpus = 1
    end
  end

  # Ansible and Helm
  config.vm.define "control" do |control|
    control.vm.hostname = "control.example.com"
    control.vm.network "private_network", ip: "172.42.42.101"
    control.vm.synced_folder ".", "/vagrant"

    control.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
      v.name = "k3s-control"
      v.memory = 2048
      v.cpus = 1
    end

    # install ansible and run playbook
    control.vm.provision "shell", privileged: false, path: "ansible.sh"

    # install kubectl and Helm
    control.vm.provision "shell", privileged: false, inline: <<-SHELL
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      sudo mv kubectl /usr/local/bin/kubectl
      sudo chmod +x /usr/local/bin/kubectl
      curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
      chmod 700 get_helm.sh
      ./get_helm.sh
    SHELL
  end

end

