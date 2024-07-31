// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MultiSend {
    function multiSend(
        address token_,
        address[] memory recipients_,
        uint256[] memory amounts_
    ) public {
        IERC20 token = IERC20(token_);

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts_.length; i++) {
            totalAmount += amounts_[i];
        }

        require(
            token.transferFrom(msg.sender, address(this), totalAmount),
            "Mismatched input lengths"
        );
        require(
            recipients_.length == amounts_.length,
            "Mismatched input lengths"
        );

        for (uint256 i = 0; i < recipients_.length; i++) {
            require(
                token.transfer(recipients_[i], amounts_[i]),
                "Transfer failed"
            );
        }
    }
}
