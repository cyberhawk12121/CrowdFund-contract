## CrowdFunding Dapp

### How to run
To the run the contract make sure you have:
1.  [Metamask](https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn?hl=en) installed in the browser
2.  [NodeJS](https://nodejs.org/en/download/) installed locally

Now run the command `npm install`. It'll install all the dependecies like truffle and it's helping libraries. After this there are few things that needs to be done:
1.  Create an account on [Infura](https://infura.io/)
2.  Start a project and get the endpoint to connect to Kovan testnet.
3.  Setup a Mnemonic as well that will get the account

> Make sure to have some Ethers on your Kovan testnet account to carry out the transactions

### Truffle Commands (On console)
1.  truffle migrate --network kovan
This will deploy the contract on the network
