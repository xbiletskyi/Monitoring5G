#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <NF name> [CA passphrase]"
    exit 1
fi

NF_NAME=$1
CERT_DIR="/etc/open5gs/tls"
CA_KEY="${CERT_DIR}/ca.key"
CA_CERT="${CERT_DIR}/ca.crt"
CA_SERIAL="${CERT_DIR}/ca.srl"
CA_PASSPHRASE=${2:-}

mkdir -p "${CERT_DIR}"

generate_ca() {
    if [ -n "$CA_PASSPHRASE" ]; then
        echo "Generating CA key and certificate with provided passphrase..."
        openssl genpkey -algorithm RSA -out "${CA_KEY}" -aes256 -pass pass:"${CA_PASSPHRASE}"
        openssl req -new -x509 -key "${CA_KEY}" -sha256 -days 3650 -out "${CA_CERT}" -subj "/C=US/ST=State/L=City/O=Open5GS/OU=CA/CN=open5gs-ca" -passin pass:"${CA_PASSPHRASE}"
    else
        echo "Generating CA key and certificate (passphrase prompt)..."
        openssl genpkey -algorithm RSA -out "${CA_KEY}" -aes256
        openssl req -new -x509 -key "${CA_KEY}" -sha256 -days 3650 -out "${CA_CERT}" -subj "/C=US/ST=State/L=City/O=Open5GS/OU=CA/CN=open5gs-ca"
    fi
}

if [ ! -f "${CA_KEY}" ] || [ ! -f "${CA_CERT}" ]; then
    generate_ca
    echo "CA certificate generated at ${CA_CERT}"
else
    echo "Using existing CA key and certificate."
fi

if [ ! -f "${CA_SERIAL}" ]; then
    echo "Creating CA serial file..."
    echo '01' > "${CA_SERIAL}"  # Initialize serial number to 1
fi

NF_KEY="${CERT_DIR}/${NF_NAME}.key"
NF_CSR="${CERT_DIR}/${NF_NAME}.csr"
NF_CERT="${CERT_DIR}/${NF_NAME}.crt"

echo "Generating private key for ${NF_NAME}..."
openssl genpkey -algorithm RSA -out "${NF_KEY}"

echo "Generating CSR for ${NF_NAME}..."
openssl req -new -key "${NF_KEY}" -out "${NF_CSR}" -subj "/C=US/ST=State/L=City/O=Open5GS/OU=${NF_NAME}/CN=${NF_NAME}.localdomain"

echo "Signing the certificate for ${NF_NAME}..."
if [ -n "$CA_PASSPHRASE" ]; then
    openssl x509 -req -in "${NF_CSR}" -CA "${CA_CERT}" -CAkey "${CA_KEY}" -CAserial "${CA_SERIAL}" -out "${NF_CERT}" -days 3650 -sha256 -passin pass:"${CA_PASSPHRASE}"
else
    openssl x509 -req -in "${NF_CSR}" -CA "${CA_CERT}" -CAkey "${CA_KEY}" -CAserial "${CA_SERIAL}" -out "${NF_CERT}" -days 3650 -sha256
fi

rm -f "${NF_CSR}"

echo "Generated files for ${NF_NAME}:"
echo "  Private Key: ${NF_KEY}"
echo "  Certificate: ${NF_CERT}"
echo "  CA Certificate: ${CA_CERT} (unchanged)"
echo "  CA Serial File: ${CA_SERIAL}"

chmod 600 "${NF_KEY}"
chmod 644 "${NF_CERT}" "${CA_CERT}" "${CA_SERIAL}"

echo "All files are ready and saved in ${CERT_DIR}."

