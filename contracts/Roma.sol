pragma solidity ^0.4.23;

contract AddProps {
  mapping(address => bool   ) isInvestor;
  address[] public arrInvestors;

    function addInvestor(address _newInvestor) internal {
        if (!isInvestor[_newInvestor]){
            isInvestor[_newInvestor] = true;
            arrInvestors.push(_newInvestor);
        }
    }
    
    function getInvestorsCount() public view returns(uint256) {
        return arrInvestors.length;
    }   
    
    function getInvestorAddress(uint256 _arrNumber) public view returns(address) {
        return arrInvestors[_arrNumber];
    }
}


contract ERC20Basic is AddProps{
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}



library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}



contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    addInvestor(_to);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
  
  function transferWholeTokens(address _to, uint256 _value) public returns (bool) {
   // the sum is entered in whole tokens (1 = 1 token)
   _value = _value.mul(1 ether);
   return transfer(_to, _value);
  }



  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}


contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    addInvestor(_to);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


contract IGTToken is StandardToken {
  string public constant name = "IGT Token";
  string public constant symbol = "IGTT";
  uint32 public constant decimals = 18;
  uint256 public INITIAL_SUPPLY = 21000000 * 1 ether;
  address public CrowdsaleAddress;
  

  
  
  constructor(address _CrowdsaleAddress) public {
    
    CrowdsaleAddress = _CrowdsaleAddress;
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;      
  }
  
    modifier onlyOwner() {
    require(msg.sender == CrowdsaleAddress);
    _;
  }


    function acceptTokens(address _from, uint256 _value) public onlyOwner returns (bool){
        require (balances[_from]>= _value);
        balances[_from] = balances[_from].sub(_value);
        balances[CrowdsaleAddress] = balances[CrowdsaleAddress].add(_value);
        emit Transfer(_from, CrowdsaleAddress, _value);
        return true;
    }



  function() external payable {
      // The token contract don`t receive ether
        revert();
  }  
}


 contract Ownable {
  address public owner;
  address candidate;

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    candidate = newOwner;
  }

  function confirmOwnership() public {
    require(candidate == msg.sender);
    owner = candidate;
    delete candidate;
  }

}


contract HoldCommandAddress {
    //Address where stored command tokens
    //Withdraw tokens allowed only after three years
    function() external payable {
        // The contract don`t receive ether
        revert();
    } 
}

contract HoldDevepolmentFundAddress {
    //Address where stored Development Fund tokens
    //Withdraw tokens allowed only after three years
    function() external payable {
        // The contract don`t receive ether
        revert();
    } 
}

contract BountyAddress {
    //Address where stored bounty tokens
    function() external payable {
        // The contract don`t receive ether
        revert();
    } 
}

contract MarketingAddress {
    //Address where stored marketing tokens
    function() external payable {
        // The contract don`t receive ether
        revert();
    } 
}

contract DividendManager  {
    //Contract receive ether, calc and payd dividends

    using SafeMath for uint256;
    mapping(address => uint256) dividends;
    IGTToken private token;
    event Dividends(address indexed to, uint256 value);
    
        constructor(address _token) public {
            token = IGTToken(_token);
        }

    
    function CalcDividends(uint256 _profit) internal {
        //расчет дивидендов по полученной прибыли
        //минимальная сумма  = 10 эфиров
        require(_profit >= 10 ether);
        uint256 myMul = 10000000000;
        uint256 myBalance;
        address myAddress;
        uint256 k = _profit.mul(myMul).div(token.totalSupply());
        uint256 myDividend;
        
        for (uint i = 0; i < token.getInvestorsCount(); i++){
            myAddress = token.getInvestorAddress(i);
            myBalance = token.balanceOf(myAddress);
            myDividend = myBalance.mul(k).div(myMul);
            dividends[myAddress] = dividends[myAddress].add(myDividend);
        }

    }
    
    function showDividends() public view returns (uint256) {
        return dividends[msg.sender];
    }
    
    function withdrawDividends(uint256 _value) public payable {
        require (msg.sender != address(0));
        require (dividends[msg.sender] >= _value);
        dividends[msg.sender] = dividends[msg.sender].sub(_value);
        msg.sender.transfer(_value);
        emit Dividends(msg.sender, _value);
    }

    function() external payable {
        CalcDividends(msg.value);
    } 

}


