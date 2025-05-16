import React, { useState } from 'react';
import {
  Box,
  Button,
  FormControl,
  FormLabel,
  Input,
  VStack,
  Text,
  useToast,
  Textarea,
  HStack,
} from '@chakra-ui/react';
import { ethers } from 'ethers';
import { useWeb3 } from './Web3Context';
import type { InputChangeEvent, FormSubmitEvent } from '../types/global';

const DonationForm: React.FC = () => {
  const { contract, account, tokenContract } = useWeb3();
  const [recipient, setRecipient] = useState('');
  const [amount, setAmount] = useState('');
  const [message, setMessage] = useState('');
  const [loading, setLoading] = useState(false);
  const [approving, setApproving] = useState(false);
  const toast = useToast();

  const handleApprove = async () => {
    if (!tokenContract || !contract || !amount) return;

    try {
      setApproving(true);
      const amountInWei = ethers.utils.parseEther(amount);
      const tx = await tokenContract.approve(contract.address, amountInWei);
      await tx.wait();

      toast({
        title: 'Success',
        description: 'Token approval successful!',
        status: 'success',
        duration: 5000,
        isClosable: true,
      });
    } catch (error: any) {
      toast({
        title: 'Error',
        description: error.message || 'Failed to approve tokens',
        status: 'error',
        duration: 5000,
        isClosable: true,
      });
    } finally {
      setApproving(false);
    }
  };

  const handleDonate = async (e: FormSubmitEvent) => {
    e.preventDefault();
    if (!contract || !account || !tokenContract) {
      toast({
        title: 'Error',
        description: 'Please connect your wallet first',
        status: 'error',
        duration: 5000,
        isClosable: true,
      });
      return;
    }

    try {
      setLoading(true);
      const amountInWei = ethers.utils.parseEther(amount);
      
      // Check allowance
      const allowance = await tokenContract.allowance(account, contract.address);
      if (allowance.lt(amountInWei)) {
        toast({
          title: 'Error',
          description: 'Please approve tokens first',
          status: 'error',
          duration: 5000,
          isClosable: true,
        });
        return;
      }

      const tx = await contract.donate(recipient, amountInWei, message);
      await tx.wait();

      toast({
        title: 'Success',
        description: 'Donation sent successfully!',
        status: 'success',
        duration: 5000,
        isClosable: true,
      });

      // Reset form
      setRecipient('');
      setAmount('');
      setMessage('');
    } catch (error: any) {
      toast({
        title: 'Error',
        description: error.message || 'Failed to send donation',
        status: 'error',
        duration: 5000,
        isClosable: true,
      });
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e: InputChangeEvent, setter: (value: string) => void) => {
    setter(e.target.value);
  };

  return (
    <Box maxW="md" mx="auto" mt={8} p={6} borderWidth={1} borderRadius="lg">
      <form onSubmit={handleDonate}>
        <VStack spacing={4}>
          <FormControl isRequired>
            <FormLabel>Recipient Address</FormLabel>
            <Input
              value={recipient}
              onChange={(e) => handleInputChange(e, setRecipient)}
              placeholder="0x..."
            />
          </FormControl>

          <FormControl isRequired>
            <FormLabel>Amount (DONA)</FormLabel>
            <Input
              type="number"
              step="0.01"
              value={amount}
              onChange={(e) => handleInputChange(e, setAmount)}
              placeholder="0.1"
            />
          </FormControl>

          <FormControl>
            <FormLabel>Message</FormLabel>
            <Textarea
              value={message}
              onChange={(e) => handleInputChange(e, setMessage)}
              placeholder="Add a message for the recipient..."
            />
          </FormControl>

          <HStack width="full" spacing={4}>
            <Button
              colorScheme="green"
              width="full"
              onClick={handleApprove}
              isLoading={approving}
              loadingText="Approving..."
            >
              Approve DONA
            </Button>
            <Button
              type="submit"
              colorScheme="blue"
              width="full"
              isLoading={loading}
              loadingText="Donating..."
            >
              Donate
            </Button>
          </HStack>
        </VStack>
      </form>
    </Box>
  );
};

export default DonationForm; 