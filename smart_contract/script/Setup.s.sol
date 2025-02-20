// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../../src/contracts/AfriacademyRegistry.sol";
import "../../src/contracts/AfriacademyCertificate.sol";

contract Setup is Script {
    function run() external {
        // Load admin private key from environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address minter = vm.envAddress("MINTER_ADDRESS");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the registry contract
        AfriacademyRegistry registry = new AfriacademyRegistry();

        // Deploy the certificate contract with a reference to the registry
        CertificateNFT certificate = new CertificateNFT(
            "AfriacademyCertificate",
            "AFCERT"
        );

        // Grant educator role in the registry
        registry.grantRole(registry.EDUCATOR_ROLE(), minter);

        // Grant minter role in the certificate contract
        certificate.grantRole(certificate.MINTER_ROLE(), minter);

        // Output contract addresses
        console.log("AfriacademyRegistry deployed at:", address(registry));
        console.log(
            "AfriacademyCertificate deployed at:",
            address(certificate)
        );

        // End broadcasting transactions
        vm.stopBroadcast();
    }
}
