// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract TipJar {
    address public owner;

    uint256 public totalTipsReceived;

    // For example, if 1 USD = 0.0005 ETH, then the rate would be 5 * 10^14
    mapping(string => uint256) public conversionRates;

    string[] public supportedCurrencies;

    mapping(address => uint256) public tipperContributions;
    mapping(string => uint256) public tipsPerCurrency;

    constructor() {
        owner = msg.sender;

        // to preload a few values for conversionRates
        addCurrency("USD", 5 * 10**14);
        addCurrency("EUR", 6 * 10**14);
        addCurrency("JPY", 4 * 10**12);
        addCurrency("GBP", 7 * 10**14);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;        
    }

    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
        require(_rateToEth > 0, "Conversion rate must be greater than 0");

        // Check if currency already exists
        bool currencyExists = false;
        for (uint i = 0; i < supportedCurrencies.length; i++) {
            // Uses keccak256 for string comparison (since Solidity doesn't support direct string ==)
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {
                currencyExists = true;
                break;
            }
        }

        if(!currencyExists){
            supportedCurrencies.push(_currencyCode);
        }

        conversionRates[_currencyCode] = _rateToEth;
    }

    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");

        uint256 ethAmount = _amount * conversionRates[_currencyCode];
        return ethAmount;
    }

    function tipInEth() payable public {
        require(msg.value > 0, "Tip amount must be greater than 0");

        tipperContributions[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency["ETH"] += msg.value;
    }

    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        require(_amount > 0, "Amount must be greater than 0");

        uint256 ethAmount = convertToEth(_currencyCode, _amount);
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");

        tipperContributions[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency[_currencyCode] += _amount;
    }

    function withdrawTips() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No tips to withdraw");

        (bool callSuccess, ) = payable(owner).call{value: contractBalance}("");
        require(callSuccess, "Transfer failed");
        totalTipsReceived = 0;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }

    function getSupportedCurrencies() public view returns(string[] memory) {
        return supportedCurrencies;
    }

    function getContractBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getTipperContribution(address _tipper) public view returns(uint256) {
        return tipperContributions[_tipper];
    }

    function getTipsInCurrency(string memory _currencyCode) public view returns(uint256) {
        return tipsPerCurrency[_currencyCode];
    }

    function getConversionRate(string memory _currencyCode) public view returns(uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        return conversionRates[_currencyCode];
    }
}
