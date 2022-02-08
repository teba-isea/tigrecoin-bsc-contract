pragma solidity ^0.5.16;

interface IBEP20 {
	// Returns the amount of tokens in existence
	function totalSupply() external view returns (uint);

	// Returns the token decimals
	function decimals() external view returns (uint);

	// Returns the token symbol
	function symbol() external view returns (string memory);

	// Returns the token name
	function name() external view returns (string memory);

	// Returns the token owner
	function getOwner() external view returns (address);

	// Returns the amount of tokens owned by `account`
	function balanceOf(address account) external view returns (uint);

	// Moves `amount` tokens from the caller's account to `recipient`
	function transfer(address recipient, uint amount) external returns (bool);

	/**
	 * Returns the remaining number of tokens that `spender` will be
	 * allowed to spend on behalf of `owner` through {transferFrom}. This is
	 * zero by default.
	 *
	 * This value changes when {approve} or {transferFrom} are called.
	 */
	function allowance(address _owner, address spender) external view returns (uint);

	/// Sets `amount` as the allowance of `spender` over the caller's tokens
	function approve(address spender, uint amount) external returns (bool);

	// Moves `amount` tokens from `sender` to `recipient` using the allowance mechanism
	function transferFrom(address sender, address recipient, uint amount) external returns (bool);

	/* EVENTS */

	// Emitted when `value` tokens are moved from one account (`from`) to another (`to`)
	event Transfer(address indexed from, address indexed to, uint value);

	// Emitted when the allowance of a `spender` for an `owner` is set by
	// a call to {approve}. `value` is the new allowance
	event Approval(address indexed owner, address indexed spender, uint value);
}

// Wrappers over Solidity's arithmetic operations with added overflow checks
library SafeMath {

	// Returns the addition of two unsigned integers, reverting on overflow
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");

		return c;
	}

	// Returns the subtraction of two unsigned integers, reverting on
	// overflow (when the result is negative)
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}
	
	// Returns the subtraction of two unsigned integers, reverting with custom message on
	// overflow (when the result is negative)
	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b <= a, errorMessage);
		uint256 c = a - b;

		return c;
	}

	// Returns the multiplication of two unsigned integers, reverting on
	// overflow.
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b, "SafeMath: multiplication overflow");

		return c;
	}

	// Returns the integer division of two unsigned integers. Reverts on
	// division by zero. The result is rounded towards zero
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return div(a, b, "SafeMath: division by zero");
	}

	// Returns the integer division of two unsigned integers. Reverts with custom message on
	// division by zero. The result is rounded towards zero
	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b > 0, errorMessage);
		uint256 c = a / b;

		return c;
	}
}

// Provides information about the current execution context
contract Context {
	uint public _totalSupply;

	// Empty internal constructor, to prevent people from mistakenly deploying
	// an instance of this contract, which should be used via inheritance
	constructor () internal { }

	function _msgSender() internal view returns (address payable) {
		return msg.sender;
	}

	function _msgData() internal view returns (bytes memory) {
		this;
		return msg.data;
	}
}

