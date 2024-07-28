// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, ERC20Burnable, Ownable {
    bool private _mintable;
    bool private _burnable;
    uint8 private _decimals;
    uint256 private _maxTokensPerWallet;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address initialOwner_,
        uint256 initialSupply_,
        bool mintable_,
        bool burnable_,
        uint256 maxTokensPerWallet_
    ) ERC20(name_, symbol_) Ownable(initialOwner_) {
        _decimals = decimals_;
        _mintable = mintable_;
        _burnable = burnable_;
        _maxTokensPerWallet = maxTokensPerWallet_;

        _mint(msg.sender, initialSupply_ * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(_mintable, "Token does not allow minting");
        _mint(to, amount);
    }

    function burn(uint256 value) public override {
        require(_burnable, "Token does not allow burning");
        _burn(_msgSender(), value);
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._beforeTokenTransfer(from, to, amount);

        if (to != address(0)) {
            require(
                balanceOf(to) + amount <= _maxTokensPerWallet,
                "Exceeds max tokens per wallet"
            );
        }

        // if (
        //     from != address(0) &&
        //     !isExcludedFromTax[from] &&
        //     !isExcludedFromTax[to]
        // ) {
        //     uint256 taxAmount = (amount * transactionTaxRate) / 10000;
        //     if (taxAmount > 0) {
        //         _burn(from, taxAmount);
        //         _mint(taxRecipient, taxAmount);
        //     }
        // }
    }
}
