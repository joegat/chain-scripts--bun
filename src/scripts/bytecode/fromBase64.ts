import { fromBase64Encoding } from "../../helpers/bytecode";

async function main() {
  const input = "BA";

  const output = fromBase64Encoding(input);
  console.log({ input, output });
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

/**
  
  bun run src/scripts/bytecode/fromBase64.ts
  
  */

/**
 * 


 xjflvtmorqpwkayzhdgnceubish
 eGpmbHZ0bW9ycXB3a2F5emhkZ25jZXViaXNo
 oRzrCwYAAAADAQACBwIcCB4gAAAbeGpmbHZ0bW9ycXB3a2F5emhkZ25jZXViaXNoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

xjflvtmorqpwkayzhdgnceubis
eGpmbHZ0bW9ycXB3a2F5emhkZ25jZXViaQ==
oRzrCwYAAAADAQACBwIaCBwgAAAZeGpmbHZ0bW9ycXB3a2F5emhkZ25jZXViaQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==



test
dGVzdA==
oRzrCwYAAAADAQACBwIFCAcgAAAEdGVzdAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==

cute
Y3V0ZQ==
oRzrCwYAAAADAQACBwIFCAcgAAAEY3V0ZQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==

pkg3pkg3
cGtnM3BrZzM=
oRzrCwYAAAADAQACBwIJCAsgAAAIcGtnM3BrZzMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=

xjflvtmorqpwkayzhdgnceubis
eGpmbHZ0bW9ycXB3a2F5emhkZ25jZXViaXM=
oRzrCwYAAAADAQACBwIbCB0gAAAaeGpmbHZ0bW9ycXB3a2F5emhkZ25jZXViaXMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=

 
  
   */
