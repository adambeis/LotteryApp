<script>
  import { onMount } from "svelte";
  import Toast from "./components/Toast.svelte";
  import Admin from "./components/Admin.svelte";
  import User from "./components/User.svelte";
  import {
    setLotteryContract,
    setLotteryContractWithSigner,
    setAccount,
    setAdmin,
    admin,
    account,
    provider,
  } from "./store/contract.js";
  import lotterySvg from "./assets/lottery.svg";

  import { ethers } from "ethers";

  const connectWallet = async () => {
    $provider = new ethers.providers.Web3Provider(window.ethereum, "any");
    await $provider.send("eth_requestAccounts", []);
  };

  const changedAccount = async () => {
    await setAccount();
    await setAdmin();
  };

  onMount(async () => {
    await connectWallet();
    const { provider: ethereum } = $provider;
    ethereum.on("accountsChanged", changedAccount);
    await setLotteryContract();
    await setLotteryContractWithSigner();
    await setAccount();
    await setAdmin();
  });
</script>

<Toast />
<main class="flex-nowrap">
  <div class="flex flex-row bg-gray-900 p-1">
    <div class="basis-1/4" />
    <div class="basis-1/2 w-full h-50 text-center">
      <p class="text-[#cc2936] font-bold text-xl">Lottery</p>
      <img class="m-auto h-14" src={lotterySvg} alt="Lottery" />
    </div>
    <div class="basis-1/4 flex text-center">
      <p class="w-full self-center">{$account}</p>
    </div>
  </div>
  <div class="">
    {#if $admin}
      <Admin />
    {:else}
      <User />
    {/if}
  </div>
</main>

<style>
  :root {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen,
      Ubuntu, Cantarell, "Open Sans", "Helvetica Neue", sans-serif;
    background-color: #242038;
    color: white;
  }

  main {
    text-align: center;

    margin: 0 auto;
  }

  @media (min-width: 480px) {
  }
</style>
