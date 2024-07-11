// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/AutomatedFundsDistributor.sol";

contract AutomatedFundsDistributorTest is Test {
    AutomatedFundsDistributor public distributor;
    address public mockSubscriptionService;

        address payable public alice = payable(address(0x1));
    address payable public bob = payable(address(0x2));
    address payable public charlie = payable(address(0x3));

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

        function testDistributeFunds() public {
        // Add shareholders
        distributor.addShareholder(alice, 100);
        distributor.addShareholder(bob, 200);
        distributor.addShareholder(charlie, 300);

        // Simulate some time passing to make Alice the longest-holding shareholder
        // skip(1 days);
        
        // Add funds to the contract
        uint256 fundAmount = 1 ether;
        payable(address(distributor)).transfer(fundAmount);

        // Record balances before distribution
        uint256 aliceBalanceBefore = alice.balance;
        uint256 bobBalanceBefore = bob.balance;
        uint256 charlieBalanceBefore = charlie.balance;

        // Distribute funds
        distributor.distributeFunds();

        // Calculate expected distributions
        uint256 totalShares = 100 + 200 + 300;
        uint256 aliceShare = (fundAmount * 100 * 110) / (totalShares * 100); // 110% due to bonus
        uint256 bobShare = (fundAmount * 200) / totalShares;
        uint256 charlieShare = (fundAmount * 300) / totalShares;

        // Check balances after distribution
        assertEq(alice.balance - aliceBalanceBefore, aliceShare, "Alice's share is incorrect");
        assertEq(bob.balance - bobBalanceBefore, bobShare, "Bob's share is incorrect");
        assertEq(charlie.balance - charlieBalanceBefore, charlieShare, "Charlie's share is incorrect");

        // Check that all funds were distributed
        assertEq(address(distributor).balance, 0, "Not all funds were distributed");

        // Check total distributed amount
        assertEq(distributor.totalDistributed(), fundAmount, "Total distributed amount is incorrect");

        // Verify that Alice is the longest-holding shareholder
        assertEq(distributor.longestHoldingShareholder(), alice, "Longest-holding shareholder is incorrect");
    }

    // Add more tests as needed
}

// Mock SubscriptionService for testing
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