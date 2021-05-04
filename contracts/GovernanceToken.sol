// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract GovernanceToken is ERC20, Ownable {
    constructor() ERC20('Governance Token', 'GOV') Ownable() {}

    /// @notice mint Governance Tokens by the Liquidity Pool to eg investor, liquidity provider etc 
    /// @param _to the address to receive the Governance Tokens
    /// @param _amountTokens the amount of Governance Tokens to send to address
    function mint(address _to, uint _amountTokens) external onlyOwner() {
        _mint(_to, _amountTokens);
    }

}