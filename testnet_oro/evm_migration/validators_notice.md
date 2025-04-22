# 🔧 Validator Notice: Kiichain EVM Fork

### 📆 Fork Date: **2025-04-23**

### 🆕 New Chain ID: `oro_1336-1`

## 🧭 Why This Fork?

We're upgrading Kiichain to use the **official Cosmos EVM module**. It is fully compatible with:

- ✅ The latest **Cosmos SDK**
- ✅ **IBC** and **Wasm**
- ✅ Ethereum-compatible tooling

This upgrade will:

- Keep us aligned with the latest Cosmos ecosystem updates
- Enable easier maintenance, flexibility, and growth

## 🛠 What Validators Need To Do

Your role is **essential** to ensure a smooth transition. Please read carefully.

### ✅ Before the Fork

1. **Review the updated chain configuration:**

   - 🆔 **Chain ID:** `oro_1336-1`
   - 💰 **New Denom:** `akii`
   - 🧮 **Decimals:** `18`
   - 🔁 **New addresses with coin type 60 and generation type eth_secp256k1**

2. **Prepare validator keys and wallets:**

   - Be sure to **backup your private validator key and node key**
   - Validator wallets will use the legacy wallet generate and can be recovered with:
     ```bash
     kiichaind keys add <wallet_name> --keyring-backend test --recover --coin-type 118 --key-type secp256k1
     ```

3. **Clear your schedule for upgrade coordination:**
   - You will have **5 days** after the fork to upgrade and rejoin the network
   - **Guides, migration scripts, and a genesis file** will be published **on the day of the upgrade**

## 🚀 Migration Process (Post-Fork)

On upgrade day, we will release:

- ✅ Migration scripts
- ✅ Updated documentation
- ✅ Finalized genesis file

### High-level migration steps:

1. **Stop your node** at the fork height (to be announced)
2. **Download and install the new binary**
3. **Initialize the new chain directory**
4. **Restore the node with state-sync**
5. **Verify validator status and block signing**

Full instructions will be included in the migration guide.

## 📦 Version Reset: `v1.0.0`

With this fork, we will **reset our chain version to `v1.0.0`**.  
All future upgrades will follow [Semantic Versioning](https://semver.org/), marking this as a new chapter in the chain’s development.

## ⚠️ Other Important Notes

- **Keplr and tooling** will require updated configuration
- External services (explorer, SDKs, faucet) are being updated in parallel

## 📣 Communication Channels

You’ll receive updates and support through:

- 🔧 **Validator chat**
- 📝 **GitHub releases**
