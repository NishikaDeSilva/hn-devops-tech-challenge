#!/bin/bash

set -euo pipefail

# Enable debug logging if DEBUG=true
DEBUG=${DEBUG:-false}
log() {
    echo "[INFO] $1"
}

error_exit() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Input tfvars file
TFVARS_FILE="${1:-}"
KEY_DIR=".ssh/keys"
CLOUD_INIT_DIR="files"
CLOUD_INIT_FILE="${CLOUD_INIT_DIR}/cloud-init.yml"

# --- Validation ---
[[ -z "$TFVARS_FILE" ]] && error_exit "Usage: $0 <path-to-tfvars-file>"
[[ ! -f "$TFVARS_FILE" ]] && error_exit "File not found: $TFVARS_FILE"

# --- Create directories ---
log "Creating directories: $KEY_DIR, $CLOUD_INIT_DIR"
mkdir -p "$KEY_DIR" || error_exit "Failed to create key directory"
mkdir -p "$CLOUD_INIT_DIR" || error_exit "Failed to create cloud-init directory"

# --- Extract user list ---
log "Extracting users from $TFVARS_FILE"
USER_LIST=$(grep '^entra_id_users' "$TFVARS_FILE" | awk -F'=' '{gsub(/[\[\]" ]/, "", $2); print $2}' | tr ',' '\n')

if [[ -z "$USER_LIST" ]]; then
    error_exit "No users found in $TFVARS_FILE under 'entra_id_users'"
fi

log "Found users: $USER_LIST"

# --- Write initial cloud-init file ---
log "Creating cloud-init file at $CLOUD_INIT_FILE"
cat <<EOF > "$CLOUD_INIT_FILE"
#cloud-config
users:
EOF

# --- Generate SSH keys & update cloud-init ---
for USER in $USER_LIST; do
    USER_KEY_DIR="${KEY_DIR}/${USER}"
    mkdir -p "$USER_KEY_DIR" || error_exit "Failed to create key dir for $USER"

    PRIVATE_KEY="${USER_KEY_DIR}/id_rsa"
    PUBLIC_KEY="${PRIVATE_KEY}.pub"

    if [[ ! -f "$PRIVATE_KEY" ]]; then
        log "Generating SSH key for $USER"
        ssh-keygen -q -t rsa -b 2048 -f "$PRIVATE_KEY" -N "" -C "$USER@cloud-init" || error_exit "SSH keygen failed for $USER"
    else
        log "SSH key already exists for $USER, skipping keygen"
    fi

    PUB_KEY_CONTENT=$(<"$PUBLIC_KEY") || error_exit "Failed to read public key for $USER"

    # Append user to cloud-init file
    cat <<EOF >> "$CLOUD_INIT_FILE"
  - name: $USER
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash
    ssh_authorized_keys:
      - $PUB_KEY_CONTENT
EOF
done

log "cloud-init.yml and SSH keys generated successfully."
