import datetime
import json
import os
import shutil


class TFBuilder:

    def __init__(self, configpath: str, tfconfigpath: str):
        f = open(configpath)
        self.dirname = "tftest/test" + datetime.datetime.today().strftime('%Y-%m-%d@%H_%M_%S')
        os.mkdir(self.dirname)
        shutil.copy(tfconfigpath, self.dirname)
        jdict = json.load(f)
        self.resources = {}
        self.node = jdict["target_node"]
        self.isos = jdict["cloud_images_available"]
        self.networkbridge = jdict["internal_network"]["network_bridge"]
        self.netModel = jdict["internal_network"]["network_model"]
        self.tag = jdict["internal_network"]["tag"]
        self.internetBridge = jdict["internet_network"]["network_bridge"]
        self.internetModel = jdict["internet_network"]["network_model"]
        self.cli_loc = jdict["cli_location"]
        self.storagePool = jdict["storage_pool"]
        res = jdict["resources"]
        self.maxRam = int(''.join(c for c in res["availableRam"] if c.isdigit()))
        self.maxcpuCores = int(''.join(c for c in res["availableCPU_cores"] if c.isdigit()))
        self.maxStorage = int(''.join(c for c in res["available_disk_storage"] if c.isdigit()))

    def getlimitations(self):
        return f"CpuCoresAvailable: {self.maxcpuCores} ; RamAvailable: {self.maxRam}; StorageAvailable: {self.maxStorage}"

    def getOs(self, resName: str):
        res = self.resources[resName]
        return res.iso
    def resourceCheck(self, cpuCores: int, ram: int, storageGB: int) -> (bool, str):

        s = ""
        res = True
        if ram > self.maxRam:
            s += f"Ram exceeded by {ram - self.maxRam}MB"
            res = False

        if cpuCores > self.maxcpuCores:
            if not res:
                s += "\t&\t"
            s += f"Cpu exceeded by {cpuCores - self.maxcpuCores} core"
            res = False

        if storageGB > self.maxStorage:
            if not res:
                s += "\t&\t"
            s += f"Storage exceeded by {storageGB - self.maxStorage}GB"
            res = False
        return res, s

    def addResource(self, name: str, iso: str, cores: int, ram: int, disktype: str, disksize: int, ip: str) -> str:
        ok, mex = self.resourceCheck(cores, ram, disksize)
        if not ok:
            return mex
        self.maxcpuCores -= cores
        self.maxRam -= ram
        self.maxStorage -= disksize
        res = Resource(name, cores, ram, self.cli_loc + iso, self.node)
        res.addDisk(disktype, disksize, self.storagePool)
        res.addNetwork(self.netModel, self.networkbridge, self.tag)
        res.addNetwork(self.internetModel, self.internetBridge, -1)
        res.addIP("ip=dhcp", 1)  # aggiunta network connessione a internet
        res.addIP(ip, 0)
        self.resources[name] = res
        return "ok"

    def build(self):
        f = open(self.dirname + "/main.tf", "a")
        for res in self.resources.values():
            f.write(res.__str__())
        f.close()

    def newPlaybook(self, resName, playbookText):
        path = self.dirname + "/" + resName + ".yml"
        f = open(path, mode="x")
        f.write(playbookText)
        f.close()
        self.resources[resName].setPlaybook(path)


class Network:

    def __init__(self, model, bridge, id: int, tag: int):
        self.id = id
        self.ip = ""
        self.netblock = "network{\nmodel  = \"" + model + "\"\nbridge = \"" + bridge + "\"\ntag = " + str(tag) + "\n}"

    def addip(self, ip):
        self.ip = ip

    def __str__(self):
        s = self.netblock
        s += "\nipconfig" + str(self.id) + " = \"" + self.ip + "\""
        return s


class Disk:
    def __init__(self, sizeGB, storage):
        self.size = sizeGB
        self.storage = storage

    def __str__(self):
        s = f"""size = {self.size} """
        store = f"""storage = "{self.storage}" """
        s = "disk{\n" + s + "\n" + store + "\n}\n"
        return s


