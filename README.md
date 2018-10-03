# docker-parityetc
Docker Image for Parity on Ethereum Classic

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
docker run -v parityetc-data:/etclassic --name=parityetc-node -d \
      -p 8546:8546 \
      -p 30304:30304 \
      -p 30304:30304/udp \
      -v /home/$USER/.etcdocker/config.toml:/etclassic/.local/share/io.parity.ethereum/config.toml \
      bitsler/docker-parityetc:latest
```

Check Logs
```
docker logs -f parityetc-node
```

Auto Installation
```
sudo bash -c "$(curl -L https://git.io/fxI26)"
```