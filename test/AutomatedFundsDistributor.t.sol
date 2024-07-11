// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/AutomatedFundsDistributor.sol";

contract AutomatedFundsDistributorTest is Test {
    AutomatedFundsDistributor public distributor;
    address public mockSubscriptionService;

    function setUp() public {
        mockSubscriptionService = address(new MockSubscriptionService());
        distributor = new AutomatedFundsDistributor(mockSubscriptionService);
    }

    function testAddShareholder() public {
        distributor.addShareholder(payable(address(1)), 100);
        (address wallet, uint256 shares) = distributor.shareholders(0);
        assertEq(wallet, address(1));
        assertEq(shares, 100);
    }

    // Add more tests as needed
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