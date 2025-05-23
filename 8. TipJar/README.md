# TipJar Contract

Let’s say you’ve been building on-chain tools — maybe a piggy bank contract, maybe a shared expense tracker like Splitwise.

Now imagine this...

You just finished a live demo of your dApp, someone loved it, and they say:

"Hey, I’d love to tip you for this. But I don’t have ETH — I can only pay in USD."

How do we make that work?

Boom. That's the moment where today’s smart contract comes in.

Today, we’re building a smart contract called TipJar that lets people send you tips:

- In ETH directly, or
- In other currencies — like USD, EUR, or JPY — and we’ll convert that to ETH

**💻 Here is the complete code**

<a href="https://github.com/ArunRawat404/30-Days-Solidity/blob/master/8.%20TipJar/TipJar.sol" style="font-size: 20px; text-decoration: none;">
    🧑‍💻 TipJar Code Github
</a>

---

This is your first look at handling real-world currencies inside smart contracts, and it comes with some very important lessons:

- How to deal with ETH and wei
- Why Solidity doesn’t support decimals
- How to do conversion math safely
- And how to ensure users send the correct amount of ETH

Let’s start with the foundation: how do you convert one currency to another in Solidity?

---

### What Data Do We Need for Our TipJar?

Before we dive into the logic, let’s break down the kind of information our contract needs to manage in our TipJar

```
address public owner;
```

This keeps track of who deployed the contract and who controls administrative actions (like adding currencies or withdrawing tips).

```
mapping(string => uint256) public conversionRates;
```

This mapping stores the exchange rate from a currency code (like "USD") to ETH —

```
string[] public supportedCurrencies;
```

This dynamic array helps us keep track of all the currency codes we’ve added so we can loop over them later.

```
uint256 public totalTipsReceived;
```

This variable tells us how much ETH (in wei) the contract has collected overall.

```
mapping(address => uint256) public tipperContributions;
```

This stores how much ETH each address has sent in tips.

```
mapping(string => uint256) public tipsPerCurrency;
```

This tracks how much was tipped in each currency. So if someone sends the equivalent of 2000 USD, we store "2000" under the "USD" entry.

### Modifiers — The Gatekeepers

So, as always, we will create a modifier that will ensure that only the owner of the contract can call certain functions

```
modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can perform this action");
    _;
}
```

Just to make sure that nobody tries anything funny with our tipjar

###

### Setting Up Currency Conversion — `addCurrency()`

Alright, before we get into the actual tipping part, there’s one big question we need to answer:

**How does our contract know how much ETH a dollar is worth?**

The truth is… it doesn’t. Not automatically.

Smart contracts live on the blockchain they don’t have access to real-world data like live exchange rates. So if someone wants to tip in USD, we have to tell the contract:

> “Here’s what 1 USD is worth in ETH.”

Later, we’ll learn how to fetch real-time data using things like oracles (like Chainlink). But for now, we’ll do it manually, using a function called `addCurrency()`.

Here’s how it works:

---

### The Code

```solidity

function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
    require(_rateToEth > 0, "Conversion rate must be greater than 0");

    // Check if currency already exists
    bool currencyExists = false;
    for (uint i = 0; i < supportedCurrencies.length; i++) {
        if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {
            currencyExists = true;
            break;
        }
    }

    // Add to the list if it's new
    if (!currencyExists) {
        supportedCurrencies.push(_currencyCode);
    }

    // Set the conversion rate
    conversionRates[_currencyCode] = _rateToEth;
}

```

---

### What This Function Actually Does

Let’s break it down piece by piece.

### Step 1: Who Can Call This?

The function is marked with `onlyOwner`, which means **only the person who deployed the contract** can add or update currency rates.

This is important — you don’t want just anyone to set “1 USD = 10 ETH” by mistake (or on purpose!).

## Step 2: Validate the Rate

```solidity

require(_rateToEth > 0, "Conversion rate must be greater than 0");

```

We check that the rate isn’t zero or negative — just a quick safety check.

---

### Variable to check if currency exists

Next we create a boolean variable to check if the currency exists

```json
    bool currencyExists = false;
```

### Step 3: Avoid Adding the Same Currency Twice

