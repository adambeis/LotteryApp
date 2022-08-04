<script>
  import { onMount } from "svelte";
  import { ethers } from "ethers";
  import Loading from "../lib/Loading.svelte";
  import {
    lotteryContract,
    lotteryContractSigner,
    getAccount,
    lotteryState,
    setLotteryState,
  } from "../store/contract.js";
  import {
    players,
    linkContract,
    linkContractSigner,
    linkBalance,
    setLinkContract,
    setLinkContractWithSigner,
  } from "../store/admin.js";
  import { lotteryAddress } from "../constants.js";
  import { notifications } from "../store/notifications.js";

  $: linkBalanceNormal = ethers.utils.formatUnits($linkBalance);
  $: contractState = getContractState($lotteryState);

  let lastWinner = "";

  const getContractState = (state) => {
    switch (state) {
      case 0:
        return "Open";

      case 1:
        return "Close";

      case 2:
        return "Calculating Winner";
      default:
        break;
    }
  };

  const getPlayers = async () => {
    $players = await $lotteryContract.getPlayers();
  };

  const getLinkBalance = async () => {
    $linkBalance = await $linkContract.balanceOf(lotteryAddress);
  };

  const getLastWinner = async () => {
    let lotteryId = await $lotteryContract.lotteryId();
    if (lotteryId > 1) {
      lastWinner = await $lotteryContract.getWinnerByLottery(lotteryId - 1);
      lastWinner = await getAccount(lastWinner);
    }
  };

  const sendLink = async () => {
    const linkAmount = ethers.utils.parseUnits("0.1", 18);
    let tx = await $linkContractSigner.transfer(lotteryAddress, linkAmount);
    const receipt = await tx.wait();
    await getLinkBalance();
  };

  const startLotteryState = async () => {
    if ($lotteryState == 1) {
      const transaction = await $lotteryContractSigner.startLottery();
      const receipt = await transaction.wait();
      await setLotteryState();
    } else if ($lotteryState == 0) {
      notifications.info("The state was already started", 5000);
    } else {
      notifications.info("A winner is being picked", 5000);
    }
  };

  const pickWinner = async () => {
    await getPlayers();
    if ($linkBalance > 0) {
      if ($players.length > 1) {
        const transaction = await $lotteryContractSigner.pickWinner();
        const receipt = await transaction.wait();
        await setLotteryState();
        await getLinkBalance();
        notifications.info("This action may take a while", 6000);
      } else {
        notifications.info("Not enough players to start", 5000);
      }
    } else {
      notifications.info("Link is needed to cover fees", 5000);
    }
  };

  onMount(async () => {
    await setLinkContract();
    await setLinkContractWithSigner();
    await getPlayers();
    await setLotteryState();
    await getLinkBalance();
    await getLastWinner();
  });
</script>

<div class="flex">
  <div class="basis-1/4" />

  <div class="basis-1/2 sm:px-5 px-20">
    <div class="flex flex-row m-4 h-12 items-center">
      <p class="basis-1/3 text-right text-xl">Lottery state:</p>
      <div class="basis-1/3 text-center">
        {#if $lotteryState == null}
          <Loading />
        {:else}
          <p>{contractState}</p>
        {/if}
      </div>
      <div class="basis-1/3 ">
        <button
          on:click={startLotteryState}
          class="w-32 bg-blue-500 hover:bg-blue-400 text-white font-bold py-2 px-4 border-b-4 border-blue-700 hover:border-blue-500 rounded active:translate-y-1 active:border-b-0"
        >
          Start State
        </button>
      </div>
    </div>

    <div class="flex flex-row m-4 h-12 items-center">
      <p class="basis-1/3 text-right text-xl">Link Balance:</p>
      <p class="basis-1/3">{linkBalanceNormal}</p>
      <div class="basis-1/3">
        <button
          on:click={sendLink}
          class="w-32 bg-blue-500 hover:bg-blue-400 text-white font-bold py-2 px-4 border-b-4 border-blue-700 hover:border-blue-500 rounded active:translate-y-1 active:border-b-0"
        >
          Send Link
        </button>
      </div>
    </div>

    <div class="flex flex-row m-4 h-12 items-center">
      <p class="basis-1/3 text-right text-xl">Players: {$players.length}</p>
      <div class="basis-1/3">
        {#each $players as player}
          {#await getAccount(player) then value}
            <p>{value}</p>
          {/await}
        {/each}
      </div>
      <div class="basis-1/3">
        <button
          on:click={pickWinner}
          class="w-32 bg-blue-500 hover:bg-blue-400 text-white font-bold py-2 px-4 border-b-4 border-blue-700 hover:border-blue-500 rounded active:translate-y-1 active:border-b-0"
        >
          Get Winner
        </button>
      </div>
    </div>

    <div class="flex flex-row m-4 h-12 items-center">
      <p class="basis-1/3 text-right text-xl">Last winner:</p>
      <p class="basis-1/3">{lastWinner}</p>
      <div class="basis-1/3" />
    </div>
  </div>

  <div class="basis-1/4" />
</div>
