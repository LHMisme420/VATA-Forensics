$ErrorActionPreference = 'Stop'

$TX        = '0xa652865c1d2474890d402547384263f6e8eb04ca11fc504558d994a8a96888ca'
$PROOFHASH = '0x6a54c7d51f1c3140c23dd06e40985acde8a4c3ca53aabfebc20b314ab83d002b'
$PREFIX    = '0x56415441'

if (-not $env:RPC) { $env:RPC = 'https://ethereum-rpc.publicnode.com' }

if (-not (Get-Command cast -ErrorAction SilentlyContinue)) { throw 'cast.exe not found (install Foundry)' }
if (-not (Test-Path '.\forensic_proof.bin')) { throw 'Missing forensic_proof.bin' }

$localSha = (Get-FileHash '.\forensic_proof.bin' -Algorithm SHA256).Hash.ToLower()
$expected = ($PREFIX + $PROOFHASH.Substring(2)).ToLower()

$raw = cast tx $TX --rpc-url $env:RPC --json
if (-not $raw) { throw "cast tx returned empty. RPC=$env:RPC" }
$tx = $raw | ConvertFrom-Json
if (-not $tx -or -not $tx.input) { throw "Could not read tx input. RPC=$env:RPC" }

$onchain = ($tx.input).ToLower()
if ($onchain -ne $expected) {
  throw ("FAIL calldata mismatch
Expected: {0}
Onchain:   {1}" -f $expected, $onchain)
}

"OK: calldata matches VATA(prefix)+proofhash"
"OK: local forensic_proof.bin sha256 = $localSha"
"TX: " + $TX
"RPC: $env:RPC"

if ((Test-Path '.\evidence_manifest.json') -and (Test-Path '.\evidence')) {
  $m = Get-Content '.\evidence_manifest.json' -Raw | ConvertFrom-Json
  foreach ($it in $m.evidence_items) {
    $p = Join-Path '.\evidence' $it.name
    if (-not (Test-Path $p)) { throw "Missing evidence file: $($it.name)" }
    $h = (Get-FileHash $p -Algorithm SHA256).Hash.ToLower()
    if ($h -ne ($it.sha256.ToLower())) { throw "FAIL evidence hash mismatch: $($it.name)" }
  }
  "OK: evidence items match manifest"
}

# --- Signature verification (optional) ---
if (Test-Path '.\signed_manifest.json') {
  $s = Get-Content '.\signed_manifest.json' -Raw | ConvertFrom-Json
  if (-not $s.signer_address -or -not $s.signature -or -not $s.digest_hex) {
    throw "signed_manifest.json missing fields"
  }

  cast wallet verify --address $s.signer_address --no-hash $s.digest_hex $s.signature | Out-Null
  "OK: signature verifies for signer = $($s.signer_address)"
}
