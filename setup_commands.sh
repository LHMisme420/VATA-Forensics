# Phase 1 (powers of tau - use a trusted ceremony file)
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="Contributor" -v

# Phase 2 (circuit-specific)
circom circuit.circom --r1cs --wasm --sym
snarkjs zkey new circuit.r1cs pot12_final.ptau circuit_0000.zkey
snarkjs zkey contribute circuit_0000.zkey circuit_0001.zkey --name="Contributor" -v
snarkjs zkey export verificationkey circuit_final.zkey vk.json

# Generate proof (example)
snarkjs groth16 prove circuit_final.zkey witness.wtns proof.json public.json

# Verify
snarkjs groth16 verify vk.json public.json proof.json
