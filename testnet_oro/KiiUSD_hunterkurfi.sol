// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title KiiStablecoin
 * @dev Simple Stablecoin implementation for KiiChain Builder Guide
 */
contract KiiStablecoin is ERC20, Ownable {
    
    // The constructor mints an initial supply to the deployer
    // Name: Kii Dollar, Symbol: KIIUSD
    constructor() ERC20("Kii Dollar", "KIIUSD") Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    /**
     * @dev Function to mint more stablecoins. 
     * Only the owner (you) can call this.
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
