// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * @title SimpleLending
 * @dev A basic DeFi lending and borrowing platform
 */
contract SimpleLending {
    // Token balances for each user
    mapping(address => uint256) public depositBalances;
    // Borrowed amounts for each user
    mapping(address => uint256) public borrowBalances;
    // Collateral provided by each user
    mapping(address => uint256) public collateralBalances;
    // Timestamp of last interest accrual
    mapping(address => uint256) public lastInterestAccrualTimestamp;

    // Interest rate in basis points (500 = 5% annual interest rate)
    uint256 public interestRateBasisPoints = 500;    
    // Determines how much you can borrow against your collateral (7500 = 75% loan-to-value (LTV))
    uint256 public collateralFactorBasisPoints = 7500;  

    // Events
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);
    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);

    /// @notice Deposit ETH into the protocol (non-collateral deposit)
    function deposit() external payable {
        require(msg.value > 0, "Must deposit a positive amount");
        depositBalances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Withdraw previously deposited ETH
    function withdraw(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount");
        require(depositBalances[msg.sender] >= amount, "Insufficient balance");
        depositBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    /// @notice Lock ETH as collateral for borrowing
    function depositCollateral() external payable {
        require(msg.value > 0, "Must deposit a positive amount as collateral");
        collateralBalances[msg.sender] += msg.value;
        emit CollateralDeposited(msg.sender, msg.value);
    }

    /// @notice Withdraw unused collateral if collateralization remains safe
    function withdrawCollateral(uint256 amount) external {
        require(amount > 0, "Must withdraw a positive amount");
        require(collateralBalances[msg.sender] >= amount, "Insufficient collateral");

        uint256 borrowedAmount = calculateInterestAccrued(msg.sender);
        uint256 requiredCollateral = (borrowedAmount * 10000) / collateralFactorBasisPoints;
        require(collateralBalances[msg.sender] - amount >= requiredCollateral, "Withdrawal would break collateral ratio");

        collateralBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit CollateralWithdrawn(msg.sender, amount);
    }

    /// @notice Borrow ETH using deposited collateral
    function borrow(uint256 amount) external {
        require(amount > 0, "Must borrow a positive amount");
        require(address(this).balance >= amount, "Not enough liquidity in the pool");

        uint256 maxBorrowAmount = (collateralBalances[msg.sender] * collateralFactorBasisPoints) / 10000;
        uint256 currentDebt = calculateInterestAccrued(msg.sender);
        require(currentDebt + amount <= maxBorrowAmount, "Exceeds allowed borrow amount");

        borrowBalances[msg.sender] = currentDebt + amount;
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;

        payable(msg.sender).transfer(amount);
        emit Borrow(msg.sender, amount);
    }

    /// @notice Repay borrowed ETH with interest
    function repay() external payable {
        require(msg.value > 0, "Must repay a positive amount");

        uint256 currentDebt = calculateInterestAccrued(msg.sender);
        require(currentDebt > 0, "No debt to repay");

        uint256 amountToRepay = msg.value;
        if (amountToRepay > currentDebt) {
            amountToRepay = currentDebt;
            // refund the extra paid amount
            payable(msg.sender).transfer(msg.value - currentDebt); 
        }

        borrowBalances[msg.sender] = currentDebt - amountToRepay;
        lastInterestAccrualTimestamp[msg.sender] = block.timestamp;
        emit Repay(msg.sender, amountToRepay);
    }

    /// @notice Calculates user's debt including accrued interest
    function calculateInterestAccrued(address user) public view returns (uint256) {
        if (borrowBalances[user] == 0) {
            return 0;
        }

        uint256 timeElapsed = block.timestamp - lastInterestAccrualTimestamp[user];
        uint256 interest = (borrowBalances[user] * interestRateBasisPoints * timeElapsed) / (10000 * 365 days);

        return borrowBalances[user] + interest;
    }

    /// @notice Returns max borrowable amount based on current collateral
    function getMaxBorrowAmount(address user) external view returns (uint256) {
        return (collateralBalances[user] * collateralFactorBasisPoints) / 10000;
    }

    /// @notice Returns total ETH liquidity in the protocol
    function getTotalLiquidity() external view returns (uint256) {
        return address(this).balance;
    }
}
