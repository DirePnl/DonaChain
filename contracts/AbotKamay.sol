// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DonationPlatformWithFee {
    struct Campaign {
        address payable recipient;
        string name;
        string description;
        uint256 totalReceived;
        bool isActive;
    }

    address payable public platformWallet;
    uint256 public platformFeePercent = 1; // 1% fee
    Campaign[] private _campaignList;
    mapping(uint256 => mapping(address => uint256)) public donations;
    mapping(uint256 => uint256) private availableFunds;

    // Reentrancy guard variables
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    event CampaignCreated(uint256 indexed id, address indexed recipient);
    event DonationMade(uint256 indexed campaignId, address indexed donor, uint256 amount, uint256 fee);
    event FundsWithdrawn(uint256 indexed campaignId, uint256 amount);

    constructor(address payable _platformWallet) {
        require(_platformWallet != address(0), "Invalid platform wallet");
        platformWallet = _platformWallet;
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "Reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    function createCampaign(string memory name, string memory description) public {
        Campaign memory newCampaign = Campaign(payable(msg.sender), name, description, 0, true);
        _campaignList.push(newCampaign);
        emit CampaignCreated(_campaignList.length - 1, msg.sender);
    }

    function donate(uint256 id) public payable nonReentrant {
        require(id < _campaignList.length, "Invalid campaign ID");
        require(_campaignList[id].isActive, "Inactive campaign");
        require(msg.value > 0, "Donation must be > 0");

        uint256 fee = (msg.value * platformFeePercent) / 100;
        uint256 donationAmount = msg.value - fee;

        _campaignList[id].totalReceived += donationAmount;
        donations[id][msg.sender] += donationAmount;
        availableFunds[id] += donationAmount;

        platformWallet.transfer(fee);

        emit DonationMade(id, msg.sender, donationAmount, fee);
    }

    function withdraw(uint256 id) public nonReentrant {
        require(id < _campaignList.length, "Invalid campaign ID");
        Campaign storage campaign = _campaignList[id];
        require(campaign.isActive, "Campaign is inactive");
        require(msg.sender == campaign.recipient, "Unauthorized");

        uint256 availableAmount = availableFunds[id];
        require(availableAmount > 0, "Nothing to withdraw");

        availableFunds[id] = 0;
        campaign.recipient.transfer(availableAmount);

        emit FundsWithdrawn(id, availableAmount);
    }

    function getCampaign(uint256 id) public view returns (
        address recipient,
        string memory name,
        string memory description,
        uint256 totalReceived,
        bool isActive
    ) {
        require(id < _campaignList.length, "Invalid campaign ID");
        Campaign memory campaign = _campaignList[id];
        return (
            campaign.recipient,
            campaign.name,
            campaign.description,
            campaign.totalReceived,
            campaign.isActive
        );
    }

    function getCampaignCount() public view returns (uint256) {
        return _campaignList.length;
    }
}
