# ERC4626Vault
A vault named **DiamondHands(ERC4626)** that allows depositors to deposit `WETH` &amp; receive `vWETH` as shares. The depositors can redeem `vWETH` for `WETH` + `USDC(rewards)`.

### Run forge tests 

Create a `.env` file in the root and add a **Goerli RPC URL** in the same like follows.

```
GOERLI_RPC_URL=
```
Do a `source .env` and `echo $GOERLI_RPC_URL` in terminal to check if RPC setup is working.

**RUN**

`forge test --fork-url $GOERLI_RPC_URL -vvv`



