resource "proxmox_vm_qemu" "VM1" {
  ssh_private_key = tls_private_key.ssh_key.private_key_openssh
  sshkeys         = tls_private_key.ssh_key.public_key_openssh
  target_node = "lab"
  name        = "VM1"
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

    command = "while ! nc -zv ${self.default_ipv4_address} 22; do echo 'Waiting for SSH to be available...' sleep 5 done"

    working_dir = path.module

    interpreter = ["PowerShell", "-Command"]

  }
  provisioner "local-exec" {

    command = "ansible-playbook -i ${self.default_ipv4_address} -u root --private-key ${self.ssh_private_key} ./tftest/test2024-08-26@17_18_58/VM1.yml"

    working_dir = path.module

    interpreter = ["PowerShell", "-Command"]

  }
  provisioner "local-exec" {

    command = <<EOT

        ssh root@${self.default_ipv4_address} "qm set ${self.id} -net1 none"

      EOT

    working_dir = path.module

    interpreter = ["PowerShell", "-Command"]

  }
}

resource "proxmox_vm_qemu" "VM2" {
  ssh_private_key = tls_private_key.ssh_key.private_key_openssh
  sshkeys         = tls_private_key.ssh_key.public_key_openssh
  target_node = "lab"
  name        = "VM2"
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

    command = "while ! nc -zv ${self.default_ipv4_address} 22; do echo 'Waiting for SSH to be available...' sleep 5 done"

    working_dir = path.module

    interpreter = ["PowerShell", "-Command"]

  }
  provisioner "local-exec" {

    command = "ansible-playbook -i ${self.default_ipv4_address} -u root --private-key ${self.ssh_private_key} ./tftest/test2024-08-26@17_18_58/VM2.yml"

    working_dir = path.module

    interpreter = ["PowerShell", "-Command"]

  }
  provisioner "local-exec" {

    command = <<EOT

        ssh root@${self.default_ipv4_address} "qm set ${self.id} -net1 none"

      EOT

    working_dir = path.module

    interpreter = ["PowerShell", "-Command"]

  }
}

resource "proxmox_vm_qemu" "VM3" {
  ssh_private_key = tls_private_key.ssh_key.private_key_openssh
  sshkeys         = tls_private_key.ssh_key.public_key_openssh
  target_node = "lab"
  name        = "VM3"
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

    command = "while ! nc -zv ${self.default_ipv4_address} 22; do echo 'Waiting for SSH to be available...' sleep 5 done"

    working_dir = path.module

    interpreter = ["PowerShell", "-Command"]

  }
  provisioner "local-exec" {

    command = "ansible-playbook -i ${self.default_ipv4_address} -u root --private-key ${self.ssh_private_key} ./tftest/test2024-08-26@17_18_58/VM3.yml"

    working_dir = path.module

    interpreter = ["PowerShell", "-Command"]

  }
  provisioner "local-exec" {

    command = <<EOT

        ssh root@${self.default_ipv4_address} "qm set ${self.id} -net1 none"

      EOT

    working_dir = path.module

    interpreter = ["PowerShell", "-Command"]

  }
}
resource "proxmox_vm_qemu" "VM4" {
  ssh_private_key = tls_private_key.ssh_key.private_key_openssh
  sshkeys         = tls_private_key.ssh_key.public_key_openssh
  target_node = "lab"
  name        = "VM4"
  iso         = "local:iso/ubuntu-24.04-desktop-amd64.iso"
  cores       = 2
  memory      = 4096
  disks {
    sata {
      sata0 {
        disk {
          size    = 50
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

    command = "while ! nc -zv ${self.default_ipv4_address} 22; do echo 'Waiting for SSH to be available...' sleep 5 done"

    working_dir = path.module

    interpreter = ["PowerShell", "-Command"]

  }
  provisioner "local-exec" {

    command = "ansible-playbook -i ${self.default_ipv4_address} -u root --private-key ${self.ssh_private_key} ./tftest/test2024-08-26@17_18_58/VM4.yml"

    working_dir = path.module

    interpreter = ["PowerShell", "-Command"]

  }
  provisioner "local-exec" {

    command = <<EOT

        ssh root@${self.default_ipv4_address} "qm set ${self.id} -net1 none"

      EOT

    working_dir = path.module

    interpreter = ["PowerShell", "-Command"]

  }
}

resource "proxmox_vm_qemu" "VM5" {
  ssh_private_key = tls_private_key.ssh_key.private_key_openssh
  sshkeys         = tls_private_key.ssh_key.public_key_openssh
  target_node = "lab"
  name        = "VM5"
  iso         = "local:iso/win11s-ci.iso"
  cores       = 2
  memory      = 4096
  disks {
    sata {
      sata0 {
        disk {
          size    = 50
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

    command = "while ! nc -zv ${self.default_ipv4_address} 22; do echo 'Waiting for SSH to be available...' sleep 5 done"

    working_dir = path.module

    interpreter = ["PowerShell", "-Command"]

  }
  provisioner "local-exec" {

    command = "ansible-playbook -i ${self.default_ipv4_address} -u root --private-key ${self.ssh_private_key} ./tftest/test2024-08-26@17_18_58/VM5.yml"

    working_dir = path.module

    interpreter = ["PowerShell", "-Command"]

  }
  provisioner "local-exec" {

    command = <<EOT

        ssh root@${self.default_ipv4_address} "qm set ${self.id} -net1 none"

      EOT

    working_dir = path.module

    interpreter = ["PowerShell", "-Command"]

  }
}

