#!/bin/bash

set -e

echo "🔧 Interactive Kiichain Price Feeder Setup 🔧"
echo "This script will guide you through the setup of the Kiichain Price Feeder."
echo "Please ensure you have the necessary permissions and dependencies installed before proceeding."
echo "This script is designed to run on a Linux system with Kiichain installed and a node running."
echo "This script also considers that the validator private is available in the keyring."
echo ""

# 1. Setup the price feeder
read -p "Enter the local path for price-feeder setup [default: $HOME/.kiichain/price-feeder]: " LOCAL_PATH
LOCAL_PATH=${LOCAL_PATH:-"$HOME/.kiichain/price-feeder"}

# Ensure directory exists
mkdir -p "$LOCAL_PATH"

# 2. Clone the repo to a temp dir if not already present
TEMP_CLONE_DIR="/tmp/price-feeder-setup-$$"
echo "⬇️ Cloning price-feeder repo to temp dir..."
git clone https://github.com/KiiChain/price-feeder.git "$TEMP_CLONE_DIR"

# 3. Copy example config
CONFIG_PATH="$LOCAL_PATH/config.toml"
echo "📄 Copying example config to $CONFIG_PATH..."
cp "$TEMP_CLONE_DIR/config.example.toml" "$CONFIG_PATH"

# 4. Keyring backend
read -p "Enter the keyring backend [default: os]: " KEYRING_BACKEND
KEYRING_BACKEND=${KEYRING_BACKEND:-"os"}

# 5. Ask for password
read -s -p "Enter the keyring password [default: test] (Default as test for test keyring): " KEYRING_PASSWORD
echo
KEYRING_PASSWORD=${KEYRING_PASSWORD:-"test"}

# 6. Validator account name
read -p "Enter your validator account name: " VALIDATOR_ACCOUNT_NAME

# Validate validator account exists
echo "🔍 Checking if validator account exists..."
if ! echo "$KEYRING_PASSWORD" | kiichaind keys show "$VALIDATOR_ACCOUNT_NAME" --keyring-backend "$KEYRING_BACKEND" --output json >/dev/null 2>&1; then
  echo "❌ Validator account \"$VALIDATOR_ACCOUNT_NAME\" not found. Exiting."
  exit 1
fi

# 7. Validator operator address
read -p "Enter your validator operator address (kiivaloper1...): " VALIDATOR_ADDRESS

# 8. Create delegated feeder account
read -p "Do you want to create and fund a new feeder account? (y/n): " SETUP_FEEDER
if [[ "$SETUP_FEEDER" =~ ^[Yy]$ ]]; then
    # 9. Feeder account name
    read -p "Choose a name for the feeder key [default: feeder]: " FEEDER_KEY_NAME
    FEEDER_KEY_NAME=${FEEDER_KEY_NAME:-"feeder"}

    echo "🧹 Removing existing key if any..."
    (echo y; echo y) | kiichaind keys delete "$FEEDER_KEY_NAME" --keyring-backend "$KEYRING_BACKEND" 2>/dev/null || true

    echo "🔐 Creating feeder key..."
    FEEDER_KEY_OUTPUT=$(echo "$KEYRING_PASSWORD" | kiichaind keys add "$FEEDER_KEY_NAME" --keyring-backend "$KEYRING_BACKEND" --output json)
    DELEGATE_ADDRESS=$(echo "$FEEDER_KEY_OUTPUT" | jq -r ".address")
    MNEMONIC=$(echo "$FEEDER_KEY_OUTPUT" | jq -r ".mnemonic")

    echo "✅ Delegate address: $DELEGATE_ADDRESS"
    echo "🧠 Mnemonic (save it securely!):"
    echo "$MNEMONIC"

    echo "🗳️ Setting feeder delegation..."
    echo "$KEYRING_PASSWORD" | kiichaind tx oracle set-feeder "$DELEGATE_ADDRESS" --from "$VALIDATOR_ACCOUNT_NAME" --gas auto --gas-adjustment 2.0 --gas-prices 100000000000akii --keyring-backend "$KEYRING_BACKEND" -y
    sleep 5

    echo "💰 Sending tokens to the feeder..."
    echo "$KEYRING_PASSWORD" | kiichaind tx bank send "$VALIDATOR_ACCOUNT_NAME" "$DELEGATE_ADDRESS" 1000000000000000000akii --gas auto --gas-adjustment 2.0 --gas-prices 100000000000akii --keyring-backend "$KEYRING_BACKEND" -y
    sleep 5
else
  read -p "Enter the existing delegated feeder address: " DELEGATE_ADDRESS
fi

# 10. Patch config.toml
echo "🛠️ Setting up config.toml with basic config..."
sed -i "s|backend = .*|backend = \"$KEYRING_BACKEND\"|g" "$CONFIG_PATH"
sed -i "s|address = .*|address = \"$DELEGATE_ADDRESS\"|g" "$CONFIG_PATH"
sed -i "s|validator = .*|validator = \"$VALIDATOR_ADDRESS\"|g" "$CONFIG_PATH"

# 11. Install price-feeder binary
echo "⚙️ Installing price-feeder binary..."
cd "$TEMP_CLONE_DIR"
make install

# 12. Create systemd service
SERVICE_NAME="price-feeder"
# Find the binary path
PRICE_FEEDER_BIN=$(which price-feeder)

echo "🧾 Creating systemd service..."
sudo tee /etc/systemd/system/$SERVICE_NAME.service > /dev/null <<EOF
[Unit]
Description=kiichain oracle price-feeder service
After=network-online.target

[Service]
User=$USER
ExecStart=$PRICE_FEEDER_BIN start $CONFIG_PATH
Restart=always
RestartSec=3
LimitNOFILE=50000
Environment='PRICE_FEEDER_PASS=$KEYRING_PASSWORD'

[Install]
WantedBy=multi-user.target
EOF

# 13. Start systemd service
echo "🚀 Starting service..."
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME.service
sudo systemctl restart $SERVICE_NAME.service
sudo systemctl restart systemd-journald

# 14. Cleanup
rm -rf "$TEMP_CLONE_DIR"

# 15. Done
echo "✅ Setup complete!"
echo "To view logs: journalctl -fu $SERVICE_NAME.service"