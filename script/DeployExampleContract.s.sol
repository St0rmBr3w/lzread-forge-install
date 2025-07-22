// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";
import { ExampleContract } from "../src/ExampleContract.sol";

contract DeployExampleContractScript is Script {
    ExampleContract public exampleContract;
    
    // Initial data value for the contract
    uint256 public constant INITIAL_DATA = 42;
    
    function run() public {
        vm.startBroadcast();
        
        address deployer = vm.addr(vm.envUint("PRIVATE_KEY"));
        console.log("Deploying ExampleContract...");
        console.log("Deployer:", deployer);
        console.log("Initial data value:", INITIAL_DATA);
        
        // Deploy ExampleContract with initial data
        exampleContract = new ExampleContract(INITIAL_DATA);
        
        console.log("ExampleContract deployed at:", address(exampleContract));
        console.log("Data value:", exampleContract.data());
        
        vm.stopBroadcast();
        
        // Save deployment info
        console.log("\n=== DEPLOYMENT COMPLETE ===");
        console.log("Add this to your .env file:");
        console.log("EXAMPLE_CONTRACT_ADDRESS=%s", address(exampleContract));
    }
} 