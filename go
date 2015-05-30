#!/bin/bash
set -euf
set -o pipefail

CA="./ca"
CLIENT="./client"
CA_BASE_PATH="dummy-ca"
CLIENT_BASE_PATH="dummy-client"

ca() {
  $CA "$1" $CA_BASE_PATH
}

client() {
  $CLIENT "$1" $CLIENT_BASE_PATH
}

clean() {
  ca "clean"
  client "clean"
}

init() {
  ca "init"
  client "init"

  # Get CSR from client, have CA issue cert, and pass the cert back to client
  client "csr" | ca "sign" | client "cert"
}

status() {
  ca "status"
  client "status"
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
