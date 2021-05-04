// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './GovernanceToken.sol';
import './LiquidityToken.sol';
import './UnderlyingToken.sol';

contract LiquidityPool is LiquidityToken {

    // keep track when deposits for reward calculations (which blocks changes happened)
    mapping(address => uint) public checkpoints;

    UnderlyingToken public underlyingToken;
    GovernanceToken  public governanceToken;

    // reward per Block 
    uint constant public REWARD_PER_BLOCK = 1;

    constructor(
        address _underlyingToken,
        address _governanceToken
    ) 
    {
        governanceToken = GovernanceToken(_governanceToken);
        underlyingToken = UnderlyingToken(_underlyingToken);
    }

    /// @notice 
    /// @param _beneficiary the address to receive rewards
    function _distributeRewards(address _beneficiary) internal {
        uint points = checkpoints[_beneficiary];
        uint numBlocks = block.number - points;
        if(numBlocks > 0) {
            // simplify to 1:1 ratio
            uint lpToken = balanceOf(_beneficiary);
            // calculate number of Governance Tokens to give per block
            uint reward = lpToken * numBlocks * REWARD_PER_BLOCK;
            // LiquidityPool is owner of Governance Token so can mint to reward 
            governanceToken.mint(_beneficiary,reward);
            checkpoints[_beneficiary] = block.number;
        }
    }

    /// @notice deposit underlyingTokens to get LiqudityToken and gain rewards Governance Tokens
    /// @param _amountUnderlyingTokens the amount of underlyingTokens to deposit
    function deposit(uint _amountUnderlyingTokens) external {
        if(checkpoints[msg.sender] == 0) {
            checkpoints[msg.sender] == block.number;
        }
        _distributeRewards(msg.sender);
        // approve needs to have been called on the liquidity pool
        underlyingToken.transferFrom(msg.sender, address(this), _amountUnderlyingTokens);
        // Liquidity pool will give Liquidity Tokens to investor in ratio here 1:1 for simplicity
        _mint(msg.sender, _amountUnderlyingTokens);
    }

    /// @notice redeem lpTokens to get back your underlyingTokens
    /// @param _amountLPTokens) the amount of lpTokens to redeem
    function withdraw(uint _amountLPTokens) external {
        require(balanceOf(msg.sender) >= _amountLPTokens, 'not enough lp token');
        _distributeRewards(msg.sender);
        underlyingToken.transfer(msg.sender, _amountLPTokens);
        _burn(msg.sender, _amountLPTokens);
    }

}