// Provides a basic access control mechanism, where there is an
// owner that can be granted exclusive access to specific functions
contract Ownable is Context {
	address public _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	// Initializes the contract setting the deployer as the initial owner
	constructor () internal {
		address msgSender = _msgSender();
		_owner = msgSender;
		emit OwnershipTransferred(address(0), msgSender);
	}

	// Returns the address of the current owner
	function owner() public view returns (address) {
		return _owner;
	}

	// Throws if called by any account other than the owner
	modifier onlyOwner() {
		require(_owner == _msgSender(), "Ownable: caller is not the owner");
		_;
	}

	// Transfers ownership of the contract to a new account (`newOwner`)
	// Can only be called by the current owner
	function transferOwnership(address newOwner) public onlyOwner {
		_transferOwnership(newOwner);
	}
	
	// Transfers ownership of the contract to a new account (`newOwner`)
	function _transferOwnership(address newOwner) internal {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}

contract BasicToken is Ownable {
	using SafeMath for uint;
	
	// Get the balances
	mapping (address => mapping (address => uint)) public _allowances;
	mapping (address => uint) public _balances;

	// See {BEP20-transfer}
	// `recipient` cannot be the zero address
	// the caller must have a balance of at least `amount`
	function transfer(address recipient, uint amount) external whenNotPaused returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	// Creates `amount` tokens and assigns them to `msg.sender`, increasing the total supply
	// `msg.sender` must be the token owner
	function mint(uint amount) public onlyOwner returns (bool) {
		_mint(_msgSender(), amount);
		return true;
	}

	// Destroy `amount` tokens from `msg.sender`, reducing
	// `msg.sender` must be the token owner
	function burn(uint amount) public onlyOwner returns (bool) {
		_burn(_msgSender(), amount);
		return true;
	}
}

// Locks or unlocks funds from an account
// Being on the blacklist does not allow transactions
contract BlackList is BasicToken {
	
	event AddedBlackList(address _user);
	event RemovedBlackList(address _user);
	event DestroyedBlackFunds(address _user, uint value);

	// Getters to allow the same blacklist to be used also by other contracts
	function getBlackListStatus(address _maker) external view returns (bool) {
		return isBlackListed[_maker];
	}

	// Returns the token owner
	function getOwner() external view returns (address) {
		return owner();
	}

	mapping (address => bool) public isBlackListed;
	
	// Adds an account to the blacklist
	function addBlackList (address _evilUser) public onlyOwner {
		isBlackListed[_evilUser] = true;
		emit AddedBlackList(_evilUser);
	}

	// Removes an account from the blacklist
	function removeBlackList (address _clearedUser) public onlyOwner {
		isBlackListed[_clearedUser] = false;
		emit RemovedBlackList(_clearedUser);
	}

	// Destroy funds of an account blacklisted
	// Update the Total Supply
	function destroyBlackFunds (address _blackListedUser) public onlyOwner {
		require(isBlackListed[_blackListedUser], "BlackList: account isn't blacklisted");

		uint dirtyFunds = _balances[_blackListedUser];
		_balances[_blackListedUser] = 0;
		_totalSupply = _totalSupply.sub(dirtyFunds);
		emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);
	}
}

// Being on the whitelist allows transactions without fees
contract WhiteList is BasicToken {

	event AddedWhiteList(address _user);
	event RemovedWhiteList(address _user);

	// Getters to allow the same Whitelist to be used also by other contracts
	function getWhiteListStatus(address _maker) external view returns (bool) {
		return isWhiteListed[_maker];
	}

	// Returns the token owner
	function getOwner() external view returns (address) {
		return owner();
	}

	mapping (address => bool) public isWhiteListed;

	// Adds an account to the whitelist
	function addWhiteList (address _user) public onlyOwner {
		isWhiteListed[_user] = true;
		emit AddedWhiteList(_user);
	}

	// Removes an account from the whitelist
	function removeWhiteList (address _user) public onlyOwner {
		isWhiteListed[_user] = false;
		emit RemovedWhiteList(_user);
	}
}

// Allows to implement an emergency stop mechanism
contract Pausable is Ownable {
	event Pause();
	event Unpause();

	bool public paused = false;

	// Modifier to make a function callable only when the contract is not paused
	modifier whenNotPaused() {
		require(!paused, "Pausable: contract is paused");
		_;
	}

	// Modifier to make a function callable only when the contract is paused
	modifier whenPaused() {
		require(paused, "Pausable: contract isn't paused");
		_;
	}

	// Called by the owner to pause, triggers stopped state
	function pause() onlyOwner whenNotPaused public {
		paused = true;
		emit Pause();
	}

	// Called by the owner to unpause, returns to normal state
	function unpause() onlyOwner whenPaused public {
		paused = false;
		emit Unpause();
	}
}

