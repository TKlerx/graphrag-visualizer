param(
  [string]$ManifestPath = "demo/corpus/manifest.json",
  [string]$RawOutputDir = "demo/corpus/raw",
  [string]$TextOutputDir = "demo/corpus/text"
)

$ErrorActionPreference = "Stop"

function Convert-HtmlToPlainText {
  param([string]$Html)

  $text = $Html -replace "(?is)<script.*?</script>", " "
  $text = $text -replace "(?is)<style.*?</style>", " "
  $text = $text -replace "(?s)<[^>]+>", " "
  $text = [System.Net.WebUtility]::HtmlDecode($text)
  $text = $text -replace "\s+", " "
  return $text.Trim()
}

$manifestFullPath = Resolve-Path -LiteralPath $ManifestPath
$manifest = Get-Content -Raw -LiteralPath $manifestFullPath | ConvertFrom-Json

New-Item -ItemType Directory -Force -Path $RawOutputDir | Out-Null
New-Item -ItemType Directory -Force -Path $TextOutputDir | Out-Null

foreach ($source in $manifest.sources) {
  $rawPath = Join-Path $RawOutputDir $source.localFileName
  Write-Host "Downloading $($source.id) -> $rawPath"

  try {
    Invoke-WebRequest -Uri $source.url -OutFile $rawPath -MaximumRedirection 10

    if ($source.localFileName -match "\.html?$") {
      $html = Get-Content -Raw -LiteralPath $rawPath
      $textPath = Join-Path $TextOutputDir ($source.localFileName -replace "\.html?$", ".txt")
      $header = @"
Title: $($source.title)
Source: $($source.url)
Category: $($source.category)
Demo use: $($source.demoUse)

"@
      $body = Convert-HtmlToPlainText -Html $html
      Set-Content -LiteralPath $textPath -Value ($header + $body) -Encoding UTF8
    } else {
      $notePath = Join-Path $TextOutputDir ($source.localFileName + ".source.txt")
      Set-Content -LiteralPath $notePath -Encoding UTF8 -Value @"
Title: $($source.title)
Source: $($source.url)
Category: $($source.category)
Demo use: $($source.demoUse)

This source was downloaded as a binary document. Convert the raw file to text before GraphRAG indexing if your pipeline does not ingest this format directly.
"@
    }
  } catch {
    Write-Warning "Failed to download $($source.id): $($_.Exception.Message)"
  }
}

Write-Host "Corpus preparation complete."
