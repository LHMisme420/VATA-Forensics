param(
  [string]$EpochDir = "epochs"
)

function Sha256Bytes([byte[]]$data) {
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { return $sha.ComputeHash($data) } finally { $sha.Dispose() }
}

function BytesToHex([byte[]]$bytes) {
  ($bytes | ForEach-Object { $_.ToString("x2") }) -join ""
}

if (!(Test-Path $EpochDir)) { throw "Missing folder: $EpochDir" }

$files = Get-ChildItem -File $EpochDir | Sort-Object Name
if ($files.Count -eq 0) { throw "No epoch files found in .\$EpochDir" }

Write-Host ("Epoch files: " + $files.Count)

# leaf = sha256(raw file bytes)
$layer = @()
foreach ($f in $files) {
  $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
  $layer += ,(Sha256Bytes $bytes)
}

# build tree (pairwise concat; if odd, promote last)
while ($layer.Count -gt 1) {
  $next = @()
  for ($i = 0; $i -lt $layer.Count; $i += 2) {
    if ($i + 1 -ge $layer.Count) {
      $next += ,$layer[$i]
    } else {
      $next += ,(Sha256Bytes ([byte[]]($layer[$i] + $layer[$i+1])))
    }
  }
  $layer = $next
}

$rootHex = "0x" + (BytesToHex $layer[0])
Set-Content -Path "EPOCH_ROOT.txt" -Value $rootHex -Encoding utf8
Write-Host "Merkle Root:" $rootHex
