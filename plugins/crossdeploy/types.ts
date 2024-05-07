import type { FhevmInstance } from "fhevmjs";

// import { EncryptedERC20 } from "../types";
import type { Signers } from "./signers";

declare module "mocha" {
  // export interface Context {
  //   signers: Signers;
  //   contractAddress: string;
  //   instances: FhevmInstances;
  //   erc20: EncryptedERC20;
  // }
}

export interface FhevmInstances {
  alice: FhevmInstance;
  bob: FhevmInstance;
  carol: FhevmInstance;
  dave: FhevmInstance;
}


/* eslint-disable @typescript-eslint/no-explicit-any */
export interface crossDeployConfig {
    contracts?: string[];
    signer?: any;
    gasLimit?: number;
  }
