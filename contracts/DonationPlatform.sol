// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DonationPlatform is Ownable, ReentrancyGuard {
    struct Donation {
        address donor;
        address recipient;
        uint256 amount;
        uint256 fee;
        uint256 timestamp;
        string message;
    }

    IERC20 public donaToken;
    uint256 public feePercentage = 2; // 2% fee
    uint256 public constant MAX_FEE = 5; // Maximum 5% fee
    mapping(uint256 => Donation) public donations;
    uint256 public donationCount;
    
    event DonationMade(
        uint256 indexed donationId,
        address indexed donor,
        address indexed recipient,
        uint256 amount,
        uint256 fee,
        string message,
        uint256 timestamp
    );

    event FeeUpdated(uint256 newFee);

    constructor(address _donaToken) {
        donaToken = IERC20(_donaToken);
        donationCount = 0;
    }

    function setFeePercentage(uint256 _feePercentage) external onlyOwner {
        require(_feePercentage <= MAX_FEE, "Fee too high");
        feePercentage = _feePercentage;
        emit FeeUpdated(_feePercentage);
    }

    function donate(address _recipient, uint256 _amount, string memory _message) external nonReentrant {
        require(_amount > 0, "Donation must be greater than 0");
        require(_recipient != address(0), "Invalid recipient address");

        uint256 fee = (_amount * feePercentage) / 100;
        uint256 donationAmount = _amount - fee;

        // Transfer tokens from donor to this contract
        require(donaToken.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");

        // Transfer donation amount to recipient
        require(donaToken.transfer(_recipient, donationAmount), "Failed to send donation to recipient");

        // Transfer fee to contract owner
        require(donaToken.transfer(owner(), fee), "Failed to send fee to owner");

        // Record donation
        donations[donationCount] = Donation({
            donor: msg.sender,
            recipient: _recipient,
            amount: donationAmount,
            fee: fee,
            timestamp: block.timestamp,
            message: _message
        });

        emit DonationMade(
            donationCount,
            msg.sender,
            _recipient,
            donationAmount,
            fee,
            _message,
            block.timestamp
        );

        donationCount++;
    }

    function getDonation(uint256 _donationId) external view returns (
        address donor,
        address recipient,
        uint256 amount,
        uint256 fee,
        uint256 timestamp,
        string memory message
    ) {
        Donation storage donation = donations[_donationId];
        return (
            donation.donor,
            donation.recipient,
            donation.amount,
            donation.fee,
            donation.timestamp,
            donation.message
        );
    }

    function getDonationCount() external view returns (uint256) {
        return donationCount;
    }
} 