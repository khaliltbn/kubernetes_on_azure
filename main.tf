terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.68.0"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.2"
    }
  }
}


provider "azurerm" {
  subscription_id = local.envs["subscription_id"]
  client_id       = local.envs["client_id"]
  client_secret   = local.envs["client_secret"]
  tenant_id       = local.envs["tenant_id"]
  features {}
}

resource "azurerm_resource_group" "kubernetes_resource_group" {
  name     = "kubernetes_group"
  location = "West Europe"
}

resource "azurerm_virtual_network" "kubernetes_vn" {
  name                = "kubernetes_network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.kubernetes_resource_group.location
  resource_group_name = azurerm_resource_group.kubernetes_resource_group.name
  depends_on = [
  	azurerm_resource_group.kubernetes_resource_group
  ]
}

resource "azurerm_subnet" "kubernetes_subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.kubernetes_resource_group.name
  virtual_network_name = azurerm_virtual_network.kubernetes_vn.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on = [
  	azurerm_virtual_network.kubernetes_vn
  ]
}

resource "azurerm_public_ip" "build_automation_server_public_ip" {
  name                = "basconnect"
  resource_group_name = azurerm_resource_group.kubernetes_resource_group.name
  location            = azurerm_resource_group.kubernetes_resource_group.location
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "cluster_public_ip" {
  name                = "k8sconnect"
  resource_group_name = azurerm_resource_group.kubernetes_resource_group.name
  location            = azurerm_resource_group.kubernetes_resource_group.location
  allocation_method   = "Static"
}




resource "azurerm_network_interface" "worker_node_1_interface" {
  name                = "worker-node-1-nic"
  location            = azurerm_resource_group.kubernetes_resource_group.location
  resource_group_name = azurerm_resource_group.kubernetes_resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.kubernetes_subnet.id
    private_ip_address = "10.0.2.5"
    private_ip_address_allocation = "Static"
  }
}

resource "azurerm_linux_virtual_machine" "worker_node_1" {
  name                = "worker-node-1"
  resource_group_name = azurerm_resource_group.kubernetes_resource_group.name
  location            = azurerm_resource_group.kubernetes_resource_group.location
  size                = "Standard_DS1_v2"
  admin_username      = "khalil"
  network_interface_ids = [
    azurerm_network_interface.worker_node_1_interface.id,
  ]

  admin_ssh_key {
    username   = "khalil"
    public_key = file("~/.ssh/id_rsa.pub")
  }
 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  } 
  
  depends_on = [
  	azurerm_network_interface.worker_node_1_interface
  ]
}



resource "azurerm_network_interface" "worker_node_2_interface" {
  name                = "worker-node-2-nic"
  location            = azurerm_resource_group.kubernetes_resource_group.location
  resource_group_name = azurerm_resource_group.kubernetes_resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.kubernetes_subnet.id
    private_ip_address            = "10.0.2.6"
    private_ip_address_allocation = "Static"
  }
  depends_on = [
  	azurerm_subnet.kubernetes_subnet
  ]
}

resource "azurerm_linux_virtual_machine" "worker_node_2" {
  name                = "worker-node-2"
  resource_group_name = azurerm_resource_group.kubernetes_resource_group.name
  location            = azurerm_resource_group.kubernetes_resource_group.location
  size                = "Standard_DS1_v2"
  admin_username      = local.envs["admin_username_worker2"]
  network_interface_ids = [
    azurerm_network_interface.worker_node_2_interface.id,
  ]

  admin_ssh_key {
    username   = local.envs["admin_username_worker2"]
    public_key = file("~/.ssh/id_rsa.pub")
  }
 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  } 

  depends_on = [
  	azurerm_network_interface.worker_node_2_interface
  ]
}



resource "azurerm_network_interface" "worker_node_3_interface" {
  name                = "worker-node-3-nic"
  location            = azurerm_resource_group.kubernetes_resource_group.location
  resource_group_name = azurerm_resource_group.kubernetes_resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.kubernetes_subnet.id
    private_ip_address            = "10.0.2.7"
    private_ip_address_allocation = "Static"
  }
  depends_on = [
  	azurerm_subnet.kubernetes_subnet
  ]
}

resource "azurerm_linux_virtual_machine" "worker_node_3" {
  name                = "worker-node-3"
  resource_group_name = azurerm_resource_group.kubernetes_resource_group.name
  location            = azurerm_resource_group.kubernetes_resource_group.location
  size                = "Standard_DS1_v2"
  admin_username      = local.envs["admin_username_worker3"]
  network_interface_ids = [
    azurerm_network_interface.worker_node_3_interface.id,
  ]

  admin_ssh_key {
    username   = local.envs["admin_username_worker3"]
    public_key = file("~/.ssh/id_rsa.pub")
  }
 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
}

  depends_on = [
  	azurerm_network_interface.worker_node_3_interface
  ]
}



