import { getClient, NetworkEnum } from "../../../lib/sui";
import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { execSync } from "child_process";
import { Transaction } from "@mysten/sui/transactions";
import { config } from "dotenv";

import { recordResponse, resolveOutputFilePath } from "../../../helpers";

config();
async function main() {
  const network = NetworkEnum.Testnet;
  const signer = Ed25519Keypair.deriveKeypair(
    process.env.flamboyant_chrysolite!
  );
  const client = getClient(network);
  const contractURI = `${process.env.ROOT_DIR}/pkgs/pkg3`;
  // const contractURI = `${process.env.ROOT_DIR}/pkgs/play/test";

  const { modules, dependencies } = JSON.parse(
    execSync(
      `${process.env.SUI_BUILD_CMD} --dump-bytecode-as-base64  --path ${contractURI}`,
      {
        //
        encoding: "utf-8",
      }
    )
  );

  console.log({ modules, dependencies });
  return;

  const tx = new Transaction();
  const upgradeCap = tx.publish({ modules, dependencies });
  tx.transferObjects([upgradeCap], signer.getPublicKey().toSuiAddress());
  tx.setSender(signer.getPublicKey().toSuiAddress());
  tx.setGasBudget(1000000000);
  const txBytes = await tx.build({ client });
  const simulationRes = await client.dryRunTransactionBlock({
    transactionBlock: txBytes,
  });
  if (simulationRes.effects.status.status !== "success") {
    console.log("Simulation failed", simulationRes?.effects?.status?.error);
    return;
  }
  console.log("Simulation success");
  // return;

  const signature = (await signer.signTransaction(txBytes)).signature;
  const res = await client.executeTransactionBlock({
    transactionBlock: txBytes,
    signature,
    options: {
      showEffects: true,
      showObjectChanges: true,
      showEvents: true,
    },
  });
  await client.waitForTransaction({ digest: res.digest });
  try {
    await recordResponse({
      filePath: resolveOutputFilePath({ currFilePath: __filename, network }),
      response: res,
    });
  } catch (error) {
    console.log("Error writing data", error);
  }
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

/**
 
bun run src/scripts/sui/pkg3/publish.ts

 */
