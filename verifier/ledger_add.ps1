param(
  [Parameter(Mandatory=$true)][string]$Name,
  [Parameter(Mandatory=$true)][string]$Calldata,
  [Parameter(Mandatory=$true)][string]$TxHash,
  [string]$Chain = "sepolia",
  [string]$Rpc = "https://ethereum-sepolia-rpc.publicnode.com",
  [string[]]$Tags = @()
)

$utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$entry = @{
  name = $Name
  created_utc = $utc
  chain = $Chain
  rpc = $Rpc
  tx_hash = $TxHash
  calldata = $Calldata
  tags = $Tags
} | ConvertTo-Json -Compress

Add-Content -Encoding utf8 -Path "ledger.jsonl" -Value $entry

Write-Host "Added ledger entry:"
Write-Host $entry
