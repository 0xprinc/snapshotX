/* eslint-disable @typescript-eslint/no-explicit-any */
import "@nomicfoundation/hardhat-ethers";
import { expect } from "chai";
import { AbiCoder } from "ethers";
import fhevmjs, { FhevmInstance } from "fhevmjs";
import { extendConfig, subtask, task } from "hardhat/config";
import { NomicLabsHardhatPluginError } from "hardhat/plugins";

import { InitializeCalldataStruct, ProposalStruct, StrategyStruct } from "../../types/contracts/target/Space";
import { crossdeployConfigExtender } from "./config";
import {
  PLUGIN_NAME,
  TASK_VERIFY_CONTRACT,
  TASK_VERIFY_GASLIMIT,
  TASK_VERIFY_SIGNER,
  TASK_VERIFY_SUPPORTED_NETWORKS,
} from "./constants";
// import { ethers } from "hardhat";
import { createInstances } from "./instance";
import { Network, networks } from "./networks";
import { getSigners } from "./signers";
import "./type-extensions";
import { createTransaction } from "./utils";

extendConfig(crossdeployConfigExtender);

task("crossdeploy", "Deploys the contract across all predefined networks").setAction(async (_, hre) => {
  await hre.run(TASK_VERIFY_SUPPORTED_NETWORKS);
  await hre.run(TASK_VERIFY_SIGNER);
  await hre.run(TASK_VERIFY_CONTRACT);
  await hre.run(TASK_VERIFY_GASLIMIT);

  await hre.run("compile");

  if (hre.config.crossdeploy.contracts) {
    const providers: any[] = [];
    const wallets: any[] = [];
    const signers: any[] = [];

    // console.info("Deploying to:", hre.network.name);

    const incoNetwork: Network = networks["inco"] as Network;
    const targetNetwork: Network = networks["baseSepolia"] as Network;
    const nets = [incoNetwork, targetNetwork];

    [0, 1].map((i) => {
      providers[i] = new hre.ethers.JsonRpcProvider(nets[i].rpcUrl);
      wallets[i] = new hre.ethers.Wallet(hre.config.crossdeploy.signer, providers[i]);
      signers[i] = wallets[i].connect(providers[i]);
    });

    // console.log("signers array -> " + signers[0].address);

    const IncoContract = await hre.ethers.getContractFactory(hre.config.crossdeploy.contracts[0]);
    const TargetContract = await hre.ethers.getContractFactory(hre.config.crossdeploy.contracts[1]);
    const Space = await hre.ethers.getContractFactory(hre.config.crossdeploy.contracts[2]);
    const VanillaAuthenticator = await hre.ethers.getContractFactory(hre.config.crossdeploy.contracts[3]);
    const VanillaProposalValidationStrategy = await hre.ethers.getContractFactory(hre.config.crossdeploy.contracts[4]);
    const VanillaVotingStrategy = await hre.ethers.getContractFactory(hre.config.crossdeploy.contracts[5]);
    const VanillaExecutionStrategy = await hre.ethers.getContractFactory(hre.config.crossdeploy.contracts[6]);

    // let defaultSigners = await hre.ethers.getSigners();
    // console.log("default signers -> " + await defaultSigners[0]);
    function delay(ms: number) {
      return new Promise((resolve) => setTimeout(resolve, ms));
    }

    function customArrayify(hexString: string): Uint8Array {
      if (!hexString.startsWith("0x")) {
          throw new Error("Invalid hex string: no 0x prefix");
      }
  
      // Remove the 0x prefix
      hexString = hexString.slice(2);
  
      if (hexString.length % 2 !== 0) {
          throw new Error("Invalid hex string: length must be even");
      }
  
      const byteArray = new Uint8Array(hexString.length / 2);
      for (let i = 0; i < byteArray.length; i++) {
          byteArray[i] = parseInt(hexString.substr(i * 2, 2), 16);
      }
  
      return byteArray;
  }
  

    try {
      console.info("\nDeploying contracts on Inco...");

      const incoContractInstance: any = await IncoContract.connect(signers[0]).deploy();
      const incoContractAddr = await incoContractInstance.getAddress();
      await incoContractInstance.waitForDeployment();
      console.info("IncoContract -> ", incoContractAddr);

      let defaultsigners = await getSigners(hre.ethers);
      // console.log("default signers -> " + defaultsigners.alice.address);
      let fhevmInstance = await createInstances(incoContractAddr, hre.ethers, defaultsigners);
      // console.log("fhevmInstance -> " + fhevmInstance);

      const token = fhevmInstance.alice.getPublicKey(incoContractAddr) || {
        signature: "",
        publicKey: "",
      };

      let defaultSigners = await hre.ethers.getSigners();
      let incoSigner = defaultSigners[0].connect(providers[0]);

      // const message = hre.ethers.utils.arrayify("0xdeadbeef");
      // const message = customArrayify("0xdeadbeef");
      // console.log(message);

      // const signn = await defaultSigners[0].signMessage(message);
      // console.log(signn);
      // console.log(await defaultSigners[0].address);

      // Example message to sign
    // const message = "0xdeadbeaf";


    // const hash = await incoContractInstance.getMessageHash(message);
    // const sig = await signers[0].signMessage(customArrayify(hash))

    // const ethHash = await incoContractInstance.getEthSignedMessageHash(hash)

    // console.log("signer          ", signers[0].address)
    // console.log("recovered signer", await incoContractInstance.recoverSigner(ethHash, sig))

    //   // Convert the message to a byte array using the custom arrayify function
    //   const byteArray = customArrayify(incoContractInstance.getHash(message));

    //   // // Sign the byte array
    //   const signature0 = await signers[0].signMessage(byteArray);
    //   console.log("signer0 is : " + await signers[0].getAddress());

    //   // Output the signature
    //   console.log("Signature0:", signature0);    

    //   // For demonstration purposes: Recover the signer's address
    //   const signerAddress0 = hre.ethers.verifyMessage(byteArray, signature0);
    //   console.log("Signer0 Address:", signerAddress0);

    //   const txn0 = await incoContractInstance.verify_sign(await signers[0].getAddress(), signature0, message);
    //   console.log("Transaction0", txn0);
    //   const txn1 = await incoContractInstance.verify_sign(await signers[0].getAddress(), signature0, byteArray);
    //   console.log("Transaction0", txn1);


      const VanillaExecutionStrategyInstance: any = await VanillaExecutionStrategy.connect(signers[0]).deploy(
        signers[0].address,
        1,
      ); // random address as the address is of no use during testing
      const VanillaExecutionStrategyAddr = await VanillaExecutionStrategyInstance.getAddress();
      await VanillaExecutionStrategyInstance.waitForDeployment();
      console.info("VanillaExecutionStrategy -> ", VanillaExecutionStrategyAddr);

      console.info("\nDeploying contracts on baseSepolia...");

      const targetContractInstance: any = await TargetContract.connect(signers[1]).deploy();
      const targetContractAddr = await targetContractInstance.getAddress();
      await targetContractInstance.waitForDeployment();
      console.info("TargetContract -> ", targetContractAddr);

      const SpaceInstance: any = await Space.connect(signers[1]).deploy();
      const SpaceAddr = await SpaceInstance.getAddress();
      await SpaceInstance.waitForDeployment();
      console.info("Space -> ", SpaceAddr);

      const VanillaAuthenticatorInstance: any = await VanillaAuthenticator.connect(signers[1]).deploy();
      const VanillaAuthenticatorAddr = await VanillaAuthenticatorInstance.getAddress();
      await VanillaAuthenticatorInstance.waitForDeployment();
      console.info("VanillaAuthenticator -> ", VanillaAuthenticatorAddr);

      const VanillaProposalValidationStrategyInstance: any = await VanillaProposalValidationStrategy.connect(
        signers[1],
      ).deploy();
      const VanillaProposalValidationStrategyAddr = await VanillaProposalValidationStrategyInstance.getAddress();
      await VanillaProposalValidationStrategyInstance.waitForDeployment();
      console.info("VanillaProposalValidationStrategy -> ", VanillaProposalValidationStrategyAddr);

      const VanillaVotingStrategyInstance: any = await VanillaVotingStrategy.connect(signers[1]).deploy();
      const VanillaVotingStrategyAddr = await VanillaVotingStrategyInstance.getAddress();
      await VanillaVotingStrategyInstance.waitForDeployment();
      console.info("VanillaVotingStrategy -> ", VanillaVotingStrategyAddr);

      // let defaultSigners = await hre.ethers.getSigners();

      // let defaultsigners = await getSigners(hre.ethers);
      // console.log("default signers -> " + defaultsigners.alice.address);
      // let fhevmInstance = await createInstances(incoContractAddr, hre.ethers, defaultsigners);
      // console.log("fhevmInstance -> " + fhevmInstance);

      {
        console.log("\ninitializing Space contract \n");

        let data0: StrategyStruct = {
          addr: VanillaProposalValidationStrategyAddr,
          params: "0x",
        };

        let data1: StrategyStruct = {
          addr: VanillaVotingStrategyInstance,
          params: "0x",
        };

        let data: InitializeCalldataStruct = {
          owner: signers[1].address, // Example address
          votingDelay: 0,
          minVotingDuration: 0,
          maxVotingDuration: 1000,
          proposalValidationStrategy: data0,
          proposalValidationStrategyMetadataURI: "proposalValidationStrategyMetadataURI",
          daoURI: "SOC Test DAO",
          metadataURI: "SOC Test Space",
          votingStrategies: [data1],
          votingStrategyMetadataURIs: ["votingStrategyMetadataURIs"],
          authenticators: [VanillaAuthenticatorAddr],
          _targetEndpoint: targetContractAddr,
        };
        // console.log("owner before initialize: " + await contractSpace.owner());
        try {
          const txn = await SpaceInstance.initialize(data);
          console.log("Transaction hash:", txn.hash);

          // Wait for 1 confirmation (adjust confirmations as needed)
          await txn.wait(1);
          console.log("Transaction successful!");
        } catch (error) {
          console.error("Transaction failed:", error);
          // Handle the error appropriately (e.g., retry, notify user)
        }
        // console.log("alice address -> " + addressSigner);
        // console.log("owner after initialize: " + await contractSpace.owner());
        // assert(addressSigner == contractSpace.owner());
        console.log("space maxVotingDuration" + (await SpaceInstance.maxVotingDuration()));
      }

      console.log("\n making a proposal \n");

      let data2propose = [signers[1].address, "", [VanillaExecutionStrategyAddr, "0x"], "0x"];

      // console.log(AbiCoder.defaultAbiCoder().encode(["address", "string", "tuple(address, bytes)", "bytes"], data2propose));

      // console.log("old proposal -> " + await contractSpace.proposals(1));
      try {
        const txn = await VanillaAuthenticatorInstance.authenticate(
          SpaceAddr,
          "0xaad83f3b",
          AbiCoder.defaultAbiCoder().encode(["address", "string", "tuple(address, bytes)", "bytes"], data2propose),
        );
        console.log("Transaction hash:", txn.hash);

        // Wait for 1 confirmation (adjust confirmations as needed)
        await txn.wait(1);
        console.log("Transaction2 successful!");
      } catch (error) {
        console.error("Transaction failed:", error);
        // Handle the error appropriately (e.g., retry, notify user)
      }

      console.log("new proposal -> " + (await SpaceInstance.proposals(1)));

      {
        console.log("\n voting \n");

        let defaultSigners = await hre.ethers.getSigners();
        // console.log("default signers -> " + await defaultSigners[0].address);

        const eChoiceAgainst = fhevmInstance.alice.encrypt8(2);
        const eChoiceFor1 = fhevmInstance.alice.encrypt8(1);
        const eChoiceFor2 = fhevmInstance.alice.encrypt8(1);
        const eChoiceAbstain = fhevmInstance.alice.encrypt8(0);

        const signedAbstain = await defaultSigners[0].signMessage(eChoiceAbstain);
        const signedFor1 = await defaultSigners[1].signMessage(eChoiceFor1);
        const signedFor2 = await defaultSigners[2].signMessage(eChoiceFor2);
        const signedAgainst = await defaultSigners[3].signMessage(eChoiceAgainst);

        console.log(signedAbstain);
        
        let data2voteAbstain = [
          await defaultSigners[0].address,
          1,
          eChoiceAgainst,
          [[0, "0x"]],
          "",
          signedAbstain,
        ];

        let data2voteFor1 = [
          await defaultSigners[1].address,
          1,
          eChoiceFor1,
          [[0, "0x"]],
          "",
          signedFor1,
        ];
        let data2voteFor2 = [
          await defaultSigners[2].address,
          1,
          eChoiceFor2,
          [[0, "0x"]],
          "",
          signedFor2,
        ];

        let data2voteAgainst = [
          await defaultSigners[3].address,
          1,
          eChoiceAbstain,
          [[0, "0x"]],
          "",
          signedAgainst,
        ];

        let eChoiceAbstainHash = hre.ethers.keccak256(eChoiceAbstain);
        let eChoiceFor1Hash = hre.ethers.keccak256(eChoiceFor1);
        let eChoiceFor2Hash = hre.ethers.keccak256(eChoiceFor2);
        let eChoiceAgainstHash = hre.ethers.keccak256(eChoiceAgainst);

        console.log("eChoiceAbstainHash - " + eChoiceAbstainHash);
        console.log("eChoiceFor1Hash - " + eChoiceFor1Hash);
        console.log("eChoiceFor2Hash - " + eChoiceFor2Hash);
        console.log("eChoiceAgainstHash - " + eChoiceAgainstHash);

        // console.log("votePower before vote -> " + (await contractSpace.votePower(1, 2)).toString());
        console.log("current block number -> " + (await hre.ethers.provider.getBlockNumber()));
        try {
          const txn = await VanillaAuthenticatorInstance.authenticate(
            SpaceAddr,
            "0xb00fe890",
            AbiCoder.defaultAbiCoder().encode(
              ["address", "uint256", "bytes", "tuple(uint8, bytes)[]", "string", "bytes"],
              data2voteAgainst,
            ),
          );
          console.log("Transaction hash:", txn.hash);

          // Wait for 1 confirmation (adjust confirmations as needed)
          await txn.wait(1);
          console.log("Against successful!");
        } catch (error) {
          console.error("Transaction failed:", error);
          // Handle the error appropriately (e.g., retry, notify user)
        }
        try {
          const txn = await VanillaAuthenticatorInstance.authenticate(
            SpaceAddr,
            "0xb00fe890",
            AbiCoder.defaultAbiCoder().encode(
              ["address", "uint256", "bytes", "tuple(uint8, bytes)[]", "string", "bytes"],
              data2voteFor1,
            ),
          );
          console.log("Transaction hash:", txn.hash);

          // Wait for 1 confirmation (adjust confirmations as needed)
          await txn.wait(1);
          console.log("For1 successful!");
        } catch (error) {
          console.error("Transaction failed:", error);
          // Handle the error appropriately (e.g., retry, notify user)
        }
        try {
          const txn = await VanillaAuthenticatorInstance.authenticate(
            SpaceAddr,
            "0xb00fe890",
            AbiCoder.defaultAbiCoder().encode(
              ["address", "uint256", "bytes", "tuple(uint8, bytes)[]", "string", "bytes"],
              data2voteFor2,
            ),
          );
          console.log("Transaction hash:", txn.hash);

          // Wait for 1 confirmation (adjust confirmations as needed)
          await txn.wait(1);
          console.log("For2 successful!");
        } catch (error) {
          console.error("Transaction failed:", error);
          // Handle the error appropriately (e.g., retry, notify user)
        }
        try {
          const txn = await VanillaAuthenticatorInstance.authenticate(
            SpaceAddr,
            "0xb00fe890",
            AbiCoder.defaultAbiCoder().encode(
              ["address", "uint256", "bytes", "tuple(uint8, bytes)[]", "string", "bytes"],
              data2voteAbstain,
            ),
          );
          console.log("Transaction hash:", txn.hash);

          // Wait for 1 confirmation (adjust confirmations as needed)
          await txn.wait(1);
          console.log("Abstain successful!");
        } catch (error) {
          console.error("Transaction failed:", error);
          // Handle the error appropriately (e.g., retry, notify user)
        }

        console.log("\n\n checking the vote mapping in incoEndpoint \n");

        console.log("waiting for 56 seconds...");
        await delay(56000);

        console.log("checking only for data2voteAbstainHash");

        let For_votes = (await incoContractInstance.getVotePower(1, 1, token.publicKey)).toString();
        let Abstain_votes = (await incoContractInstance.getVotePower(1, 2, token.publicKey)).toString();
        let Against_votes = (await incoContractInstance.getVotePower(1, 0, token.publicKey)).toString();

        console.log(For_votes);
        console.log(Abstain_votes);
        console.log(Against_votes);

        console.log("For votes -> " + fhevmInstance.alice.decrypt(incoContractAddr, For_votes));
        console.log("Abstain votes -> " + fhevmInstance.alice.decrypt(incoContractAddr, Abstain_votes));
        console.log("Against votes -> " + fhevmInstance.alice.decrypt(incoContractAddr, Against_votes));

        console.log("\n\n\n\n execution \n");
        let executionPayload = "0x";
        try {
          const txn = await SpaceInstance.execute(1, executionPayload);
          console.log("Transaction hash:", txn.hash);

          // Wait for 1 confirmation (adjust confirmations as needed)
          await txn.wait(1);
          console.log("execution successful!");
        } catch (error) {
          console.error("Transaction failed:", error);
          // Handle the error appropriately (e.g., retry, notify user)
        }

        console.log("waiting 30 seconds till the execution is done...");
        await delay(30000);

        console.log("is executed - " + (await incoContractInstance.getIsExecuted(1)));
      }
    } catch (err) {
      console.error(err);
    }
  }
});

