#!/bin/bash

while true
do

# Logo

echo -e '\e[40m\e[91m'
echo -e '  ____                  _                    '
echo -e ' / ___|_ __ _   _ _ __ | |_ ___  _ __        '
echo -e '| |   |  __| | | |  _ \| __/ _ \|  _ \       '
echo -e '| |___| |  | |_| | |_) | || (_) | | | |      '
echo -e ' \____|_|   \__  |  __/ \__\___/|_| |_|      '
echo -e '            |___/|_|                         '
echo -e '\e[0m'

sleep 2

# Menu

PS3='Select an action: '
options=(
"Install"
"Create Wallet"
"Create Validator"
"Exit")
select opt in "${options[@]}"
do
case $opt in

"Install")
echo "============================================================"
echo "Install start"
echo "============================================================"

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export NATIVE_CHAIN_ID=native-t1" >> $HOME/.bash_profile
source $HOME/.bash_profile

# update
sudo apt update && sudo apt upgrade -y

# packages
sudo apt install curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev tar clang bsdmainutils ncdu unzip libleveldb-dev lz4 screen bc fail2ban -y

# install go
ver="1.23.1"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile
go version

# download binary
cd $HOME && mkdir -p go/bin/
wget https://github.com/gonative-cc/gonative/releases/download/v0.1.1/gonative-v0.1.1-linux-amd64.gz
gunzip gonative-v0.1.1-linux-amd64.gz
chmod +x gonative-v0.1.1-linux-amd64
mv gonative-v0.1.1-linux-amd64 /root/go/bin/gonatived

# config
#gonatived config chain-id $NATIVE_CHAIN_ID
#gonatived config keyring-backend test

# init
gonatived init $NODENAME --chain-id $NATIVE_CHAIN_ID

# download genesis and addrbook
wget -O $HOME/.gonative/config/addrbook.json "https://server-4.stavr.tech/Testnet/Native/addrbook.json"
wget -O $HOME/.gonative/config/genesis.json "https://server-4.stavr.tech/Testnet/Native/genesis.json"

# set minimum gas price
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.1untiv\"|" $HOME/.gonative/config/app.toml

# set peers and seeds
SEEDS=""
PEERS="2e2f0def6453e67a5d5872da7f73002caf55a010@195.3.221.110:52656,612e6279e528c3fadfe0bb9916fd5532bc9be2cd@164.132.247.253:56406,f2e45e48f55f649dee0e8dc4adfa445308ae8018@167.235.247.51:26656,a7577f50cdefd9a7a5e4a673278d9004df9b4bb4@103.219.169.97:56406,236946946eacbf6ab8a6f15c99dac1c80db6f8a5@65.108.203.61:52656,13b49060d7ae1375a04a8eaec8602920f47b5a55@37.142.120.99:27656,48bd9b42755de1a3039089c4cb66b9dd01561001@57.129.53.32:40656,0c2926cdac1e31e39ea137ec3438be6485fd58d7@116.202.85.179:10007,b80d0042f7096759ae6aada870b52edf0dcd74af@65.109.58.158:26056,f0e48f295e0d7c7d03943c82ac01bfc54969320b@78.46.185.199:26656,8eb8024d28b070d21844a90c7c2d34ef4b731365@193.34.213.77:15007,b5f52d67223c875947161ea9b3a95dbec30041cb@116.202.42.156:32107,5be5b41a6aef28a7779002f2af0989c7a7da5cfe@165.154.245.110:26656,b07e0482f43a2add3531e9aa7946609386b2e7e7@65.109.113.219:30656,6edabc54e76245af9f8f739303c788bfb23bd09a@95.216.12.106:24096,ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@176.9.82.221:30656,d0e0d80be68cec942ad46b36419f0ba76d35d134@94.130.138.41:26444,be5b6092815df2e0b2c190b3deef8831159bb9a2@64.225.109.119:26656,49784fe6a1b812fd45f4ac7e5cf953c2a3630cef@136.243.17.170:38656,40cbf43553e7ee3507814e3110a749a7e638aa83@194.163.169.182:24656,1e9a3f3615ec98ea66c41b7e37a724889067bc05@193.24.209.155:12056,7567880ef17ce8488c55c3256c76809b37659cce@161.35.157.54:26656,d856c6c6f195b791c54c18407a8ad4391bd30b99@142.132.156.99:24096,2dacf537748388df80a927f6af6c4b976b7274cb@148.251.44.42:26656,2c1e6b6b54daa7646339fa9abede159519ca7cae@37.252.186.248:26656,fbc51b668eb84ae14d430a3db11a5d90fc30f318@65.108.13.154:52656,48d0fdcc642690ede0ad774f3ba4dce6e549b4db@142.132.215.124:26656,24d51644ea1a6b91bf745f6767a9079d4b35e3d2@37.27.202.188:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.gonative/config/config.toml

# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.gonative/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.gonative/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.gonative/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.gonative/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.gonative/config/app.toml
sed -i "s/snapshot-interval *=.*/snapshot-interval = 0/g" $HOME/.gonative/config/app.toml

#be
sed -i -e "s/^app-db-backend *=.*/app-db-backend = \"goleveldb\"/;" $HOME/.gonative/config/app.toml
sed -i -e "s/^db_backend *=.*/db_backend = \"pebbledb\"/" $HOME/.gonative/config/config.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.gonative/config/config.toml

# create service
sudo tee /etc/systemd/system/gonatived.service > /dev/null << EOF
[Unit]
Description=Native node service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which gonatived) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# reset
gonatived tendermint unsafe-reset-all --home $HOME/.gonative --keep-addr-book
LATEST_SNAPSHOT=$(curl -s https://server-4.stavr.tech/Testnet/Native/ | grep -oE 'native-snap-[0-9]+\.tar\.lz4' | while read SNAPSHOT; do HEIGHT=$(curl -s "https://server-4.stavr.tech/Testnet/Native/${SNAPSHOT%.tar.lz4}-info.txt" | awk '/Block height:/ {print $3}'); echo "$SNAPSHOT $HEIGHT"; done | sort -k2 -nr | head -n 1 | awk '{print $1}')
curl -o - -L https://server-4.stavr.tech/Testnet/Native/$LATEST_SNAPSHOT | lz4 -c -d - | tar -x -C $HOME/.gonative

# start service
sudo systemctl daemon-reload
sudo systemctl enable gonatived
sudo systemctl restart gonatived

break
;;

"Create Wallet")
gonatived keys add $WALLET
echo "============================================================"
echo "Save address and mnemonic"
echo "============================================================"
NATIVE_WALLET_ADDRESS=$(gonatived keys show $WALLET -a)
NATIVE_VALOPER_ADDRESS=$(gonatived keys show $WALLET --bech val -a)
echo 'export NATIVE_WALLET_ADDRESS='${NATIVE_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export NATIVE_VALOPER_ADDRESS='${NATIVE_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile

break
;;

"Create Validator")
gonatived tx staking create-validator \
--amount=1000000untiv \
--pubkey=$(gonatived tendermint show-validator) \
--moniker=$NODENAME \
--chain-id=native-t1 \
--commission-rate=0.05 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--fees=35000untiv \
--gas=300000 \
-y 
  
break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done
