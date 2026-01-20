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
- 🔄 **Project Cancellation**: Companies can cancel active projects and receive full refunds
- 🎯 **Project Milestones**: Track detailed restoration progress with customizable milestone checkpoints

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

3. **Cancel Project** (before verification)
    ```clarity
    (contract-call? .environmental-impact-reclamation-fund cancel-project u1)
    ```

4. **Add Milestone**
    ```clarity
    (contract-call? .environmental-impact-reclamation-fund add-milestone u1 "Soil preparation completed")
    ```

5. **Complete Milestone**
    ```clarity
    (contract-call? .environmental-impact-reclamation-fund complete-milestone u1 u1)
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
| `cancel-project` | Cancel active project and refund deposit | Project Owner |
| `add-verifier` | Add authorized verifier | Contract Owner |
| `remove-verifier` | Remove verifier authorization | Contract Owner |
| `emergency-release` | Emergency fund release | Contract Owner |
| `add-milestone` | Add restoration milestone | Project Owner |
| `complete-milestone` | Mark milestone as completed | Project Owner |

### Read-Only Functions

| Function | Description |
|----------|-------------|
| `get-project` | Retrieve project details |
| `get-project-verification` | Check verification status |
| `is-verifier` | Check if address is authorized verifier |
| `get-contract-stats` | View contract statistics |
| `get-contract-balance` | Check contract balance |
| `get-milestone` | Retrieve milestone details |
| `get-project-milestones` | Get total milestones for project |

## 📊 Project Status Flow

```
Active → Verified → Released
   ↓         ↑
Cancelled    Emergency Released
```

- **Active**: Project created, awaiting verifications
- **Verified**: Required verifications received
- **Released**: Funds returned to mining company
- **Cancelled**: Project cancelled by company, funds refunded
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

### 🎯 Project Milestones Enhancement

The new milestone tracking system enables granular progress monitoring throughout the restoration process. Companies can define specific checkpoints like "Site assessment completed," "Topsoil replacement finished," or "Vegetation establishment achieved," providing stakeholders with detailed visibility into restoration progress and fostering greater transparency in environmental rehabilitation efforts.

---

### 🏢 Project Ownership Transfer Enhancement

Introducing seamless project ownership transfers to empower mining companies with greater operational flexibility. This feature enables companies to reassign project ownership during active status, supporting scenarios like corporate restructuring, mergers, or strategic partnerships. By allowing direct principal transfers, the contract maintains security through strict authorization checks while providing the agility needed in dynamic business environments.

Key capabilities include:
- 🔄 **Instant Ownership Reassignment**: Transfer projects to new principals without disrupting escrow protection
- 🛡️ **Secure Authorization**: Only current project owners can initiate transfers
- 📋 **Active Project Focus**: Transfers restricted to active projects to prevent manipulation
- 🚫 **Duplicate Prevention**: Blocks transfers to the same owner to avoid unnecessary operations

*Built with 💚 for environmental protection*
