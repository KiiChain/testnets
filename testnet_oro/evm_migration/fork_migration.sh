#!/bin/bash
# This is an example for the fork migration
# This script is used to migrate from the old chain to the new chain
# It will backup the current directories and remove the old configuration
# and install the new chain with Cosmosvisor
# and set up a service to join the testnet oro chain.

# Define the variables
NODE_HOME=$HOME/.kiichain3
NODE_HOME_BACKUP=$HOME/.kiichain3-bk
CHAIN_BINARY='kiichaind'
KIICHAIN_REPO_PATH=$HOME/kiichain
SERVICE_NAME=kiichain

# Stop service if exists
systemctl --user stop $SERVICE_NAME.service

# Backup the current node home
mv $NODE_HOME $NODE_HOME_BACKUP

# Remove old configuration
rm -rf $KIICHAIN_REPO_PATH
rm -f "$(which $CHAIN_BINARY)"
sudo rm /etc/systemd/system/$SERVICE_NAME.service

# Install the new chain with Cosmosvisor
curl -O https://raw.githubusercontent.com/KiiChain/testnets/refs/heads/main/testnet_oro/join_oro_cv.sh
chmod +x join_oro_cv.sh
# Initialize the script passing the private validator key and node key from the backup
./join_oro_cv.sh $NODE_HOME_BACKUP/config/priv_validator_key.json $NODE_HOME_BACKUP/config/node_key.json
