param(
  [Parameter(Mandatory=$true)][string]$InputPath,
  [string]$Name = "",
  [string]$OutDir = "out_vata",
  [string]$Chain = "sepolia",
  [string]$Rpc = "https://ethereum-sepolia-rpc.publicnode.com"
)

if (!(Test-Path $InputPath)) { throw "Not found: $InputPath" }

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$base = if ($Name -ne "") { $Name } else { Split-Path $InputPath -Leaf }
$dst = Join-Path $OutDir $base
Copy-Item $InputPath $dst -Force

# SHA-256
$hash = (python -c "import hashlib,sys;print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())" $dst).Trim()
$calldata = "0x$hash"
$calldata | Out-File -Encoding ascii (Join-Path $OutDir "sha256.txt")

# Receipt
python verifier\make_receipt.py $OutDir | Out-Null

# Receipt hash
$receiptPath = Join-Path $OutDir "receipt.json"
$receiptHash = (python -c "import hashlib,sys;print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())" $receiptPath).Trim()

# Manifest
$utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$manifest = @{
  vata_version = "0.1"
  name = $base
  created_utc = $utc
  artifacts = @(
    @{ path = $base; sha256 = $hash }
    @{ path = "receipt.json"; sha256 = $receiptHash }
    @{ path = "sha256.txt"; sha256 = (python -c "import hashlib,sys;print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())" (Join-Path $OutDir "sha256.txt")).Trim() }
  )
  anchor = @{
    chain = $Chain
    rpc = $Rpc
    tx_hash = ""
    calldata = $calldata
  }
}
$manifest | ConvertTo-Json -Depth 8 | Out-File -Encoding utf8 (Join-Path $OutDir "manifest.json")

Write-Host ""
Write-Host "VATA Snapshot created:"
Write-Host "  OutDir: $OutDir"
Write-Host "  Artifact: $base"
Write-Host "  Calldata(SHA256): $calldata"
Write-Host ""
Write-Host "Anchor command:"
Write-Host "  cast send --private-key `$env:PK --rpc-url $Rpc YOUR_WALLET $calldata"
Write-Host ""
Write-Host "Verify command (after anchoring):"
Write-Host "  python verifier\verify_tx_min.py $dst YOUR_TX_HASH $Rpc"
Write-Host ""
