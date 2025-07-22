// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";
import { ReadPublic } from "../src/ReadPublic.sol";
import { ExampleContract } from "../src/ExampleContract.sol";
import { MessagingFee, MessagingReceipt } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";

contract TestReadScript is Script {
    function run() public {
        address readPublicAddress = vm.envAddress("READ_PUBLIC_ADDRESS");
        address exampleContractAddress = vm.envAddress("EXAMPLE_CONTRACT_ADDRESS");
        
        console.log("Testing cross-chain read functionality...");
        console.log("ReadPublic contract:", readPublicAddress);
        console.log("ExampleContract target:", exampleContractAddress);
        
        ReadPublic readPublic = ReadPublic(readPublicAddress);
        
        // Network EIDs - update these based on your target network
        uint32 targetEid = 30111; // Optimism Mainnet EID (update as needed)
        bytes memory extraOptions = "";
        
        vm.startBroadcast();
        
        // Step 1: Get quote for read operation
        console.log("\n=== STEP 1: Getting read fee quote ===");
        try readPublic.quoteReadFee(exampleContractAddress, targetEid, extraOptions) returns (MessagingFee memory fee) {
            console.log("Native fee required:", fee.nativeFee);
            console.log("LZ token fee:", fee.lzTokenFee);
            
            // Step 2: Execute read with sufficient gas
            console.log("\n=== STEP 2: Sending read request ===");
            console.log("Sending read request with", fee.nativeFee, "wei...");
            
            try readPublic.readData{value: fee.nativeFee}(
                exampleContractAddress,
                targetEid,
                extraOptions
            ) returns (MessagingReceipt memory receipt) {
                console.log("Read request sent successfully!");
                console.log("Message GUID:", vm.toString(receipt.guid));
                console.log("Nonce:", receipt.nonce);
                console.log("Fee paid:", receipt.fee.nativeFee);
                
                console.log("\n=== SUCCESS ===");
                console.log("Cross-chain read request has been submitted.");
                console.log("Monitor the ReadPublic contract for DataReceived events.");
                console.log("Event will be emitted when the read response is received.");
                
            } catch Error(string memory reason) {
                console.log("Failed to send read request:", reason);
            } catch {
                console.log("Failed to send read request: Unknown error");
            }
            
        } catch Error(string memory reason) {
            console.log("Failed to get quote:", reason);
        } catch {
            console.log("Failed to get quote: Unknown error");
        }
        
        vm.stopBroadcast();
        
        console.log("\n=== NEXT STEPS ===");
        console.log("1. Monitor transaction status on block explorer");
        console.log("2. Check for DataReceived events on ReadPublic contract");
        console.log("3. Verify the read operation completed successfully");
    }
    
    // Helper function to check contract states
    function checkStates() public view {
        address readPublicAddress = vm.envAddress("READ_PUBLIC_ADDRESS");
        
        ReadPublic readPublic = ReadPublic(readPublicAddress);
        
        console.log("\n=== CONTRACT STATES ===");
        console.log("ReadPublic owner:", readPublic.owner());
        console.log("ReadPublic read channel:", readPublic.READ_CHANNEL());
        
        // Note: Checking ExampleContract state requires being on the same chain
        // You can manually verify the ExampleContract data using:
        // cast call $EXAMPLE_CONTRACT_ADDRESS "data()" --rpc-url $RPC_URL_TARGET
    }
} 