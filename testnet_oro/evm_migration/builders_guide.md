# 🧱 Builder Migration Guide: Kiichain EVM Fork

### 📆 Fork Date: **2025-04-29 17:00UTC**

### 🆕 New Chain ID: `oro_1336-1`

## 🧭 Why This Fork?

We're upgrading Kiichain to use the **official Cosmos EVM module**. It is fully compatible with:

- ✅ The latest **Cosmos SDK**
- ✅ **IBC** and **Wasm**
- ✅ Ethereum-compatible tooling

This upgrade will:

- Keep us aligned with the latest Cosmos ecosystem updates
- Enable easier maintenance, flexibility, and growth

## 🆕 New Chain Parameters (Post-Fork)

Be sure to update **any Cosmos SDK integrations, frontends, or tooling** with the following:

- Chain ID: `oro_1336-1`
- Denom: `akii`
- Decimals: `18`
- Coin Type: `60`
- Ethereum-style addresses: ✅ Enabled

## 🧠 Keplr Integration Notes

To enable Ethereum-compatible keys in Keplr, **update your chain config** as shown below or use the official JSON link:

🔗 [Official Keplr JSON](../assets/connections/keplr.json)

```json
{
  "chain_id": "oro_1336-1",
  "bip44": { "coin_type": 60 },
  "evm": {
    "chainId": 1336,
    "rpc": "https://json-rpc.uno.sentry.testnet.v3.kiivalidator.com"
  },
  "features": ["eth-address-gen", "eth-key-sign", "eth-secp256k1-cosmos"],
  "currencies": [
    {
      "coinDenom": "AKII",
      "coinMinimalDenom": "akii",
      "coinDecimals": 18
    }
  ],
  "feeCurrencies": [
    {
      "coinDenom": "AKII",
      "coinMinimalDenom": "akii",
      "coinDecimals": 18
    }
  ],
  "stakeCurrency": {
    "coinDenom": "AKII",
    "coinMinimalDenom": "akii",
    "coinDecimals": 18
  }
}
```

Keplr will use `eth_secp256k1` keys and show Ethereum-style addresses correctly when this is set.

## 📦 EVM Connection JSON

Use this official EVM config JSON for RPC-based integrations:

🔗 [Official EVM JSON](https://github.com/ethereum-lists/chains/blob/master/_data/chains/eip155-1336.json)

## ⚠️ Required Actions for Builders

### ✅ Frontend/SDK Developers

- Update all references to the old chain ID, denom, and coin type
- If you parse balances, be sure to account for the **18 decimal places**
- Confirm contract interactions use the updated precompiles where necessary (official precompile docs coming soon)

### ✅ Wallet Integrators

- Update your chain registry (e.g. Keplr, Leap, MetaMask w/ signing middleware)
- Use `coin-type: 60` and `eth_secp256k1` as the key algorithm

### ✅ Explorer & Tooling Developers

- Update backend logic for:
  - `akii` denomination
  - `18` decimals
  - `oro_1336-1` chain ID
- Ensure compatibility with Ethereum-style transactions and addresses

## 📣 Support Channels

- [Discord](https://discord.com/invite/kiichain)
- [Official documentation](https://docs.kiiglobal.io)

## 📚 References

### 📘 Documentation

- [Kiichain Docs](https://docs.kiiglobal.io)
- [Builders Migration Guide](./builders_notice.md)
- [Validator Migration Guide](validators_guide.md)

### 🧰 Scripts

- [Migration Script](fork_migration.sh)
- [Join Oro](../join_oro.sh)
- [Join Oro With Cosmovisor](../join_oro_cv.sh)

### 🔐 Wallet Connections

- [Official EVM JSON](https://github.com/ethereum-lists/chains/blob/master/_data/chains/eip155-1336.json)
- [Official Keplr JSON](../assets/connections/keplr.json)
