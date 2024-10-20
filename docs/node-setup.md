# Setting Up a Kubernetes Cluster Node on a Virtual Machine

This guide provides step-by-step instructions to prepare a Virtual Machine (VM) for setting up Kubernetes cluster nodes.
We will update the system, configure networking, install `containerd`, and set up the required configurations.

## Prerequisites

- A Virtual Machine with Ubuntu (or any supported Linux distribution).
- Sudo privileges to execute administrative commands.
- Access to the terminal.

## Step 1: Update the System

Start by updating the package list and upgrading the installed packages to their latest versions.

```bash
sudo apt update && sudo apt dist-upgrade
```

## Step 2: Install QEMU Guest Agent

Install the QEMU Guest Agent, which helps in communication between the host and guest systems.

```bash
sudo apt install qemu-guest-agent
```

## Step 3: Configure Networking (Optional)

> [!NOTE]  
> Configuring the network is an optional step. By default, many cloud environments automatically manage network
> settings, which may include DHCP. However, if you require a static IP address for specific applications or to ensure
> consistent networking in a Kubernetes setup, follow this section.

### Backup Existing Netplan Configuration

Find and back up the current netplan configuration file.

```bash
CLOUD_INIT_YAML=$(find /etc/netplan/ -name "*.yaml")
sudo cp $CLOUD_INIT_YAML $CLOUD_INIT_YAML.bak
```

### Create a New Netplan Configuration

Create a new netplan configuration file to set a static IP address and define the network routes and DNS servers.

```bash
sudo bash -c 'cat > /etc/netplan/50-cloud-init.yaml <<EOF
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - $(hostname -I | awk "{print \$1}")/24
      routes:
        - to: default
          via: $(ip route | grep default | awk "{print \$3}")
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
      dhcp4: no
EOF'
```

### Apply the Netplan Configuration

Test and apply the new netplan configuration.

```bash
sudo netplan try
```

## Step 4: Install Containerd

Install `containerd`, which is a container runtime used in Kubernetes.

```bash
sudo apt install containerd -y
```

### Verify the Installation

Check the status of the `containerd` service to ensure it is running correctly.

```bash
systemctl status containerd
```

## Step 5: Configure Containerd

### Create Configuration Directory

Create the directory for `containerd` configurations.

```bash
sudo mkdir -p /etcd/containerd
```

### Generate Default Configuration

Generate a default configuration file for `containerd`.

```bash
containerd config default | sudo tee /etcd/containerd/config.toml
```

### Modify Configuration for Systemd Cgroup

Edit the configuration file to enable Systemd cgroup management.

```bash
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etcd/containerd/config.toml
```

## Conclusion

Your VM is now prepared for setting up Kubernetes cluster nodes. You have updated the system, configured the network
with a static IP, installed `containerd`, and set the necessary configurations. You can proceed to install Kubernetes
components such as `kubelet`, `kubeadm`, and `kubectl` to complete your Kubernetes setup.
