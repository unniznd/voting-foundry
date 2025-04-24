// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {Voting} from "../src/Voting.sol";

contract VotingScript is Script {
    function run() external {
        vm.startBroadcast();

        new Voting();

        vm.stopBroadcast();
    }
}
