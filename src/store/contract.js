import { get, writable } from "svelte/store";
import { ethers } from "ethers";
import { lotteryAddress, lotteryAbi } from "../constants.js";

export const lotteryContract = writable(null);
export const lotteryContractSigner = writable(null);
export const admin = writable(false);
export const account = writable("");
export const lotteryState = writable(null);
export const provider = writable(null);

export const connect = async () => {
  await setAccount();
};

export const getProvider = () => {
  return get(provider);
};

const getSigner = () => {
  let _provider = get(provider);
  let signer = _provider.getSigner();
  return signer;
};

export const getContract = (address, abi) => {
  let _provider = get(provider);
  const contract = new ethers.Contract(address, abi, _provider);
  return contract;
};

export const setLotteryContract = async () => {
  const contract = getContract(lotteryAddress, lotteryAbi);
  lotteryContract.set(contract);
};

export const setLotteryContractWithSigner = async () => {
  const contractWithSigner = await getContractWithSigner(
    lotteryAddress,
    lotteryAbi
  );
  lotteryContractSigner.set(contractWithSigner);
};

export const getContractWithSigner = async (address, abi) => {
  const contract = getContract(address, abi);
  let signer = getSigner();
  return contract.connect(signer);
};

export const getAccount = (acc) => {
  return acc.slice(0, 4) + " ... " + acc.slice(acc.length - 4, acc.length);
};

export const setAccount = async () => {
  const signerObject = getProvider().getSigner();
  const signerAddress = await signerObject.getAddress();
  account.set(getAccount(signerAddress.toString()));
};

export const setAdmin = async () => {
  const contract = get(lotteryContractSigner);
  const owner = await contract.owner();
  const signerObject = getProvider().getSigner();
  const signerAddress = await signerObject.getAddress();
  let isAdmin = false;
  if (owner == signerAddress) isAdmin = true;
  admin.set(isAdmin);
};

export const setLotteryState = async () => {
  const contract = getContract(lotteryAddress, lotteryAbi);
  let state = await contract.lottery_state();
  lotteryState.set(state);
};
