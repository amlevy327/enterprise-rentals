const hre = require('hardhat');

async function main() {

  const EnterpriseAgreements = await hre.ethers.getContractFactory(
    'EnterpriseAgreements',
  );

  const name = "EnterpriseAgreements"
  const symbol = "EA"

  const enterpriseAgreements = await EnterpriseAgreements.deploy(
    name,
    symbol
  );

  await enterpriseAgreements.waitForDeployment();

  console.log(`enterpriseAgreements deployed to ${await enterpriseAgreements.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});