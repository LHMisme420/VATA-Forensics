param(
  [string]$Manifest = ".\evidence_manifest.json",
  [string]$Tx = "0xaeee34f3010df0f720a427baa39c55ddd5595a2ce17f65186d1aa03f063f4c55",
  [string]$Rpc = "https://ethereum-rpc.publicnode.com"
)

$manifestHash = "0x$((Get-FileHash $Manifest -Algorithm SHA256).Hash)"
$input = (cast tx $Tx --rpc-url $Rpc | Select-String "input").ToString().Split()[-1].Trim()

Write-Host "Manifest:" (Resolve-Path $Manifest)
Write-Host "Local SHA256 :" $manifestHash
Write-Host "Onchain input:" $input

if ($manifestHash -ieq $input) {
  Write-Host "MATCH ✅ Manifest is anchored to mainnet tx $Tx"
  exit 0
} else {
  Write-Host "MISMATCH ❌ File does not match tx calldata"
  exit 1
}
