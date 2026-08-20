#!/bin/sh
set -e

CONFIG_TEMPLATE="/etc/xray/config.template.json"
CONFIG_JSON="/var/xray/config.json"

if [ -f "$CONFIG_JSON" ]; then
  exec xray run -config "$CONFIG_JSON"
fi

if [ -z "$DEST" ]; then
  echo "missing required env: DEST"
  exit 1
fi

if [ -z "$SHORT_ID" ]; then
  echo "missing required env: SHORT_ID"
  exit 1
fi

mkdir -p "$(dirname "$CONFIG_JSON")"

# Generate private key via xray x25519
KEY_OUTPUT="$(xray x25519)"
PRIVATE_KEY="$(echo "$KEY_OUTPUT" | grep -i 'PrivateKey' | awk '{print $NF}')"
if [ -z "$PRIVATE_KEY" ]; then
  echo "failed to generate private key via xray x25519"
  exit 1
fi
echo "generated new private key via xray x25519"

# Generate client id via xray uuid
CLIENT_ID="$(xray uuid)"
echo "generated client_id: $CLIENT_ID"

DEST_HOST="${DEST%%:*}"

export CLIENT_ID DEST DEST_HOST PRIVATE_KEY SHORT_ID

envsubst '$CLIENT_ID $DEST $DEST_HOST $PRIVATE_KEY $SHORT_ID' \
  < "$CONFIG_TEMPLATE" > "$CONFIG_JSON"
exec xray run -c "$CONFIG_JSON"
