# LayerZero V2 Cross-Chain Read Application

A complete implementation of LayerZero V2's cross-chain read functionality using Foundry. This project demonstrates how to read data from contracts deployed on remote chains using LayerZero's infrastructure.

## 📋 **Project Overview**

- **ReadPublic.sol**: Cross-chain reader contract that can fetch data from other chains
- **ExampleContract.sol**: Simple contract with a public `data` variable that can be read cross-chain
- **Deployment Scripts**: Automated deployment and configuration scripts
- **Test Scripts**: End-to-end testing functionality

## 🚀 **Complete End-to-End Guide**

### **1. Installation & Setup**

#### **Prerequisites**
- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
- Private key with testnet/mainnet tokens
- RPC endpoints for your target networks
- Basic understanding of LayerZero V2

#### **Install Dependencies**
```bash
# Clone the repository
git clone <your-repo>
cd lzread-forge-vanilla

# Install Foundry dependencies
forge install

# Build the project
forge build
```

### **2. Environment Configuration**

Create a `.env` file in the project root:

```bash
# Private key (MUST include 0x prefix)
PRIVATE_KEY="0xyour_private_key_here"

# RPC URLs for your target networks
RPC_URL_ARBITRUM="https://arbitrum.gateway.tenderly.co"
# Add other networks as needed:
# RPC_URL_ETHEREUM="https://mainnet.infura.io/v3/YOUR_KEY"
# RPC_URL_POLYGON="https://polygon-rpc.com"

# API keys for contract verification (optional)
ARBISCAN_API_KEY="your_arbiscan_api_key"
ETHERSCAN_API_KEY="your_etherscan_api_key"

# Contract addresses (will be populated after deployment)
EXAMPLE_CONTRACT_ADDRESS=""
READ_PUBLIC_ADDRESS=""
```

**⚠️ Important**: Your private key MUST start with `0x` or deployments will fail.

### **3. Deployment**

#### **Step 3.1: Deploy Contracts**

```bash
# Load environment variables
source .env

# Deploy ExampleContract (contract to be read from)
forge script script/DeployExampleContract.s.sol \
  --fork-url $RPC_URL_ARBITRUM \
  --private-key $PRIVATE_KEY \
  --broadcast

# Deploy ReadPublic (contract that performs reads)
forge script script/DeployReadPublic.s.sol \
  --fork-url $RPC_URL_ARBITRUM \
  --private-key $PRIVATE_KEY \
  --broadcast
```

#### **Step 3.2: Update Environment with Deployed Addresses**

Add the deployed contract addresses to your `.env` file:

```bash
# Add these lines with your actual deployed addresses
EXAMPLE_CONTRACT_ADDRESS="0x..."  # From DeployExampleContract output
READ_PUBLIC_ADDRESS="0x..."       # From DeployReadPublic output

# Reload environment
source .env
```

### **4. LayerZero Configuration (Wiring)**

#### **Step 4.1: Update SetConfig.s.sol**

Update `script/SetConfig.s.sol` with the correct LayerZero addresses for your network:

```solidity
// For Arbitrum example:
// Configuration constants - REPLACE WITH YOUR VALUES
uint32 public constant READ_CHANNEL = 4294967295; // LayerZero Read Channel ID
address public constant ENDPOINT_ADDRESS = 0x1a44076050125825900e736c501f859c50fE728c; // LayerZero V2 Endpoint
address public constant READ_LIB_ADDRESS = 0xbcd4CADCac3F767C57c4F402932C4705DF62BEFf; // ReadLib1002 address for your chain - UPDATE THIS
address public constant READ_COMPATIBLE_DVN = 0x1308151a7ebaC14f435d3Ad5fF95c34160D539A5; // DVN that supports read operations - UPDATE THIS
```

