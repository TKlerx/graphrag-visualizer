param(
  [string]$ManifestPath = "demo/corpus/manifest.json",
  [string]$RawInputDir = "demo/corpus/raw",
  [string]$MarkdownOutputDir = "demo/corpus/text",
  [string]$PdfToTextPath = ""
)

$ErrorActionPreference = "Stop"

function Find-PdfToText {
  param([string]$RequestedPath)

  if ($RequestedPath -and (Test-Path -LiteralPath $RequestedPath)) {
    return (Resolve-Path -LiteralPath $RequestedPath).Path
  }

  $command = Get-Command pdftotext -ErrorAction SilentlyContinue
  if ($command) {
    return $command.Source
  }

  throw "pdftotext was not found. Install Poppler or MiKTeX, or pass -PdfToTextPath."
}

function Convert-TextToMarkdownBody {
  param([string]$Text)

  $normalized = $Text -replace "`r`n", "`n"
  $normalized = $normalized -replace "`f", "`n`n---`n`n"
  $normalized = $normalized -replace "[ `t]+`n", "`n"
  $normalized = $normalized.Trim()
  return $normalized
}

$manifest = $null
if (Test-Path -LiteralPath $ManifestPath) {
  $manifest = Get-Content -Raw -LiteralPath $ManifestPath | ConvertFrom-Json
}

$pdfToText = Find-PdfToText -RequestedPath $PdfToTextPath
New-Item -ItemType Directory -Force -Path $MarkdownOutputDir | Out-Null

$pdfFiles = Get-ChildItem -LiteralPath $RawInputDir -Filter "*.pdf" -File -ErrorAction SilentlyContinue

foreach ($pdf in $pdfFiles) {
  $source = $null
  if ($manifest) {
    $source = $manifest.sources | Where-Object { $_.localFileName -eq $pdf.Name } | Select-Object -First 1
  }

  $tempTxt = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName() + ".txt")
  $outputName = [System.IO.Path]::GetFileNameWithoutExtension($pdf.Name) + ".md"
  $outputPath = Join-Path $MarkdownOutputDir $outputName

  Write-Host "Converting $($pdf.Name) -> $outputPath"

  try {
    & $pdfToText -layout -enc UTF-8 $pdf.FullName $tempTxt
    $body = Convert-TextToMarkdownBody -Text (Get-Content -Raw -LiteralPath $tempTxt)

    $title = if ($source) { $source.title } else { $pdf.BaseName }
    $url = if ($source) { $source.url } else { "" }
    $category = if ($source) { $source.category } else { "pdf" }
    $demoUse = if ($source) { $source.demoUse } else { "" }

    $markdown = @"
---
title: "$title"
source: "$url"
category: "$category"
demo_use: "$demoUse"
raw_file: "$($pdf.Name)"
---

# $title

$body
"@

    Set-Content -LiteralPath $outputPath -Value $markdown -Encoding UTF8
  } finally {
    Remove-Item -LiteralPath $tempTxt -Force -ErrorAction SilentlyContinue
  }
}

Write-Host "PDF conversion complete."
