// SPDX-License-Identifier: MIT
pragma solidty ^0.8.20;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner,address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external  returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns(bool);
}

interface IERC20Metadata {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns(uint8);
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
    string private _decimals;
    uint256 private _totalSupply;
    mapping(address account=>uint256) private balances;
    mapping(address account=> mapping(address spender=> uint256)) private _allowance;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        _name = _name;
        _symbol = _symbol;
        _decimals = _decimals;
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
        return balances[account];
    }

    function transfer(address from, address to, uint256 value) external virtual returns (bool) {
        address sender = msg.sender;
        _deductAllowance(spender, from, value);
        _deductToken(from, value);
        _addToken(to, value);

        emit Transfer(from, to, value);
        return true;
    }


    function allowance(address owner, address spender) external virtual view returns (uint256) {
        return _allowance[owner][spender];
    }

    function approve(address spender, uint256 value) external virtual returns(bool) {
        address _personApproving = msg.sender;
        _addAllowance(spender, _personApproving, value);

        emit Approval(_personApproving, spender, value);
        return true;
    }


    function _addAllowance(address from, address approver, uint256 value) internal invalidApprover(approver) invalidSpender(from) {
        unchecked {
            _allowance[approver][from] +=value;
        }
    }

}

