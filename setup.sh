#!/bin/sh
set -e

IMAGE="${XRAY_IMAGE:-ghcr.io/weijiany/xray-reality:xray-v26.6.27}"
CONTAINER_NAME="${XRAY_CONTAINER_NAME:-xray}"

usage() {
  cat <<'EOF'
Usage:
  ./setup.sh
  ./setup.sh --dest DEST --short-id SHORT_ID

Options:
  --dest DEST            VLESS REALITY dest (example: www.microsoft.com:443)
  --short-id SHORT_ID    REALITY short id (example: 0123456789abcdef)
  -h, --help             Show this help

Environment:
  XRAY_IMAGE             Docker image name (default: xray-reality)
  XRAY_CONTAINER_NAME    Docker container name (default: xray)
EOF
}

DEST="${DEST:-}"
SHORT_ID="${SHORT_ID:-}"

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --dest)
      [ $# -ge 2 ] || { echo "missing value for $1"; exit 1; }
      DEST="$2"
      shift 2
      ;;
    --short-id)
      [ $# -ge 2 ] || { echo "missing value for $1"; exit 1; }
      SHORT_ID="$2"
      shift 2
      ;;
    *)
      echo "unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [ -z "$DEST" ]; then
  printf 'Dest (example: www.microsoft.com:443): '
  read -r DEST
fi

if [ -z "$SHORT_ID" ]; then
  printf 'Short ID (example: 0123456789abcdef): '
  read -r SHORT_ID
fi

if [ -z "$DEST" ]; then
  echo "dest is required"
  exit 1
fi

if [ -z "$SHORT_ID" ]; then
  echo "short_id is required"
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is not installed or not in PATH"
  exit 1
fi

docker run --rm \
  -p 443:443 \
  --restart always \
  -v ${HOME}/data/config.json:/var/xray/config.json \
  --name xray \
  -e DEST="$DEST" \
  -e SHORT_ID="$SHORT_ID" \
  -d \
  "$IMAGE"

sleep 1

docker logs xray | grep vless_link
