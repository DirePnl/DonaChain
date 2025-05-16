// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DonaChain is ERC20, Ownable {
    constructor() ERC20("DonaChain Token", "DONA") {
        // Mint initial supply to contract deployer (1 million tokens)
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    // Allow minting of new tokens by owner
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
} 