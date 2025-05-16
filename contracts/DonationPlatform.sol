// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DonationPlatform is Ownable, ReentrancyGuard {
    struct Donation {
        address donor;
        address recipient;
        uint256 amount;
        uint256 fee;
        uint256 timestamp;
        string message;
    }

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

    constructor() {
        donationCount = 0;
    }

    function setFeePercentage(uint256 _feePercentage) external onlyOwner {
        require(_feePercentage <= MAX_FEE, "Fee too high");
        feePercentage = _feePercentage;
        emit FeeUpdated(_feePercentage);
    }

    function donate(address _recipient, string memory _message) external payable nonReentrant {
        require(msg.value > 0, "Donation must be greater than 0");
        require(_recipient != address(0), "Invalid recipient address");

        uint256 fee = (msg.value * feePercentage) / 100;
        uint256 donationAmount = msg.value - fee;

        // Transfer donation amount to recipient
        (bool recipientSuccess, ) = _recipient.call{value: donationAmount}("");
        require(recipientSuccess, "Failed to send donation to recipient");

        // Transfer fee to contract owner
        (bool feeSuccess, ) = owner().call{value: fee}("");
        require(feeSuccess, "Failed to send fee to owner");

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