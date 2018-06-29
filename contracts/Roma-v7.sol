//  убрано все, что связано с массивами[] и расчетом дивидендов.
//  дивиденды под вопросом.
//  убраны контракты адресов.
//  убран холд 
//  убраны ф-ии возврата токенов с адресов (стали безполезны)
//  добавлены стадии работы контракта
//  добавлен расчет бонусов - calcBonus()


pragma solidity ^0.4.23;


contract ERC20Basic {
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



contract DividendManager  {
    //Contract receive ether, calc and payd dividends

    using SafeMath for uint256;
    mapping(address => uint256) dividends;
    IGTToken private token;
    event Dividends(address indexed to, uint256 value);
    event Profit (address indexed from, uint256 value);
    
        constructor(address _token) public {
            token = IGTToken(_token);
        }

    
    function CalcDividends() internal pure returns (bool){
        //������ ���������� �� ���������� �������
        // ???????????????????????????
        return true;

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
        emit Profit(msg.sender, msg.value);
    } 

}


contract Crowdsale is Ownable {
  using SafeMath for uint; 
  address myAddress = this;
  uint256 public startICODate;
  IGTToken public token = new IGTToken(myAddress);
  
  event LogStateSwitch(State newState);

  enum State { 
        PreTune, 
        CrowdSale, 
        Refunding,
        Migrate }
  State choice;
  State public currentState = State.PreTune;

  
  // �������� �� �������� ������
  address public holdCommandAddress=myAddress;
  address public holdDevepolmentFundAddress=myAddress;
  address public bountyAddress=myAddress;
  address public marketingAddress=myAddress;

  DividendManager public myDivManager = new DividendManager(address(token));
  
  
    constructor() public {
        startICODate = now;
        // ������ PreTune - �������������. �� ��������� ������ � ����� ����� ���������
        // �������� ������� �� �������� �� ����-����� ������� (10%)
        giveTokens(address(holdCommandAddress), 2100000);
        // �������� ������� �� �������� �� ����-����� ����� �������� (15%)
        giveTokens(address(holdDevepolmentFundAddress), 3150000);
        // �������� ������� �� �������� �� ����� ������ (10%)
        giveTokens(address(bountyAddress), 2100000);
        // �������� ������� �� �������� �� ����� ��������� (5%)
        giveTokens(address(marketingAddress), 1050000);

        // ������ CrowdSale ��������
        nextState();    
    }

    function nextState() public onlyOwner{
        currentState = State(uint(currentState) + 1);
    }

    function showBalanceDividends() public view onlyOwner returns (uint256){
        return address(myDivManager).balance;
    }


    function calcBonus () public view returns(uint256) {
        // 2m - 12%
        // 4m - 8%
        // 6m - 6%
        // 8m - 4%
        // 10m - 2%
        // 12.6m - 0%
        uint256 amountToken = token.getSoldTokens();
        uint256 actualBonus = 0;
        uint256 mul = 1000000 * 1 ether;
        
        if (amountToken < 2*mul){ 
            actualBonus = 12;    
        }
        if (amountToken >= 2*mul && amountToken < 4*mul){
            actualBonus = 8;
        }
        if (amountToken >= 4*mul && amountToken < 6*mul){
            actualBonus = 6;
        }
        if (amountToken >= 6*mul && amountToken < 8*mul){
            actualBonus = 4;
        }
        if (amountToken >= 8*mul && amountToken < 10*mul){
            actualBonus = 2;
        }
        return actualBonus;
    }

    function giveTokens(address _newInvestor, uint256 _value) public onlyOwner {
        // the function give tokens to new investors
        // the sum is entered in whole tokens (1 = 1 token)
        require (_newInvestor!= address(0));
        require (_value >= 1);

        uint256 mySoldTokens = token.getSoldTokens();
        uint256 myBonus = calcBonus();

        _value = _value.mul(1 ether);

        // Add Bonus
        if (myBonus > 0){
        _value = _value + _value.mul(myBonus).div(100);            
        }
        

        // ����� �������������� ������� (�������, ���� ��������, �������� � �.�. �� ��������� ��� �������� ��������� �������
        if (currentState != State.PreTune){
            mySoldTokens = mySoldTokens.add(_value);
            token.setSoldTokens(mySoldTokens);
        }
        token.transfer(_newInvestor, _value);
        
    }  
    


    function() external payable {
        // The contract don`t receive ether
        revert();
    }    
 
}