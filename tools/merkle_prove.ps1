param(
  [Parameter(Mandatory=$true)][string]$InputDir,
  [Parameter(Mandatory=$true)][string]$TargetRelPath,
  [Parameter(Mandatory=$true)][string]$OutProofJson,
  [string[]]$ExcludeGlobs = @("merkle\*", "*.zip")
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

function IsExcluded([string]$rel, [string[]]$globs) {
  foreach ($g in $globs) {
    $rgx = "^" + [Regex]::Escape($g).Replace("\*",".*") + "$"
    if ($rel -match $rgx) { return $true }
  }
  return $false
}

$inFull = (Resolve-Path $InputDir).Path

# Collect files deterministically by rel path
$items =
  Get-ChildItem -Path $inFull -Recurse -File |
  ForEach-Object {
    $rel = $_.FullName.Substring($inFull.Length).TrimStart("\","/")
    [PSCustomObject]@{ Full=$_.FullName; Rel=($rel -replace "\\","/") }
  } |
  Where-Object { -not (IsExcluded $_.Rel $ExcludeGlobs) } |
  Sort-Object Rel

if ($items.Count -lt 1) { throw "No files found under $InputDir after excludes." }

# Find target index
$targetNorm = ($TargetRelPath -replace "\\","/").TrimStart("./")
$idx = -1
for ($i=0; $i -lt $items.Count; $i++) {
  if ($items[$i].Rel -ieq $targetNorm) { $idx = $i; break }
}
if ($idx -lt 0) {
  throw "TargetRelPath not found. Target='$targetNorm'. First 10 files:`n$($items | Select-Object -First 10 Rel | ForEach-Object { $_.Rel } | Out-String)"
}

# Leaves
$leaves = New-Object System.Collections.Generic.List[string]
foreach ($it in $items) {
  $bytes = [IO.File]::ReadAllBytes($it.Full)
  $leaves.Add( (ToHex (Sha256 $bytes)) ) | Out-Null
}

$proofSteps = New-Object System.Collections.Generic.List[object]
$current = $leaves.ToArray()
$pos = $idx

while ($current.Length -gt 1) {
  $next = New-Object System.Collections.Generic.List[string]

  for ($i=0; $i -lt $current.Length; $i += 2) {
    $left = $current[$i]
    $right = if ($i+1 -lt $current.Length) { $current[$i+1] } else { $current[$i] } # duplicate last

    $parent = HashPair $left $right
    $next.Add($parent) | Out-Null

    # if target is in this pair, record sibling
    if ($pos -eq $i) {
      # target is left, sibling is right
      $proofSteps.Add([PSCustomObject]@{ dir="R"; sibling=$right }) | Out-Null
      $pos = [int]($i/2)
    } elseif ($pos -eq ($i+1)) {
      # target is right, sibling is left
      $proofSteps.Add([PSCustomObject]@{ dir="L"; sibling=$left }) | Out-Null
      $pos = [int]($i/2)
    }
  }

  $current = $next.ToArray()
}

$root = $current[0]
$leaf = $leaves[$idx]

$outObj = [ordered]@{
  rel_path = $items[$idx].Rel
  file_count = $items.Count
  leaf = $leaf
  root = $root
  proof = $proofSteps
  algorithm = "sha256"
  merkle_rule = "parent=sha256(left||right), odd=duplicate_last"
}

New-Item -ItemType Directory -Force (Split-Path -Parent $OutProofJson) | Out-Null
($outObj | ConvertTo-Json -Depth 8) | Out-File -Encoding utf8 $OutProofJson

Write-Host "OK ✅ Proof written:"
Write-Host (Resolve-Path $OutProofJson)
Write-Host "Target:" $items[$idx].Rel
Write-Host "Root  :" $root
