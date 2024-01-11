// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {
    IValidator, IERC4337, VALIDATION_SUCCESS, VALIDATION_FAILED
} from "src/interfaces/IModule.sol";

import { IExecution, IExecutionUserOp } from "../interfaces/IMSA.sol";
import { DecodeLib } from "../utils/Decode.sol";

contract DecodeValidator is IValidator {
    using DecodeLib for bytes;

    mapping(address => address) public owners;

    function setOwner(address owner) external {
        owners[msg.sender] = owner;
    }

    function onInstall(bytes calldata data) external override {
        address owner = address(bytes20(data));
        owners[msg.sender] = owner;
    }

    function onUninstall(bytes calldata data) external override {
        delete owners[msg.sender];
    }

    function validateUserOp(
        IERC4337.UserOperation calldata userOp,
        bytes32 userOpHash
    )
        external
        override
        returns (uint256)
    {
        bytes4 selector = bytes4(userOp.callData[0:4]);
        bytes calldata callData;
        // check if transaction is a executeUserOp or ERC7579 execute
        if (selector == IExecutionUserOp.executeUserOp.selector) {
            callData = userOp.callData[4:];
            selector = bytes4(userOp.callData[0:4]);
        } else {
            callData = userOp.callData;
        }
        if (selector == IExecution.execute.selector) {
            (address target, uint256 value, bytes calldata callData) = callData.decodeSingle();
        } else if (selector == IExecution.executeBatch.selector) {
            IExecution.Execution[] calldata executions = callData.decodeBatch();
        } else {
            return VALIDATION_FAILED;
        }
    }

    function isValidSignatureWithSender(
        address sender,
        bytes32 hash,
        bytes calldata data
    )
        external
        view
        override
        returns (bytes4)
    { }

    function isModuleType(uint256 typeID) external view returns (bool) {
        return typeID == 1;
    }
}
