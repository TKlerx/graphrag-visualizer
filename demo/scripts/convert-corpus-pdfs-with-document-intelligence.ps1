param(
  [string]$ManifestPath = "demo/corpus/manifest.json",
  [string]$RawInputDir = "demo/corpus/raw",
  [string]$MarkdownOutputDir = "demo/corpus/text",
  [string]$Endpoint = $env:AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT,
  [string]$ApiKey = $env:AZURE_DOCUMENT_INTELLIGENCE_KEY,
  [string]$ApiVersion = "2024-11-30",
  [int]$PollingSeconds = 3,
  [int]$PollingAttempts = 120
)

$ErrorActionPreference = "Stop"

function Get-DocumentSource {
  param(
    [object]$Manifest,
    [string]$FileName
  )

  if (-not $Manifest) {
    return $null
  }

  return $Manifest.sources | Where-Object { $_.localFileName -eq $FileName } | Select-Object -First 1
}

function New-MarkdownDocument {
  param(
    [string]$Title,
    [string]$SourceUrl,
    [string]$Category,
    [string]$DemoUse,
    [string]$RawFile,
    [string]$Body
  )

  return @"
---
title: "$Title"
source: "$SourceUrl"
category: "$Category"
demo_use: "$DemoUse"
raw_file: "$RawFile"
extraction: "azure-document-intelligence-prebuilt-layout"
---

# $Title

$Body
"@
}

if (-not $Endpoint -or -not $ApiKey) {
  throw "Set AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT and AZURE_DOCUMENT_INTELLIGENCE_KEY, or pass -Endpoint and -ApiKey."
}

$Endpoint = $Endpoint.TrimEnd("/")
$analyzeUri = "$Endpoint/documentintelligence/documentModels/prebuilt-layout:analyze?_overload=analyzeDocument&api-version=$ApiVersion&outputContentFormat=markdown"

$manifest = $null
if (Test-Path -LiteralPath $ManifestPath) {
  $manifest = Get-Content -Raw -LiteralPath $ManifestPath | ConvertFrom-Json
}

New-Item -ItemType Directory -Force -Path $MarkdownOutputDir | Out-Null

$headers = @{
  "Ocp-Apim-Subscription-Key" = $ApiKey
  "Content-Type"              = "application/json"
}

$pdfFiles = Get-ChildItem -LiteralPath $RawInputDir -Filter "*.pdf" -File -ErrorAction SilentlyContinue

foreach ($pdf in $pdfFiles) {
  $source = Get-DocumentSource -Manifest $manifest -FileName $pdf.Name
  $outputName = [System.IO.Path]::GetFileNameWithoutExtension($pdf.Name) + ".md"
  $outputPath = Join-Path $MarkdownOutputDir $outputName

  Write-Host "Analyzing $($pdf.Name) with Azure Document Intelligence"

  $bytes = [System.IO.File]::ReadAllBytes($pdf.FullName)
  $body = @{
    base64Source = [Convert]::ToBase64String($bytes)
  } | ConvertTo-Json

  $response = Invoke-WebRequest -Method Post -Uri $analyzeUri -Headers $headers -Body $body
  $operationLocation = $response.Headers["Operation-Location"]
  if (-not $operationLocation) {
    throw "Document Intelligence did not return an Operation-Location header for $($pdf.Name)."
  }

  $result = $null
  for ($attempt = 1; $attempt -le $PollingAttempts; $attempt++) {
    Start-Sleep -Seconds $PollingSeconds
    $pollResponse = Invoke-RestMethod -Method Get -Uri $operationLocation -Headers @{ "Ocp-Apim-Subscription-Key" = $ApiKey }

    if ($pollResponse.status -eq "succeeded") {
      $result = $pollResponse
      break
    }

    if ($pollResponse.status -eq "failed") {
      throw "Document Intelligence analysis failed for $($pdf.Name): $($pollResponse.error.message)"
    }
  }

  if (-not $result) {
    throw "Timed out waiting for Document Intelligence analysis of $($pdf.Name)."
  }

  $title = if ($source) { $source.title } else { $pdf.BaseName }
  $sourceUrl = if ($source) { $source.url } else { "" }
  $category = if ($source) { $source.category } else { "pdf" }
  $demoUse = if ($source) { $source.demoUse } else { "" }
  $content = $result.analyzeResult.content

  $markdown = New-MarkdownDocument `
    -Title $title `
    -SourceUrl $sourceUrl `
    -Category $category `
    -DemoUse $demoUse `
    -RawFile $pdf.Name `
    -Body $content

  Set-Content -LiteralPath $outputPath -Value $markdown -Encoding UTF8
  Write-Host "Wrote $outputPath"
}

Write-Host "Azure Document Intelligence conversion complete."
