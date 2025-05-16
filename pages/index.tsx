import React from 'react';
import {
  Box,
  Container,
  Heading,
  Button,
  Text,
  VStack,
  useToast,
} from '@chakra-ui/react';
import { useWeb3 } from '../components/Web3Context';
import DonationForm from '../components/DonationForm';
import DonationHistory from '../components/DonationHistory';

const Home: React.FC = () => {
  const { account, connectWallet, loading } = useWeb3();
  const toast = useToast();

  const handleConnect = async () => {
    try {
      await connectWallet();
    } catch (error: any) {
      toast({
        title: 'Error',
        description: error.message || 'Failed to connect wallet',
        status: 'error',
        duration: 5000,
        isClosable: true,
      });
    }
  };

  return (
    <Container maxW="container.xl" py={8}>
      <VStack spacing={8} align="stretch">
        <Box textAlign="center">
          <Heading as="h1" size="2xl" mb={4}>
            DonaChain
          </Heading>
          <Text fontSize="xl" color="gray.600">
            Make secure and transparent donations on the blockchain
          </Text>
        </Box>

        <Box textAlign="center">
          {!account ? (
            <Button
              colorScheme="blue"
              size="lg"
              onClick={handleConnect}
              isLoading={loading}
            >
              Connect Wallet
            </Button>
          ) : (
            <Text fontSize="md" color="gray.600">
              Connected: {account.slice(0, 6)}...{account.slice(-4)}
            </Text>
          )}
        </Box>

        {account && (
          <>
            <DonationForm />
            <DonationHistory />
          </>
        )}
      </VStack>
    </Container>
  );
};

export default Home; 