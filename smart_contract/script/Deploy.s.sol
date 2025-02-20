// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../../src/contracts/AfriacademyRegistry.sol";
import "../../src/contracts/AfriacademyCertificate.sol";

contract Deploy is Script {
    function run() external {
        // Load admin private key from environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the AfriacademyRegistry contract
        AfriacademyRegistry registry = new AfriacademyRegistry();

        // Optionally grant roles or configure initial state
        address educator = vm.envAddress("EDUCATOR_ADDRESS");
        registry.grantRole(registry.EDUCATOR_ROLE(), educator);

        // End broadcasting transactions
        vm.stopBroadcast();

        console.log("AfriacademyRegistry deployed at:", address(registry));
    }
}
