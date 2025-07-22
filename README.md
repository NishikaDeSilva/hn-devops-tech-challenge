# HN DevOps Technical Challenge

This repository contains the code for HN Company DevOps Technical Challenge

## Overview

This repository contains terraform configurations and other scripts to successfully conduct the given technical
challenge.

### Pre-requisite
- An exising azure subscription
- Private/public key pair to configure remote access. 
    1. Run following command to generate keys
        ```
        ssh-keygen -t rsa
        ````
    2. Once prompted provide the location to store these keys.


## How-To Guide

### Connect to Private instance via Jumphost

1. Ideally you need to create a terraform variable (i.e. demo.tfvars) file with following vars added.
   
    ```
    location                 = "uksouth"
    subscription_id          = "AZURE_SUBSCRIPTION_ID"
    environment              = "demo" 
    jumpbox_allow_ips        = JUMP_BOX_ALLOWED_IPS
    ssh_public_key_file_path = "{PATH_TO_SSH_KEYS}.pub"
    ```

    `AZURE_SUBSCRIPTION_ID`:  Azure Subscription ID

    `JUMP_BOX_ALLOWED_IPS` : List of IPs / IP ranges that can access the jump host. It's more secure to restrict IPs without giving public access

    `PATH_TO_SSH_KEYS`: Path given when generating ssh in pre-requisites.

2. Log into Azure. You can use `az login`
3. Run terraform to deploy infrastructure.
   
   ```
   terraform init
   terraform plan -var-file demo.tfvars
   terraform apply -var-file demo.tfvars
   ```
   Note outputs of the deployment `jumpbox_public_ip`, `vm_0_private_ip_address`, `vm_1_private_ip_address`
4. Since we use the same keys file for both jump host and vms, copy the private key into the jump host 
  (In a production environment we should use separate ssh keys to reduce the attack surface in case of a breach)
    ```
    scp -i {PATH_TO_SSH_KEYS} {user}@{jumpbox_public_ip}:~/.ssh/
    ```
    To test the connection SSH into jump host and then into the VM
   ```
   ssh -i {PATH_TO_SSH_KEYS} {user}@{jumpbox_public_ip}
   ssh -i {PATH_TO_SSH_KEYS} {user}@{vm_0_private_ip_address}
   ```

### Mount Storage account fileshare. 

Once required infrastructure is ready (previous step), run the following command(s) to mount a given storage account file share to the Virtual Machines.

```
export JUMPHOST_IP="{jumpbox_public_ip}"
export VM_IPS="{vm_0_private_ip_address} {vm_1_private_ip_address}"
export REMOTE_USER="{user}"
export SSH_KEY_PATH="{PATH_TO_SSH_KEYS}"
export RESOURCE_GROUP_NAME="{resource_group}"
export STORAGE_ACCOUNT_NAME="{storage_account_name}"

./scripts/mount_az_file_share.sh {FILE_SHARE_NAME} {FILE_SHARE_MOUNT_PATH}
```

`FILE_SHARE_NAME`: name of the file share to mount

`FILE_SHARE_MOUNT_PATH`: mount path in virtual machines.

Once this is done, any files we added to the `FILE_SHARE_NAME` will be available in both Virtual Machines.