resource "azurerm_network_interface" "master_node_1_interface" {
  name                = "master-node-1-nic"
  location            = azurerm_resource_group.kubernetes_resource_group.location
  resource_group_name = azurerm_resource_group.kubernetes_resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.kubernetes_subnet.id
    private_ip_address            = "10.0.2.10"
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.cluster_public_ip.id
  }
  depends_on = [
  	azurerm_subnet.kubernetes_subnet
  ]
}

resource "azurerm_linux_virtual_machine" "master_node_1" {
  name                = "master-node-1"
  resource_group_name = azurerm_resource_group.kubernetes_resource_group.name
  location            = azurerm_resource_group.kubernetes_resource_group.location
  size                = "Standard_F2"
  admin_username      = local.envs["admin_username_master1"]
  network_interface_ids = [
    azurerm_network_interface.master_node_1_interface.id,
  ]

  admin_ssh_key {
    username   = local.envs["admin_username_master1"]
    public_key = file("~/.ssh/id_rsa.pub")
  }
 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  } 

  depends_on = [
  	azurerm_network_interface.master_node_1_interface
  ]
}




resource "azurerm_network_interface" "build_automation_server_interface" {
  name                = "build-automation-server-nic"
  location            = azurerm_resource_group.kubernetes_resource_group.location
  resource_group_name = azurerm_resource_group.kubernetes_resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.kubernetes_subnet.id
    private_ip_address            = "10.0.2.9"
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.build_automation_server_public_ip.id
  }
  depends_on = [
  	azurerm_subnet.kubernetes_subnet,
  	azurerm_public_ip.build_automation_server_public_ip
  ]
}

resource "azurerm_linux_virtual_machine" "build_automation_server" {
  name                = "build-automation-server"
  resource_group_name = azurerm_resource_group.kubernetes_resource_group.name
  location            = azurerm_resource_group.kubernetes_resource_group.location
  size                = "Standard_F1"
  admin_username      = local.envs["admin_username_bas"]
  network_interface_ids = [
    azurerm_network_interface.build_automation_server_interface.id,
  ]

  admin_ssh_key {
    username   = local.envs["admin_username_bas"]
    public_key = file("~/.ssh/id_rsa.pub")
  }
 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  
  connection {
    host = "${azurerm_public_ip.build_automation_server_public_ip.ip_address}"
    user = local.envs["admin_username_bas"]
    type = "ssh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-add-repository ppa:ansible/ansible -y",
      "sudo apt update",
      "sudo apt install ansible -y",
      "sudo apt-get update",
      "mkdir ~/ansible.conf",
      "ssh-keyscan -H 127.0.0.1 >> ~/.ssh/known_hosts",
      "ssh-keygen -f ~/.ssh/id_rsa -t rsa -N '' -C 'tbn.khalil@gmail.com'"
    ]
  }
  
  provisioner "file" {
    source      = "./my-playbook.yaml"
    destination = "/home/${local.envs["admin_username_bas"]}/ansible.conf/my-playbook.yaml"
  }
  
  provisioner "file" {
    source      = "./hosts"
    destination = "/home/${local.envs["admin_username_bas"]}/ansible.conf/hosts"
  }
  
  
  provisioner "file" {
    source      = "./kubernetes.yaml"
    destination = "/home/${local.envs["admin_username_bas"]}/ansible.conf/kubernetes.yaml"
  }

  depends_on = [
  	azurerm_network_interface.build_automation_server_interface 
  ]
}

resource "null_resource" "kubernetes" {
  connection {
    host = "${azurerm_public_ip.build_automation_server_public_ip.ip_address}"
    user = local.envs["admin_username_bas"]
    type = "ssh"
  }
  
  provisioner "remote-exec" {
    inline = [
      "ansible-playbook -v -i ./ansible.conf/hosts ./ansible.conf/my-playbook.yaml",
      "ansible-playbook -v -i ./ansible.conf/hosts ./ansible.conf/kubernetes.yaml"
    ]
  }
   depends_on = [
  	azurerm_linux_virtual_machine.build_automation_server ,
  	azurerm_linux_virtual_machine.master_node_1 ,
  	azurerm_linux_virtual_machine.worker_node_1 ,
  	azurerm_linux_virtual_machine.worker_node_2 ,
  	azurerm_linux_virtual_machine.worker_node_3
  ]
}


output "build_automation_server_public_ip_address" {
  value  = "${azurerm_public_ip.build_automation_server_public_ip.ip_address}"
}

output "kubernetes_public_ip_address" {
  value  = "${azurerm_public_ip.cluster_public_ip.ip_address}"
}

