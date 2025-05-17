#!/bin/bash

set -e

CONFIG_FILE="./remote-dev.conf"
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "❌ Config file '$CONFIG_FILE' not found."
  exit 1
fi

COMMAND=""
REMOTE_HOST="$DEFAULT_REMOTE_HOST"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    start|stop|ssh|connect|vscode)
      COMMAND="$1"
      shift
      ;;
    --host|-h)
      shift
      input="$1"
      if [[ "$input" =~ ^[0-9]+$ ]]; then
        REMOTE_HOST="192.168.1.$input"
      else
        REMOTE_HOST="$input"
      fi
      shift
      ;;
    *)
      echo "Usage: $0 {start|stop|ssh|connect|vscode} [-h|--host <IP or last octet>]"
      exit 1
      ;;
  esac
done

RUNTIME=""
if command -v docker &> /dev/null; then
  RUNTIME="docker"
elif command -v podman &> /dev/null; then
  RUNTIME="podman"
else
  echo "❌ Docker or Podman is required but not found."
  exit 1
fi

DECRYPTED_TEMP_VPN_PASS=$(mktemp)
DECRYPTED_TEMP_OVPN=$(mktemp)

ensure_encrypted_credentials() {
  local created_any=false

  if [[ ! -f "$VPN_PASSWORD_FILE" ]]; then
    echo "🔐 VPN password file not found. Creating..."
    read -rp "VPN Username: " vpn_user
    read -rsp "VPN Password: " vpn_pass
    echo
    created_any=true
  fi

  if [[ ! -f "$VPN_CONFIG_FILE" ]]; then
    echo "🔐 VPN config file not found. Creating..."
    echo "Paste your .ovpn config, followed by Ctrl+D:" >&2
    read -r -d '' vpn_config || true
    created_any=true
  fi

  if $created_any; then
    read -rsp "🔑 Enter passphrase to encrypt: " passphrase
    echo

    if [[ -n "$vpn_user" && -n "$vpn_pass" ]]; then
      echo -e "$vpn_user\n$vpn_pass" | \
        openssl enc -aes-256-cbc -pbkdf2 -salt -out "$VPN_PASSWORD_FILE" -pass pass:"$passphrase"
      echo "✅ Encrypted VPN credentials saved to $VPN_PASSWORD_FILE"
    fi

    if [[ -n "$vpn_config" ]]; then
      echo "$vpn_config" | \
        openssl enc -aes-256-cbc -pbkdf2 -salt -out "$VPN_CONFIG_FILE" -pass pass:"$passphrase"
      echo "✅ Encrypted VPN config saved to $VPN_CONFIG_FILE"
    fi
  else
    read -rsp "🔑 Enter passphrase to decrypt credentials: " passphrase
    echo
  fi

  if ! openssl enc -d -aes-256-cbc -pbkdf2 -in "$VPN_PASSWORD_FILE" -pass pass:"$passphrase" -out "$DECRYPTED_TEMP_VPN_PASS"; then
    echo "❌ Failed to decrypt VPN password file."
    exit 1
  fi

  if ! openssl enc -d -aes-256-cbc -pbkdf2 -in "$VPN_CONFIG_FILE" -pass pass:"$passphrase" -out "$DECRYPTED_TEMP_OVPN"; then
    echo "❌ Failed to decrypt VPN config file."
    exit 1
  fi
}

start_container() {
  ensure_encrypted_credentials

  echo "🚀 Starting $APP_NAME container with $RUNTIME..."
  $RUNTIME run -d --rm \
    --name "$CONTAINER_NAME" \
    --privileged \
    -p $PORT_SSH:22 \
    -p $PORT_SSH_FORWARD:2222 \
    -p $PORT_CODE_SERVER:7777 \
    -e VPN_CONFIG_PATH="/etc/openvpn/vpn-config.ovpn" \
    -e REMOTE_SSH_HOST="$REMOTE_HOST" \
    -e REMOTE_SSH_PORT="22" \
    -e REMOTE_CODE_SERVER_HOST="$REMOTE_HOST" \
    -e REMOTE_CODE_SERVER_PORT="7777" \
    -e SSH_USER="$SSH_USER" \
    -e SSH_PASSWORD="$SSH_PASSWORD" \
    -v "$DECRYPTED_TEMP_OVPN":/etc/openvpn/vpn-config.ovpn:ro \
    -v "$DECRYPTED_TEMP_VPN_PASS":/tmp/vpn_password:ro \
    "$IMAGE_NAME"

  echo "✅ Container started. You can now SSH with:"
  echo "   ssh $SSH_USER@localhost -p $PORT_SSH_FORWARD"
  echo "🌐 Code Server: http://localhost:$PORT_CODE_SERVER"
}

ssh_connect() {
  echo "🔐 Waiting for SSH server to become available on port $PORT_SSH_FORWARD..."

  for i in {1..30}; do
    if nc -z localhost $PORT_SSH_FORWARD 2>/dev/null; then
      echo "✅ Port $PORT_SSH_FORWARD is open! Attempting SSH connection..."
      ssh-keygen -R "[localhost]:$PORT_SSH_FORWARD" >/dev/null 2>&1

      for j in {1..10}; do
        printf "\r🔁 SSH attempt %d..." "$j"
        SSH_LOG=$(mktemp)
        if ssh -o StrictHostKeyChecking=accept-new "$SSH_USER@localhost" -p "$PORT_SSH_FORWARD" 2>"$SSH_LOG"; then
          echo -e "\r✅ SSH connected on attempt $j.                        "
          lazy_stop &
          wait $!
          rm -f "$SSH_LOG"
          return
        fi
        sleep 2
        printf "."
      done

      echo -e "\n❌ SSH connection failed. Last error:"
      cat "$SSH_LOG"
      rm -f "$SSH_LOG"
      exit 1
    else
      echo "⏳ Waiting for port... ($i/30)"
      sleep 1
    fi
  done

  echo "❌ Timeout waiting for port $PORT_SSH_FORWARD to open."
  exit 1
}

lazy_stop() {
  echo "👋 SSH session ended. Cleaning up..."
  stop_container
  rm -f "$DECRYPTED_TEMP_VPN_PASS" "$DECRYPTED_TEMP_OVPN"
}

stop_container() {
  echo "🛑 Stopping $APP_NAME container..."
  $RUNTIME stop "$CONTAINER_NAME" || echo "Already stopped"
}

connect() {
  if ! $RUNTIME ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
    echo "🚀 Container not running. Starting..."
    start_container
    sleep 3
  fi
  ssh_connect
}

vscode() {
  if ! $RUNTIME ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
    echo "🚀 Container not running. Starting..."
    start_container
    sleep 3
  fi
  echo "🖥️  Opening VSCode remote session (you will be prompted to pick a folder)..."
  code --new-window --remote "ssh-remote+$SSH_USER@localhost:$PORT_SSH_FORWARD"
}

# Main
case "$COMMAND" in
  start)
    start_container
    ;;
  stop)
    stop_container
    ;;
  ssh)
    ssh_connect
    ;;
  connect)
    connect
    ;;
  vscode)
    vscode
    ;;
  *)
    echo "Usage: $0 {start|stop|ssh|connect|vscode} [-h|--host <IP or last octet>]"
    exit 1
    ;;
esac
