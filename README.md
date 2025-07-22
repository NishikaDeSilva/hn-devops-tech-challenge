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


### How-To Guide

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
    scp -i {PATH_TO_SSH_KEYS} adminuser@{jumpbox_public_ip}:~/.ssh/
    ```
5. SSH into jump host and then into the VM
   ```
   ssh -i {PATH_TO_SSH_KEYS} adminuser@{jumpbox_public_ip}
   ssh -i {PATH_TO_SSH_KEYS} adminuser@{vm_0_private_ip_address}
   ```
