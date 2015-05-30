#!/bin/bash
set -euf
set -o pipefail

BASE_PATH=${2:-./client}
KEY_FILE="$BASE_PATH.key"
CERT_FILE="$BASE_PATH.cert"
CERT_SUBJ="/C=FI/ST=Helsinki/L=Dummy/O=Dummy/OU=IT/CN=Dummy Client"

OPENSSL=/usr/bin/openssl

ensure_openssl() {
  if ! $OPENSSL version; then
    echo "OpenSSL required but not found. 'sudo apt-get install openssl' should fix it."
    exit 1
  fi
}

cert() {
  cat > "$CERT_FILE"
}

clean() {
  rm -f "$KEY_FILE" "$CERT_FILE"
}

csr() {
  $OPENSSL req -new -key "$KEY_FILE" -subj "$CERT_SUBJ"
}

init() {
  ensure_openssl
  test -f "$KEY_FILE"  ||$OPENSSL genrsa -out "$KEY_FILE" 4096
}

status() {
  test ! -f "$KEY_FILE"  ||echo "Dummy Client private key          : $KEY_FILE"
  test ! -f "$CERT_FILE" ||echo "Dummy Client certificate          : $CERT_FILE"
}

case "${1:-init}" in
  cert)      cert            ;;
  clean)     clean           ;;
  csr)       csr             ;;
  init)      init            ;;
  status)    status          ;;

  *)
    echo "Usage: $0 {cert|clean|csr|init|status}" >&2
    exit 2
    ;;
esac
