# 🌍 Environmental Impact & Reclamation Fund

> 🏭 A blockchain-based escrow system ensuring mining companies restore land after extraction

## 📋 Overview

The Environmental Impact & Reclamation Fund is a smart contract solution that addresses the critical problem of incomplete land restoration after mining operations. Mining companies deposit funds into an escrow system before beginning extraction, and these funds are only released upon verified restoration by authorized third-party validators.

## ✨ Key Features

- 💰 **Secure Fund Deposits**: Mining companies must deposit reclamation funds before starting operations
- 🔍 **Third-Party Verification**: Multiple independent verifiers must confirm restoration completion  
- 📊 **Public Progress Tracking**: Transparent monitoring of all restoration projects
- 🔐 **Escrow Protection**: Funds remain locked until verification requirements are met
- 🚨 **Emergency Controls**: Contract owner can release funds in exceptional circumstances

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- STX tokens for testing

### Installation

```bash
clarinet new my-reclamation-fund
cd my-reclamation-fund
# Replace contracts/my-reclamation-fund.clar with our contract
```

## 🔧 Usage Instructions

### For Mining Companies 🏗️

1. **Create a Project**
   ```clarity
   (contract-call? .environmental-impact-reclamation-fund create-project u1000000 u2)
   ```
   - `u1000000`: Deposit amount in microSTX
   - `u2`: Number of verifications required

2. **Release Funds** (after verification)
   ```clarity
   (contract-call? .environmental-impact-reclamation-fund release-funds u1)
   ```

### For Verifiers 🔍

1. **Verify Restoration**
   ```clarity
   (contract-call? .environmental-impact-reclamation-fund verify-restoration u1)
   ```

### For Contract Owner 👥

1. **Add Verifier**
   ```clarity
   (contract-call? .environmental-impact-reclamation-fund add-verifier 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
   ```

2. **Emergency Release**
   ```clarity
   (contract-call? .environmental-impact-reclamation-fund emergency-release u1)
   ```

## 📖 Smart Contract Functions

### Public Functions

| Function | Description | Access |
|----------|-------------|--------|
| `create-project` | Deposit funds and create new project | Mining Companies |
| `verify-restoration` | Submit restoration verification | Authorized Verifiers |
| `release-funds` | Release escrowed funds | Project Owner |
| `add-verifier` | Add authorized verifier | Contract Owner |
| `remove-verifier` | Remove verifier authorization | Contract Owner |
| `emergency-release` | Emergency fund release | Contract Owner |

### Read-Only Functions

| Function | Description |
|----------|-------------|
| `get-project` | Retrieve project details |
| `get-project-verification` | Check verification status |
| `is-verifier` | Check if address is authorized verifier |
| `get-contract-stats` | View contract statistics |
| `get-contract-balance` | Check contract balance |

## 📊 Project Status Flow

```
Active → Verified → Released
   ↓         ↑
Emergency Released
```

- **Active**: Project created, awaiting verifications
- **Verified**: Required verifications received
- **Released**: Funds returned to mining company
- **Emergency Released**: Funds released by contract owner

## 🔐 Security Features

- ✅ Role-based access control
- ✅ Multi-signature verification requirements
- ✅ Fund escrow protection
- ✅ Emergency override capabilities
- ✅ Comprehensive error handling
- ✅ Public transparency

## 🧪 Testing

```bash
clarinet test
```

## 📝 Error Codes

| Code | Description |
|------|-------------|
| `u401` | Not authorized |
| `u404` | Project not found |
| `u402` | Insufficient funds |
| `u409` | Project already exists |
| `u400` | Invalid verification |
| `u403` | Funds already released |
| `u405` | Project not active |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## 🌟 Impact

This contract ensures environmental accountability in mining operations, protecting ecosystems and communities from abandoned extraction sites. By requiring upfront deposits and verified restoration, we create financial incentives for responsible mining practices.

---

*Built with 💚 for environmental protection*
