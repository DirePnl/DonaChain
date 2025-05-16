const hre = require("hardhat");

async function main() {
  // Deploy DonaToken first
  const DonaToken = await hre.ethers.getContractFactory("DonaToken");
  const donaToken = await DonaToken.deploy();
  await donaToken.deployed();
  console.log("DonaToken deployed to:", donaToken.address);

  // Deploy DonationPlatform with DonaToken address
  const DonationPlatform = await hre.ethers.getContractFactory("DonationPlatform");
  const donationPlatform = await DonationPlatform.deploy(donaToken.address);
  await donationPlatform.deployed();
  console.log("DonationPlatform deployed to:", donationPlatform.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 