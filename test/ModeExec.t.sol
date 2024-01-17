import "./MSA_ValidatorInNonce.t.sol";

contract ModeExecTest is MSANonceTest {
    bytes32 constant MODE_TRY_EXEC =
        0xdeadbeef00000000000000000000000000000000000000000000000000000001;

    function test_execMode() public {
        bytes memory setValueOnTarget = abi.encodeCall(MockTarget.setValue, 1337);
        implementation.executeMode(MODE_TRY_EXEC, address(target), 0, setValueOnTarget);
    }
}
