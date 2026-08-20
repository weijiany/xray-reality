#!/bin/sh
set -e

CONFIG_TEMPLATE="/etc/xray/config.template.json"
CONFIG_BASE_DIR="/var/xray"
CONFIG_JSON="${CONFIG_BASE_DIR}/config.json"

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
PUBLIC_KEY="$(echo "$KEY_OUTPUT" | grep -i 'PublicKey' | awk '{print $NF}')"

echo "generated new private key via xray x25519"

# Generate client id via xray uuid
CLIENT_ID="$(xray uuid)"
echo "generated client_id: $CLIENT_ID"

DEST_HOST="${DEST%%:*}"
DEST_PORT="${DEST##*:}"
[ "$DEST_PORT" != "$DEST_HOST" ] || DEST_PORT="443"

HOST_IP="$(curl -4 --max-time 3 -fsSL ip.sb 2>/dev/null)"

LINK="vless://${CLIENT_ID}@${HOST_IP}:${DEST_PORT}?tls=1&peer=${DEST_HOST}&xtls=2&pbk=${PUBLIC_KEY}&sid=${SHORT_ID}&fingerprint=Chrome140&remark=${HOST_IP}"
echo "----------------------"
echo "vless_link: $LINK" > "${CONFIG_BASE_DIR}/vless-link"
cat "${CONFIG_BASE_DIR}/vless-link"
echo "----------------------"

export CLIENT_ID DEST DEST_HOST DEST_PORT PRIVATE_KEY SHORT_ID HOST_IP PUBLIC_KEY

envsubst '$CLIENT_ID $DEST $DEST_HOST $PRIVATE_KEY $SHORT_ID' \
  < "$CONFIG_TEMPLATE" > "$CONFIG_JSON"
exec xray run -c "$CONFIG_JSON"
