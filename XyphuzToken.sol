// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract XyphuzToken is ERC20 {
    // Declare the address of the master (owner)
    address public master;
    // Declare the address of the censor
    address public censor;
    // Declare a mapping to keep track of blacklisted addresses
    mapping(address => bool) public blacklist;

    // Constructor function to initialize the token
    constructor() ERC20("XyphuzToken", "XT") {
        // Set the initial master and censor to the deployer's address
        master = msg.sender;
        censor = msg.sender;
        
        // Mint 100,000,000 tokens to the deployer's address
        _mint(msg.sender, 100000000 * 10 ** decimals());
    }

    // Modifier to restrict function access to the master only
    modifier onlyMaster() {
        require(msg.sender == master, "Caller must be master.");
        _;
    }

    // Modifier to restrict function access to the master or censor
    modifier onlyWhoCanCensor() {
        require(msg.sender == master || msg.sender == censor, "Caller must be master or censor.");
        _;
    }

    // Modifier to prevent blacklisted addresses from participating in transfers
    modifier notBlacklisted(address target) {
        require(!blacklist[target], "Sender or recipient must not be blacklisted.");
        _;
    }

    // Function to change the master address
    function changeMaster(address newMaster) external onlyMaster {
        master = newMaster;
    }

    // Function to change the censor address
    function changeCensor(address newCensor) external onlyMaster {
        censor = newCensor;
    }

    // Function to add or remove an address from the blacklist
    function setBlacklist(address target, bool blacklisted) external onlyWhoCanCensor {
        blacklist[target] = blacklisted;
    }

    // Override the transfer function to prevent blacklisted addresses from transferring tokens
    function transfer(address recipient, uint256 amount) public override notBlacklisted(msg.sender) notBlacklisted(recipient) returns (bool) {
        return super.transfer(recipient, amount);
    }

    // Override the transferFrom function to prevent blacklisted addresses from transferring tokens
    function transferFrom(address sender, address recipient, uint256 amount) public override notBlacklisted(msg.sender) notBlacklisted(recipient) returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }

    // Function to mint new tokens, accessible only by the master
    function mint(address target, uint256 amount) external onlyMaster {
        _mint(target, amount);
    }

    // Function to burn existing tokens, accessible only by the master
    function burn(address target, uint256 amount) external onlyMaster {
        _burn(target, amount);
    }

    // Function to claw back tokens from an address, accessible only by the master
    function clawBack(address target, uint256 amount) external onlyMaster {
        _transfer(target, master, amount);
    }
}