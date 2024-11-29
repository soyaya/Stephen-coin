// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Stephen is ERC20, ERC20Permit, Ownable {
    address public taxAddress;
    uint256 public taxRate;
    address public owner1;

    constructor(address initialOwner, address _taxAddress, uint256 _taxRate)
        ERC20("Stephen", "SPN")
        ERC20Permit("Stephen")
        Ownable(owner1)
    {
        taxAddress = _taxAddress;
        taxRate = _taxRate;
        transferOwnership(initialOwner); // Set the initial owner
    }

    // Custom mint function to allow minting new tokens to an address
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount); // Calls the internal _mint function from ERC20
    }

    // Custom transfer function that handles tax
    function transferWithTax(address recipient, uint256 amount) public returns (bool) {
        uint256 taxAmount = (amount * taxRate) / 10000;
        uint256 amountAfterTax = amount - taxAmount;

        // Transfer tax to the tax address
        _transfer(_msgSender(), taxAddress, taxAmount);
        
        // Transfer remaining amount to recipient
        _transfer(_msgSender(), recipient, amountAfterTax);

        return true;
    }

    // Custom transferFrom function that handles tax
    function transferFromWithTax(address sender, address recipient, uint256 amount) public returns (bool) {
        uint256 taxAmount = (amount * taxRate) / 10000; 
        uint256 amountAfterTax = amount - taxAmount;

        // Transfer tax to the tax address
       // _transferFrom(sender, taxAddress, taxAmount);

        // Transfer remaining amount to recipient
       // _transferFrom(sender, recipient, amountAfterTax);

        return true;
    }

    // Function to set the tax rate
    function setTaxRate(uint256 _taxRate) external onlyOwner {
        taxRate = _taxRate;
    }

    // Function to set the tax address
    function setTaxAddress(address _taxAddress) external onlyOwner {
        taxAddress = _taxAddress;
    }
}
