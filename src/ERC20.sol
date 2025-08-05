// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface IERC20Metadata {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface IERC20Errors {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
}

contract ERC20 is IERC20, IERC20Metadata, IERC20Errors {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    modifier invalidSender(address sender) {
        if (sender == address(0)) {
            revert ERC20InvalidSender(sender);
        }
        _;
    }

    modifier invalidReceiver(address receiver) {
        if (receiver == address(0)) {
            revert ERC20InvalidReceiver(receiver);
        }
        _;
    }

    modifier invalidApprover(address approver) {
        if (approver == address(0)) {
            revert ERC20InvalidApprover(approver);
        }
        _;
    }

    modifier invalidSpender(address spender) {
        if (spender == address(0)) {
            revert ERC20InvalidSpender(spender);
        }
        _;
    }

    modifier checkBalanceBeforeDeduction(address account, uint256 amount) {
        if (_balances[account] < amount) {
            revert ERC20InsufficientBalance(account, _balances[account], amount);
        }
        _;
    }

    modifier checkAllowance(address owner, address spender, uint256 amount) {
        if (_allowances[owner][spender] < amount) {
            revert ERC20InsufficientAllowance(spender, _allowances[owner][spender], amount);
        }
        _;
    }

    function name() external virtual view returns (string memory) {
        return _name;
    }

    function symbol() external virtual view returns (string memory) {
        return _symbol;
    }

    function decimals() external virtual view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external virtual view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) external virtual returns (bool) {
        address sender = msg.sender;
        _deductToken(sender, value);
        _addToken(to, value);
        emit Transfer(sender, to, value);
        return true;
    }

    function allowance(address owner, address spender) external virtual view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) external virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external virtual returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, value);
        _deductToken(from, value);
        _addToken(to, value);
        emit Transfer(from, to, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = _allowances[owner][spender];
        if (currentAllowance < subtractedValue) {
            revert ERC20InsufficientAllowance(spender, currentAllowance, subtractedValue);
        }
        _approve(owner, spender, currentAllowance - subtractedValue);
        return true;
    }

    function _approve(address owner, address spender, uint256 value) internal virtual invalidApprover(owner) invalidSpender(spender) {
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _spendAllowance(address owner, address spender, uint256 value) internal virtual checkAllowance(owner, spender, value) {
        _allowances[owner][spender] -= value;
    }

    function _deductToken(address from, uint256 amount) internal virtual invalidSender(from) checkBalanceBeforeDeduction(from, amount) {
        _balances[from] -= amount;
    }

    function _addToken(address to, uint256 amount) internal virtual invalidReceiver(to) {
        _balances[to] += amount;
    }

    function _mint(address to, uint256 amount) internal virtual invalidReceiver(to) {
        _totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual invalidSender(from) checkBalanceBeforeDeduction(from, amount) {
        _balances[from] -= amount;
        _totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }
}