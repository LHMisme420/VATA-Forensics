param(
  [Parameter(Mandatory=$true)][string]$FilePath,
  [Parameter(Mandatory=$true)][string]$ProofJsonPath,
  [Parameter(Mandatory=$true)][string]$Tx,
  [string]$Rpc = "https://ethereum-rpc.publicnode.com"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# 1) Verify inclusion proof locally
& "$PSScriptRoot\merkle_verify.ps1" -FilePath $FilePath -ProofJsonPath $ProofJsonPath
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# 2) Load Merkle root from proof JSON
$root = (Get-Content $ProofJsonPath -Raw | ConvertFrom-Json).root

# 3) Fetch on-chain calldata input from the anchor tx
$input = (cast tx $Tx --rpc-url $Rpc | Select-String "input").ToString().Split()[-1].Trim()

Write-Host "Proof root :" $root
Write-Host "Onchain    :" $input

if ($root -ieq $input) {
  Write-Host "MATCH ✅ Root is anchored on mainnet tx $Tx"
  exit 0
} else {
  Write-Host "MISMATCH ❌ Proof root does not match tx calldata"
  exit 3
}
