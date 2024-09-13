// SPDX-License-Identifier: ISC
pragma solidity 0.8.27;

import "forge-std/Script.sol";
import {BonusBooster} from "src/BonusBooster.sol";

contract BonusDeployer is Script {
    string public PATH_PREFIX = string.concat("deployment/", vm.toString(block.chainid));
    string public BOOSTER_PATH = string.concat(PATH_PREFIX, "/BonusBooster/address");

    uint256 pkey = vm.envUint("PRIVATE_KEY");
    address token = vm.envAddress("TOKEN_ADDRESS");
    string uri = vm.envString("URI");

    BonusBooster booster;

    function run() external {
        vm.startBroadcast(pkey);
        booster = new BonusBooster(token, uri);

        vm.writeFile(BOOSTER_PATH, vm.toString(address(booster)));
        vm.stopBroadcast();
    } 
}