For Tests:
```sh
forge test
```

For Deployments:
```sh
forge script script/BonusDeployer.s.sol --broadcast --legacy --slow --rpc-url <RPC> --verify
```

Make sure to checkout and fill out [the env file correctly](.env.example).

Also if something with the deployment is yanky it most likely is missing chainid in the [deployments folder](./deployment/).