# Groth16 Circuit for VATA Provenance

This circuit verifies AI artifact provenance using zk-SNARKs (Groth16 scheme). It takes public inputs (e.g., artifact hash, score threshold) and private inputs (e.g., model parameters or dataset proofs) to prove compliance without revealing sensitive data.

- Signals: Public (artifact_id, min_score), Private (model_weights_hash, dataset_integrity).
- Constraints: Hash checks, score computation gates, integrity assertions.
- Compiled with Circom: ~X constraints (update with your actual count).
