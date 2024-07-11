// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IReactive.sol";
import "./ISubscriptionService.sol";

contract AutomatedFundsDistributor is IReactive {
    ISubscriptionService private subscriptionService;
    
    struct Shareholder {
        address payable wallet;
        uint256 shares;
    }
    
    Shareholder[] public shareholders;
    uint256 public totalShares;
    uint256 public totalDistributed;
    
    // Memecoin twist: Bonus multiplier for longest-holding shareholder
    uint256 public constant BONUS_MULTIPLIER = 110; // 10% bonus
    uint256 public longestHoldingTimestamp;
    address public longestHoldingShareholder;
    
    event FundsDistributed(uint256 amount);
    event ShareholderAdded(address indexed wallet, uint256 shares);
    event ShareholderRemoved(address indexed wallet);
    
    constructor(address _subscriptionService) {
        subscriptionService = ISubscriptionService(_subscriptionService);
        
        // Subscribe to receive notifications for incoming ETH
        subscriptionService.subscribe(
            0, // all chains
            address(this), // this contract
            0, // all topics
            0, 0, 0 // ignore other topics
        );
    }
    
    function addShareholder(address payable _wallet, uint256 _shares) external {
        require(_wallet != address(0), "Invalid wallet address");
        require(_shares > 0, "Shares must be greater than 0");
        
        for (uint i = 0; i < shareholders.length; i++) {
            require(shareholders[i].wallet != _wallet, "Shareholder already exists");
        }
        
        shareholders.push(Shareholder(_wallet, _shares));
        totalShares += _shares;
        
        if (shareholders.length == 1 || block.timestamp < longestHoldingTimestamp) {
            longestHoldingTimestamp = block.timestamp;
            longestHoldingShareholder = _wallet;
        }
        
        emit ShareholderAdded(_wallet, _shares);
    }
    
    function removeShareholder(address _wallet) external {
        for (uint i = 0; i < shareholders.length; i++) {
            if (shareholders[i].wallet == _wallet) {
                totalShares -= shareholders[i].shares;
                shareholders[i] = shareholders[shareholders.length - 1];
                shareholders.pop();
                emit ShareholderRemoved(_wallet);
                return;
            }
        }
        revert("Shareholder not found");
    }
    
    function react(
        uint256 chain_id,
        address _contract,
        uint256 topic_0,
        uint256 topic_1,
        uint256 topic_2,
        uint256 topic_3,
        bytes calldata data,
        uint256 block_number,
        uint256 op_code
    ) external override {
        // This function is called when funds are received
        distributeFunds();
    }
    
    function distributeFunds() public {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to distribute");
        require(shareholders.length > 0, "No shareholders");
        
        for (uint i = 0; i < shareholders.length; i++) {
            uint256 amount = (balance * shareholders[i].shares) / totalShares;
            
            // Apply bonus for longest-holding shareholder
            if (shareholders[i].wallet == longestHoldingShareholder) {
                amount = (amount * BONUS_MULTIPLIER) / 100;
            }
            
            shareholders[i].wallet.transfer(amount);
        }
        
        totalDistributed += balance;
        emit FundsDistributed(balance);
    }
    
    // Function to receive ETH
    receive() external payable {
        // Funds received, distribution will be handled by the react function
    }
    
    // Fallback function in case someone sends funds with data
    fallback() external payable {
        // Funds received, distribution will be handled by the react function
    }
}