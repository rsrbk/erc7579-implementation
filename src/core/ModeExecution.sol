// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { DecodeLib } from "../utils/Decode.sol";
import { IExecution } from "../interfaces/IMSA.sol";

enum SELECTOR {
    NONE,
    SINGLE,
    BATCH,
    DELEGATECALL
}

enum EXEC_MODE {
    NONE,
    EXEC,
    TRY_EXEC
}

library ModeLib {
    function decode(bytes32 mode)
        internal
        pure
        returns (SELECTOR _selector, EXEC_MODE _mode, bytes30 _context)
    {
        assembly {
            _selector := shr(248, mode)
            _mode := shr(224, mode)
            _context := shr(192, mode)
        }
    }
}

abstract contract ModeExecution {
    using ModeLib for bytes32;
    using DecodeLib for bytes;

    function executeMode(bytes32 _mode, bytes calldata data) external payable {
        // handle batch
        (SELECTOR selector, EXEC_MODE mode, bytes30 context) = _mode.decode();

        // (optional) decode stuff from context

        if (selector == SELECTOR.BATCH) {
            IExecution.Execution[] calldata executions = data.decodeBatch();
            if (mode == EXEC_MODE.EXEC) {
                _execute(executions);
            } else if (mode == EXEC_MODE.TRY_EXEC) {
                _tryExecute(executions);
            }
        } else if (selector == SELECTOR.SINGLE) {
            (address target, uint256 value, bytes calldata callData) = data.decodeSingle();
            if (mode == EXEC_MODE.EXEC) {
                _execute(target, value, callData);
            } else if (mode == EXEC_MODE.TRY_EXEC) {
                _tryExecute(target, value, callData);
            }
        }
    }

    function supportsMode(SELECTOR selector, EXEC_MODE mode) external view virtual returns (bool) {
        if (mode == EXEC_MODE.EXEC) {
            return selector == SELECTOR.SINGLE || selector == SELECTOR.BATCH;
        } else if (mode == EXEC_MODE.TRY_EXEC) {
            return selector == SELECTOR.SINGLE || selector == SELECTOR.BATCH;
        } else {
            return false;
        }
    }

    function _execute(
        address target,
        uint256 value,
        bytes calldata callData
    )
        internal
        virtual
        returns (bytes[] memory result);

    function _execute(IExecution.Execution[] calldata executions)
        internal
        virtual
        returns (bytes[] memory result);

    function _tryExecute(
        address target,
        uint256 value,
        bytes calldata callData
    )
        internal
        virtual
        returns (bytes[] memory result);

    function _tryExecute(IExecution.Execution[] calldata executions)
        internal
        virtual
        returns (bytes[] memory result);
}
