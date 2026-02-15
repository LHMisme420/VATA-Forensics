[![Verify Ledger](https://github.com/LHMisme420/VATA-Forensics/actions/workflows/verify.yml/badge.svg)](https://github.com/LHMisme420/VATA-Forensics/actions/workflows/verify.yml)



# VATA Forensics — Verifiable AI Truth Anchors

This repository publishes a cryptographically verifiable evidence bundle
demonstrating immutable anchoring of a forensic proof hash to Ethereum mainnet.

## Evidence Bundle

vata_bundle_mainnet_a652865c/

Contains:

- forensic_proof.bin  
- evidence_manifest.json  
- verify_all.ps1  
- evidence/*.csv  

## Mainnet Anchor

Tx:
0xa652865c1d2474890d402547384263f6e8eb04ca11fc504558d994a8a96888ca

Proof Hash:
0x6a54c7d51f1c3140c23dd06e40985acde8a4c3ca53aabfebc20b314ab83d002b

Calldata:
0x56415441 || <proofHash>

## Verify (PowerShell)

$env:RPC="https://ethereum-rpc.publicnode.com"
cd vata_bundle_mainnet_a652865c
.\verify_all.ps1

If any byte of the proof file changes, verification fails.

Verify. Don’t trust.


## 30-Second Verification (epoch2)

Merkle Root (44 files):
0x013a92494483dc611422b9022adebe1464ae88e2a8d0a410dffe43fb7f9fc6ed

Ethereum Mainnet Anchor Tx:
0x8c30e83d516406aa09af769e5a9b15e65a025bbb6fa543623d1090aa2ad9749b

Verify a file is included and anchored:

```powershell
.\tools\verify_against_mainnet.ps1 `
  -FilePath .\bundles\epoch2\evidence_manifest.json `
  -ProofJsonPath .\bundles\epoch2\merkle\proofs\evidence_manifest.json.proof.json `
  -Tx 0x8c30e83d516406aa09af769e5a9b15e65a025bbb6fa543623d1090aa2ad9749b
