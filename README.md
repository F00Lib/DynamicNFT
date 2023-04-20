# 





#The Chainlink Keepers Network will check our checkUpkeep() function every time a new block is added to the blockchain and simulate the execution of our function off-chain!

That function returns a boolean:

If it's false, that means no automated upkeep is due yet.
If it returns true, that means the interval we set has passed, and an upkeep action is due.
The Keepers Network calls our performUpkeep() function automatically, and run logic on-chain.