contract TIGRE is BasicToken, BlackList, WhiteList, Pausable {

	string public _name;
	string public _symbol;
	uint public _decimals;

	constructor (
		string memory tokenName,
		string memory tokenSymbol,
		uint initialSupply,
		uint decimalUnits

	) public {

		_name = tokenName;
		_symbol = tokenSymbol;
		_decimals = decimalUnits;
		_totalSupply = initialSupply * (10 ** _decimals);
		_maxSupply = 100000000 * (10 ** _decimals);
		_balances[msg.sender] = _totalSupply;

		emit Transfer(address(0), msg.sender, _totalSupply);
	}

	// Returns the token decimals
	function decimals() external view returns (uint) {
		return _decimals;
	}

	// Returns the token symbol
	function symbol() external view returns (string memory) {
		return _symbol;
	}

	// Returns the token name
	function name() external view returns (string memory) {
		return _name;
	}

	// See {BEP20-totalSupply}
	function totalSupply() external view returns (uint) {
		return _totalSupply;
	}

	
	// See {BEP20-balanceOf}
	function balanceOf(address account) external view returns (uint) {
		return _balances[account];
	}

	// See {BEP20-allowance}
	function allowance(address owner, address spender) external view returns (uint) {
		return _allowances[owner][spender];
	}
	
	// See {BEP20-approve}
	// `spender` cannot be the zero address
	function approve(address spender, uint amount) external returns (bool) {
		_approve(_msgSender(), spender, amount);
		
		return true;
	}
	
	// See {BEP20-transferFrom}
	// `sender` and `recipient` cannot be the zero address
	// `sender` must have a balance of at least `amount`
	// the caller must have allowance for `sender`'s tokens of at least `amount`
	function transferFrom(address sender, address recipient, uint amount) external returns (bool) {
		require(!isBlackListed[sender], "TIGRE: account is blacklisted");
		
		_transfer(sender, recipient, amount);
		
		_approve(
			sender,
			_msgSender(),
			_allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance")
			);
			
			return true;
	}

	// Atomically increases the allowance granted to `spender` by the caller
	// `spender` cannot be the zero address
	function increaseAllowance(address spender, uint addedValue) public returns (bool) {
		_approve(
			_msgSender(),
			spender,
			_allowances[_msgSender()][spender].add(addedValue)
			);
			
			return true;
	}

	// Automatically decreases the allowance granted to `spender` by the caller
	// `spender` cannot be the zero address
	// `spender` must have allowance for the caller of at least `subtractedValue`
	function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
		_approve(
			_msgSender(),
			spender,
			_allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero")
			);
			
			return true;
	}

	// Sets `amount` as the allowance of `spender` over the `owner`s tokens
	// `owner` cannot be the zero address.
	// `spender` cannot be the zero address.
	function _approve(address owner, address spender, uint amount) internal {
		require(owner != address(0), "TIGRE: approve from the zero address");
		require(spender != address(0), "TIGRE: approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	// additional variables for use if transaction fees ever became necessary
	uint public transferFee = 0;

	// Moves tokens `amount` from `sender` to `recipient`
	function _transfer(address sender, address recipient, uint amount) internal {
		require(sender != recipient, "TIGRE: sender and recipient can't be the same address");
		require(sender != address(0), "TIGRE: transfer from the zero address");
		require(recipient != address(0), "TIGRE: transfer to the zero address");
		require(!isBlackListed[msg.sender], "TIGRE: account is blacklisted");

		if (amount < _totalSupply.div(200) || isWhiteListed(sender) || transferFee == 0) {
			_balances[sender] = _balances[sender].sub(amount);
			_balances[recipient] = _balances[recipient].add(amount);
		} else {
			uint toOwner = (amount.mul(transferFee)).div(100);
			uint sendAmount = amount.sub(transferFee);

			_balances[sender] = _balances[sender].sub(amount);
			_balances[recipient] = _balances[recipient].add(sendAmount);

			_balances[_owner] = _balances[_owner].add(toOwner);
			emit Transfer(sender, _owner, toOwner);
		}

		emit Transfer(sender, recipient, amount);
	}

	// Creates `amount` tokens and assigns them to `account`, increasing
	// `to` cannot be the zero address
	function _mint(address account, uint amount) internal {
		require(account != address(0), "TIGRE: mint to the zero address");
		require(_totalSupply.add(amount) <= _maxSupply, "TIGRE: max supply can't be surpassed");
		
		_totalSupply = _totalSupply.add(amount);
		_balances[account] = _balances[account].add(amount);
		emit Transfer(address(0), account, amount);
	}

	// Destroys `amount` tokens from `account`, reducing the total supply
	// `account` cannot be the zero address
	// `account` must have at least `amount` tokens
	function _burn(address account, uint amount) internal {
		require(account != address(0), "TIGRE: burn from the zero address");
	
		_balances[account] = _balances[account].sub(amount, "TIGRE: burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(amount);
		emit Transfer(account, address(0), amount);
	}

	// Only owner sets the fee value
	function setParams(uint _transferFee) public onlyOwner returns (bool) {
		_setParams(_transferFee);

		return true;
	}

	function _setParams(uint _transferFee) internal {
		require(_transferFee <= 20);

		transferFee = _transferFee;
	}

	function showTransferFee() external view returns (uint) {
		return transferFee;
	}
}