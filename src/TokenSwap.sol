// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interfaces/IERC20.sol";
import {AggregatorV3Interface} from "lib/chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {FeedRegistryInterface} from "lib/chainlink/contracts/src/v0.8/interfaces/FeedRegistryInterface.sol";

contract TokenSwap {
    address public ethToken;
    address public linkToken;
    address public daiToken;

    FeedRegistryInterface private feedRegistry;
    address private feedRegistryAddress;

    event EthToLinkSwap(address indexed sender, uint256 amount);
    event EthToDaiSwap(address indexed sender, uint256 amount);
    event LinkToEthSwap(address indexed sender, uint256 amount);
    event LinkToDaiSwap(address indexed sender, uint256 amount);
    event DaiToEthSwap(address indexed sender, uint256 amount);
    event DaiToLinkSwap(address indexed sender, uint256 amount);

    constructor(
        address _ethToken,
        address _linkToken,
        address _daiToken,
        address _feedRegistryAddress
    ) {
        ethToken = _ethToken;
        linkToken = _linkToken;
        daiToken = _daiToken;
        feedRegistryAddress = _feedRegistryAddress;
    }

    /**
     * @dev Swap LINK for ETH.
     * @notice This function swaps LINK for ETH using the Chainlink Price Feed.
     * @param amount The amount of LINK to swap.
     */
    function swapLinkToEth(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");

        // Transfer LINK from the sender to this contract.
        IERC20(linkToken).transferFrom(msg.sender, address(this), amount);

        // Get the amount of ETH from the LINK amount and the price feed.
        uint256 amountOut = _amountOut(linkToken, ethToken, amount);

        // Transfer the ETH to the sender.
        IERC20(ethToken).transfer(msg.sender, amountOut);

        // Emit an event with the sender and the LINK amount.
        emit LinkToEthSwap(msg.sender, amount);
    }

    /**
     * @dev Swap ETH for LINK.
     * @notice This function swaps ETH for LINK using the Chainlink Price Feed.
     * @param amount The amount of ETH to swap.
     */
    function swapEthToLink(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");

        // Transfer ETH from the sender to this contract.
        IERC20(ethToken).transferFrom(msg.sender, address(this), amount);

        // Get the amount of LINK from the ETH amount and the price feed.
        uint256 amountOut = _amountOut(ethToken, linkToken, amount);

        // Transfer the LINK to the sender.
        IERC20(linkToken).transfer(msg.sender, amountOut);

        // Emit an event with the sender and the ETH amount.
        emit EthToLinkSwap(msg.sender, amount);
    }

    /**
     * @dev Swap ETH for DAI.
     * @notice This function swaps ETH for DAI using the Chainlink Price Feed.
     * @param amount The amount of ETH to swap.
     */
    function swapEthToDai(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");

        // Transfer ETH from the sender to this contract.
        IERC20(ethToken).transferFrom(msg.sender, address(this), amount);

        // Get the amount of DAI from the ETH amount and the price feed.
        uint256 amountOut = _amountOut(ethToken, daiToken, amount);

        // Transfer the DAI to the sender.
        IERC20(daiToken).transfer(msg.sender, amountOut);

        // Emit an event with the sender and the ETH amount.
        emit EthToDaiSwap(msg.sender, amount);
    }

    /**
     * @dev Swap DAI for LINK.
     * @notice This function swaps DAI for LINK using the Chainlink Price Feed.
     * @param amount The amount of DAI to swap.
     */
    function swapDaiToLink(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        // Require a valid amount to swap.

        IERC20(daiToken).transferFrom(msg.sender, address(this), amount);
        // Transfer DAI from the sender to this contract.

        uint256 amountOut = _amountOut(daiToken, linkToken, amount);
        // Get the amount of LINK from the DAI amount and the price feed.

        IERC20(linkToken).transfer(msg.sender, amountOut);
        // Transfer the LINK to the sender.

        emit DaiToLinkSwap(msg.sender, amount);
        // Emit an event with the sender and the DAI amount.
    }

    /**
     * @dev Swap LINK for DAI.
     * @notice This function swaps LINK for DAI using the Chainlink Price Feed.
     * @param amount The amount of LINK to swap.
     */
    function swapLinkToDai(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");

        // Transfer LINK from the sender to this contract.
        IERC20(linkToken).transferFrom(msg.sender, address(this), amount);

        // Get the amount of DAI from the LINK amount and the price feed.
        uint256 amountOut = _amountOut(linkToken, daiToken, amount);

        // Transfer the DAI to the sender.
        IERC20(daiToken).transfer(msg.sender, amountOut);

        // Emit an event with the sender and the LINK amount.
        emit LinkToDaiSwap(msg.sender, amount);
    }

    /**
     * @dev Swap DAI for ETH.
     * @notice This function swaps DAI for ETH using the Chainlink Price Feed.
     * @param amount The amount of DAI to swap.
     */
    function swapDaiToEth(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");

        // Transfer DAI from the sender to this contract.
        IERC20(daiToken).transferFrom(msg.sender, address(this), amount);

        // Get the amount of ETH from the DAI amount and the price feed.
        uint256 amountOut = _amountOut(daiToken, ethToken, amount);

        // Transfer the ETH to the sender.
        IERC20(ethToken).transfer(msg.sender, amountOut);

        // Emit an event with the sender and the DAI amount.
        emit DaiToEthSwap(msg.sender, amount);
    }

    /**
     * @dev Get the amount of quote asset that would be received for a given amount
     * of base asset.
     * @notice This function retrieves the current Chainlink price feed data and
     * multiplies it by the given amount of base asset to determine the amount of
     * quote asset that would be received.
     * @param base The address of the base asset token.
     * @param quote The address of the quote asset token.
     * @param amountIn The amount of base asset to swap.
     * @return The amount of quote asset that would be received.
     */
    function _amountOut(
        address base,
        address quote,
        uint256 amountIn
    ) internal view returns (uint256) {
        // Retrieve the latest round data from the Chainlink price feed.
        (, int256 priceIn, , , ) = feedRegistry.latestRoundData(base, quote);
        // Check that the price feed is available for the base asset.
        require(priceIn > 0, "Price feed not available for base asset");
        // Calculate the amount of quote asset that would be received.
        return uint256(amountIn * uint256(priceIn));
    }
}
