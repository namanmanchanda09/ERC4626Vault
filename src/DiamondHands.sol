//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "solmate/mixins/ERC4626.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./IERC20.sol";

struct WethDeposit {
    uint256 amount;
    uint256 wethPriceAtDeposit;
}

contract DiamondHands is ERC4626 {

    AggregatorV3Interface internal dataFeed;
    IERC20 internal usdc;

    mapping(address => uint256) public depositors;
    mapping(address => WethDeposit[]) public WethDeposits;

    constructor (ERC20 WETH, address _USDC) ERC4626(WETH, "WETH", "vWETH") {
        dataFeed = AggregatorV3Interface(
            0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        );

        usdc = IERC20(_USDC);
    }

    /**
    Function to accept WETH from depositors
     */
    function depositAsset(uint _WETH) public {
        // Checks deposited WETH is greater than zero
        require(_WETH > 0, "WETH deposit is less than zero");

        // Calls the Solmate's Deposit fn
        deposit(_WETH, msg.sender);
        
        // Change the state variables to track the deposits
        depositors[msg.sender] += _WETH;
        WethDeposit[] storage WethDepositArray = WethDeposits[msg.sender];
        uint256 currentEthPriceInUsd = getPrice();
        WethDepositArray.push(WethDeposit(_WETH, currentEthPriceInUsd));
    }

    /**
    Function to redeem the vWETH and rewward depositors
     */
    function redeemAsset(uint _vWETH) public {
        // Various checks
        require(_vWETH > 0, "vWETH amount is less than zero");
        require(depositors[msg.sender] > 0, "Not a depositor");
        require(depositors[msg.sender] >= _vWETH, "Depositor doesnt have enough vWETH");

        WethDeposit[] memory WethDepositArray = WethDeposits[msg.sender];
        uint256 numberOfDeposits = WethDepositArray.length;

        // Fetching the ETH/USD price at which depositor deposited
        uint256 atDepositPrice = depositEthPriceInUsd(numberOfDeposits, WethDepositArray);

        // Fetching the current ETH/USD price
        uint256 currentDepositPrice = getPrice();
        require(currentDepositPrice >= atDepositPrice, "WETH price is lower than deposit");

        // Calculating 10% yield on the withdrawal amt
        uint256 rewardPercentage = (10 * _vWETH) / 100;

        // Transferring WETH & USDC to depositor
        redeem(_vWETH, msg.sender, msg.sender);
        usdc.transfer(msg.sender, rewardPercentage);
        depositors[msg.sender] -= _vWETH;
    }

    /**
    Function to get ETH/USD price using Chainlink
     */
    function getPrice() internal view returns(uint256) {
        (,int256 price,,,) = dataFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    /**
    Calculate the weighed ETH/USC price in case of multiple deposits
     */
    function depositEthPriceInUsd(uint256 _depositCount, WethDeposit[] memory _WethDepositArray) internal pure returns(uint256) {
        uint256 priceAtDeposit;
        uint256 totalDepositAmount;
        if (_depositCount > 1) {
            for (uint i = 0; i< _depositCount; i++) {
                priceAtDeposit += (_WethDepositArray[i].wethPriceAtDeposit * _WethDepositArray[i].amount);
                totalDepositAmount += _WethDepositArray[i].amount;
            }
            priceAtDeposit /= totalDepositAmount;
        } else {
            priceAtDeposit = _WethDepositArray[0].wethPriceAtDeposit;
        }
        return priceAtDeposit;
    }

    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this));
    }
}





