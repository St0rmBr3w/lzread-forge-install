// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";
import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import { ExecutorOptions } from "@layerzerolabs/lz-evm-protocol-v2/contracts/messagelib/libs/ExecutorOptions.sol";
import { EnforcedOptionParam } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import { ReadLibConfig } from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/readlib/ReadLibBase.sol";
import { SetConfigParam } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
import { ILayerZeroEndpointV2 } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import { ReadPublic } from "../src/ReadPublic.sol";

contract SetConfigScript is Script {
    using OptionsBuilder for bytes;
    
    // Configuration constants - REPLACE WITH YOUR VALUES
    uint32 public constant READ_CHANNEL = 4294967295; // LayerZero Read Channel ID
    address public constant ENDPOINT_ADDRESS = 0x1a44076050125825900e736c501f859c50fE728c; // LayerZero V2 Endpoint
    address public constant READ_LIB_ADDRESS = 0xbcd4CADCac3F767C57c4F402932C4705DF62BEFf; // ReadLib1002 address for your chain - UPDATE THIS
    address public constant READ_COMPATIBLE_DVN = 0x1308151a7ebaC14f435d3Ad5fF95c34160D539A5; // DVN that supports read operations - UPDATE THIS
    
    // Contract addresses to configure - SET THESE AFTER DEPLOYMENT
    address public readPublicAddress;
    
    function setUp() public {
        // Set your deployed ReadPublic contract address here
        readPublicAddress = vm.envAddress("READ_PUBLIC_ADDRESS");
    }

    function run() public {
        vm.startBroadcast();
        
        console.log("Configuring ReadPublic contract at:", readPublicAddress);
        
        // Get contract instances
        ILayerZeroEndpointV2 endpoint = ILayerZeroEndpointV2(ENDPOINT_ADDRESS);
        ReadPublic myReadApp = ReadPublic(readPublicAddress);
        
        // // 1. Set Read Library (only on source chain)
        // console.log("Step 1: Setting Read Library...");
        // endpoint.setSendLibrary(readPublicAddress, READ_CHANNEL, READ_LIB_ADDRESS);
        // endpoint.setReceiveLibrary(readPublicAddress, READ_CHANNEL, READ_LIB_ADDRESS, 0);
        
        // // 2. Configure DVNs (must support target chains you want to read from)
        // console.log("Step 2: Configuring DVNs...");
        // SetConfigParam[] memory params = new SetConfigParam[](1);
        
        // address[] memory requiredDVNs = new address[](1);
        // requiredDVNs[0] = READ_COMPATIBLE_DVN;
        
        // address[] memory optionalDVNs = new address[](0);
        
        // params[0] = SetConfigParam({
        //     eid: READ_CHANNEL,
        //     configType: 1, // LZ_READ_LID_CONFIG_TYPE
        //     config: abi.encode(ReadLibConfig({
        //         executor: address(0x31CAe3B7fB82d847621859fb1585353c5720660D), // Executor address - UPDATE THIS
        //         requiredDVNCount: 1,
        //         optionalDVNCount: 0,
        //         optionalDVNThreshold: 0,
        //         requiredDVNs: requiredDVNs,
        //         optionalDVNs: optionalDVNs
        //     }))
        // });
        // endpoint.setConfig(readPublicAddress, READ_LIB_ADDRESS, params);
        
        // // 3. Activate Read Channel (enables receiving responses)
        // console.log("Step 3: Activating Read Channel...");
        // myReadApp.setReadChannel(READ_CHANNEL, true);
        
        // 4. Set Enforced Options (with lzRead-specific options)
        console.log("Step 4: Setting Enforced Options...");
        EnforcedOptionParam[] memory enforcedOptions = new EnforcedOptionParam[](1);
        enforcedOptions[0] = EnforcedOptionParam({
            eid: READ_CHANNEL,
            msgType: 1, // READ_MSG_TYPE
            options: OptionsBuilder.newOptions().addExecutorLzReadOption(50000, 128, 0)
        });
        myReadApp.setEnforcedOptions(enforcedOptions);
        
        console.log("Configuration complete!");
        
        vm.stopBroadcast();
    }
}