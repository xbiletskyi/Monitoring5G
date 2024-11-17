#!/bin/bash

GEN_TLS_SCRIPT="./generate_tls.sh"

NF_LIST=("amf" "ausf" "bsf" "nrf" "nssf" "pcf" "scp" "smf" "udm" "udr")

if [ -z "$1" ]; then
    echo "Usage: $0 <CA passphrase>"
    exit 1
fi

CA_PASSPHRASE=$1

if [ ! -x "$GEN_TLS_SCRIPT" ]; then
    echo "Error: $GEN_TLS_SCRIPT not found or not executable."
    exit 1
fi

for NF in "${NF_LIST[@]}"; do
    echo "Generating TLS keys and certificates for $NF..."
    sudo $GEN_TLS_SCRIPT "$NF" "$CA_PASSPHRASE"
    if [ $? -ne 0 ]; then
        echo "Error occurred while generating TLS keys for $NF. Exiting."
        exit 1
    fi
done

echo "TLS keys and certificates have been generated for all selected NFs."

