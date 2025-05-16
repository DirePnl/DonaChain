import type { AppProps } from 'next/app';
import { ChakraProvider } from '@chakra-ui/react';
import { Web3Provider } from '../components/Web3Context';

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <ChakraProvider>
      <Web3Provider>
        <Component {...pageProps} />
      </Web3Provider>
    </ChakraProvider>
  );
}

export default MyApp; 