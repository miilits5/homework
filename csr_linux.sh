#!/usr/bin/env bash
#used several sources. Can reference them if needed to give credit. As this is just a job application task and this won't be used anywhere in the product lines, I see no point to reference the material/scripts I used.
#Check if openssl exists, if not then return information and close script. If exists ask some input and fill in some information that is needed for generating the request. The script essentially creates a file with some user input to feed to Openssl and generate a private key and CSR. Also a validation check against the private key and CSR is done. Probably a good idea to limit the inputs to standards but in this case I think it is good enough.

PROGRAM="openssl"
if ! command -v ${PROGRAM} >/dev/null; then
  echo "This script requires ${PROGRAM} to be installed and on your PATH ..."
  exit 1
  
else
	echo 'Do you want to generate a Certificate Request (enter a number)? You will be asked basic details for certificate request generation.'
#promt for CSR generation, if Yes then minimum input is asked

select yn in "Yes" "No"; do
    case $yn in
        Yes )
		read -p "Country Name (2 letter code) [AU]: " COUNTRY;
		read -p "State or Province Name (full name) [Harjumaa]: " STATE;
		read -p "Locality Name (eg, city) [Tallinn]: " LOCALITY;
		read -p "Organization Name (eg, company) [Swedbank] " ORGANISATION;
		read -p "Common Name (e.g. server FQDN or YOUR name) []: " COMMONNAME;
		YEAR=$(date +"%Y")
		TARGET_DIR="${COMMONNAME}"
		PRIVATE_KEY_FILE="${TARGET_DIR}/${COMMONNAME}_${YEAR}_private.pem"
		CERT_SIGN_REQUEST_FILE="${TARGET_DIR}/${COMMONNAME}_${YEAR}.csr"
		
		
		
cat <<EOF > .temp-openssl-config
[ req ]
default_bits           = 2048
distinguished_name     = req_distinguished_name
prompt                 = no
encrypt_key            = no
string_mask            = utf8only
req_extensions         = v3_req
[ req_distinguished_name ]
C                      = ${COUNTRY}
ST                     = ${STATE}
L                      = ${LOCALITY}
O                      = ${ORGANISATION}
CN                     = ${COMMONNAME}
[ v3_req ]
basicConstraints       = CA:FALSE
keyUsage               = nonRepudiation, digitalSignature, keyEncipherment
EOF


if [ -d "${TARGET_DIR}" ]; then
	echo "Target directory already exists: ${TARGET_DIR}"
	echo "Remove or rename it before you try again."
exit 1
fi


mkdir -p ${TARGET_DIR}

openssl genrsa -out ${PRIVATE_KEY_FILE} 2048
openssl req -new -config .temp-openssl-config -key ${PRIVATE_KEY_FILE} -out ${CERT_SIGN_REQUEST_FILE}
rm -f .temp-openssl-config

# certificate quality check
M_RSA=$(openssl rsa -noout -modulus -in ${PRIVATE_KEY_FILE})
M_REQ=$(openssl req -noout -modulus -in ${CERT_SIGN_REQUEST_FILE})
if [ "${M_RSA}" != "${M_REQ}" ]; then
	echo "Something went wrong. Private key and CSR files don't match."
	exit 1
fi


echo "Done. Files generated:"
echo ""
echo "  1. Private key:"
echo "     ${PRIVATE_KEY_FILE}"
echo "     > Keep this file safe. It will be required on the server."
echo ""
echo "  2. Certificate Signing Request (CSR):"
echo "     ${CERT_SIGN_REQUEST_FILE}"
echo "     > Submit this file to the SSL certificate provider."
echo ""
echo "To see the decoded contents of the CSR file, run the following command:"
echo "  openssl req -verify -noout -text -in ${CERT_SIGN_REQUEST_FILE}"
exit 0;;

        No ) exit;;
    esac
done

exit 0

fi