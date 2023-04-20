import { ethers } from "hardhat";

async function main() {
  const BullBear = await ethers.getContractFactory("BullBear");
  const bullBear = await BullBear.deploy();

  await bullBear.deployed();

  console.log(
    `BullBear deployed to ${bullBear.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
