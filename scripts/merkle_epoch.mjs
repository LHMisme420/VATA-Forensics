import fs from "fs";
import crypto from "crypto";

const dir = "epochs";
if (!fs.existsSync(dir)) fs.mkdirSync(dir);

const files = fs.readdirSync(dir).sort();

if (files.length === 0) {
  console.error("No epoch files in /epochs");
  process.exit(1);
}

function sha256(x){
  return crypto.createHash("sha256").update(x).digest();
}

let leaves = files.map(f =>
  sha256(fs.readFileSync(`${dir}/${f}`))
);

while (leaves.length > 1) {
  let next = [];
  for (let i = 0; i < leaves.length; i += 2) {
    if (i + 1 === leaves.length) {
      next.push(leaves[i]);
    } else {
      next.push(sha256(Buffer.concat([leaves[i], leaves[i+1]])));
    }
  }
  leaves = next;
}

const root = "0x" + leaves[0].toString("hex");
fs.writeFileSync("EPOCH_ROOT.txt", root);
console.log("Merkle Root:", root);
