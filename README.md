# VATA Forensics
Verifiable AI & Truth Anchoring

Open forensic infrastructure for proving the existence and integrity of digital data using deterministic hashing and public blockchain anchoring.

---

## What This Is

VATA Forensics is a minimal, reproducible pipeline:

Capture → Normalize → Hash → Anchor → Verify

If data existed at a point in time, it can be proven.

No trust in people.
No trust in platforms.
Only math.

---

## Why This Exists

Digital narratives can be edited, deleted, or rewritten.

VATA Forensics provides a public, cryptographic method to:

- Prove a dataset existed
- Prove it has not changed
- Allow anyone to independently verify

This is forensic-grade proof-of-existence.

---

## Core Workflow

1. Capture raw data (HAR, JSON, logs, files)
2. Convert into structured dataset (CSV)
3. Compute SHA-256 hash
4. Embed hash into Ethereum transaction calldata
5. Anyone verifies by re-hashing and comparing

---

## Example: Moltbook Forensics Run

Dataset Hash (SHA-256):

b2bdf74d7a6a2713722d7664ad636cf85a4faf503fe7bdcda86aef576d358660

Anchored on Ethereum Sepolia:

0xf5c2e4fa7a4382fd4a161eead51dc195fde5e0f71fdb95826763d14f4cae1528

---

## Verifying

1. Recreate dataset
2. Hash with SHA-256
3. Inspect transaction calldata
4. Confirm hash matches

If equal → dataset integrity proven.

---

## Philosophy

Proof > Authority  
Math > Narratives  
Verification > Persuasion  

VATA Forensics is open, neutral, and censorship-resistant.

---

## License

MIT
