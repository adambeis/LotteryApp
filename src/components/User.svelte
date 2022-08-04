<script>
  import { onMount } from "svelte";
  import { ethers } from "ethers";
  import {
    lotteryContract,
    lotteryContractSigner,
    lotteryState,
    setLotteryState,
    getAccount,
  } from "../store/contract.js";
  import { notifications } from "../store/notifications.js";

  let entrancePrice = 0;
  let lastWinner = "";

  const getEntrancePrice = async () => {
    if ($lotteryContract != null) {
      let entrancePriceBN = await $lotteryContract.getEntranceFee();
      entrancePrice =
        parseFloat(ethers.utils.formatUnits(entrancePriceBN).slice(0, 6)) +
        0.0001;
    }
  };

  const getLastWinner = async () => {
    let lotteryId = await $lotteryContract.lotteryId();
    if (lotteryId > 1) {
      lastWinner = await $lotteryContract.getWinnerByLottery(lotteryId - 1);
      lastWinner = await getAccount(lastWinner);
    }
  };

  const enterLottery = async () => {
    if ($lotteryState == 0) {
      await getEntrancePrice();
      let priceEntranceStr = entrancePrice.toString();
      const options = { value: ethers.utils.parseEther(priceEntranceStr) };

      try {
        const transaction = await $lotteryContractSigner.enter(options);
        const receipt = await transaction.wait();
        notifications.info("You are participating in the lottery", 5000);
      } catch (error) {
        notifications.danger(error.error.message, 5000);
      }
    } else {
      notifications.info("Cannot participate at this time", 5000);
    }
  };

  onMount(async () => {
    await getEntrancePrice();
    await setLotteryState();
    await getLastWinner();
  });
</script>

<div class="p-4">
  <div class="m-4">
    <p class="text-xl">Enter Lottery</p>
    <div class="flex mt-2">
      <div class="basis-1/4" />

      <div class="basis-1/2 h-12">
        <button
          on:click={enterLottery}
          class="w-32 bg-blue-500 hover:bg-blue-400 text-white font-bold py-2 px-4 border-b-4 border-blue-700 hover:border-blue-500 rounded active:translate-y-1 active:border-b-0"
        >
          Enter
        </button>
      </div>

      <div class="basis-1/4" />
    </div>
  </div>
  <div class=" flex-row m-4 h-12 text-center">
    <p class="text-center text-xl">Last winner:</p>
    <p class="text-center mt-1">{lastWinner}</p>
  </div>
</div>
