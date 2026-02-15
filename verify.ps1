Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# No-key default RPC (override by setting $env:RPC)
if (-not $env:RPC) { $env:RPC = "https://ethereum-rpc.publicnode.com" }

Write-Host "=== VATA-Forensics: One-Command Verify ==="
Write-Host "RPC: $env:RPC"
Write-Host ""

pwsh .\scripts\merkle_epoch.ps1

Push-Location .\vata_bundle_mainnet_a652865c
pwsh .\verify_all.ps1
Pop-Location

Write-Host ""
Write-Host "=== VERIFIED OK ==="
