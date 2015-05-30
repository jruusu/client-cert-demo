#!/bin/bash
set -euf
set -o pipefail

BASE_PATH=${2:-./ca}
KEY_FILE="$BASE_PATH.key"
CERT_FILE="$BASE_PATH.cert"
CERT_SUBJ="/C=FI/ST=Helsinki/L=Dummy/O=Dummy/OU=IT/CN=Dummy CA"

OPENSSL=/usr/bin/openssl

ensure_openssl() {
  if ! $OPENSSL version; then
    echo "OpenSSL required but not found. 'sudo apt-get install openssl' should fix it."
    exit 1
  fi
}

clean() {
  rm -f "$KEY_FILE" "$CERT_FILE"
}

init() {
  ensure_openssl
  test -f "$KEY_FILE"  ||$OPENSSL genrsa -out "$KEY_FILE" 4096
  test -f "$CERT_FILE" ||$OPENSSL req -new -x509 -days 3650 -key "$KEY_FILE" -out "$CERT_FILE" -subj "$CERT_SUBJ"
}

sign() {
  $OPENSSL x509 -req -days 3650 -CA "$CERT_FILE" -CAkey "$KEY_FILE" -set_serial 01
}

status() {
  test ! -f "$KEY_FILE"  ||echo "Dummy CA private key              : $KEY_FILE"
  test ! -f "$CERT_FILE" ||echo "Dummy CA certificate              : $CERT_FILE"
}



case "${1:-init}" in
  clean)     clean           ;;
  init)      init            ;;
  sign)      sign            ;;
  status)    status          ;;

  *)
    echo "Usage: $0 {clean|init|sign|status}" >&2
    exit 2
    ;;
esac
