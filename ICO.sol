pragma solidity ^0.4.18;
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */

 /**
  * @title SafeMath
  * @dev Math operations with safety checks that throw on error
  */
 library SafeMath {
   function mul(uint256 a, uint256 b) internal pure returns (uint256) {
     if (a == 0) {
       return 0;
     }
     uint256 c = a * b;
     assert(c / a == b);
     return c;
   }

   function div(uint256 a, uint256 b) internal pure returns (uint256) {
     // assert(b > 0); // Solidity automatically throws when dividing by 0
     uint256 c = a / b;
     // assert(a == b * c + a % b); // There is no case in which this doesn't hold
     return c;
   }

   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
     assert(b <= a);
     return a - b;
   }

   function add(uint256 a, uint256 b) internal pure returns (uint256) {
     uint256 c = a + b;
     assert(c >= a);
     return c;
   }
 }

 library SafeERC20 {
   function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
     assert(token.transfer(to, value));
   }

   function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
     assert(token.transferFrom(from, to, value));
   }

   function safeApprove(ERC20 token, address spender, uint256 value) internal {
     assert(token.approve(spender, value));
   }
 }

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) public balances;

  mapping(address => address) internal addresses;
  address[] internal addressArray;

  function getAddressCount() constant public returns (uint256 length) {
    return addressArray.length;
  }

  function getAddressById(uint256 id) constant public returns (address length) {
    return addressArray[id];
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    //our code
    if (addresses[_to] != _to) {
      addresses[_to] = _to;
      addressArray.push(_to);
    }
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    // our code
    if (addresses[_to] != _to) {
      addresses[_to] = _to;
      addressArray.push(_to);
    }

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
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
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
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  using SafeERC20 for ERC20;
  /*string public constant name = "TestGinexToken";
  string public constant symbol = "TGT";
  uint8 public constant decimals = 18;*/
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    // our code
    if (addresses[_to] != _to) {
      addresses[_to] = _to;
      addressArray.push(_to);
    }
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  MintableToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;

  // адрес контракта
  address public contractAddress;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  // tokens for team, advicers etc.
  uint256 public rewardRate;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _rewardRate, address _wallet, address _contractAddress) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_rewardRate > 0);
    require(_wallet != address(0));

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    rewardRate = _rewardRate;
    wallet = _wallet;
    contractAddress = _contractAddress;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }


  // fallback function can be used to buy tokens
  function () external payable {
    if (now >= endTime) {
      /*address contractAddress = this;*/
     contractAddress.transfer(msg.value);
    } else {
        buyTokens(msg.sender);
    }
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);
    // tokens for team, advicers etc.
    uint256 tokensReward = weiAmount.mul(rewardRate);
    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    token.mint(wallet, tokensReward);
    uint256 tokensTotal = tokens.add(tokensReward);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokensTotal);

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }


}

contract SplitPayment {
  using SafeMath for uint256;

  uint256 public totalShares = 0;
  uint256 public totalReleased = 0;

  mapping(address => uint256) public shares;
  mapping(address => uint256) public released;
  address[] public payees;

  /**
   * @dev Constructor
   */
  function SplitPayment(address[] _payees, uint256[] _shares) public payable {
    require(_payees.length == _shares.length);

    for (uint256 i = 0; i < _payees.length; i++) {
      addPayee(_payees[i], _shares[i]);
    }
  }

  /**
   * @dev Add a new payee to the contract.
   * @param _payee The address of the payee to add.
   * @param _shares The number of shares owned by the payee.
   */
  function addPayee(address _payee, uint256 _shares) internal {
    require(_payee != address(0));
    require(_shares > 0);
    require(shares[_payee] == 0);

    payees.push(_payee);
    shares[_payee] = _shares;
    totalShares = totalShares.add(_shares);
  }

  /**
   * @dev Claim your share of the balance.
   */
  function claim(address payee, address ginexIcoContract) public returns (uint256 paymentDiv) {
    /*address payee = msg.sender;*/

    require(shares[payee] > 0);

    uint256 totalReceived = ginexIcoContract.balance.add(totalReleased);
    /*uint256 totalReceived = 1;*/
    uint256 payment = totalReceived.mul(shares[payee]).div(totalShares).sub(released[payee]);

    require(payment != 0);
    require(ginexIcoContract.balance >= payment);

    released[payee] = released[payee].add(payment);
    totalReleased = totalReleased.add(payment);

    return payment;
    /*payee.transfer(payment);*/
  }

  /**
   * @dev payable fallback
   */
  function () external payable {}
}

contract GinexToken is MintableToken {
  string public constant name = "Ginex Test token";
  string public constant symbol = "GTT";
  uint256 public constant decimals = 18;
  uint256 public constant _totalSupply = 0;
  /*uint256 public constant _totalSupply = 400000000 * 1 ether;*/

/** Constructor KalikoeToken */
  function GinexToken() public {
    totalSupply = _totalSupply;
  }
}

contract GinexICO is Crowdsale, Ownable{
  uint256 _startTime = now;
  uint256 _endTime = now + 1 minutes;
  uint256 _rate = 3000;
  uint256 _rewardRate = 1000;
  address _wallet = 0x9CBf6af0Eb27386Be92a45f357c1673826534328;

  address[] _payees;
  uint256[] _shares;

  SplitPayment public splitPayment;



  function GinexICO() public
  Crowdsale(_startTime, _endTime, _rate, _rewardRate, _wallet, this)
  {
  }

function createTokenContract() internal returns (MintableToken) {
  return new GinexToken();
}

function getBalance() view public returns (uint256) {
  return this.balance;
}

function createSplitPayment() public payable onlyOwner {
    require(now > _endTime);

    uint256 addrCount = token.getAddressCount();
    if (_payees.length < addrCount) {
        for (uint256 j = _payees.length; j < addrCount; j++) {
        _payees.push(address(0));
        _shares.push(0);
        }
    }

     for (uint256 i = 0; i < addrCount; i++) {
       if (token.balanceOf(token.getAddressById(i)) > 0) {
         //payees.push(token.getAddressById(i));
         //_shares.push(token.balanceOf(token.getAddressById(i)));
         _payees[i] = token.getAddressById(i);
         _shares[i] = token.balanceOf(token.getAddressById(i));
       }
       else {
         _payees[i] = token.getAddressById(i);
         _shares[i] = 0;
       }

    }
    splitPayment = new SplitPayment(_payees, _shares);
  }

  function getDividend() public payable {
    require(now > _endTime);
    uint256 payment = splitPayment.claim(msg.sender, this);
    msg.sender.transfer(payment);
  }

}
