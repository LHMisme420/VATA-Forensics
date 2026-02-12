import fs from "fs";
import crypto from "crypto";

const file = process.argv[2];
if (!file) {
  console.error("Usage: node scripts/verify_manifest.mjs <manifest.json> [expectedHash]");
  process.exit(1);
}

const EXPECTED = (process.argv[3] || "").toLowerCase(); // optional

const buf = fs.readFileSync(file);
const computed = "0x" + crypto.createHash("sha256").update(buf).digest("hex");

console.log("File:", file);
console.log("Computed sha256 (raw bytes):", computed);

if (EXPECTED) {
  console.log("Expected anchored root:", EXPECTED);
  console.log(computed.toLowerCase() === EXPECTED ? "PASS ✅" : "FAIL 🔴 Hash mismatch.");
} else {
  console.log("No expected hash provided. Paste one as arg #2 to compare.");
}
