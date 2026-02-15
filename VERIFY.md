# Verify the VATA Manifest Anchor

This repository contains a manifest snapshot that is cryptographically anchored to Ethereum mainnet.

---

## Step 1 — Hash the file (SHA-256)

PowerShell:

Get-FileHash sfs_manifest.json -Algorithm SHA256

The result must equal:

0x529c144f4983c552effcbaac269823cc2fdd77b3b7ac3d0a0cdf53e99f563fea

---

## Step 2 — Check the Ethereum mainnet transaction calldata

Transaction:
0x579b3caa3061836fad2f1590dea3c99855a6bd2ba77510584ebf61ba67b1311b

Using Foundry:

cast tx 0x579b3caa3061836fad2f1590dea3c99855a6bd2ba77510584ebf61ba67b1311b --rpc-url https://ethereum-rpc.publicnode.com

Confirm the `input` field equals the same hash above.

---

If both match, the file is authentic and untampered.