contract Crowdsale is Ownable {
  using SafeMath for uint; 
  address myAddress = this;
  uint public  saleRate = 30;  //tokens for 1 ether
  uint public  purchaseRate = 30;  //tokens for 1 ether
  bool public purchaseTokens = false;

  event Mint(address indexed to, uint256 amount);
  event SaleRates(uint256 indexed value);
  event PurchaseRates(uint256 indexed value);
  event Withdraw(address indexed from, address indexed to, uint256 amount);

  modifier purchaseAlloved() {
      // The contract accept tokens
    require(purchaseTokens);
    _;
  }


  IGTToken public token = new IGTToken(myAddress);
  
  HoldCommandAddress public holdAddress1 = new HoldCommandAddress();

  HoldDevepolmentFundAddress public holdAddress2 = new HoldDevepolmentFundAddress();
  
  BountyAddress public myBountyAddress = new BountyAddress();
  
  MarketingAddress public myMarketingAddress = new MarketingAddress();

  DividendManager public myDivManager = new DividendManager(address(token));
  
  
    constructor() public {
        // передача токенов на хранение на холд-адрес команды (10%)
        giveTokens(address(holdAddress1), 2100000);
        // передача токенов на хранение на холд-адрес фонда развития (15%)
        giveTokens(address(holdAddress2), 3150000);
        // передача токенов на хранение на адрес баунти (10%)
        giveTokens(address(myBountyAddress), 2100000);
        // передача токенов на хранение на адрес маркетинг (5%)
        giveTokens(address(myMarketingAddress), 1050000);
    }



    function giveTokens(address _newInvestor, uint256 _value) public onlyOwner payable {
        // the function give tokens to new investors
        // the sum is entered in whole tokens (1 = 1 token)
        
        require (_newInvestor!= address(0));
        require (_value >= 1);
        _value = _value.mul(1 ether);
        token.transfer(_newInvestor, _value);
    }  
    
    function returnTokensFromHoldCommandAddress(uint256 _value) public onlyOwner {
        // the function take tokens from HoldCommandAddress to contract
        // only after 01.07.2021 = Unix TimeStamp 1625097600
        // the sum is entered in whole tokens (1 = 1 token)
        require (_value >= 1);
        _value = _value.mul(1 ether);
        
        require (now >= 1625097600);
        token.acceptTokens(address(holdAddress1), _value);    
    } 
    
    function returnTokensFromHoldDevelopmentFundAddress(uint256 _value) public onlyOwner {
        // the function take tokens from HoldDevepolmentFundAddress to contract
        // only after 01.07.2021 = Unix TimeStamp 1625097600
        // the sum is entered in whole tokens (1 = 1 token)
        require (_value >= 1);
        _value = _value.mul(1 ether);
        
        require (now >= 1625097600);
        token.acceptTokens(address(holdAddress2), _value);    
    }     
 
    function returnTokensFromBountyAddress(uint256 _value) public onlyOwner {
        // the function take tokens from BountyAddress to contract
        // the sum is entered in whole tokens (1 = 1 token)
        require (_value >= 1);
        _value = _value.mul(1 ether);

        token.acceptTokens(address(myBountyAddress), _value);    
    }     

    function returnTokensFromMarketingAddress(uint256 _value) public onlyOwner {
        // the function take tokens from BountyAddress to contract
        // the sum is entered in whole tokens (1 = 1 token)
        require (_value >= 1);
        _value = _value.mul(1 ether);

        token.acceptTokens(address(myMarketingAddress), _value);    
    }     


  
  function WithdrawProfit (address _to, uint256 _value) public onlyOwner payable {
    // здесь будет функция вывода средств
    require (myAddress.balance >= _value);
    require(_to != address(0));
    _to.transfer(_value);
    emit Withdraw(msg.sender, _to, _value);
  }
 
    function saleTokens() internal {
        require (msg.value >= 1 ether);  //minimum 1 ether
        uint tokens = saleRate.mul(msg.value);
        token.transfer(msg.sender, tokens);
    }
 
    function() external payable {
        saleTokens();
    }    
 
}