class DiskSection:

    def __init__(self):
        self.controllers = {}
        self.admittedTypes = ["ide", "sata", "scsi", "virtio"]
        self.defaultType = "virtio"

    def addDisk(self, typedisk, disk: Disk):
        if typedisk not in self.admittedTypes:
            typedisk = self.defaultType
        if typedisk in self.controllers:
            self.controllers.get(typedisk).append(disk)
        else:
            self.controllers[typedisk] = [disk]

    def __str__(self):
        s = "disks{"
        for tipo in self.controllers.keys():
            i = 0
            s += "\n" + tipo + "{"
            for disco in self.controllers[tipo]:
                s += "\n" + tipo + str(i) + "{\n" + disco.__str__() + "}\n"
                i += 1
            s += "}\n"
        s += "}\n"
        return s


class NetworkBlock:
    def __init__(self):
        self.count = 0
        self.networks: list[Network] = []

    def addNetwork(self, model, bridge, tag):
        net = Network(model=model, bridge=bridge, id=self.count, tag=tag)
        self.count += 1
        self.networks.append(net)

    def addIp(self, i: int, ip: str):
        self.networks[i].addip(ip)

    def __str__(self):
        s = ""
        for n in self.networks:
            s += n.__str__() + "\n"
        return s


class Resource:

    def __init__(self, name: str, cpu: int, ram: int, iso: str, node: str):
        self.nome = name
        self.iso = iso
        self.cpu = cpu
        self.ram = ram
        self.node = node
        self.disks = DiskSection()
        self.net: NetworkBlock = NetworkBlock()
        self.keyblock = """ssh_private_key = tls_private_key.ssh_key.private_key_openssh\nsshkeys = tls_private_key.ssh_key.public_key_openssh\n"""
        self.playbookPath = ""  # placeholder

    def setPlaybook(self, path):
        self.playbookPath = path

    def addNetwork(self, model: str, bridge: str, tag: int):
        self.net.addNetwork(model, bridge, tag)

    def addIP(self, ip: str, i: int):
        self.net.addIp(i, ip)

    def addDisk(self, typ, size, storage):
        d = Disk(size, storage)
        self.disks.addDisk(typ, d)

    def __str__(self):
        s = "resource \"proxmox_vm_qemu\" \"" + self.nome + "\" {\n"
        s += self.keyblock + "\n"
        s += f"target_node = \"{self.node}\"" + "\n"
        s += f"name = \"{self.nome}\"" + "\n"
        s += f"iso = \"{self.iso}\"" + "\n"
        s += "cores = " + str(self.cpu) + "\n"
        s += "memory = " + str(self.ram) + "\n"
        s += self.disks.__str__() + "\n"
        s += self.net.__str__() + "\n"
        if self.playbookPath != "":
            s += printLocalExec(self.playbookPath, os.name)
        s += "}\n\n"
        return s


@staticmethod
def printLocalExec( playbookPath: str, osType: str):
    ip = "self.default_ipv4_address"
    pkey = "self.ssh_private_key"
    id = "self.id"
    shelltype = ""
    if osType == "nt":
        shelltype = "interpreter = [\"PowerShell\", \"-Command\"]\n"
    return ("provisioner \"local-exec\" {\n"
            "    command = \"while ! nc -zv ${"+ip+"} 22;"
            " do echo \'Waiting for SSH to be available...\' sleep 5 done\"\n"
            "    working_dir = path.module\n"
            "    " + shelltype + "}\n provisioner \"local-exec\" {\n "
            "   command     = \"ansible-playbook -i ${" + ip + "} -u root --private-key ${" + pkey + "} ./" + playbookPath + "\"\n"
            "    working_dir = path.module\n "
            "   " + shelltype + "}\n"
            " provisioner \"local-exec\" {\n "
            "   command     = <<EOT\n        ssh root@${" + ip + "} "
            "\"qm set ${" + id + "} -net1 none\"\n    "
            "  EOT\n    working_dir = path.module\n    " + shelltype + "}\n")
