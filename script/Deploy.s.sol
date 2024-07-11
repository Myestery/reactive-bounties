// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/AutomatedFundsDistributor.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy a mock SubscriptionService for testing purposes
        MockSubscriptionService mockSubscriptionService = new MockSubscriptionService();

        // Deploy the AutomatedFundsDistributor
        AutomatedFundsDistributor distributor = new AutomatedFundsDistributor(address(mockSubscriptionService));

        vm.stopBroadcast();
    }
}

// Mock SubscriptionService for testing
contract MockSubscriptionService is ISubscriptionService {
    function subscribe(
        uint256,
        address,
        uint256,
        uint256,
        uint256,
        uint256
    ) external override {}
}