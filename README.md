# 30 Days of Solidity

Welcome to my "30 Days of Solidity" challenge repository! This project documents my journey of learning and implementing a variety of smart contracts, one per day, to explore different concepts and use cases within the Ethereum and blockchain ecosystem.

Each contract aims to tackle a specific problem or demonstrate a particular feature of Solidity and smart contract development, ranging from simple utility contracts to more complex DeFi and NFT interactions.

## 🚀 Purpose

The main goals of this project are:

- **Deepen understanding:** To solidify my knowledge of Solidity, its syntax, patterns, and best practices.
- **Explore diverse use cases:** To build mini contracts covering various domains like DeFi, NFTs, DAOs, oracles, security patterns, and more.
- **Practical application:** To move beyond theory and gain hands-on experience in writing, testing, and deploying smart contracts.

## 📜 Contracts Developed

Below is a list of the contracts developed during this challenge. Many include detailed explanations/guides within their respective folder.

| Day | Contract Name                 | Brief Description                                                              | Key Concepts / Features Implemented                                        |
| --- | ----------------------------- | ------------------------------------------------------------------------------ | -------------------------------------------------------------------------- |
| 1   | ClickCounter                  | Simple counter incremented by clicks.                                          | State variables, functions, events. _Detailed guide available._            |
| 2   | SaveMyName                    | Allows users to save and retrieve a name.                                      | Mappings, string manipulation. _Detailed guide available._                 |
| 3   | PollStation                   | Basic polling/voting mechanism.                                                | Structs, mappings, modifiers. _Docs for AuctionHouse (related)._           |
| 4   | AuctionHouse                  | Simple auction contract for bidding on an item.                                | `payable`, `transfer`, event emission. _Detailed guide available._         |
| 5   | AdminOnly                     | Contract with functions restricted to an admin/owner.                          | `Ownable` pattern, modifiers. _Detailed guide available._                  |
| 6   | Ether Piggy Bank              | A simple piggy bank to deposit and withdraw Ether.                             | `payable`, `receive`, `fallback`. _Detailed guide available._              |
| 7   | SimpleIOU                     | Tracks "I Owe You" between parties.                                            | Mappings, basic debt tracking. _Detailed guide available._                 |
| 8   | TipJar                        | Allows users to send tips to the contract owner.                               | `payable`, owner withdrawal. _Detailed guide available._                   |
| 9   | Smart Calculator              | On-chain calculator for basic arithmetic operations, power, and square root.   | Math operations, error handling.                                           |
| 10  | ActivityTracker               | Fitness tracker with user profiles and activity logging.                       | Structs, mappings, access control.                                         |
| 11  | Masterkey (VaultMaster)       | Secure vault using `Ownable` for deposit/withdrawal.                           | `Ownable` (OpenZeppelin), Ether handling.                                  |
| 12  | Simple ERC20                  | Custom ERC20 token and an OpenZeppelin-based `MyToken`.                        | ERC20 standard, token minting/transfer.                                    |
| 13  | PreOrderToken                 | Token sale contract with pre-order logic and timed transfers.                  | ICO/token sale mechanics, time-based logic.                                |
| 14  | SafeDeposit (VaultManager)    | Manages creation, naming, and ownership of multiple vault instances.           | Factory pattern, contract interaction.                                     |
| 15  | GasSaver (Voting)             | Gas-optimized voting contract.                                                 | Gas efficiency techniques, bitmasking (example).                           |
| 16  | PluginStore                   | Manages and retrieves plugin information for users.                            | Data storage, retrieval patterns.                                          |
| 17  | UpgradeHub                    | Demonstrates a basic upgradability pattern (proxy concept).                    | Upgradability, proxy patterns (simple).                                    |
| 18  | WeatherOracle (CropInsurance) | Basic crop insurance purchase and claim based on weather data (mock oracle).   | Oracle interaction (conceptual), conditional logic.                        |
| 19  | SignThis (EventEntry)         | Event check-in with ECDSA signature verification.                              | Cryptographic signatures, off-chain verification.                          |
| 20  | FortKnox (GoldThief)          | Simulates a reentrancy attack scenario and a guarded contract.                 | Reentrancy attacks, security best practices (Checks-Effects-Interactions). |
| 21  | SimpleNFT                     | Minimal ERC721-compliant NFT contract with safe transfers.                     | ERC721 standard, `_safeMint`.                                              |
| 22  | DecentralizedLottery          | Lottery contract using Chainlink VRF for randomness.                           | Chainlink VRF, randomness, prize distribution.                             |
| 23  | LendingPool                   | Basic ETH lending and borrowing protocol with collateral.                      | DeFi primitives, collateralization, interest (simple).                     |
| 24  | DecentralizedEscrow           | Enhanced escrow with dispute resolution and timelocks.                         | Escrow logic, dispute handling, timelocks.                                 |
| 25  | AutomatedMarketMaker          | AMM with liquidity provisioning, swapping, and LP tokens.                      | DeFi (AMM, liquidity pools, constant product formula).                     |
| 26  | NFTMarketplace                | Marketplace for listing and buying NFTs with royalty support.                  | ERC721, ERC2981 (royalties), marketplace logic.                            |
| 27  | YieldFarming                  | Yield farming contract for staking tokens and earning rewards.                 | DeFi (staking, reward distribution, liquidity mining).                     |
| 28  | DecentralizedGovernance       | ERC-20 based DAO with proposals, voting, quorum, and timelock.                 | DAO, governance tokens, on-chain voting.                                   |
| 29  | Stablecoin                    | Part of MiniDex, logic for a token pair including liquidity and swap.          | DeFi (DEX pair, liquidity management).                                     |
| 30  | MiniDex                       | Factory contract to deploy and track token pairs for a decentralized exchange. | DeFi (DEX factory, pair creation).                                         |

