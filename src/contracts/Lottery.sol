// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract Lottery is VRFConsumerBase, Ownable {
	address payable[] public players;
	uint256 public lotteryId;
	uint256 public randomness;
	uint256 public usdEntryFee;
	uint256 public fee;
	bytes32 public keyHash;
	AggregatorV3Interface internal ethUsdPriceFeed;
	mapping(uint256 => address payable) public winnersHistory;
	enum LOTTERY_STATE {
		OPEN,
		CLOSED,
		CALCULATING_WINNER
	}
	LOTTERY_STATE public lottery_state;

	constructor(
		address _priceFeedAddress,
		address _vrfCoordinator,
		address _link,
		uint256 _fee,
		bytes32 _keyHash
	) public VRFConsumerBase(_vrfCoordinator, _link) {
		usdEntryFee = 20 * (10**18);
		ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
		lottery_state = LOTTERY_STATE.CLOSED;
		fee = _fee;
		keyHash = _keyHash;
		lotteryId = 1;
	}

	receive() external payable {
		enter();
	}

	function enter() public payable {
		require(lottery_state == LOTTERY_STATE.OPEN);
		require(msg.value >= getEntranceFee(), "Wrong entrance fee");
		require(msg.sender != owner());
		players.push(payable(msg.sender));
	}

	function getEntranceFee() public view returns (uint256) {
		(, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();
		uint256 adjustedPrice = uint256(price) * 10**10;
		uint256 costToEnter = (usdEntryFee * 10**18) / adjustedPrice;
		return costToEnter;
	}

	function getPlayers() public view returns (address payable[] memory) {
		return players;
	}

	function getBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getWinnerByLottery(uint256 _lotteryId)
		public
		view
		returns (address payable)
	{
		return winnersHistory[_lotteryId];
	}

	function startLottery() public onlyOwner {
		require(
			lottery_state == LOTTERY_STATE.CLOSED,
			"Can't start a new lottery yet!"
		);
		lottery_state = LOTTERY_STATE.OPEN;
	}

	function pickWinner() public onlyOwner returns (bytes32 requestId) {
		require(
			LINK.balanceOf(address(this)) >= fee,
			"Not enough LINK in contract"
		);
		require(
			players.length > 1,
			"Not enought players participating in the lottery"
		);
		lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
		return requestRandomness(keyHash, fee);
	}

	function fulfillRandomness(bytes32 _requestId, uint256 _randomness)
		internal
		override
	{
		randomness = _randomness;
		payWinner();
	}

	function payWinner() public {
		require(
			lottery_state == LOTTERY_STATE.CALCULATING_WINNER,
			"You aren't there yet!"
		);
		address payable winner;
		winner = players[randomness % players.length];
		payable(owner()).transfer((getBalance() * 10) / 100);
		winner.transfer(getBalance());
		players = new address payable[](0);
		lottery_state = LOTTERY_STATE.CLOSED;
		winnersHistory[lotteryId] = winner;
		lotteryId++;
	}
}
