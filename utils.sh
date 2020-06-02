#!/usr/bin/env bash
set -e
if [[ $EUID -ne 0 ]]; then
   echo "This script must be ran as root or sudo" 1>&2
   exit 1
fi

cat >/usr/bin/openetc-update <<'EOL'
#!/usr/bin/env bash
set -e
if [[ $EUID -ne 0 ]]; then
   echo "This script must be ran as root or sudo" 1>&2
   exit 1
fi

VERSION="${1:-latest}"
shift

echo "Stopping parityetc-node if it exists"
docker stop parityetc-node || true
echo "Waiting openetc gracefull shutdown..."
docker wait parityetc-node || true
echo "Updating openetc to $VERSION version..."
docker pull bitsler/docker-openetc:$VERSION
echo "Removing old openetc installation"
docker rm parityetc-node || true
echo "Running new parityetc-node container"
docker run -v parityetc-data:/etclassic --name=parityetc-node -d \
      -p 8546:8546 \
      -p 30304:30304 \
      -p 30304:30304/udp \
      -v $HOME/.etcdocker/config.toml:/etclassic/.local/share/io.parity.ethereum/config.toml \
      bitsler/docker-openetc:$VERSION $@

echo "openetc successfully updated and started"
echo ""
EOL

cat >/usr/bin/openetc-cli <<'EOL'
#!/usr/bin/env bash
command=$1
shift
curldata='{"method":"'$command'","params":['$@'],"id":1,"jsonrpc":"2.0"}'
curl --fail --silent --data "${curldata}" -H "Content-Type: application/json" -X POST localhost:8546
EOL

cat >/usr/bin/openetc-rm <<'EOL'
#!/usr/bin/env bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be ran as root or sudo" 1>&2
   exit 1
fi
echo "WARNING! This will delete ALL openetc-docker installation and files"
echo "Make sure your wallet.dat is safely backed up, there is no way to recover it!"
function uninstall() {
  sudo docker stop parityetc-node
  sudo docker rm parityetc-node
  sudo rm -rf ~/docker/volumes/parityetc-data ~/.etcdocker /usr/bin/openetc-cli
  sudo docker volume rm parityetc-data
  echo "Successfully removed"
  sudo rm -- "$0"
}
read -p "Continue (Y)?" choice
case "$choice" in
  y|Y ) uninstall;;
  * ) exit;;
esac
EOL

cat >/usr/bin/openetc-backup <<'EOL'
#!/usr/bin/env bash
echo "Backing up Ethereum Classic wallet, Please wait, this might take a few minutes"
mkdir -p $HOME/etcbackup

docker run -v parityetc-data:/dbdata --name dbstore ubuntu /bin/bash
docker run --rm --volumes-from dbstore -v $HOME/etcbackup:/backup ubuntu tar czvf /backup/ethereum-keys.tar.gz /dbdata/.local/share/io.parity.ethereum/keys
docker rm dbstore
echo "Done! Backup located at $HOME/etcbackup"
EOL

chmod +x /usr/bin/openetc-update
chmod +x /usr/bin/openetc-cli
chmod +x /usr/bin/openetc-rm
chmod +x /usr/bin/openetc-backup

echo "Successfully updated!"
echo "CLI use the command openetc-cli"