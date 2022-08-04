# Lottery App

Lottery App that picks a random winner between all participants. The random number is generated fully on-chain

## How to use

- Get some ETH: https://rinkebyfaucet.com/
- Get some LINK: https://faucets.chain.link/
- Deploy the smart contract
- Clone this repo
- Go to the terminal
- **cd LotteryApp**
- **npm install**
- **npm run dev**
- open browser at: **http://localhost:3000/**

## Deploy info(rinkeby)

Price Feed Address: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
VrfCoordinator: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
Link Token: 0x01BE23585060835E02B77ef475b0Cc51aA1e0709
Link Fee: 0.1
Key Hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311

## Admin

- Admin can change lottery state
- Admin can send Link to the contract(needed for the RNG)
- Admin triggers the function that selects the winner

## User

- Users can participate on the lottery
