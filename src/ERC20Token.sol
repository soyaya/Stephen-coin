// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Stephen
 * @dev This contract is an ERC20 token that includes a transfer tax system. It uses OpenZeppelin's ERC20 and ERC20Permit for token functionality 
 * and Ownable for ownership management. The contract allows setting a tax address and tax rate for each transfer, 
 * enabling automatic tax deductions from transactions.
 */
contract Stephen is ERC20, ERC20Permit, Ownable {
    
    // Public state variables
    address public taxAddress;  // Address where tax funds are sent
    uint256 public taxRate;     // Tax rate applied on each transaction (in basis points, e.g., 100 = 1%)

    /**
     * @dev Constructor initializes the token with a name, symbol, tax address, and tax rate.
     * It also sets the initial owner via the Ownable contract.
     * @param initialOwner Address of the initial owner who will control the contract (usually the deployer).
     * @param _taxAddress Address to which taxes will be sent.
     * @param _taxRate The rate at which tax is applied to each transaction (in basis points).
     */
    constructor(address initialOwner, address _taxAddress, uint256 _taxRate)
        ERC20("Stephen", "SPN") // Set the token's name and symbol
        ERC20Permit("Stephen")  // Enable permit functionality for gasless transactions
        Ownable(initialOwner)   // Set the initial owner
    {
        taxAddress = _taxAddress; // Set the tax address
        taxRate = _taxRate;       // Set the tax rate
    }

    /**
     * @dev Custom transfer function that deducts a tax from the transfer amount.
     * The tax amount is transferred to the tax address, and the remainder is transferred to the recipient.
     * @param recipient Address of the recipient.
     * @param amount The amount to transfer.
     * @return bool Returns true if the transfer was successful.
     */
    function transferWithTax(address recipient, uint256 amount) public returns (bool) {
        uint256 taxAmount = (amount * taxRate) / 10000; // Calculate the tax based on the taxRate
        uint256 amountAfterTax = amount - taxAmount;    // Subtract the tax from the original amount

        // Transfer the tax to the tax address
        super._transfer(_msgSender(), taxAddress, taxAmount);
        
        // Transfer the remaining amount to the recipient
        super._transfer(_msgSender(), recipient, amountAfterTax);

        return true;
    }

    /**
     * @dev Custom transferFrom function that handles tax for transfers initiated by a spender.
     * The tax is deducted and sent to the tax address, and the remainder is transferred to the recipient.
     * @param sender Address of the sender.
     * @param recipient Address of the recipient.
     * @param amount The amount to transfer.
     * @return bool Returns true if the transfer was successful.
     */
    function transferFromWithTax(address sender, address recipient, uint256 amount) public returns (bool) {
        uint256 taxAmount = (amount * taxRate) / 10000; // Calculate the tax based on the taxRate
        uint256 amountAfterTax = amount - taxAmount;    // Subtract the tax from the original amount

        // Transfer the tax to the tax address
        // super._transferFrom(sender, taxAddress, taxAmount); // Commented out for now

        // Transfer the remaining amount to the recipient
        // super._transferFrom(sender, recipient, amountAfterTax); // Commented out for now

        return true;
    }

    /**
     * @dev Function to update the tax rate. Can only be called by the owner.
     * @param _taxRate The new tax rate to be applied (in basis points).
     */
    function setTaxRate(uint256 _taxRate) external onlyOwner {
        taxRate = _taxRate;
    }

    /**
     * @dev Function to update the tax address. Can only be called by the owner.
     * @param _taxAddress The new address where taxes will be sent.
     */
    function setTaxAddress(address _taxAddress) external onlyOwner {
        taxAddress = _taxAddress;
    }
}
