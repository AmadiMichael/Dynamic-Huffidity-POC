// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SolHuff {
    // this is equal to solidityBytecode.length,
    // making this immutable would not let us get the `solidityBytecode` variable for the constructor before deploying
    // it has to be written manually as a constant beforehand
    uint256 constant offsetOfHuffAddImplementation = 165;

    constructor(bytes memory solidityBytecode, bytes memory huffBytecode) {
        // concat the solidity and huff runtime code together
        bytes memory fullRuntimeCode = bytes.concat(solidityBytecode, huffBytecode);

        // return the concatenated runtime code as the runtime code
        assembly {
            return(add(0x20, fullRuntimeCode), mload(fullRuntimeCode))
        }
    }

    function entryPoint(uint256 a, uint256 b, uint256 c) external pure returns (uint256 x) {
        // we are trying to do `a + b - c`
        // `a + b` happens in huff, `result - c` happens in solidity in the `sub()` function below

        // pointer to our huff embedded runtime code, uninitialized for now
        function() internal pure optimizedAdder;
        // where we want the huff runtime code to return to after executing
        function() internal pure continueJumpdest = sub;

        assembly {
            // mstore the runtime code offset where execution should continue in memory for the huff runtime code to get it after it's done executing
            mstore(0x20, continueJumpdest)
            // set jumpdest of huffRuntime code to optimizedAdder so that when called, it executes huffRuntime code
            optimizedAdder := offsetOfHuffAddImplementation
        }

        // call the huff runtime code
        // this will add a and b, then jump to `sub()` jumpdest where we subtract using solidity inline assembly
        optimizedAdder();
    }

    // huff runtime will jump back here after it's done executing
    function sub() private pure {
        // normally this will take an input `addResult` but we can't pass that directly to solidity from huff so we store it in memory with huff and load it here
        // declare the variables that would have been inputs

        // @huff_param uint256 addResult: mem[0x00:0x20]
        // @huff_param uint256 c: calldata[0x44:0x64]
        assembly {
            // get addResult from memory
            let addResult := mload(0x00)

            // get `c` from calldata
            let c := calldataload(0x44)

            // no overflow check
            let subResult := sub(addResult, c)

            // return from the whole execution
            mstore(0x00, subResult)
            return(0x00, 0x20)
        }
    }
}
