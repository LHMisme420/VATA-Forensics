# VATA-Forensics / Sovereign Forensics Suite
**VATA VERIFIED ✅** = file SHA-256 matches on-chain tx calldata (input).
## One-liner Verify (no deps)

```powershell
python verifier\verify_tx_min.py <PATH_TO_FILE> <TX_HASH> https://ethereum-sepolia-rpc.publicnode.com



Tamper-evident provenance for AI artifacts & outputs. Math > opinions.

- Groth16 zk-SNARKs for private integrity proofs
- On-chain anchoring (Ethereum mainnet txs live)
- Local verification scripts (Node.js + ethers.js)
- Manifest anchoring demo (JSON → hash → compare to calldata root)

Quick Start:
1. Clone: git clone https://github.com/LHMisme420/VATA-Forensics.git
2. npm install ethers
3. node scripts/verify_manifest.mjs sfs_manifest.json  # VERIFIED 🟢
4. Edit file → rerun → FAIL 🔴

Live mainnet anchors:
- FULL MANIFEST root: 0xdcc2d86eb896f827c78480c2ea2c8d96dc65a7ad3603e0bcc1bdb4d54660ef2b
- Latest tx: 0x579b3caa3061836fad2f1590dea3c99855a6bd2ba77510584ebf61ba67b1311b (self-call calldata)

Builders: Fork & anchor your own. Orgs: DM @Lhmisme for API/license.
