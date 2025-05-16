const hre = require("hardhat");

async function main() {
  const DonationPlatform = await hre.ethers.getContractFactory("DonationPlatform");
  const donationPlatform = await DonationPlatform.deploy();

  await donationPlatform.deployed();

  console.log("DonationPlatform deployed to:", donationPlatform.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 