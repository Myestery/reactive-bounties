// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/AutomatedFundsDistributor.sol";
import "../src/ISubscriptionService.sol";

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

contract MockSubscriptionService is ISubscriptionService {
    event Subscribed(uint256 chainId, address contractAddress, uint256 topic0, uint256 topic1, uint256 topic2, uint256 topic3);
    event Unsubscribed(uint256 chainId, address contractAddress, uint256 topic0, uint256 topic1, uint256 topic2, uint256 topic3);

    function subscribe(
        uint256 chainId,
        address contractAddress,
        uint256 topic0,
        uint256 topic1,
        uint256 topic2,
        uint256 topic3
    ) external override {
        emit Subscribed(chainId, contractAddress, topic0, topic1, topic2, topic3);
    }

    function unsubscribe(
        uint256 chainId,
        address contractAddress,
        uint256 topic0,
        uint256 topic1,
        uint256 topic2,
        uint256 topic3
    ) external override {
        emit Unsubscribed(chainId, contractAddress, topic0, topic1, topic2, topic3);
    }
}