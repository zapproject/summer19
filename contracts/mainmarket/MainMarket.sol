pragma solidity ^0.5.8;

import "../platform/registry/RegistryInterface.sol";
import "../platform/bondage/BondageInterface.sol";
import "../lib/ownership/ZapCoordinatorInterface.sol";
import "../token/ZapToken.sol";
import "./MainMarketTokenInterface.sol";


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
// library SafeMath {

//     /**
//     * @dev Multiplies two numbers, throws on overflow.
//     */
//     function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
//         // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
//         // benefit is lost if 'b' is also tested.
//         // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
//         if (a == 0) {
//             return 0;
//         }

//         c = a * b;
//         assert(c / a == b);
//         return c;
//     }

//     /**
//     * @dev Integer division of two numbers, truncating the quotient.
//     */
//     function div(uint256 a, uint256 b) internal pure returns (uint256) {
//         // assert(b > 0); // Solidity automatically throws when dividing by 0
//         // uint256 c = a / b;
//         // assert(a == b * c + a % b); // There is no case in which this doesn't hold
//         return a / b;
//     }

//     /**
//     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
//     */
//     function sub(uint256 a, uint256 b) internal pure returns (uint256) {
//         assert(b <= a);
//         return a - b;
//     }

//     /**
//     * @dev Adds two numbers, throws on overflow.
//     */
//     function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
//         c = a + b;
//         assert(c >= a);
//         return c;
//     }
// }

contract MainMarket {
    using SafeMath for uint256;

    //tokensOwner for quantity of tokens
    struct MainMarketHolder{
        uint256 tokensOwned;
        uint256 zapBalance;
    }

    RegistryInterface public registry;
    BondageInterface public bondage;
    ZapCoordinatorInterface public coordinator;

    ZapToken public zapToken;

    MainMarketTokenInterface public mainMarketToken;

    bytes32 public endPoint = "Bond To Main Market";
    int256[] curve1 = [1,1,1000];


    mapping (address => MainMarketHolder) holders;
    


    constructor(address _zapCoor) public {
        coordinator = ZapCoordinatorInterface(_zapCoor);
        address bondageAddr = coordinator.getContract("BONDAGE");
        address mainMarketTokenAddress = coordinator.getContract("MAINMARKET_TOKEN");
        mainMarketToken = MainMarketTokenInterface(mainMarketTokenAddress);
        bondage = BondageInterface(bondageAddr);

        zapToken = ZapToken(coordinator.getContract("ZAP_TOKEN"));

        address registryAddress = coordinator.getContract("REGISTRY");
        registry = RegistryInterface(registryAddress);

        // initialize in registry
        bytes32 title = "Main market";

        registry.initiateProvider(12345, title);
        registry.initiateProviderCurve(endPoint, curve1, address(0));


    }


    function depositZap (uint256 quantity) external payable {
        uint256 zapBalance = zapToken.balanceOf(msg.sender);

        //amount must be equal to balance of zap deposited
        require (zapBalance >= quantity, "Not enough Zap in account");

        holders[msg.sender].zapBalance = quantity;

        zapToken.transferFrom(msg.sender, address(this), quantity);
    }


    //
    function buyAndBond(uint256 amount) external {
        //to bond msg.sender needs to give zap to this contract(MainMarket)
        address bondageAddr = coordinator.getContract("BONDAGE");
        zapToken.approve(bondageAddr, amount);
        uint zapSpent = bondage.delegateBond(msg.sender, address(this), endPoint, amount);
        address mainMarketTokenAddress = coordinator.getContract("MAINMARKET_TOKEN");
        mainMarketToken.approve(mainMarketTokenAddress, amount);
        allocateMMT(amount);
    }



    //Sell Main Market token (param amount) in exchange for zap token
    function sellAndUnbond(uint256 amount) public payable{
        mainMarketToken.transferFrom(msg.sender, address(this), amount);

        uint netZap = bondage.unbond(msg.sender, endPoint, amount);

        //Unbonding Zap from this contract so now tranfer it to the msg.sender
        zapToken.transferFrom(address(this), msg.sender, netZap);
    }

    function getZapBalance(address _owner) external returns(uint256) {
        return zapToken.balanceOf(_owner);
    }

    function allocateMMT(uint256 amount) public {
        mainMarketToken.mint(msg.sender, amount);
    }

    function allocateZap(uint256 amount) public {
        zapToken.allocate(address(this), amount);
    }

     function getMMTBalance(address _owner) external returns(uint256) {
        return mainMarketToken.balanceOf(_owner);
    }



    function getZapPrice() public view {}


    //Withdraw 5% from
    function withdraw(address holder, uint256 amount) external returns(uint256) {
        uint256 fee = (amount.mul(5)).div(100);
        return fee;
    }


    // Destroys the contract when there is no more Zap
    function destroyMainMarket() private {}
}