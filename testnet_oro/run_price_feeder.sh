#!/bin/bash

# You should only have to modify the values in this block
# ***
SERVICE_VERSION="v3.0.0"
PROJECT_PATH="$HOME/kiichain"
SERVICE_NAME="price_feeder"
CONFIG_PATH=$PROJECT_PATH/oracle/price_feeder/config.toml
KEYRING_BACKEND="test" 
VALIDATOR_ACCOUNT_NAME="<YOUR_VALIDATOR_ACCOUNT>" # <- Edit this
VALIDATOR_ADDRESS="kiivaloper1..." # <- Edit this
KEYRING_PASSWORD="<YOUR_PASSWORD_HERE>" # <- Edit this 
# ***

# Binary
PRICE_FEEDER='price_feeder'
CHAIN_ID=kiichain3

# Build and install price-feeder
cd $PROJECT_PATH
git checkout $SERVICE_VERSION
make install-price-feeder

# remove key if exits
echo "Removing existing key if present..."
(echo y; echo y) | kiichaind keys delete price-feeder-delegate --keyring-backend "$KEYRING_BACKEND" 2>/dev/null || true

# create delegated wallet and delegate the voting process
echo "Creating and delegating account..."
DELEGATE_ADDRESS=$(echo "$KEYRING_PASSWORD" | kiichaind keys add price-feeder-delegate --keyring-backend "$KEYRING_BACKEND" --output json | jq -r ".address")
echo "Delegate address: $DELEGATE_ADDRESS"

# wait time between transactions
sleep 2

# send tokens to the delegated wallet
echo "Setting feedeing address..."
echo "$KEYRING_PASSWORD" | kiichaind tx oracle set-feeder "$DELEGATE_ADDRESS" --from "$VALIDATOR_ACCOUNT_NAME" --fees 21000ukii -y --chain-id "$CHAIN_ID" --keyring-backend "$KEYRING_BACKEND"

# wait time between transactions
sleep 5

# send tokens to the delegated adddress 
echo "Sending tokens..."
echo "$KEYRING_PASSWORD" | kiichaind tx bank send "$VALIDATOR_ACCOUNT_NAME" "$DELEGATE_ADDRESS" 100000000ukii --fees=21000ukii -y --keyring-backend "$KEYRING_BACKEND" 

# setup config.toml
echo "Setting up config file..."
sed -i "s|backend = \"os\"|backend = \"$KEYRING_BACKEND\"|g" "$CONFIG_PATH"
sed -i "s|address = \"kii1...\"|address = \"$DELEGATE_ADDRESS\"|g" "$CONFIG_PATH"
sed -i "s|validator = \"kiivaloper1...\"|validator = \"$VALIDATOR_ADDRESS\"|g" "$CONFIG_PATH"

# create systemctl service
echo "Creating system daemon..."
sudo rm /etc/systemd/system/$SERVICE_NAME.service
sudo touch /etc/systemd/system/$SERVICE_NAME.service

echo "[Unit]"                                                          | sudo tee /etc/systemd/system/$SERVICE_NAME.service
echo "Description=kiichain oracle price-feeder service"                | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "After=network-online.target"                                     | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "[Service]"                                                       | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo ""                                                                | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "User=$USER"                                                      | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "ExecStart=$HOME/go/bin/$PRICE_FEEDER $CONFIG_PATH"               | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "Restart=always"                                                  | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "RestartSec=3"                                                    | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "LimitNOFILE=50000"                                               | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "Environment='PRICE_FEEDER_PASS=$KEYRING_PASSWORD'"               | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo ""                                                                | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "[Install]"                                                       | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a
echo "WantedBy=multi-user.target"                                      | sudo tee /etc/systemd/system/$SERVICE_NAME.service -a

# run price-feeder
echo "Starting price-feeder..."
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME.service
sudo systemctl start $SERVICE_NAME.service
sudo systemctl restart systemd-journald

echo "***********************"
echo "To see the service log enter:"
echo "journalctl -fu $SERVICE_NAME.service"
echo "***********************"

# Get the env vars
source ~/.profile


