import React, { useEffect, useState } from 'react';
import {
  Box,
  Table,
  Thead,
  Tbody,
  Tr,
  Th,
  Td,
  Text,
  Spinner,
  VStack,
} from '@chakra-ui/react';
import { ethers } from 'ethers';
import { useWeb3 } from './Web3Context';

interface Donation {
  donor: string;
  recipient: string;
  amount: string;
  fee: string;
  message: string;
  timestamp: number;
}

interface DonationResponse {
  [key: number]: string | ethers.BigNumber;
  toNumber: () => number;
}

const DonationHistory: React.FC = () => {
  const { contract } = useWeb3();
  const [donations, setDonations] = useState<Donation[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchDonations = async () => {
    if (!contract) return;

    try {
      const donationCount = await contract.getDonationCount();
      const donationsArray: Donation[] = [];

      for (let i = 0; i < donationCount.toNumber(); i++) {
        const donation = (await contract.getDonation(i)) as DonationResponse[];
        donationsArray.push({
          donor: donation[0] as string,
          recipient: donation[1] as string,
          amount: ethers.utils.formatEther(donation[2] as ethers.BigNumber),
          fee: ethers.utils.formatEther(donation[3] as ethers.BigNumber),
          timestamp: (donation[4] as ethers.BigNumber).toNumber(),
          message: donation[5] as string,
        });
      }

      setDonations(donationsArray.reverse());
    } catch (error) {
      console.error('Error fetching donations:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (contract) {
      fetchDonations();

      // Listen for new donations
      contract.on('DonationMade', () => {
        fetchDonations();
      });

      return () => {
        contract.removeAllListeners('DonationMade');
      };
    }
  }, [contract]);

  if (loading) {
    return (
      <VStack p={8}>
        <Spinner size="xl" />
        <Text>Loading donations...</Text>
      </VStack>
    );
  }

  return (
    <Box overflowX="auto" mt={8}>
      <Table variant="simple">
        <Thead>
          <Tr>
            <Th>Date</Th>
            <Th>Donor</Th>
            <Th>Recipient</Th>
            <Th>Amount (ETH)</Th>
            <Th>Fee (ETH)</Th>
            <Th>Message</Th>
          </Tr>
        </Thead>
        <Tbody>
          {donations.map((donation: Donation, index: number) => (
            <Tr key={index}>
              <Td>{new Date(donation.timestamp * 1000).toLocaleDateString()}</Td>
              <Td>{`${donation.donor.slice(0, 6)}...${donation.donor.slice(-4)}`}</Td>
              <Td>{`${donation.recipient.slice(0, 6)}...${donation.recipient.slice(-4)}`}</Td>
              <Td>{donation.amount}</Td>
              <Td>{donation.fee}</Td>
              <Td>{donation.message}</Td>
            </Tr>
          ))}
        </Tbody>
      </Table>
    </Box>
  );
};

export default DonationHistory; 