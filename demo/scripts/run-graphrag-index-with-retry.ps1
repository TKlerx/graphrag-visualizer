param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectRoot,

  [int]$MaxAttempts = 5,

  [int]$InitialDelaySeconds = 60,

  [int]$MaxDelaySeconds = 900,

  [string]$GraphRagCommand = "graphrag"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ProjectRoot -PathType Container)) {
  throw "GraphRAG project root does not exist: $ProjectRoot"
}

function Test-RetryableGraphRagError {
  param([string]$LogText)

  return $LogText -match "(?i)(429|rate.?limit|too many requests|tokens per minute|tpm|quota|capacity|retry-after|temporarily unavailable|timeout)"
}

$attempt = 1
$delaySeconds = $InitialDelaySeconds

while ($attempt -le $MaxAttempts) {
  Write-Host "GraphRAG index attempt $attempt of $MaxAttempts..."

  $output = & $GraphRagCommand index --root $ProjectRoot 2>&1
  $exitCode = $LASTEXITCODE
  $logText = ($output | Out-String)
  Write-Host $logText

  if ($exitCode -eq 0) {
    Write-Host "GraphRAG indexing completed."
    exit 0
  }

  if ($attempt -ge $MaxAttempts -or -not (Test-RetryableGraphRagError -LogText $logText)) {
    throw "GraphRAG indexing failed with exit code $exitCode."
  }

  $jitter = Get-Random -Minimum 0 -Maximum 30
  $sleepSeconds = [Math]::Min($delaySeconds + $jitter, $MaxDelaySeconds)
  Write-Warning "GraphRAG hit a retryable rate/quota condition. Sleeping $sleepSeconds seconds before retry."
  Start-Sleep -Seconds $sleepSeconds

  $delaySeconds = [Math]::Min($delaySeconds * 2, $MaxDelaySeconds)
  $attempt++
}

throw "GraphRAG indexing failed after $MaxAttempts attempts."
