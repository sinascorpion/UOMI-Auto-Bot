# UOMI Auto Bot
![IMG_20250804_114728_494](https://github.com/user-attachments/assets/142425f7-0dd2-4335-863b-27942c0bf398)

*Version 1.0 | Created by irdropper | [Join our Telegram Community](https://t.me/irdropper)*

---

## Overview

**UOMI Auto Bot** is a Python-based automation script designed for interacting with the UOMI Decentralized Exchange (DEX) on the UOMI testnet. This script facilitates automated token swaps across multiple trading pairs using the Uniswap V3-style router. It provides a user-friendly terminal interface with colorful output, loading animations, and robust error handling. The bot supports both manual and automated swap cycles for various tokens, including SYN, SIM, USDC, DOGE, and WUOMI.

This project is open-source and hosted on [GitHub](https://github.com/UOMI-Auto-Bot). Contributions and feedback are welcome!

---

## Features

- **Automated Token Swaps**: Execute single or multiple swap cycles for predefined token pairs (e.g., SYN → UOMI, UOMI → WUOMI).
- **User-Friendly Interface**: Interactive terminal with centered text, loading animations, and color-coded output using `colorama`.
- **Dynamic Gas Management**: Automatically calculates gas fees based on the latest block data for efficient transaction execution.
- **Error Handling**: Robust error handling for transaction failures and invalid inputs.
- **Environment Configuration**: Securely manages sensitive data (e.g., private keys, wallet addresses) using `.env` files.
- **Customizable Swap Options**: Supports both manual selection of token pairs and automated cycling through all pairs.
- **Transaction Tracking**: Provides transaction links for the UOMI testnet explorer.

---

## Prerequisites

Before running the UOMI Auto Bot, ensure you have the following:

- **Python 3.8+**: Install Python from [python.org](https://www.python.org/downloads/).
- **Node.js**: Required for the UOMI testnet RPC (if applicable).
- **UOMI Testnet Wallet**: A funded wallet with testnet tokens (e.g., UOMI, SYN, SIM, USDC, DOGE).
- **Metamask or Compatible Wallet**: For managing your private key and wallet address.
- **Dependencies**: Install required Python packages listed in `requirements.txt`.

---

## Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/sinascorpion/UOMI-Auto-Bot.git
   cd UOMI-Auto-Bot
   ```

2. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

   Required packages:
   - `web3`
   - `python-dotenv`
   - `colorama`

3. **Set Up Environment Variables**:
   Create a `.env` file in the project root and add the following:
   ```plaintext
   RPC_URL=https://finney.uomi.ai
   PRIVATE_KEY=your_private_key_here
   WALLET_ADDRESS=your_wallet_address_here
   ```

   **⚠️ Security Note**: Never share your private key or commit the `.env` file to version control.

4. **Verify RPC Connection**:
   Ensure the RPC URL (`https://finney.uomi.ai`) is accessible and the wallet is funded with testnet tokens.

---

## Usage

1. **Run the Script**:
   ```bash
   python index.py
   ```

2. **Terminal Interface**:
   - The script displays a colorful ASCII banner and version information.
   - Choose from available swap options (e.g., SYN → UOMI, UOMI → WUOMI, etc.).
   - Select the `[Auto Swap All Pairs]` option for automated cycling through all token pairs.
   - Enter the number of swaps or cycles when prompted.

3. **Example Workflow**:
   - Select option `[1]` to swap `SYN → UOMI`.
   - Input the number of swaps (e.g., `5`).
   - The bot will execute the swaps, display transaction links, and show progress with loading animations.

4. **Sample Output**:
   ```
   UOMI DEX Swap Terminal
   Wallet: 0x1234...abcd | Time: 15:30:45 04-08-2025
   ---------------------------------------
   Swap Options:
   [1] SYN → UOMI
   [2] SIM → UOMI
   [3] USDC → UOMI
   [4] DOGE → UOMI
   [5] UOMI → WUOMI
   [6] Auto Swap All Pairs
   ---------------------------------------
   >> Select Option: 
   ```

## Technical Details

- **Web3 Integration**: Uses the `web3.py` library to interact with the UOMI testnet via the provided RPC URL.
- **Router Contract**: Interacts with the Uniswap V3-style router at `0x197EEAd5Fe3DB82c4Cd55C5752Bc87AEdE11f230`.
- **Gas Strategy**: Dynamically calculates `maxFeePerGas` and `maxPriorityFeePerGas` based on the latest block's base fee.
- **Swap Logic**:
  - For `UOMI → WUOMI`, uses a direct deposit transaction.
  - For other pairs, approves ERC20 tokens and executes swaps using the `execute` function with Uniswap V3 commands.
- **Randomized Amounts**: Generates random swap amounts (e.g., 0.001–0.004 UOMI for WUOMI swaps, 0.01 for others) to simulate realistic trading.

---

## Contributing

We welcome contributions to improve the UOMI Auto Bot! To contribute:

1. Fork the repository: [https://github.com/sinascorpion/UOMI-Auto-Bot](https://github.com/sinascorpion/UOMI-Auto-Bot).
2. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Make your changes and commit:
   ```bash
   git commit -m "Add your feature description"
   ```
4. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```
5. Open a Pull Request with a detailed description of your changes.

Please follow the [Code of Conduct](CODE_OF_CONDUCT.md) and ensure your code adheres to the project's style guidelines.

---

## Community & Support

Join our community for updates, support, and discussions:
- **Telegram**: [t.me/irdropper](https://t.me/irdropper)
- **GitHub Issues**: Report bugs or suggest features at [GitHub Issues](https://github.com/sinascorpion/UOMI-Auto-Bot/issues).

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- **Creator**: irdropper ([t.me/irdropper](https://t.me/irdropper))
- **UOMI Testnet**: For providing the infrastructure to test this bot.
- **Open-Source Libraries**: Thanks to `web3.py`, `colorama`, and `python-dotenv` for powering this project.

---
