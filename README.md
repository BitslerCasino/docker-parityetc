# docker-parityetc
Docker Image for OpenEthereum for use with ETH

### Quick Start
Create a parityetc-data volume to persist the parityetc blockchain data, should exit immediately. The parityetc-data container will store the blockchain when the node container is recreated (software upgrade, reboot, etc):
```
docker volume create --name=parityetc-data
```
Create a config.toml file and put your configurations
```
mkdir -p ~/.etcdocker
nano /home/$USER/.etcdocker/config.toml
```

Run the docker image
```
docker run -v parityetc-data:/eth --name=parityetc-node -d \
      -p 8546:8546 \
      -p 30304:30304 \
      -p 30304:30304/udp \
      -v /home/$USER/.etcdocker/config.toml:/etclassic/.local/share/io.parity.ethereum/config.toml \
      bitsler/docker-openetc:latest
```

Check Logs
```
docker logs -f parityetc-node
```

Auto Installation
```
sudo bash -c "$(curl -L https://github.com/BitslerCasino/docker-parityetc/releases/download/v3.0.0/install.sh)"
```

Auto Updater
```
sudo bash -c "$(curl -L https://github.com/BitslerCasino/docker-parityetc/releases/download/v3.0.0/utils.sh)"
```
Then run `sudo openetc-update 3.0.0` for the latest version

