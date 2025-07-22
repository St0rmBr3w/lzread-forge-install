// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";
import { ReadPublic } from "../src/ReadPublic.sol";

contract DeployReadPublicScript is Script {
    // LayerZero configuration - UPDATE THESE FOR YOUR TARGET NETWORK
    address public constant ENDPOINT_ADDRESS = 0x1a44076050125825900e736c501f859c50fE728c; // LayerZero V2 Endpoint
    uint32 public constant READ_CHANNEL = 4294967295; // LayerZero Read Channel ID
    
    ReadPublic public readPublic;
    
    function run() public {
        vm.startBroadcast();
        
        address deployer = vm.addr(vm.envUint("PRIVATE_KEY"));
        console.log("Deploying ReadPublic contract...");
        console.log("Deployer:", deployer);
        console.log("Endpoint:", ENDPOINT_ADDRESS);
        console.log("Read Channel:", READ_CHANNEL);
        
        // Deploy ReadPublic contract
        readPublic = new ReadPublic(
            ENDPOINT_ADDRESS,    // LayerZero endpoint
            deployer,           // Delegate (owner)
            READ_CHANNEL        // Read channel ID
        );
        
        console.log("ReadPublic deployed at:", address(readPublic));
        console.log("Owner:", readPublic.owner());
        console.log("Read Channel:", readPublic.READ_CHANNEL());
        
        vm.stopBroadcast();
        
        // Save deployment info
        console.log("\n=== DEPLOYMENT COMPLETE ===");
        console.log("Add this to your .env file:");
        console.log("READ_PUBLIC_ADDRESS=%s", address(readPublic));
    }
} 