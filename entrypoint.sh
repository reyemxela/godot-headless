#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  echo "Usage:"
  echo "${container:-docker} run --rm \\"
  echo "  -v .:/project \\"
  echo "  [-v <release-keystore-path>:/keys] \\"
  echo "  ghcr.io/reyemxela/godot-headless:latest \\"
  echo "    [--release-file <keystore base filename>] \\"
  echo "    [--release-user <keystore username>] \\"
  echo "    [--release-pass <keystore password>] \\"
  echo "  [godot options]"
  echo ""
  exit 1
fi

export GODOT_ANDROID_KEYSTORE_RELEASE_PATH=
export GODOT_ANDROID_KEYSTORE_RELEASE_USER=
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD=

ARGS=(
  "--headless"
)

while (( $# )); do
  case "$1" in
    --release-file)
      export GODOT_ANDROID_KEYSTORE_RELEASE_PATH="/keys/$2"
      shift 2
      ;;
    --release-user)
      export GODOT_ANDROID_KEYSTORE_RELEASE_USER="$2"
      shift 2
      ;;
    --release-pass)
      export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD="$2"
      shift 2
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
done

set -- "${ARGS[@]}"

exec godot "$@"