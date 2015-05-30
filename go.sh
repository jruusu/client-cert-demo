#!/bin/bash
set -euf
set -o pipefail

CA="./ca.sh"
CLIENT="./client.sh"
CA_BASE_PATH="dummy-ca"
CLIENT_BASE_PATH="dummy-client"

CA_DIR="ca"
CA_SERIAL_FILE="$CA_DIR/dummy-ca.srl"
CA_KEY_FILE="$CA_DIR/dummy-ca.key"
CA_CERT_FILE="$CA_DIR/dummy-ca.cert"
CA_CERT_SUBJ="/C=FI/ST=Helsinki/L=Dummy/O=Dummy/OU=IT/CN=Dummy CA"

CLIENT_DIR="client"
CLIENT_KEY_FILE="$CLIENT_DIR/dummy-client.key"
CLIENT_CSR_FILE="$CLIENT_DIR/dummy-client.csr"
CLIENT_CERT_FILE="$CLIENT_DIR/dummy-client.cert"
CLIENT_CERT_SUBJ="/C=FI/ST=Helsinki/L=Dummy/O=Dummy/OU=IT/CN=Dummy Client"

SERVER_DIR="server"
SERVER_KEY_FILE="$SERVER_DIR/dummy-server.key"
SERVER_CSR_FILE="$SERVER_DIR/dummy-server.csr"
SERVER_CERT_FILE="$SERVER_DIR/dummy-server.cert"
SERVER_CERT_SUBJ="/C=FI/ST=Helsinki/L=Dummy/O=Dummy/OU=IT/CN=example.org"

OPENSSL=/usr/bin/openssl

require_openssl() {
  if ! $OPENSSL version > /dev/null; then
    echo "OpenSSL required but not found. 'sudo apt-get install openssl' should fix it."
    exit 1
  fi
}

# Generate a new private key of specified size (in bits)
key() { $OPENSSL genrsa "$1"; }

# Generate a new Certificate Signing Request (CSR) for the specified key file and subject
# $1: key filename
# $2: subject
csr() { $OPENSSL req -new -key "$1" -subj "$2"; }

# Issue a new self-signed Certificate for the specified key, subject
# $1: key filename
# $2: subject
self_sign() { $OPENSSL req -new -x509 -days 3650 -key "$1" -subj "$2"; }

# Establish a dummy Certificate Authority
ca_init() {
  test -f "$CA_KEY_FILE"      ||(key 4096 > "$CA_KEY_FILE")
  test -f "$CA_CERT_FILE"     ||(self_sign "$CA_KEY_FILE" "$CA_CERT_SUBJ" > "$CA_CERT_FILE")
}

# Issue a new Certificate for the specified CSR
# $1: CSR filename
ca_sign() { $OPENSSL x509 -req -days 3650 -in "$1" -CAkey "$CA_KEY_FILE" -CA "$CA_CERT_FILE" -CAserial "$CA_SERIAL_FILE" -CAcreateserial; }

clean() {
  rm -rf "$CA_DIR" "$CLIENT_DIR" "$SERVER_DIR"
}

init() {
  require_openssl
  mkdir -p $CA_DIR
  mkdir -p $CLIENT_DIR
  mkdir -p $SERVER_DIR

  # Establish a dummy CA
  ca_init

  # Create a Client Certificate signed by the dummy CA
  test -f "$CLIENT_KEY_FILE"      ||(key 4096 > "$CLIENT_KEY_FILE")
  test -f "$CLIENT_CSR_FILE"      ||(csr "$CLIENT_KEY_FILE" "$CLIENT_CERT_SUBJ" > "$CLIENT_CSR_FILE")
  test -f "$CLIENT_CERT_FILE"     ||(ca_sign "$CLIENT_CSR_FILE" > "$CLIENT_CERT_FILE")

  # Create a Server Certificate signed by the dummy CA
  test -f "$SERVER_KEY_FILE"      ||(key 4096 > "$SERVER_KEY_FILE")
  test -f "$SERVER_CSR_FILE"      ||(csr "$SERVER_KEY_FILE" "$SERVER_CERT_SUBJ" > "$SERVER_CSR_FILE")
  test -f "$SERVER_CERT_FILE"     ||(ca_sign "$SERVER_CSR_FILE" > "$SERVER_CERT_FILE")
}

status() {
  test ! -f "$CA_KEY_FILE"        ||echo "Dummy CA key                 $CA_KEY_FILE"
  test ! -f "$CA_CERT_FILE"       ||echo "Dummy CA certificate         $CA_CERT_FILE"
  test ! -f "$CA_SERIAL_FILE"     ||echo "Dummy CA serial number file  $CA_SERIAL_FILE"

  test ! -f "$CLIENT_KEY_FILE"    ||echo "Dummy client key             $CLIENT_KEY_FILE"
  test ! -f "$CLIENT_CSR_FILE"    ||echo "Dummy client CSR             $CLIENT_CSR_FILE"
  test ! -f "$CLIENT_CERT_FILE"   ||echo "Dummy client certificate     $CLIENT_CERT_FILE"

  test ! -f "$SERVER_KEY_FILE"    ||echo "Dummy server key             $SERVER_KEY_FILE"
  test ! -f "$SERVER_CSR_FILE"    ||echo "Dummy server csr             $SERVER_CSR_FILE"
  test ! -f "$SERVER_CERT_FILE"   ||echo "Dummy server certificate     $SERVER_CERT_FILE"
}

case "${1:-init}" in
  clean)     clean            ;;
  init)      init && status   ;;
  status)    status           ;;

  *)
    echo "Usage: $0 {clean|init|status}" >&2
    exit 2
    ;;
esac
