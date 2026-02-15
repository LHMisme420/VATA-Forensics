# VATA Artifact Format (v0.1)

A VATA artifact is a reproducible proof bundle that enables independent verification of a dataset’s integrity and existence.

## Required
- Primary artifact: `dataset.csv` or `evidence.zip`
- `sha256.txt` (hex, lowercase, no spaces; may be prefixed with `0x`)
- `manifest.json` (machine-readable metadata)

## manifest.json (required fields)

```json
{
  "vata_version": "0.1",
  "name": "moltbook-run-02",
  "created_utc": "2026-02-12T00:00:00Z",
  "capture": {
    "method": "HAR",
    "source": "moltbook.com",
    "notes": "browser network capture"
  },
  "artifacts": [
    { "path": "moltbook.csv", "sha256": "b2bdf74d7a6a2713722d7664ad636cf85a4faf503fe7bdcda86aef576d358660" }
  ],
  "anchor": {
    "chain": "sepolia",
    "rpc": "https://ethereum-sepolia-rpc.publicnode.com",
    "tx_hash": "0xf5c2e4fa7a4382fd4a161eead51dc195fde5e0f71fdb95826763d14f4cae1528",
    "calldata": "0xb2bdf74d7a6a2713722d7664ad636cf85a4faf503fe7bdcda86aef576d358660"
  }
}