Now,Before we add a new currency, we want to make sure we’re not accidentally adding a duplicate. To do that, we loop through the list of currencies we’ve already added and compare each one with the new currency:

```solidity

for (uint i = 0; i < supportedCurrencies.length; i++) {
    if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {
        currencyExists = true;
        break;
    }
}

```

Now, here’s the important part — in Solidity, **you can’t directly compare two strings using `==`** like you would in JavaScript or Python. That’s because strings in Solidity are complex types stored in memory, not primitive values.

So how do we compare them?

We **convert them to bytes** using `bytes(...)`, and then pass those bytes into `keccak256()` — Solidity’s built-in cryptographic hash function. This gives us a unique fingerprint for each string, and we compare those instead.

If the hashes match, that means the strings are equal, and we know the currency already exists. So we set `currencyExists = true` and break out of the loop.

This approach is a safe and reliable way to compare strings in Solidity — and a great trick to remember whenever you're working with dynamic text values on-chain.

### Step 4: Store the Currency and Rate

If it’s a new currency, i.e the currencyExists variable remains false we add the currency to the supportedCurrencies list:

```solidity
    if (!currencyExists) {
        supportedCurrencies.push(_currencyCode);
    }

```

And either way, we update or set the conversion rate:

```solidity

conversionRates[_currencyCode] = _rateToEth;

```

This ensures that:

- New currencies get added
- Existing ones can have their rates updated safely

---

### The Constructor

Once we have our `addCurrency()` function, we can use it in our constructor to actually preload a few values and store the contract owner address

```solidity
constructor() {
    owner = msg.sender;

    addCurrency("USD", 5 * 10**14);
    addCurrency("EUR", 6 * 10**14);
    addCurrency("JPY", 4 * 10**12);
    addCurrency("GBP", 7 * 10**14);
}

```

---

###

### ETH and Wei — The Precision Layer

Alright, let’s pause for a second.

You’ve probably noticed all these `10**14` and `10**18` values flying around and thought — "Wait, why all the zeros?"

Well, welcome to the world of **wei** — the smallest unit of ETH.
I mean, we already mentioned it above, but here is a bit more detailed explanation

So, Solidity doesn’t work with decimals. No floats, no fractions. So when you’re dealing with Ether in smart contracts, you're not dealing with `0.5 ETH` or `1.25 ETH`.

You're actually dealing with **wei**.

And here’s the conversion:

```

1 ETH = 1,000,000,000,000,000,000 wei = 10^18 wei
```

Think of it like this:

- ETH is the "dollar" or “Rupee”
- Wei is the "cent" or “paisa” — but with 18 decimal places instead of 2

So if someone tips **0.05 ETH**, that’s actually:

```

0.05 * 10^18 = 5 * 10^16 wei

```

And that’s the value that gets passed around in the contract.

Why does this matter?

Because when we convert from another currency — let’s say 2000 USD — we calculate its value **in wei**, not in ETH. That’s why the conversion rates are also scaled by `10^18`, so the math works out cleanly and accurately.

We’re doing everything in whole numbers, just at a really, really small scale.

It’s kind of like measuring things in millimeters instead of meters — it lets us be precise without worrying about decimal math, which Solidity doesn't handle.

So whenever you see:

```solidity

5 * 10**14

```

That just means:

“Hey, this is `0.0005 ETH`, but scaled up to fit Solidity’s no-decimal world.”

And when you want to display that to a user in ETH (on your frontend), you just divide it back down:

```

let readableEth = rawWei / 10**18;
```

Simple. Accurate. No rounding errors.

---

### Converting to ETH (in wei)

Alright, let’s get to the core of our logic — converting a foreign currency amount into ETH.

Now remember: we’re doing everything in **wei**, the smallest unit of ETH. So the result won’t be a human-readable `0.5` or `1.2 ETH` — it’ll be a large integer that represents the equivalent value in wei.

Here’s the function that handles this:

```solidity

function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
    require(conversionRates[_currencyCode] > 0, "Currency not supported");

    uint256 ethAmount = _amount * conversionRates[_currencyCode];
    return ethAmount;
}

```

Let’s walk through an example.

Let’s say someone wants to tip **2000 USD**.

And earlier, we defined the conversion rate like this:

```solidity

addCurrency("USD", 5 * 10**14); // 1 USD = 0.0005 ETH

```

