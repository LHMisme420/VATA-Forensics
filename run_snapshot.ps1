param(
  [Parameter(Mandatory=$true)]
  [string]$Path
)

if (!(Test-Path $Path)) {
  Write-Error "File not found: $Path"
  exit 1
}

# SHA-256
$hash = (python -c "import hashlib; import sys; print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())" $Path).Trim()

Write-Host ""
Write-Host "VATA Snapshot"
Write-Host "============"
Write-Host "File: $Path"
Write-Host "SHA256: $hash"
Write-Host ""

Write-Host "Anchor (Sepolia, tx-to-self calldata):"
Write-Host "cast send --private-key `$env:PK --rpc-url https://ethereum-sepolia-rpc.publicnode.com YOUR_WALLET 0x$hash"
Write-Host ""

Write-Host "Verify receipt:"
Write-Host "cast receipt YOUR_TX_HASH --rpc-url https://ethereum-sepolia-rpc.publicnode.com"
Write-Host ""
