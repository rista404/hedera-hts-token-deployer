```sh
forge script script/Deploy.s.sol:DeployScript --rpc-url https://testnet.hashio.io/api --broadcast --private-key 0x...

cast send --rpc-url https://testnet.hashio.io/api --private-key 0xb5a285e87dedb75d702f56cfe666234f447114d2ed9c4f189a202de4512b43f3 0xE4A7de4b40D1E53e63F581B4cE975BEc823035dB "deploy(string memory name, string memory symbol, uint8 decimals)" "RSD Pazova 1" "RSDPZ1" "2"  --value 100.1ether --gas-limit 25000

cast send --rpc-url https://testnet.hashio.io/api --private-key 0xb5a285e87dedb75d702f56cfe666234f447114d2ed9c4f189a202de4512b43f3 0x80DC6672EED75cC451558455D9b3aB219A3F874B "mint(address tokenAddress, address to, uint64 amount)" 0x00000000000000000000000000000000004c19F6 0x8d5af9d897a80afcaf854202acf6d2641378ba6c 100 --gas-limit 22000
```