subtask(TASK_VERIFY_SUPPORTED_NETWORKS).setAction(async (_, hre) => {
  if (!Object.keys(networks).includes(hre.network.name) || hre.network.name === "inco") {
    throw new NomicLabsHardhatPluginError(
      PLUGIN_NAME,
      `The network you are trying to deploy to is not supported by this plugin.
      The currently supported networks are ${Object.keys(networks).filter((n) => n !== "inco")}.`,
    );
  }
});

subtask(TASK_VERIFY_SIGNER).setAction(async (_, hre) => {
  if (!hre.config.crossdeploy.signer || hre.config.crossdeploy.signer === "") {
    throw new NomicLabsHardhatPluginError(
      PLUGIN_NAME,
      `Please provide a signer private key. We recommend using Hardhat configuration variables.
      See https://hardhat.org/hardhat-runner/docs/guides/configuration-variables.
      E.g.: { [...], crossdeploy: { signer: vars.get("PRIVATE_KEY", "") }, [...] }.`,
    );
  }
});

subtask(TASK_VERIFY_CONTRACT).setAction(async (_, hre) => {
  if (!hre.config.crossdeploy.contracts) {
    throw new NomicLabsHardhatPluginError(
      PLUGIN_NAME,
      `Please specify a pair of contract names to be deployed.
      E.g.: { [...], crossdeploy: { contracts: ["WERC20", "ERC20"] }, [...] }.`,
    );
  }
});

subtask(TASK_VERIFY_GASLIMIT).setAction(async (_, hre) => {
  if (hre.config.crossdeploy.gasLimit && hre.config.crossdeploy.gasLimit > 15 * 10 ** 6) {
    throw new NomicLabsHardhatPluginError(
      PLUGIN_NAME,
      `Please specify a lower gasLimit. Each block has currently 
      a target size of 15 million gas.`,
    );
  }
});
