resource "proxmox_vm_qemu" "EmployeeWorkstation" {
  ssh_private_key = tls_private_key.ssh_key.private_key_openssh
  sshkeys         = tls_private_key.ssh_key.public_key_openssh
  target_node = "lab"
  name        = "EmployeeWorkstation"
  iso         = "local:iso/win11s-ci.iso"
  cores       = 4
  memory      = 8192
  disks {
    sata {
      sata0 {
        disk {
          size    = 100
          storage = "local-lvm"
        }
      }
    }
  }
  network {
    model  = "virtio"
    bridge = "vmbr3"
    tag    = 10
  }
  ipconfig0 = "ip=dhcp"
  network {
    model  = "virtio"
    bridge = "vmbr0"
    tag    = -1
  }
  ipconfig1 = "ip=dhcp"

  provisioner "local-exec" {
    command     = "while ! nc -zv ${self.default_ipv4_address} 22; do echo 'Waiting for SSH to be available...' sleep 5 done"
    working_dir = path.module
    interpreter = ["PowerShell", "-Command"]
  }
  provisioner "local-exec" {
    command     = "ansible-playbook -i ${self.default_ipv4_address} -u root --private-key ${self.ssh_private_key} ./tftest/test2024-08-27@16_45_58/EmployeeWorkstation.yml"
    working_dir = path.module
    interpreter = ["PowerShell", "-Command"]
  }
  provisioner "local-exec" {
    command     = <<EOT
        ssh root@${self.default_ipv4_address} "qm set ${self.id} -net1 none"
      EOT
    working_dir = path.module
    interpreter = ["PowerShell", "-Command"]
  }
}

resource "proxmox_vm_qemu" "PatientDatabaseServer" {
  ssh_private_key = tls_private_key.ssh_key.private_key_openssh
  sshkeys         = tls_private_key.ssh_key.public_key_openssh
  target_node = "lab"
  name        = "PatientDatabaseServer"
  iso         = "local:iso/ubuntu-24.04-desktop-amd64.iso"
  cores       = 4
  memory      = 16384
  disks {
    sata {
      sata0 {
        disk {
          size    = 200
          storage = "local-lvm"
        }
      }
    }
  }
  network {
    model  = "virtio"
    bridge = "vmbr3"
    tag    = 10
  }
  ipconfig0 = "ip=dhcp"
  network {
    model  = "virtio"
    bridge = "vmbr0"
    tag    = -1
  }
  ipconfig1 = "ip=dhcp"
  provisioner "local-exec" {
    command     = "while ! nc -zv ${self.default_ipv4_address} 22; do echo 'Waiting for SSH to be available...' sleep 5 done"
    working_dir = path.module
    interpreter = ["PowerShell", "-Command"]
  }
  provisioner "local-exec" {
    command     = "ansible-playbook -i ${self.default_ipv4_address} -u root --private-key ${self.ssh_private_key} ./tftest/test2024-08-27@16_45_58/PatientDatabaseServer.yml"
    working_dir = path.module
    interpreter = ["PowerShell", "-Command"]
  }
  provisioner "local-exec" {
    command     = <<EOT
        ssh root@${self.default_ipv4_address} "qm set ${self.id} -net1 none"
      EOT
    working_dir = path.module
    interpreter = ["PowerShell", "-Command"]
  }
}

resource "proxmox_vm_qemu" "MedicalDeviceServer" {
  ssh_private_key = tls_private_key.ssh_key.private_key_openssh
  sshkeys         = tls_private_key.ssh_key.public_key_openssh
  target_node = "lab"
  name        = "MedicalDeviceServer"
  iso         = "local:iso/ubuntu-24.04-desktop-amd64.iso"
  cores       = 4
  memory      = 16384
  disks {
    sata {
      sata0 {
        disk {
          size    = 200
          storage = "local-lvm"
        }
      }
    }
  }
  network {
    model  = "virtio"
    bridge = "vmbr3"
    tag    = 10
  }
  ipconfig0 = "ip=dhcp"
  network {
    model  = "virtio"
    bridge = "vmbr0"
    tag    = -1
  }
  ipconfig1 = "ip=dhcp"

  provisioner "local-exec" {
    command     = "while ! nc -zv ${self.default_ipv4_address} 22; do echo 'Waiting for SSH to be available...' sleep 5 done"
    working_dir = path.module
    interpreter = ["PowerShell", "-Command"]
  }
  provisioner "local-exec" {
    command     = "ansible-playbook -i ${self.default_ipv4_address} -u root --private-key ${self.ssh_private_key} ./tftest/test2024-08-27@16_45_58/MedicalDeviceServer.yml"
    working_dir = path.module
    interpreter = ["PowerShell", "-Command"]
  }
  provisioner "local-exec" {
    command     = <<EOT
        ssh root@${self.default_ipv4_address} "qm set ${self.id} -net1 none"
      EOT
    working_dir = path.module
    interpreter = ["PowerShell", "-Command"]
  }
}

resource "proxmox_vm_qemu" "AdminServicesServer" {
  ssh_private_key = tls_private_key.ssh_key.private_key_openssh
  sshkeys         = tls_private_key.ssh_key.public_key_openssh
  target_node = "lab"
  name        = "AdminServicesServer"
  iso         = "local:iso/ubuntu-24.04-desktop-amd64.iso"
  cores       = 4
  memory      = 16384
  disks {
    sata {
      sata0 {
        disk {
          size    = 200
          storage = "local-lvm"
        }
      }
    }
  }
  network {
    model  = "virtio"
    bridge = "vmbr3"
    tag    = 10
  }
  ipconfig0 = "ip=dhcp"
  network {
    model  = "virtio"
    bridge = "vmbr0"
    tag    = -1
  }
  ipconfig1 = "ip=dhcp"

  provisioner "local-exec" {
    command     = "while ! nc -zv ${self.default_ipv4_address} 22; do echo 'Waiting for SSH to be available...' sleep 5 done"
    working_dir = path.module
    interpreter = ["PowerShell", "-Command"]
  }
  provisioner "local-exec" {
    command     = "ansible-playbook -i ${self.default_ipv4_address} -u root --private-key ${self.ssh_private_key} ./tftest/test2024-08-27@16_45_58/AdminServicesServer.yml"
    working_dir = path.module
    interpreter = ["PowerShell", "-Command"]
  }
  provisioner "local-exec" {
    command     = <<EOT
        ssh root@${self.default_ipv4_address} "qm set ${self.id} -net1 none"
      EOT
    working_dir = path.module
    interpreter = ["PowerShell", "-Command"]
  }
}

