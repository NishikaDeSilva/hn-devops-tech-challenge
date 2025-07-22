#!/bin/bash

# ==================== This script requires following as ENV vars =====================
# JUMPHOST_IP
# VM_IPS
# REMOTE_USER
# SSH_KEY_PATH
# RESOURCE_GROUP_NAME
# STORAGE_ACCOUNT_NAME
# =====================================================================================

set -euo pipefail

# Getting args from command line
FILE_SHARE_NAME="$1"
MOUNT_POINT="$2"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

abort() {
  echo "ERROR: $*" >&2
  exit 1
}

# ------- Fetch Storage Account Key --------
log "Fetching storage account key..."
if ! STORAGE_ACCOUNT_KEY=$(az storage account keys list \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --query "[0].value" --output tsv | tr -d '"'); then
  abort "Failed to retrieve storage account key."
fi

if [[ -z "$STORAGE_ACCOUNT_KEY" ]]; then
  abort "Storage account key is empty."
fi

log "Storage key retrieved."

# ------- Remote command to mount Azure File Share --------
read -r -d '' REMOTE_CMD <<EOF || true
echo "Mounting Azure File Share on remote host..."
sudo mkdir -p "$MOUNT_POINT" || { echo "Failed to create mount point"; exit 1; }
sudo mount -t cifs "//$STORAGE_ACCOUNT_NAME.file.core.windows.net/$FILE_SHARE_NAME" "$MOUNT_POINT" \
  -o username="$STORAGE_ACCOUNT_NAME",password="$STORAGE_ACCOUNT_KEY",serverino,nosharesock,actimeo=30,mfsymlinks,dir_mode=0777,file_mode=0777 || {
    echo "Mount command failed"; exit 1;
  }
echo "Mount successful at $MOUNT_POINT"
EOF

# ------- Loop through VM IPs --------
for ip in $VM_IPS; do
  log "Connecting to VM: $ip via bastion $JUMPHOST_IP"

  if ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no -t "$REMOTE_USER@$JUMPHOST_IP" \
    "ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH -t $REMOTE_USER@$ip '$REMOTE_CMD'"; then
    log "Successfully mounted Azure File Share on $ip"
  else
    log "Failed to mount Azure File Share on $ip"
  fi
done
