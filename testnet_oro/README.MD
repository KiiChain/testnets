# `Testnet Oro` Chain Details

The `Testnet Oro` chain is the Kiichain testnet.

- **Chain-ID**: `kiichain3`
- **denom**: `ukii`
- **Spawn time**: `2024-12-17T17:55:40.565516258Z`
- **Genesis file with CCV state:** [genesis.json](./genesis.json) (available after chain spawn time)
- **SHA256 for genesis file**: `e22442f19149db7658bcf777d086b52b38d834ea17010c313cd8aece137b647a`

## Endpoints

The following endpoints are exposed:

**Uno**:

- `RPC`: https://rpc.uno.sentry.testnet.v3.kiivalidator.com
- `Rest (LCD)`: https://lcd.uno.sentry.testnet.v3.kiivalidator.com
- `JSON-RPC (EVM)`: https://json-rpc.uno.sentry.testnet.v3.kiivalidator.com

Persistent peer:

- 42355192eb77b71edbaa7e03f38e335849993ca0@p2p.uno.sentry.testnet.v3.kiivalidator.com

**Dos**:

- `RPC`: https://rpc.dos.sentry.testnet.v3.kiivalidator.com
- `Rest (LCD)`: https://lcd.dos.sentry.testnet.v3.kiivalidator.com
- `JSON-RPC (EVM)`: https://json-rpc.dos.sentry.testnet.v3.kiivalidator.com

Persistent peer:

- f3232ca5248aeb38af1d99542316d3c784dbf6f2@p2p.dos.sentry.testnet.v3.kiivalidator.com

## How to Join

### Hardware Requirements

- 64 GB RAM
- 1 TB NVME SSD
- 16 Cores (modern CPU's)

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
git clone https://github.com/KiiChain/kiichain3.git
cd kiichain3
make install
```

After installation please check installed version by running:

`kiichaind version --long`
