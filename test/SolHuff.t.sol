// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {SolHuff} from "../src/SolHuff.sol";
import {HuffDeployer} from "lib/foundry-huff/src/HuffDeployer.sol";

contract SolHuffTest is Test {
    // SolHuff public solHuff;

    function setUp() public {}

    function test_SolHuff() public {
        bytes memory solidityBytecode = type(SolHuff).runtimeCode;
        // console2.logUint(solidityBytecode.length);
        bytes memory huffBytecode = HuffDeployer.deploy("HuffAdder").code;
        // console2.logBytes(huffBytecode);

        SolHuff solHuff = new SolHuff(solidityBytecode, huffBytecode);
        console2.logUint(solHuff.entryPoint(3, 2, 2));
    }
}

// AddAndSub addAndSub = new AddAndSub();
// YulAddAndSub yulAddAndSub = new YulAddAndSub();
// console2.logUint(addAndSub.addAndSub(3, 2, 2));
// console2.logUint(yulAddAndSub.yulAddAndSub(3, 2, 2));
// contract AddAndSub {
//     function addAndSub(uint256 a, uint256 b, uint256 c) external pure returns (uint256) {
//         return a + b - c;
//     }
// }

// contract YulAddAndSub {
//     function yulAddAndSub(uint256 a, uint256 b, uint256 c) external pure returns (uint256) {
//         assembly {
//             let addResult := add(a, b)

//             // no overflow check
//             let subResult := sub(addResult, c)
//             mstore(0x00, subResult)
//             return(0x00, 0x20)
//         }
//     }
// }
