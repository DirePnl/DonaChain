// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IUniswapV2Router02.sol";

contract DonationPlatform is Ownable, ReentrancyGuard {
    struct Donation {
        address donor;
        address recipient;
        uint256 amount;
        uint256 fee;
        uint256 timestamp;
        string message;
        bool wasEthDonation;
    }

    IERC20 public donaToken;
    IUniswapV2Router02 public uniswapRouter;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // Mainnet WETH
    uint256 public feePercentage = 2; // 2% fee
    uint256 public constant MAX_FEE = 5; // Maximum 5% fee
    uint256 public minDonaOut; // Minimum DONA tokens to receive from swap
    mapping(uint256 => Donation) public donations;
    uint256 public donationCount;
    
    event DonationMade(
        uint256 indexed donationId,
        address indexed donor,
        address indexed recipient,
        uint256 amount,
        uint256 fee,
        string message,
        uint256 timestamp,
        bool wasEthDonation
    );

    event FeeUpdated(uint256 newFee);
    event MinDonaOutUpdated(uint256 newMinDonaOut);

    constructor(
        address _donaToken,
        address _uniswapRouter,
        uint256 _minDonaOut
    ) {
        donaToken = IERC20(_donaToken);
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        minDonaOut = _minDonaOut;
        donationCount = 0;
    }

    function setFeePercentage(uint256 _feePercentage) external onlyOwner {
        require(_feePercentage <= MAX_FEE, "Fee too high");
        feePercentage = _feePercentage;
        emit FeeUpdated(_feePercentage);
    }

    function setMinDonaOut(uint256 _minDonaOut) external onlyOwner {
        minDonaOut = _minDonaOut;
        emit MinDonaOutUpdated(_minDonaOut);
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
            message: _message,
            wasEthDonation: false
        });

        emit DonationMade(
            donationCount,
            msg.sender,
            _recipient,
            donationAmount,
            fee,
            _message,
            block.timestamp,
            false
        );

        donationCount++;
    }

    function donateWithEth(address _recipient, string memory _message) external payable nonReentrant {
        require(msg.value > 0, "ETH amount must be greater than 0");
        require(_recipient != address(0), "Invalid recipient address");

        // Setup swap path
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = address(donaToken);

        // Calculate minimum DONA tokens to receive
        uint256[] memory amounts = uniswapRouter.getAmountsOut(msg.value, path);
        require(amounts[1] >= minDonaOut, "Insufficient DONA output");

        // Swap ETH for DONA tokens
        uint256[] memory swappedAmounts = uniswapRouter.swapExactETHForTokens{value: msg.value}(
            minDonaOut,
            path,
            address(this),
            block.timestamp + 300 // 5 minute deadline
        );

        uint256 donaReceived = swappedAmounts[1];
        uint256 fee = (donaReceived * feePercentage) / 100;
        uint256 donationAmount = donaReceived - fee;

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
            message: _message,
            wasEthDonation: true
        });

        emit DonationMade(
            donationCount,
            msg.sender,
            _recipient,
            donationAmount,
            fee,
            _message,
            block.timestamp,
            true
        );

        donationCount++;
    }

    function getDonation(uint256 _donationId) external view returns (
        address donor,
        address recipient,
        uint256 amount,
        uint256 fee,
        uint256 timestamp,
        string memory message,
        bool wasEthDonation
    ) {
        Donation storage donation = donations[_donationId];
        return (
            donation.donor,
            donation.recipient,
            donation.amount,
            donation.fee,
            donation.timestamp,
            donation.message,
            donation.wasEthDonation
        );
    }

    function getDonationCount() external view returns (uint256) {
        return donationCount;
    }

    // Function to get current ETH to DONA conversion rate
    function getEthToDonaRate(uint256 _ethAmount) external view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = address(donaToken);
        uint256[] memory amounts = uniswapRouter.getAmountsOut(_ethAmount, path);
        return amounts[1];
    }

    // Allow contract to receive ETH
    receive() external payable {}
    fallback() external payable {}
} 