## ✨ Key Concepts Explored

Throughout this challenge, I work with various important concepts in smart contract development, including:

- **Core Solidity:** State variables, functions, modifiers, events, error handling (`require`, `revert`, `assert`).
- **Data Structures:** Mappings, structs, arrays.
- **ERC Standards:** ERC20 (fungible tokens), ERC721 (non-fungible tokens)
- **DeFi Primitives:** Automated Market Makers (AMMs), lending/borrowing, yield farming, decentralized exchanges (DEXs), stablecoins (conceptual).
- **Governance:** Decentralized Autonomous Organizations (DAOs), token-based voting, timelocks.
- **Security:** Reentrancy attacks and prevention, access control (Ownable, role-based), signature verification.
- **Oracles:** Interaction with external data sources (Chainlink VRF, conceptual weather oracle).
- **Gas Optimization:** Techniques for writing more efficient smart contracts.
- **Upgradability:** Basic proxy patterns.
- **Oracles:** Interaction with external data sources (Chainlink VRF, conceptual weather oracle).
- **Development Tools & Libraries:** Use of tools like Remix, and libraries like OpenZeppelin, Chainlink contracts.

## 🛠️ Technologies Used

- **Solidity:** The primary language for smart contract development.
- **OpenZeppelin Contracts:** Utilized for standard implementations like ERC20, ERC721, Ownable, etc., promoting security and best practices.
- **Chainlink VRF:** For provably random number generation in the Decentralized Lottery.

## 🚀 Getting Started

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/ArunRawat404/30-Days-Solidity.git
    cd 30-Days-Solidity
    ```
2.  **Explore the contracts:** Each contract is typically a `.sol` file. You can review the code and the commit history for more context on its development.
3.  **Compile & Deploy:** Use your preferred Solidity development environment (e.g., Remix, Hardhat, Foundry) to compile, deploy, and interact with these contracts on a local blockchain or testnet.

## 🤝 Contributing

While this is primarily a personal learning project, suggestions, feedback, or bug reports are welcome! Feel free to open an issue if you spot something or have an idea for improvement.

## 📄 License

The code in this repository is generally licensed under the MIT License.

---