Now, this rate is already scaled up to work in wei. So we multiply:

```

ethAmount = 2000 * 5 * 10^14 = 1 * 10^18 wei

```

And that gives us exactly **1 ETH** — but in **wei**, the format Solidity understands.

So the `convertToEth` function takes a currency code and an amount, does the math, and returns the equivalent ETH value (in wei).

Important: If you want to display this value in your frontend as 1.0 ETH, you’ll need to divide the output of the function by 10^18. But make sure to do that on the frontend — not inside the Solidity contrac

Why?

Because Solidity only works with whole numbers. If you try:

```solidity
uint256 eth = ethAmount / 10**18;
```

You’ll lose all the decimals, and anything less than 1 ETH would just round down to 0 — which we definitely don’t want.

So just remember: all currency math stays in wei on-chain. Human-readable ETH comes from formatting off-chain.

---

### Sending a Tip in ETH

Let’s start with the simplest way someone can send a tip: **directly in ETH**.

Here’s the function:

```solidity

function tipInEth() public payable {
    require(msg.value > 0, "Tip amount must be greater than 0");

    tipperContributions[msg.sender] += msg.value;
    totalTipsReceived += msg.value;
    tipsPerCurrency["ETH"] += msg.value;
}

```

Let’s break it down step by step:

- `msg.value` is the amount of ETH (in wei) sent along with the function call.
- The `payable` keyword allows the function to actually receive ETH. Without it, the function would reject any Ether sent.
- We first check that `msg.value > 0`. This prevents users from sending a 0 ETH tip — because, well, what’s the point of that?

If the check passes, the contract does three things:

1. It records how much this specific user has contributed so far in `tipperContributions`.
2. It updates `totalTipsReceived`, a running total of all ETH the contract has ever received.
3. It adds the tip to the `"ETH"` bucket in `tipsPerCurrency`, so we can track ETH tips separately from USD or other currencies.

This function is super straightforward — no currency conversion, no matching values — just pure ETH sent from the user’s wallet to the contract.

---

### Tipping in a Foreign Currency

Alright, now let’s get into the real heart of this contract — tipping in something **other than ETH**.

Here’s the function that makes it happen:

```solidity

function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
    require(conversionRates[_currencyCode] > 0, "Currency not supported");
    require(_amount > 0, "Amount must be greater than 0");

    uint256 ethAmount = convertToEth(_currencyCode, _amount);
    require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");

    tipperContributions[msg.sender] += msg.value;
    totalTipsReceived += msg.value;
    tipsPerCurrency[_currencyCode] += _amount;
}

```

Let’s break this down with an example:

Imagine a user wants to tip **2000 USD**.

- `_amount = 2000`
- The conversion rate for USD is `5 * 10^14 wei` (i.e., 1 USD = 0.0005 ETH)
- So, the required ETH in wei would be:

```

ethAmount = 2000 * 5 * 10^14 = 1 * 10^18 wei
```

Which is exactly **1 ETH** in Solidity terms.

Here’s the catch:

The function checks whether the `msg.value` (i.e., the actual ETH sent with the transaction) matches the expected amount.

If it doesn’t — if the user sends even a little too much or too little — the transaction fails.

This protects the contract from mistakes and ensures the ETH received is exactly what we expect based on the currency input.

It’s a really neat way to simulate multi-currency tipping — even though under the hood, everything still runs on ETH.

---

### Withdrawing Tips

Once tips have been collected, the owner might want to withdraw them from the contract. That’s what this function is for:

```solidity

function withdrawTips() public onlyOwner {
    uint256 contractBalance = address(this).balance;
    require(contractBalance > 0, "No tips to withdraw");

    (bool success, ) = payable(owner).call{value: contractBalance}("");
    require(success, "Transfer failed");

    totalTipsReceived = 0;
}

```

Let’s walk through what’s happening her

1. **Check the balance:**

   First, we get the contract’s current ETH balance using `address(this).balance`. If there’s nothing to withdraw, the function stops immediately.

