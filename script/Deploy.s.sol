// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import "src/accountExamples/MSA_ValidatorInNonce.sol";
import "src/MSAFactory.sol";
import "src/utils/Bootstrap.sol";

/**
 * @title Deploy
 * @author @kopy-kat
 */
contract DeployScript is Script {
    function run() public {
        bytes32 salt = bytes32(uint256(0));

        vm.startBroadcast(vm.envUint("PK"));

        // Deploy MSA
        MSA account = new MSA{ salt: salt }();

        // Deploy Factory
        MSAFactory factory = new MSAFactory{ salt: salt }(address(account));

        // Deploy Bootstrap
        Bootstrap bootstrap = new Bootstrap{ salt: salt }();

        vm.stopBroadcast();
    }
}
