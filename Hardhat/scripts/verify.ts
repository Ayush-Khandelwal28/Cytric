import { run } from "hardhat";

async function main() {
  const contractAddress = "0xc95Cc3F45E62f977C40ad4fD9259E9b775fB2A32";
  const contractArguments = ["0x423DFf192F47949C741836b1E1E382D8bD33db3B", "0x423DFf192F47949C741836b1E1E382D8bD33db3B", "60"];

  console.log("Verifying contract...");
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: contractArguments,
    });
    console.log("Contract verified successfully");
  } catch (error: any) {
    if (error.message.toLowerCase().includes("already verified")) {
      console.log("Contract is already verified!");
    } else {
      console.error("Error verifying contract:", error);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });