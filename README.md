<p align="center">
  <img height="100" height="auto" src="https://github.com/user-attachments/assets/70c0e724-0d02-4c7e-bd36-1fa49069e4b4">
</p>

# Native Testnet — native-t1

Official documentation:
>- [Validator setup instructions](https://github.com/gonative-cc/network-docs/blob/master/validator.md)

Explorer:
>- [Explorer](https://testnet.native.explorers.guru)

### Minimum Hardware Requirements
 - 4x CPUs; the faster clock speed the better
 - 8GB RAM
 - 100GB of storage (SSD or NVME)

### Recommended Hardware Requirements 
 - 8x CPUs; the faster clock speed the better
 - 16GB RAM
 - 1TB of storage (SSD or NVME)

## Set up your artela fullnode
```
wget https://raw.githubusercontent.com/freshe4qa/native/main/native.sh && chmod +x native.sh && ./native.sh
```

## Post installation

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Synchronization status:
```
gonatived status 2>&1 | jq .SyncInfo
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
gonatived keys add $WALLET
```

Recover your wallet using seed phrase
```
gonatived keys add $WALLET --recover
```

To get current list of wallets
```
gonatived keys list
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu gonatived -o cat
```

Start service
```
sudo systemctl start gonatived
```

Stop service
```
sudo systemctl stop gonatived
```

Restart service
```
sudo systemctl restart gonatived
```

### Node info
Synchronization info
```
gonatived status 2>&1 | jq .SyncInfo
```

Validator info
```
gonatived status 2>&1 | jq .ValidatorInfo
```

Node info
```
gonatived status 2>&1 | jq .NodeInfo
```

Show node id
```
gonatived tendermint show-node-id
```

### Wallet operations
List of wallets
```
gonatived keys list
```

Recover wallet
```
gonatived keys add $WALLET --recover
```

Delete wallet
```
gonatived keys delete $WALLET
```

Get wallet balance
```
gonatived query bank balances $NATIVE_WALLET_ADDRESS
```

Transfer funds
```
gonatived tx bank send $NATIVE_WALLET_ADDRESS <TO_NATIVE_WALLET_ADDRESS> 10000000untiv
```

### Voting
```
gonatived tx gov vote 1 yes --from $WALLET --chain-id=$NATIVE_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
gonatived tx staking delegate $NATIVE_VALOPER_ADDRESS 10000000untiv --from=$WALLET --chain-id=$NATIVE_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
gonatived tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000untiv --from=$WALLET --chain-id=$NATIVE_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
gonatived tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$NATIVE_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
gonatived tx distribution withdraw-rewards $NATIVE_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$NATIVE_CHAIN_ID
```

Unjail validator
```
gonatived tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$NATIVE_CHAIN_ID \
  --gas=auto
```