**📚 Resources for Addresses:**
- [LayerZero V2 Endpoint Addresses](https://docs.layerzero.network/contracts/endpoint-addresses)
- [DVN Addresses](https://docs.layerzero.network/concepts/security-stack-dvns)
- [ReadLib1002 Addresses](https://docs.layerzero.network/) (check latest docs)

#### **Step 4.2: Configure LayerZero Settings**

```bash
# Run the configuration script
forge script script/SetConfig.s.sol \
  --fork-url $RPC_URL_ARBITRUM \
  --private-key $PRIVATE_KEY \
  --broadcast
```

**⚠️ CRITICAL NOTES:**

1. **Library Setting is Permanent**: Once you set the read library using `setSendLibrary` and `setReceiveLibrary`, you **CANNOT set it again to the same address**. The transaction will revert if you try to call again using the same library value.

2. **Enforced Options Must Be Correct**: The enforced options configuration is critical. Incorrect gas limits, sizes, or option encoding will cause read operations to fail.

3. **DVN Compatibility**: Ensure your chosen DVN supports reading between your source and target chains.

### **5. Testing & Sending Read Requests**

#### **Step 5.1: Update Test Script**

Update `script/TestRead.s.sol` with the correct target EID:

```solidity
// Update this line based on your target network
uint32 targetEid = 30110; // Arbitrum EID
```

#### **Step 5.2: Execute Test**

```bash
# Run the cross-chain read test
forge script script/TestRead.s.sol \
  --fork-url $RPC_URL_ARBITRUM \
  --private-key $PRIVATE_KEY \
  --broadcast
```

### **6. Verification & Monitoring**

#### **Check Deployment Status**

```bash
# Verify ExampleContract data
cast call $EXAMPLE_CONTRACT_ADDRESS "data()" --rpc-url $RPC_URL_ARBITRUM

# Verify ReadPublic configuration
cast call $READ_PUBLIC_ADDRESS "owner()" --rpc-url $RPC_URL_ARBITRUM
cast call $READ_PUBLIC_ADDRESS "READ_CHANNEL()" --rpc-url $RPC_URL_ARBITRUM
```

#### **Monitor Read Operations**

After sending a read request, monitor for:

1. **Transaction Success**: Check that the read request transaction succeeds
2. **DataReceived Events**: Watch for `DataReceived` events on your ReadPublic contract
3. **Block Explorer**: Monitor transactions on your chosen block explorer

## ⚡ **Quick Commands Reference**

### **Complete Deployment Flow**
```bash
# 1. Setup
source .env

# 2. Deploy contracts
forge script script/DeployExampleContract.s.sol --fork-url $RPC_URL_ARBITRUM --private-key $PRIVATE_KEY --broadcast
forge script script/DeployReadPublic.s.sol --fork-url $RPC_URL_ARBITRUM --private-key $PRIVATE_KEY --broadcast

# 3. Update .env with deployed addresses, then configure
forge script script/SetConfig.s.sol --fork-url $RPC_URL_ARBITRUM --private-key $PRIVATE_KEY --broadcast

# 4. Test
forge script script/TestRead.s.sol --fork-url $RPC_URL_ARBITRUM --private-key $PRIVATE_KEY --broadcast
```

### **Verification Commands**
```bash
# Check contract states
cast call $EXAMPLE_CONTRACT_ADDRESS "data()" --rpc-url $RPC_URL_ARBITRUM
cast call $READ_PUBLIC_ADDRESS "owner()" --rpc-url $RPC_URL_ARBITRUM

# Get read fee quote
cast call $READ_PUBLIC_ADDRESS "quoteReadFee(address,uint32,bytes)" \
  $EXAMPLE_CONTRACT_ADDRESS 30110 0x \
  --rpc-url $RPC_URL_ARBITRUM
```

## 🌐 **Network Support**

### **Supported Networks & EIDs**

| Network | EID | Endpoint Address |
|---------|-----|-----------------|
| Ethereum | 30101 | 0x1a44076050125825900e736c501f859c50fE728c |
| Arbitrum | 30110 | 0x1a44076050125825900e736c501f859c50fE728c |
| Polygon | 30109 | 0x1a44076050125825900e736c501f859c50fE728c |
| Optimism | 30111 | 0x1a44076050125825900e736c501f859c50fE728c |
| Base | 30184 | 0x1a44076050125825900e736c501f859c50fE728c |

*Note: Verify addresses in [official LayerZero docs](https://docs.layerzero.network)*

## 🚨 **Common Issues & Solutions**

### **"VM.envUint: failed parsing PRIVATE_KEY"**
- **Solution**: Ensure your private key starts with `0x`

### **"Library setting reverted"**
- **Cause**: Trying to reset an already configured library
- **Solution**: Libraries can only be set once. Comment out setSendLibrary and setReceiveLibrary if already set.

### **"Read operation fails with unknown error"**
- **Cause**: Incorrect enforced options or missing configuration
- **Solution**: Verify enforced options are correctly encoded and all configuration steps completed

### **"DVN not supported"**
- **Cause**: DVN doesn't support your source-target chain pair
- **Solution**: Choose a DVN that supports both chains in your setup

### **"Insufficient gas" on read operations**
- **Cause**: Gas limit too low in enforced options
- **Solution**: Increase gas limit in `addExecutorLzReadOption`

## 📚 **Additional Resources**

- [LayerZero V2 Documentation](https://docs.layerzero.network/)
- [Foundry Documentation](https://book.getfoundry.sh/)

## 🤝 **Contributing**

1. Fork the repository
2. Create your feature branch
3. Test your changes thoroughly
4. Submit a pull request

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Need Help?** Check the troubleshooting section above or refer to the [LayerZero V2 documentation](https://docs.layerzero.network/) for more detailed information.
