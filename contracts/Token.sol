// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, ERC20Burnable, Ownable {
    bool private _mintable;
    bool private _burnable;
    uint8 private _decimals;
    uint256 private _maxTokensPerWallet = type(uint256).max;
    uint256 private _maxSupply = type(uint256).max;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address initialOwner_,
        uint256 initialSupply_,
        uint256 maxSupply_,
        bool mintable_,
        bool burnable_,
        uint256 maxTokensPerWallet_
    ) ERC20(name_, symbol_) Ownable(initialOwner_) {
        _decimals = decimals_;
        _mintable = mintable_;
        _burnable = burnable_;
        _maxTokensPerWallet = maxTokensPerWallet_;

        if (maxSupply_ != 0) _maxSupply = maxSupply_;
        if (maxSupply_ != 0) _maxTokensPerWallet = maxTokensPerWallet_;

        _mint(msg.sender, initialSupply_ * 10 ** decimals());
    }

    modifier maxTokensPerWalletCheck(address to, uint256 value) {
        if (to != address(0)) {
            require(
                balanceOf(to) + value <= _maxTokensPerWallet,
                "Exceeds max tokens per wallet"
            );
        }
        _;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    function maxTokensPerWallet() public view returns (uint256) {
        return _maxTokensPerWallet;
    }

    function mintable() public view returns (bool) {
        return _mintable;
    }

    function burnable() public view returns (bool) {
        return _burnable;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(_mintable, "Token does not allow minting");
        require(totalSupply() + amount < maxSupply(), "Max Supply Reached");
        _mint(to, amount);
    }

    function burn(uint256 value) public override {
        require(_burnable, "Token does not allow burning");
        _burn(_msgSender(), value);
    }

    function transfer(
        address to,
        uint256 value
    ) public override maxTokensPerWalletCheck(to, value) returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override maxTokensPerWalletCheck(to, value) returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }
}
