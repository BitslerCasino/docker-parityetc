#!/usr/bin/env bash

set -e

if [[ $EUID -ne 0 ]]; then
   echo "This script must be ran as root or sudo" 1>&2
   exit 1
fi

echo "Installing OpenEthereum Docker"

mkdir -p $HOME/.etcdocker

echo "Initial OpenEthereum Configuration"

echo "Creating OpenEthereum configuration at $HOME/.etcdocker/config.toml"

cat >$HOME/.etcdocker/config.toml <<EOL
[secretstore]
# You won't be able to encrypt and decrypt secrets.
disable = true

[dapps]
# Disable the Dapps server (e.g. status page).
disable = true

[rpc]
interface = "all"
apis = ["web3", "eth", "pubsub", "net", "parity", "private", "parity_pubsub", "traces", "rpc", "shh", "shh_pubsub", "personal", "parity_accounts"]

[ipc]
# You won't be able to use IPC to interact with Parity.
disable = true

[websockets]
# UI won't work and WebSockets server will be not available.
disable = true

[footprint]
# Compute and Store tracing data. (Enables trace_* APIs).
tracing = "on"
# Increase performance on HDD.
db_compaction = "hdd"
# Prune old state data. Maintains journal overlay - fast but extra 50MB of memory used.
pruning = "fast"
# Enables Fat DB
fat_db = "on"
# Number of threads will vary depending on the workload. Not guaranteed to be faster.
scale_verifiers = true
# Initial number of verifier threads
num_verifiers = 6
# If defined will never use more then 4096MB for all caches. (Overrides other cache settings).
cache_size = 4096

[misc]
log_file = "/etclassic/.local/share/io.parity.ethereum/parity.log"
logging = "own_tx=trace"

[parity]
chain = "classic"
mode = "active"
base_path = "/etclassic/.local/share/io.parity.ethereum"
no_persistent_tx_queue = true

[network]
min_peers = 50
max_peers = 100
EOL

echo Installing OpenEthereum Container

docker volume create --name=parityetc-data
docker run -v parityetc-data:/etclassic --name=parityetc-node -d \
      -p 8546:8546 \
      -p 30304:30304 \
      -p 30304:30304/udp \
      -v $HOME/.etcdocker/config.toml:/etclassic/.local/share/io.parity.ethereum/config.toml \
      bitsler/docker-openetc:latest


echo
echo "==========================="
echo "==========================="
echo "Installation Complete"
echo "RUN the utils.sh file to install openetc-cli utilities"
echo "Your configuration file is at $HOME/.etcdocker/config.toml"
echo "If you wish to change it, make sure to restart parityetc-node"
echo "IMPORTANT: To start parityetc-node manually simply start the container by docker start parityetc-node"
echo "IMPORTANT: To stop parityetc-node simply stop the container by docker stop parityetc-node"
