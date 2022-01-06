#------------------------------------------------------------------------------------------- 
# Настройка провайдера
#------------------------------------------------------------------------------------------- 
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.61.0"
    }
  }
}

provider "yandex" {
  token     = "AQAAAAAG0cZqAATuwZYU1VuB9kDIskE6A0StSfY"  #"<OAuth>" пароль token
  cloud_id  = "aje697tjfiaj6i43o108"  #"<идентификатор облака>"
  folder_id = "b1guch9inm7uijbsh39j"  #"<идентификатор каталога>"
  zone      = "ru-central1-b"         #"<зона доступности по умолчанию>"
}
#------------------------------------------------------------------------------------------- 
# План инфраструктуры
#------------------------------------------------------------------------------------------- 
# Настройка ВМ
#------------------------------------------------------------------------------------------- 

resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80viupr3qjr5g6g9du"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
	user-data = "${file("./user-data.txt")}"
  }
}

resource "yandex_compute_instance" "vm-2" {
  name = "terraform2"

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd80viupr3qjr5g6g9du"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
	user-data = "${file("./user-data.txt")}"
  }
}
#------------------------------------------------------------------------------------------- 
# Настройка сети
#------------------------------------------------------------------------------------------- 
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

#------------------------------------------------------------------------------------------- 
# Настройка адрессов сети
#------------------------------------------------------------------------------------------- 
output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}


output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

output "external_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
}
