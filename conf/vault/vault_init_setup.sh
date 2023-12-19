#!/bin/sh
set -e

#### ENV vars ####
export VAULT_ADDR=http://127.0.0.1:8200

# Install tools
apk add curl jq

##### WAIT FOR Vault ######
echo "[*] - $(date) - Wait for Vault to start"
while [[ "$(curl -s http://127.0.0.1:8200/v1/sys/health | jq .sealed)" != "false" ]]; do sleep 3; done
echo "[+] - $(date) - Vault has started"

# Check if Vault has been initialized
if [ $(curl -s http://127.0.0.1:8200/v1/sys/health | jq .sealed) = "false" ]
then
    # Login in as root
    vault login

    # Write admin policy to Vault
    vault policy write admin-users /vault/policies/vault-policy-admin-user.hcl
    echo "[+] - $(date) - Uploaded Vault admin policy"

    #### Enable LDAP auth ####
    vault auth enable ldap
    echo "[+] - $(date) - Enabled Vault LDAP auth"

    read -p "LDAP_URL: " LDAP_URL
    read -s -p "BIND_USERNAME: " BIND_USERNAME
    read -s -p "BIND_PASSWORD: " BIND_PASSWORD

    vault write auth/ldap/config $(cat /vault/config/vault-ldap-config.ldif | \
    sed "s#{{ LDAP_URL }}#${LDAP_URL}#g" | \
    sed "s#{{ LDAP_DOMAIN_NAME }}#$( echo ${LDAP_URL} | awk -F'.' '{print $2}')#g" | \
    sed "s#{{ LDAP_DOMAIN_TLD }}#$( echo ${LDAP_URL} | awk -F'.' '{print $3}')#g" | \
    sed "s#{{ BIND_USERNAME }}#${BIND_USERNAME}#g" | \
    sed "s#{{ BIND_PASSWORD }}#${BIND_PASSWORD}#g")

    echo "[+] - $(date) - Configured Vault LDAP auth"

    # Make LDAP admins assing to admin policy
    vault write auth/ldap/groups/admins policies=admin-users
    echo "[+] - $(date) - All LDAP admins have been granted the Vault admin policy"


    echo -e "\n\n######################################################################"
    echo "#                     Vault setup complete"
    echo "######################################################################"

else
    echo '[-] - Vault has not started'
fi
