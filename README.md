```sh
#
forge script script/Deploy.s.sol:DeployScript --rpc-url https://testnet.hashio.io/api --broadcast --private-key 0x...

# create a new token
cast send --rpc-url https://testnet.hashio.io/api --private-key 0x 0xea00e66888e659214eED9B0F2F7348fafa459355 "deploy(string memory name, string memory symbol, uint8 decimals)" "RSD Pazova 1" "RSDPZ1" "2"  --value 100.1ether --gas-limit 25000

# mint tokens to an address
# account must previously be associated with the token
cast send --rpc-url https://testnet.hashio.io/api --private-key 0x 0xd91fC0946Cc5437f14eE68F9B8C80F5745A9BeE8 "mint(address tokenAddress, address to, uint64 amount)" 0x00000000000000000000000000000000004C1ac7 0x8d5af9d897a80afcaf854202acf6d2641378ba6c 100 --gas-limit 22000

# approve the service to spend my tokens
cast send --rpc-url https://testnet.hashio.io/api --private-key 0x 0x00000000000000000000000000000000004C1ac7 "approve(address spender, uint256 amount)" 0xd91fC0946Cc5437f14eE68F9B8C80F5745A9BeE8 1000 --gas-limit 20000

# burn tokens
cast send --rpc-url https://testnet.hashio.io/api --private-key 0x 0xd91fC0946Cc5437f14eE68F9B8C80F5745A9BeE8 "burn(address tokenAddress, address from, uint64 amount)" 0x00000000000000000000000000000000004C1ac7 0x8d5af9d897a80afcaf854202acf6d2641378ba6c 20
```
