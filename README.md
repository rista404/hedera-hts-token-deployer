```sh
forge script script/Deploy.s.sol:DeployScript --rpc-url https://testnet.hashio.io/api --broadcast --private-key 0x...

cast send --rpc-url http://localhost:7546/api --private-key 0x... 0xbe64A2D06EC7f378a420A92CecabD992Da5D3dF3  "deploy(string memory name, string memory symbol, uint8 decimals)" "RSD Pazova 1" "RSDPZ1" "2" --value 400011104
```
