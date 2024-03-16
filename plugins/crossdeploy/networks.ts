export type Network = {
    rpcUrl: string;
    chainId: number;
    explorer: string;
    interchainAccountRouterAddress: string;
    interchainExecuteRouterAddress: string;
};
  
// List of supported networks
export const networks = {
    inco: {
      rpcUrl: "https://testnet.inco.org",
      chainId: 9090,
      explorer: "https://explorer.testnet.inco.org/",
      interchainAccountRouterAddress: "0x86A5337E029B32BA1d34e89Ff9A96667583C7b4B",
      interchainExecuteRouterAddress: "0x015b8be6946ee593Ee2230E56221Db9cEE22aC20"
    } as Network,
    baseSepolia: {
      rpcUrl: "https://sepolia.base.org",
      chainId: 84532,
      explorer: "https://sepolia.basescan.org/",
      interchainAccountRouterAddress: "0x7867F458DBF31D9D9F7B1B758ea3847C3f7345fd",
      interchainExecuteRouterAddress: "0xAC4fAb4c9E99606d255EB87cFAfAd4587801f743"
    } as Network,
    edgeless: {
      rpcUrl: "https://edgeless-testnet.rpc.caldera.xyz/http",
      chainId: 202,
      explorer: "https://edgeless-testnet.explorer.caldera.xyz/",
      interchainAccountRouterAddress: "0xEA7E5a8Cb8741250326532b72c1bA05D067F8A61",
      interchainExecuteRouterAddress: "0xc5F722b899dee3F01fC530f10664043aF0B927B2"
    } as Network
};

  