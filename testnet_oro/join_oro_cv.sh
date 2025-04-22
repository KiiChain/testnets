#!/bin/bash
# Set up a service to join the testnet oro chain.

# How to use:
# join_oro priv_validator_key.json node_key.json

# Configuration
# You should only have to modify the values in this block
# ***
PRIV_VALIDATOR_KEY_FILE=${1:-"$HOME/priv_validator_key.json"}
NODE_KEY_FILE=${2:-"$HOME/node_key.json"}
NODE_HOME=~/.kiichain
NODE_MONIKER=testnet_oro
SERVICE_NAME=kiichain
SERVICE_VERSION="v1.0.0"
MINIMUM_GAS_PRICES="1000000000akii"
# ***

# Binary
CHAIN_BINARY='kiichaind'
CHAIN_ID="oro_1336-1"

# Persistent peers and RPC endpoints
PERSISTENT_PEERS="5b6aa55124c0fd28e47d7da091a69973964a9fe1@uno.sentry.testnet.v3.kiivalidator.com:26656,5e6b283c8879e8d1b0866bda20949f9886aff967@dos.sentry.testnet.v3.kiivalidator.com:26656"
PRIMARY_ENDPOINT=https://rpc.uno.sentry.testnet.v3.kiivalidator.com
SECONDARY_ENDPOINT=https://rpc.dos.sentry.testnet.v3.kiivalidator.com

# The genesis for the chain
GENESIS_URL=https://raw.githubusercontent.com/KiiChain/testnets/refs/heads/main/testnet_oro/genesis.json

# Install wget, git and jq
sudo apt update
sudo apt-get install git jq curl wget -y

# Stop service if exists
systemctl --user stop $SERVICE_NAME.service

# Install go 1.23.8
echo "Installing go..."
rm go*linux-amd64.tar.gz
wget https://go.dev/dl/go1.23.8.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.23.8.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile

# Install Kiichain binary
echo "Installing build-essential..."
sudo apt install build-essential -y
echo "Installing Kiichain..."
cd $HOME
mkdir -p $HOME/go/bin
rm -rf kiichain
git clone git@github.com:KiiChain/kiichain4.git
cd kiichain
git checkout $SERVICE_VERSION
make install
export PATH=$PATH:$HOME/go/bin
echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.profile

# Initialize home directory
echo "Initializing $NODE_HOME..."
cd $HOME
rm -rf $NODE_HOME
$CHAIN_BINARY init $NODE_MONIKER --chain-id $CHAIN_ID --home $NODE_HOME

# Set the PERSISTENT_PEERS
sed -i -e "/persistent-peers =/ s^= .*^= \"$PERSISTENT_PEERS\"^" $NODE_HOME/config/config.toml
# Set the min gas price
sed -i -e "/minimum-gas-prices =/ s^= .*^= \"$MINIMUM_GAS_PRICES\"^" $NODE_HOME/config/app.toml

# Configure state-sync
TRUST_HEIGHT_DELTA=500
LATEST_HEIGHT=$(curl -s "$PRIMARY_ENDPOINT"/block | jq -r ".block.header.height")
if [[ "$LATEST_HEIGHT" -gt "$TRUST_HEIGHT_DELTA" ]]; then
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - $TRUST_HEIGHT_DELTA))
else
SYNC_BLOCK_HEIGHT=$LATEST_HEIGHT
fi

# Get the sync block hash
SYNC_BLOCK_HASH=$(curl -s "$PRIMARY_ENDPOINT/block?height=$SYNC_BLOCK_HEIGHT" | jq -r ".block_id.hash")

# Enable state sync
sed -i.bak -e "s|^enable *=.*|enable = true|" $NODE_HOME/config/config.toml
sed -i.bak -e "s|^rpc_servers *=.*|rpc_servers = \"$PRIMARY_ENDPOINT,$SECONDARY_ENDPOINT\"|" $NODE_HOME/config/config.toml
sed -i.bak -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" $NODE_HOME/config/config.toml
sed -i.bak -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" $NODE_HOME/config/config.toml

# Replace genesis file
echo "Replacing genesis file..."
wget $GENESIS_URL -O genesis.json
mv genesis.json $NODE_HOME/config/genesis.json

# Replace keys
echo "Replacing keys..."
cp $PRIV_VALIDATOR_KEY_FILE $NODE_HOME/config/priv_validator_key.json
cp $NODE_KEY_FILE $NODE_HOME/config/node_key.json

# Set up cosmovisor
echo "Setting up cosmovisor..."
mkdir -p $NODE_HOME/cosmovisor/genesis/bin
mkdir -p $NODE_HOME/cosmovisor/upgrades
mkdir -p $NODE_HOME/cosmovisor/backup
cp $(which $CHAIN_BINARY) $NODE_HOME/cosmovisor/genesis/bin

echo "Installing cosmovisor..."
export BINARY=$NODE_HOME/cosmovisor/genesis/bin/$CHAIN_BINARY
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.5.0

# Apply env vars
export DAEMON_NAME=$CHAIN_BINARY
echo "export DAEMON_NAME=$CHAIN_BINARY" >> ~/.profile
export DAEMON_HOME=$NODE_HOME
echo "export DAEMON_HOME=$NODE_HOME" >> ~/.profile
export DAEMON_DATA_BACKUP_DIR=$NODE_HOME/cosmovisor/backup
echo "export DAEMON_DATA_BACKUP_DIR=$NODE_HOME/cosmovisor/backup" >> ~/.profile
export DAEMON_RESTART_AFTER_UPGRADE="true"
echo 'export DAEMON_RESTART_AFTER_UPGRADE="true"' >> ~/.profile

# Create the service
echo "Creating $SERVICE_NAME.service..."
sudo rm /etc/systemd/system/$SERVICE_NAME.service
sudo touch /etc/systemd/system/$SERVICE_NAME.service

echo "[Unit]"                                            | sudo tee /etc/systemd/system/$SERVICE_NAME.service
echo "Description=Cosmovisor and Kiichaind service"      | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "After=network-online.target"                       | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo ""                                                  | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "[Service]"                                         | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "User=$USER"                                        | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "ExecStart=$HOME/go/bin/cosmovisor run start --x-crisis-skip-assert-invariants --home $NODE_HOME --chain-id $CHAIN_ID" | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "Restart=always"                                    | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "RestartSec=3"                                      | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "LimitNOFILE=50000"                                 | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "Environment='DAEMON_NAME=$CHAIN_BINARY'"           | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "Environment='DAEMON_HOME=$NODE_HOME'"              | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "Environment='DAEMON_ALLOW_DOWNLOAD_BINARIES=true'" | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "Environment='DAEMON_RESTART_AFTER_UPGRADE=true'"   | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "Environment='DAEMON_LOG_BUFFER_SIZE=512'"          | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo ""                                                  | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "[Install]"                                         | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "WantedBy=multi-user.target"                        | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a

# Start service
sudo systemctl daemon-reload

# Enable and start the service
sudo systemctl enable $SERVICE_NAME.service
sudo systemctl start $SERVICE_NAME.service
sudo systemctl restart systemd-journald

echo "***********************"
echo "To see the service log enter:"
echo "journalctl -fu $SERVICE_NAME.service"
echo "***********************"

# Get the env vars
source ~/.profile
