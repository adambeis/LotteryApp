import { writable } from "svelte/store";
import { getContract, getContractWithSigner } from "./contract.js";
import { linkAddress, linkAbi } from "../constants.js";

export const players = writable([]);

export const linkContract = writable(null);
export const linkContractSigner = writable(null);

export const linkBalance = writable(0);

export const setLinkContract = async () => {
  const contract = getContract(linkAddress, linkAbi);
  linkContract.set(contract);
};

export const setLinkContractWithSigner = async () => {
  const contractWithSigner = await getContractWithSigner(linkAddress, linkAbi);
  linkContractSigner.set(contractWithSigner);
};
