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
        ssh-keygen -t rsa -b 2048
        ````
    2. Once prompted provide the location to store these keys.


## How-To Guide

### Connect to Private instance via Jumphost

1. Ideally you need to create a terraform variable file (i.e. demo.tfvars) with following vars added.
   
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
   terraform plan -var-file {TF_VAR_FILE_PATH}
   terraform apply -var-file {TF_VAR_FILE_PATH}
   ```
   Note outputs of the deployment `jumpbox_public_ip`, `vm_0_private_ip_address`, `vm_1_private_ip_address`, `resource_group_name`, `storage_account_name`
4. Since we use the same keys file for both jump host and vms, copy the private key into the jump host 
  (In a production environment we should use separate ssh keys to reduce the attack surface in case of a breach)
    ```
    scp -i {PATH_TO_SSH_KEYS} {PATH_TO_SSH_KEYS} {user}@{jumpbox_public_ip}:~/.ssh/
    ```
    To test the connection SSH into jump host and then into the VM
   ```
   ssh -i {PATH_TO_SSH_KEYS} {user}@{jumpbox_public_ip}
   ssh -i {PATH_TO_SSH_KEYS} {user}@{vm_0_private_ip_address}
   ```

   `user`: Admin Username (default=adminuser)

### Mount Storage account fileshare. 

Once required infrastructure is ready (previous step), run the following command(s) to mount a given storage account file share to the Virtual Machines.

```
export JUMPHOST_IP="{jumpbox_public_ip}"
export VM_IPS="{vm_0_private_ip_address} {vm_1_private_ip_address}"
export REMOTE_USER="{user}"
export SSH_KEY_PATH="{PATH_TO_SSH_KEYS}"
export RESOURCE_GROUP_NAME="{resource_group_name}"
export STORAGE_ACCOUNT_NAME="{storage_account_name}"

./scripts/mount_az_file_share.sh {FILE_SHARE_NAME} {FILE_SHARE_MOUNT_PATH}
```

`FILE_SHARE_NAME`: name of the file share to mount (default=local)

`FILE_SHARE_MOUNT_PATH`: mount path in virtual machines.

Once this is done, any files we added to the `FILE_SHARE_NAME` will be available in both Virtual Machines.

### Create users and manage SSH 

To create users and manage ssh key for each user follow the instructions below.

> **Note:** *The SSH key management solution for each user is implemented in two parts. First, access to the jumpbox is controlled using Entra ID RBAC, ensuring only authorized organizational users can connect via SSH.([Ref](https://learn.microsoft.com/en-us/entra/identity/devices/howto-vm-sign-in-azure-ad-linux)).* 
> *Second, each private VM is configured with a user-specific SSH key through a cloud-init script. This approach ensures that only organizational users can access the public-facing jumpbox, while providing controlled, individual access to private VMs.*

1. Add following entries to the tfvars file

    ```
    tenant_id                = "AZURE_TENANT_ID"
    entra_ssh_enabled        = true
    entra_id_users           = "LIST_OF_USERS"
    ```
    `AZURE_TENANT_ID`: Tenant ID of the azure organization. Needs to create users
    
    `LIST_OF_USERS`: List of the users (e.g. ["Jane", "Ava", "Nick"]).

2. Run the script to create SSH keys for each user and a cloud-init.yml
    ```
    ./scripts/manage_ssh_keys.sh {TF_VAR_FILE_PATH}
    ```
    `TF_VAR_FILE_PATH`: File path to terraform variables file (i.e. tfvars)

3. Apply Terraform. This will recreate the virtual machines since it's not possible to update the resource with custom data.
    ```
   terraform init
   terraform plan -var-file {TF_VAR_FILE_PATH}
   terraform apply -var-file {TF_VAR_FILE_PATH}
   ```
   Once this is successful, run the step above to **Mount Storage account fileshare**

4. Test functionality
   *to test the functionality you need to log into azure as one of the users that was created. Use `az login`*

   ```
   # Create temporary ssh config for vm
   $ az ssh config -n {jumpbox_vm_name} -g {resource_group_name} --file ./azure-sshconfig

   # Copy users private key to jumpbox vm
   $ scp -F ./azure-sshconfig .ssh/keys/{user_name}/id_rsa 172.167.219.125:./

   # SSH into Jumpbox
   $ az ssh vm -n {jumpbox_vm_name} -g {resource_group_name}

   # SSH into the private vm from Jumpbox
   $ ssh -i id_rsa {user}@{vm_0_private_ip_address}
   ```

   If the login is successful the resources are configured as expected.