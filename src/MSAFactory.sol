// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import { IMSA } from "./interfaces/IMSA.sol";
import { LibClone } from "solady/src/utils/LibClone.sol";
import { Bootstrap, BootstrapConfig } from "src/utils/Bootstrap.sol";
import { IModule } from "src/interfaces/IModule.sol";

contract MSAFactory {
    address public immutable implementation;

    constructor(address _msaImplementation) {
        implementation = _msaImplementation;
    }

    function makeBootstrapConfig(
        address module,
        bytes memory data
    )
        public
        pure
        returns (BootstrapConfig[] memory config)
    {
        config = new BootstrapConfig[](1);
        config[0].module = module;
        config[0].data = abi.encodeCall(IModule.onInstall, data);
    }

    function _makeBootstrapConfig(
        address module,
        bytes memory data
    )
        public
        pure
        returns (BootstrapConfig memory config)
    {
        config.module = module;
        config.data = abi.encodeCall(IModule.onInstall, data);
    }


    function createAccount(address owner,uint256 salt) public returns (address) {
        bytes32 exampleSalt = 0x123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0;

        BootstrapConfig[] memory validators = makeBootstrapConfig(address(0), "");
        BootstrapConfig[] memory executors = makeBootstrapConfig(address(0), "");
        BootstrapConfig memory hook = _makeBootstrapConfig(address(0), "");
        BootstrapConfig memory fallbackHandler = _makeBootstrapConfig(address(0), "");

        Bootstrap bootstrap = new Bootstrap();

        bytes memory initCode = bootstrap._getInitMSACalldata(
                        validators, executors, hook, fallbackHandler
                        );

        return createAccount1(
            exampleSalt, initCode);
    }

    function createAccount1(
        bytes32 salt,
        bytes memory initCode
    )
        public
        payable
        virtual
        returns (address)
    {
        bytes32 _salt = _getSalt(salt, initCode);
        (bool alreadyDeployed, address account) =
            LibClone.createDeterministicERC1967(msg.value, implementation, _salt);

        if (!alreadyDeployed) {
            IMSA(account).initializeAccount(initCode);
        }
        return account;
    }

    function getAddress(address owner,uint256 salt) public returns (address) {
        bytes32 exampleSalt = 0x123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0;

        BootstrapConfig[] memory validators = makeBootstrapConfig(address(0), "");
        BootstrapConfig[] memory executors = makeBootstrapConfig(address(0), "");
        BootstrapConfig memory hook = _makeBootstrapConfig(address(0), "");
        BootstrapConfig memory fallbackHandler = _makeBootstrapConfig(address(0), "");

        Bootstrap bootstrap = new Bootstrap();

        bytes memory initCode = bootstrap._getInitMSACalldata(
                        validators, executors, hook, fallbackHandler
                        );

        return getAddress1(
            exampleSalt, initCode);
    }

    function getAddress1(
        bytes32 salt,
        bytes memory initcode
    )
        public
        view
        virtual
        returns (address)
    {
        bytes32 _salt = _getSalt(salt, initcode);
        return LibClone.predictDeterministicAddressERC1967(implementation, _salt, address(this));
    }

    function _getSalt(
        bytes32 _salt,
        bytes memory initCode
    )
        public
        pure
        virtual
        returns (bytes32 salt)
    {
        salt = keccak256(abi.encodePacked(_salt, initCode));
    }
}
