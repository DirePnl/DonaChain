declare module 'web3modal' {
  interface Web3ModalOptions {
    cacheProvider?: boolean;
    providerOptions?: any;
    network?: string;
    theme?: string;
  }

  class Web3Modal {
    constructor(options: Web3ModalOptions);
    connect(): Promise<any>;
    clearCachedProvider(): void;
    setCachedProvider(id: string): void;
    updateTheme(theme: string): void;
  }

  export = Web3Modal;
} 