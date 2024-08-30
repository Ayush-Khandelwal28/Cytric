import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const CytricTokens = buildModule("CytricTokens", (m) => {

  const tokens = m.contract("CytricTokens");

  return { tokens };
});

export default CytricTokens;
