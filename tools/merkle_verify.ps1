param(
  [Parameter(Mandatory=$true)][string]$FilePath,
  [Parameter(Mandatory=$true)][string]$ProofJsonPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function ToHex([byte[]]$bytes) { "0x" + ([BitConverter]::ToString($bytes) -replace "-", "").ToLower() }

function Sha256([byte[]]$bytes) {
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { return $sha.ComputeHash($bytes) } finally { $sha.Dispose() }
}

function HexToBytes([string]$hex) {
  $h = $hex.ToLower().Trim()
  if ($h.StartsWith("0x")) { $h = $h.Substring(2) }
  if ($h.Length -ne 64) { throw "Expected 32-byte hex (64 nibbles). Got length=$($h.Length)" }
  $bytes = New-Object byte[] 32
  for ($i=0; $i -lt 32; $i++) { $bytes[$i] = [Convert]::ToByte($h.Substring($i*2,2),16) }
  return $bytes
}

function HashPair($leftHex,$rightHex) {
  $buf = New-Object byte[] 64
  [Array]::Copy((HexToBytes $leftHex),0,$buf,0,32)
  [Array]::Copy((HexToBytes $rightHex),0,$buf,32,32)
  ToHex (Sha256 $buf)
}

$proofObj = Get-Content $ProofJsonPath -Raw | ConvertFrom-Json
$fileBytes = [IO.File]::ReadAllBytes((Resolve-Path $FilePath))
$leaf = ToHex (Sha256 $fileBytes)

Write-Host "File :" (Resolve-Path $FilePath)
Write-Host "Leaf :" $leaf
Write-Host "Root :" $proofObj.root

if ($leaf -ine $proofObj.leaf) {
  Write-Host "LEAF MISMATCH ❌"
  Write-Host "Proof leaf:" $proofObj.leaf
  exit 1
}

$h = $leaf
foreach ($step in $proofObj.proof) {
  if ($step.dir -eq "L") { $h = HashPair $step.sibling $h }
  elseif ($step.dir -eq "R") { $h = HashPair $h $step.sibling }
  else { throw "Bad proof step dir: $($step.dir)" }
}

Write-Host "Computed root:" $h

if ($h -ieq $proofObj.root) {
  Write-Host "MATCH ✅ Inclusion proof valid"
  exit 0
} else {
  Write-Host "MISMATCH ❌ Inclusion proof invalid"
  exit 2
}
