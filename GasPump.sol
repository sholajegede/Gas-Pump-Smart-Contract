// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract GasPump {
    /**
    The address of the person that deployed the contract.
    In this case, the owner of the contract is the owner of the gas station.
    */
    address payable public pumpOwner;   //address of the person that deployed the contract.

    /**
    The amount the gas is being sold for.
    This would be fixed at the time of deploying the contract.
    */
    uint public gasAmount;
    
    /**
    This is an event that would be called after payment
    has been made for the gas.
    */
    event Purchase(uint amount);

    /**
    In simple terms, this shows the amount of gas currently
    in the pump (in litres).
    */
    mapping (address => uint) internal pumpBalance;

    constructor() {
        /**
        "[address(this)]" represents the address of the smart contract.
        */
        pumpOwner = payable(msg.sender);

        /**
        Most petrol and diesel pumps have large cylindrical tanks
        placed below the ground. Each tank has a capacity of
        21000–22000 litres.
        Hence, we would be giving this smart contract an initial
        balance of 21000 litres. 
        */
        pumpBalance[address(this)] = 21000;

        /**
        Using Chevron's current gas price of 4.27 USD per-gallon
        which is equivalent to 0.0025 ETH.
        */
        gasAmount =  0.0025 ether;
    }

    /**
    This function does exactly what it is called.
    It shows the balance (or amount of gas in litres)
    currently in the pump.
    */
    function getPumpBalance() public view returns (uint) {
        return pumpBalance[address(this)];
    }

    /**
    This function is used to purchase the gas from the pump.
    */
    function buyGas(uint amount) public payable {
        /**
        Ether for the transaction should be equal
        to the amount the gas is sold for.
        */
        require(msg.value == amount * gasAmount, "You must pay at least 0.00083 ETH for a litre");

        /**
        pumpBalance should be greater than the
        amount of gas the buyer wants to buy.
        */  
        require(pumpBalance[address(this)] >= amount, "Not enough gas in the Pump");        
        pumpBalance[address(this)] -= amount;
        pumpBalance[msg.sender] += amount;
        emit Purchase(msg.value);
    }

    /**
    This function can only be called by the deployer of the
    contract (the gas station owner).
    It pulls out funds paid into the contract by buyers
    and sends it to the address of the address the owner.
    */
    function withdrawPayments() external payable {
        require(msg.sender == pumpOwner, "You are unauthorized.");
        pumpOwner.transfer(address(this).balance);
    }

    /**
    This function can also be called only by the deployer
    of the contract.
    It's purpose is to update the smart contract with the 
    number of litres that have been refuled back into
    the gas cylinders.
    */
    function restockPump(uint amount) public {
        require(msg.sender == pumpOwner, "You are not authorized");
        pumpBalance[address(this)] += amount;
    }  
}


/**
 * MAKING PAYMENTS:
To make payments at the gas station, a QR code initiating 
the smart contract would be provided on each gas pump.
This qr code can then be scanned by the buyers at the gas station connecting
their mobile wallets to the Gas Pump.
*/