2. **Send the funds:**

   We use this line to actually send the ETH:

   ```solidity
   (bool success, ) = payable(owner).call{value: contractBalance}("");

   ```

   This sends the entire balance to the `owner` of the contract.

   You might wonder — why not just use `.transfer()`?

   Well, `.call{value: ...}` is considered the safest and most flexible way to send ETH:

   - It works even if the recipient is a smart contract (some contracts reject `.transfer()` due to gas limitations)
   - It returns a `success` flag so we can check if the transfer worked
   - It avoids some of the limitations and risks associated with older methods

3. **Reset the count:**

   Finally, we reset `totalTipsReceived` to 0, just for bookkeeping. (Note: this doesn’t affect the actual ETH balance — that’s already been sent.)

This is a simple but secure withdrawal flow that follows Solidity best practices. It ensures only the owner can withdraw tips, prevents empty withdrawals, and safely handles ETH transfers without assuming anything about the recipient.

---

### Transferring Ownership

Sometimes, the person who deployed the contract might want to hand over control to someone else — maybe you're passing the torch, maybe it's part of a team change, or you're simply moving accounts.

That’s exactly what this function allows:

```solidity

function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0), "Invalid address");
    owner = _newOwner;
}

```

Let’s break it down:

1. **Restricted access:**

   This function can only be called by the current `owner`, thanks to the `onlyOwner` modifier. That prevents just anyone from assigning ownership.

2. **Valid new address:**

   We make sure the new owner’s address isn’t the zero address (`0x000...000`). That would effectively make the contract ownerless — and we probably don’t want that.

3. **Update ownership:**

   If everything checks out, we update the `owner` state variable with the new address. From this point forward, the new address has full control — including the ability to withdraw tips or update currency rates.

It’s a simple but powerful function that adds flexibility and long-term maintainability to the contract.

###

### Utility Functions — Getting Info from the Contract

So far, we’ve talked a lot about how people can **send** tips. But what about checking on things? How do we read the data stored in the contract?

That’s where utility functions come in — these don’t modify the blockchain; they just return useful info.

Let’s walk through each one:

---

### `getSupportedCurrencies()`

```solidity

function getSupportedCurrencies() public view returns (string[] memory) {
    return supportedCurrencies;
}

```

This returns the full list of currency codes (like "USD", "EUR", etc.) that the owner has added to the contract.

It’s helpful when you want to loop through the currencies , or just display what’s currently supported.

---

### `getContractBalance()`

```solidity

function getContractBalance() public view returns (uint256) {
    return address(this).balance;
}

```

This tells you how much ETH the contract currently holds.

It includes:

- All tips that have been sent
- Any ETH that hasn't been withdrawn yet

Note: the number is returned in **wei**, not ETH — so remember to divide by `10^18` if you want to display it in ETH.

---

### `getTipperContribution(address _tipper)`

```solidity
function getTipperContribution(address _tipper) public view returns (uint256) {
    return tipperContributions[_tipper];
}

```

Want to know how much a specific person has tipped?

Pass in their address, and this function will return their total contribution (in wei). Great for building leaderboards, thank-you pages, or tracking individual supporters.

---

### `getTipsInCurrency(string memory _currencyCode)`

```solidity

function getTipsInCurrency(string memory _currencyCode) public view returns (uint256) {
    return tipsPerCurrency[_currencyCode];
}

```

This one tells you the total amount that has been tipped **in a specific currency** — like 2000 USD or 15000 JPY.

Note: this amount is in the foreign currency unit the user entered — not converted to ETH. It's useful for showing original tip intent, even if the actual ETH received was calculated via a rate.

---

### `getConversionRate(string memory _currencyCode)`

```solidity

function getConversionRate(string memory _currencyCode) public view returns (uint256) {
    require(conversionRates[_currencyCode] > 0, "Currency not supported");
    return conversionRates[_currencyCode];
}

```

Need to check how much ETH (in wei) 1 unit of a currency is worth?

Use this function. Just provide the currency code (like `"USD"`), and you’ll get the current conversion rate stored in the contract.

For example, if it returns `5 * 10^14`, that means:

```
1 USD = 0.0005 ETH

```

All of these utility functions are **read-only**, marked as `view`, and can be called without spending gas — perfect for retrieving data in a safe and efficient way.

---

###

### Final Thoughts

With this TipJar contract, you now know how to:

- Handle ETH and foreign currency tipping
- Use scaled conversion math without decimals
- Work safely with wei
- Protect your withdrawals using `.call()`
