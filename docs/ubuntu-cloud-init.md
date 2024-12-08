# How to Customize an Ubuntu CloudInit Image on Proxmox VE

Below are the steps I followed to customize an Ubuntu CloudInit image in Proxmox VE. While it's possible to handle
everything via the CLI, I used a mix of both CLI and GUI based on a guide I followed.

## Step 1: Prepare the Ubuntu CloudInit Image via CLI

1. Open a terminal in Proxmox VE and switch to the root directory:
    ```bash
    cd /root
    ```

2. Create a directory to store the CloudInit images:
    ```bash
    mkdir cloud-init-images
    cd cloud-init-images/
    ```

3. Download the latest Ubuntu CloudInit image:
    ```bash
    wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
    ```

4. Install the necessary tools for customizing the image:
    ```bash
    sudo apt install libguestfs-tools -y
    ```

5. Customize the downloaded image by installing additional tools like `qemu-guest-agent`, `ncat`, `net-tools`, and
   `bash-completion`:
    ```bash
    virt-customize -a jammy-server-cloudimg-amd64.img --install qemu-guest-agent,ncat,net-tools,bash-completion
    ```

6. Convert the image to QCOW2 format for Proxmox compatibility:
    ```bash
    mv jammy-server-cloudimg-amd64.img ubuntu-22.04-minimal-cloudimg-amd64.qcow2
    ```

7. Resize the disk image to 20GB:
    ```bash
    qemu-img resize ubuntu-22.04-minimal-cloudimg-amd64.qcow2 20G
    ```

## Step 2: Create and Configure a Virtual Machine in the GUI

1. In the Proxmox GUI, create a new virtual machine (VM), and assign it an ID (e.g., `9000`) and set its name to
   `ubuntu-2204-template`.

2. In the **OS** tab, select **Do not use any media**.

3. In the **System** tab, enable the **QEMU agent**.

4. In the **Disks** tab, remove the default **scsi0** disk.

5. In the **Memory** tab, you can reduce the memory to **1024** MiB.

## Step 3: Import the Customized Image via CLI

1. Set up the VM’s serial console and VGA configuration:
    ```bash
    sudo qm set 9000 --serial0 socket --vga serial0
    ```

2. Import the customized QCOW2 image into the VM:
    ```bash
    qm importdisk 9000 /root/cloud-init-images/ubuntu-22.04-minimal-cloudimg-amd64.qcow2 local-lvm
    ```

## Step 4: Final Configuration in the GUI

1. In the **Hardware** tab, locate the **Unused Disk** that was just imported. Select it, click **Edit**, and enable:
    - **Discard**
    - **SSD emulation** (under **Advanced Options**, if your local-lvm is on an SSD).

2. In the **Options** tab, go to **Boot Order** and set **scsi0** as the boot device. Make sure it’s moved to the second
   position.

## Step 5: Optional Backup (Recommended)

- Before converting the VM to a template, consider creating a backup to preserve your work.

## Step 6: Convert the VM to a Template

- Once everything is configured, right-click the VM in the Proxmox GUI and select **Convert to template**.
