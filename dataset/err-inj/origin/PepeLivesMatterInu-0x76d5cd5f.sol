/**
 * @title PepeLivesMatterInu (LGBT) Token
 * @dev A token contract dedicated to raising awareness and supporting the conservation of Pepe lives.
 * The token name "PepeLivesMatterInu (LGBT)" signifies the importance of every Pepe's existence.
 * The emission of 337,550,940 tokens symbolizes the current population of the United States.
 * Purchasing the token contributes 1% to the Pepe support fund, while selling burns 2% of the Pepe population.
 * Let's unite to protect these endangered creatures by acquiring Pepe tokens and refraining from selling them recklessly.
 * May Pepe be forever preserved in our hearts. 🐸❤️
 * Telegram: t.me/pepelives
 */

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Apache-2.0

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint256);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Context {
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// PepeLivesMatterInu Token Contract - Pepe's journey to spread love and awareness
contract PepeLivesMatterInu is Context, IERC20, Ownable {
    using SafeMath for uint256;

    // Reflection and ownership mappings
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    // Exclusion mappings
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    // Constants and trackers
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    // Token information
    string private _name;
    string private _symbol;
    uint256 private _decimals;

    // Addresses for Pepe's journey
    address public FundPepeAddress;
    address public pairAddress;

    // Fee configuration
    uint256 public _taxFee;
    uint256 private _previousTaxFee;
    uint256 public _PepeFundFee;
    uint256 private _previousPepeFundFee;
    uint256 public _PepeBurnFee;
    uint256 private _previousPepeBurnFee;

    // Max holding and transaction amounts
    uint256 public _maxHoldPercent;
    uint256 public _maxTxAmount;

    // Address of Pepe in the afterlife
    address public constant PepeRIP = 0x000000000000000000000000000000000000dEaD;
   
    constructor () public {
        _name = "PepeLivesMatterInu";
        _symbol = "LGBT";
        _decimals = 18;
        _tTotal = 337550940 * 10 ** _decimals;
        _rTotal = (MAX - (MAX % _tTotal));

        _taxFee = 0;
        _PepeFundFee = 1;
        _PepeBurnFee = 2;
        _previousTaxFee = _taxFee;
        _previousPepeFundFee = _PepeFundFee;
        _previousPepeBurnFee = _PepeBurnFee;
        _maxTxAmount = 337550940 * 10 ** _decimals;
        _maxHoldPercent = 100;
        FundPepeAddress = owner();
       
        _rOwned[owner()] = _rTotal;
       
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), owner(), _tTotal);
    }

    // The PepeLivesMatterInu Token - Spreading love, awareness, and unity
    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function decimals() external view override returns (uint256) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    // Pepe's guardian
    function getOwner() external view override returns (address) {
        return owner();
    }

    // Checking balance in Pepe's heart
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    // Pepe's caring touch in a transfer
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    // Pepe's approval for spreading love
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    // Pepe's guidance for secure transferring
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    // Pepe's helping hand in increasing allowances
    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    // Pepe's caring embrace in decreasing allowances
    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    // Pepe's wisdom in determining reward exclusion
    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcluded[account];
    }

    // Counting the love Pepe has shared
    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }

    // Pepe's magical conversion of love to reflection
    function deliver(uint256 tAmount) external {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    // Pepe's prediction of reflection from love
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) external view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    // Pepe's revelation: token from reflection
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    // Pepe's decision to exclude from reward
    function excludeFromReward(address account) external onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    // Pepe's embrace in including in reward
    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    // Pepe's directions to a new journey with pairs
    function setPairAddress(address account) external onlyOwner {
        pairAddress = account;
    }

    // Pepe's guidance in finding a new FundPepe
    function setFundPepe(address account) external onlyOwner {
        FundPepeAddress = account;
    }

    // Pepe's secretive manipulation of fee exclusion
    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    // Pepe's grand revelation: include in fee
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    // Pepe's power to limit transactions
    function setMaxTxAmount(uint256 maxTxAmount) public onlyOwner {
        _maxTxAmount = maxTxAmount  * 10 ** _decimals;
    }

    // Pepe's reflection of fee
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    // Pepe's magic in getting values
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tEcoSystemFund, uint256 tBurn) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tEcoSystemFund, tBurn, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tEcoSystemFund, tBurn);
    }

    // Pepe's empathy in getting token values
    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tecosystem = calculateFundPepe(tAmount);
        uint256 tBurn = calculateBurnPepe(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tecosystem).sub(tBurn);
        return (tTransferAmount, tFee, tecosystem, tBurn);
    }

    // Pepe's vision in getting reflection values
    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tEcoSystem, uint256 tBurn, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rEcoSystem = tEcoSystem.mul(currentRate);
        uint256 rBurn = tBurn.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rEcoSystem).sub(rBurn);
        return (rAmount, rTransferAmount, rFee);
    }

    // Pepe's knowledge in getting the rate
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    // Pepe's sight in getting the current supply
    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    // Pepe's funding to preserve his legacy
    function _FundPepe(address sender, uint256 tFundPepe) private {
        uint256 currentRate =  _getRate();
        uint256 rFundPepe = tFundPepe.mul(currentRate);
        _rOwned[FundPepeAddress] = _rOwned[FundPepeAddress].add(rFundPepe);
        if(_isExcluded[FundPepeAddress])
            _tOwned[FundPepeAddress] = _tOwned[FundPepeAddress].add(tFundPepe);
        emit Transfer(sender, FundPepeAddress, tFundPepe);
    }

    // Pepe's farewell to those who left him
    function _BurnPepe(uint256 tBurnPepe) private {
        uint256 currentRate =  _getRate();
        uint256 rBurnPepe = tBurnPepe.mul(currentRate);
        _rOwned[PepeRIP] = _rOwned[PepeRIP].add(rBurnPepe);
        if (_isExcluded[PepeRIP])
            _tOwned[PepeRIP] = _tOwned[PepeRIP].add(tBurnPepe);

        emit Transfer(_msgSender(), PepeRIP, tBurnPepe);
    }

    // Pepe's magic in calculating tax fee
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10**2
        );
    }

    // Pepe's vision in calculating ecosystem fund
    function calculateFundPepe(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_PepeFundFee).div(
            10**2
        );
    }

    // Pepe's fire in calculating burn fee
    function calculateBurnPepe(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_PepeBurnFee).div(
            10**2
        );
    }

     // Pepe's discretion in removing all fee
    function removeAllFee() private {
        if(_taxFee == 0 && _PepeFundFee == 0 && _PepeBurnFee == 0) return;
       
        _previousTaxFee = _taxFee;
        _previousPepeFundFee = _PepeFundFee;
        _previousPepeBurnFee = _PepeBurnFee;
       
        _taxFee = 0;
        _PepeFundFee = 0;
        _PepeBurnFee = 0;
    }

    // Pepe's wisdom in restoring all fee
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _PepeFundFee = _previousPepeFundFee;
        _PepeBurnFee = _previousPepeBurnFee;
    }

    // Pepe's insight in fee exclusion
    function isExcludedFromFee(address account) external view returns(bool) {
        return _isExcludedFromFee[account];
    }

    // Pepe's approval for allowance
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // Pepe's power in transferring tokens
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(from != owner() && to != owner())
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

        bool takeFee = true;
       
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
       
        _tokenTransfer(from, to, amount, takeFee);

        require(to == owner() || to == pairAddress || balanceOf(to) < (_tTotal * _maxHoldPercent / 100), "Max holding exceeded");
    }

    // Pepe's token transfer function
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        removeAllFee();
        if(takeFee) {
            if (recipient == pairAddress) { 
                _PepeBurnFee = _previousPepeBurnFee;       
            } else if (sender == pairAddress) {
                _PepeFundFee = _previousPepeFundFee;
            }
        }
       
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
       
        restoreAllFee();
    }

    // Pepe's love-filled standard transfer
    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tFundPepe, uint256 tBurnPepe) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _FundPepe(sender, tFundPepe);
        _BurnPepe(tBurnPepe);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    // Pepe's warm transfer to an excluded address
    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tFundPepe, uint256 tBurnPepe) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);          
        _FundPepe(sender, tFundPepe);
        _BurnPepe(tBurnPepe);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    // Pepe's heartfelt transfer from an excluded address
    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tFundPepe, uint256 tBurnPepe) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);  
        _FundPepe(sender, tFundPepe);
        _BurnPepe(tBurnPepe);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    // Pepe's dual transfer for both excluded addresses
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tFundPepe, uint256 tBurnPepe) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _FundPepe(sender, tFundPepe);
        _BurnPepe(tBurnPepe);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
}