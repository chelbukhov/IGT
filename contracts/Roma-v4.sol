// добавлена функция подсчета проданных токенов.
// учитываются все токены, и зарезервированные тоже

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


  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }


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
  uint256 public soldTokens;
    
    function getSoldTokens() public view returns (uint256) {
        return soldTokens;
    }


  
  
  constructor(address _CrowdsaleAddress) public {
    
    CrowdsaleAddress = _CrowdsaleAddress;
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;      
  }
  
    modifier onlyOwner() {
    require(msg.sender == CrowdsaleAddress);
    _;
  }

    function setSoldTokens(uint256 _value) public onlyOwner {
        soldTokens = _value;
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
        uint256 k = _profit.mul(myMul).div(token.getSoldTokens());
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



    function giveTokens(address _newInvestor, uint256 _value) public onlyOwner {
        // the function give tokens to new investors
        // the sum is entered in whole tokens (1 = 1 token)
        uint256 mySoldTokens = token.getSoldTokens();
        require (_newInvestor!= address(0));
        require (_value >= 1);
        _value = _value.mul(1 ether);
        mySoldTokens = mySoldTokens.add(_value);
        token.setSoldTokens(mySoldTokens);
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


    function() external payable {
        // The contract don`t receive ether
        revert();
    }    
 
}

