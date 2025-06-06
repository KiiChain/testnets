# `Testnet Oro` Chain Details

The `Testnet Oro` chain is the Kiichain testnet.

- **Chain-ID**: `oro_1336-1`
- **denom**: `akii`
- **decimals**: `18`
- **Spawn time**: `2024-12-17T17:55:40.565516258Z`
- **Genesis file with CCV state:** [genesis.json](./genesis.json) (available after chain spawn time)
- **SHA256 for genesis file**: `2805ae1752dc8c3435afd6bdceea929b3bbd2883606f3f3589f4d62c99156d2d`

## Endpoints

The following endpoints are exposed:

**Uno**:

- `RPC`: https://rpc.uno.sentry.testnet.v3.kiivalidator.com
- `Rest (LCD)`: https://lcd.uno.sentry.testnet.v3.kiivalidator.com
- `JSON-RPC (EVM)`: https://json-rpc.uno.sentry.testnet.v3.kiivalidator.com

Persistent peer:

- 5b6aa55124c0fd28e47d7da091a69973964a9fe1@uno.sentry.testnet.v3.kiivalidator.com:26656

**Dos**:

- `RPC`: https://rpc.dos.sentry.testnet.v3.kiivalidator.com
- `Rest (LCD)`: https://lcd.dos.sentry.testnet.v3.kiivalidator.com
- `JSON-RPC (EVM)`: https://json-rpc.dos.sentry.testnet.v3.kiivalidator.com

Persistent peer:

- 5e6b283c8879e8d1b0866bda20949f9886aff967@dos.sentry.testnet.v3.kiivalidator.com:26656

## How to Join

### Hardware Requirements

- 8 GB RAM
- 1 TB NVME SSD
- 4 Cores x86_64

#### Bash Script

The scripts provided in this repo will install Kiichaind and optionally set up a `Cosmovisor` service with the auto-download feature enabled on your machine.

Run script provided to set up a `kiichaind` service without `Cosmovisor`:

- [join_oro.sh](./join_oro.sh) will create a `kiichaind` service.
  - Script must be run either as root or from a sudoer account.

Or run the second script provided to set up a `kiichaind` service with `Cosmovisor`:

- [join_oro_cv.sh](./join_oro_cv.sh) will create a `cosmosvisor-kiichaind` service.
  - Script must be run either as root or from a sudoer account.

### Node manual installation

Install Kiichain binary.

```bash
git clone https://github.com/KiiChain/kiichain.git
cd kiichain
make install
```

After installation please check installed version by running:

`kiichaind version --long`
