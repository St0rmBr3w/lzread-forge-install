// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ExampleContract
 * @notice A simple contract with a public state variable that can be read cross-chain.
 * @dev This contract would be deployed on target chains (e.g., Ethereum, Polygon, Arbitrum)
 *      and the ReadPublic contract can fetch its `data` value from any other supported chain.
 */
contract ExampleContract {
    /// @notice Public state variable that can be read from other chains
    /// @dev The public keyword automatically generates a getter function data()
    uint256 public data;

    constructor(uint256 _data) {
        data = _data;
    }
}