param(
  [string]$ApiBaseUrl = $env:GRAPHRAG_API_URL,
  [string]$CataloguePath = "demo/ic-memo/question-catalogue.json",
  [string]$OutputDir = "demo/ic-memo/generated",
  [switch]$SkipGlobal,
  [switch]$SkipLocal,
  [switch]$SkipDrift
)

$ErrorActionPreference = "Stop"

function Invoke-GraphRagSearch {
  param(
    [string]$BaseUrl,
    [string]$Mode,
    [string]$Query
  )

  $encodedQuery = [System.Web.HttpUtility]::ParseQueryString("")
  $encodedQuery["query"] = $Query
  $uri = "$($BaseUrl.TrimEnd('/'))/search/$Mode`?$($encodedQuery.ToString())"

  try {
    return Invoke-RestMethod -Method Get -Uri $uri
  } catch {
    return [pscustomobject]@{
      error = $_.Exception.Message
      mode  = $Mode
      query = $Query
    }
  }
}

function Convert-ResponseToMarkdown {
  param(
    [string]$Section,
    [object]$Question,
    [hashtable]$Responses
  )

  $lines = New-Object System.Collections.Generic.List[string]
  $lines.Add("## $Section")
  $lines.Add("")
  $lines.Add("**Objective**: $($Question.objective)")
  $lines.Add("")

  foreach ($mode in @("global", "local", "drift")) {
    if (-not $Responses.ContainsKey($mode)) {
      continue
    }

    $response = $Responses[$mode]
    $lines.Add("### $($mode.Substring(0,1).ToUpper() + $mode.Substring(1)) Search")
    $lines.Add("")

    if ($response.error) {
      $lines.Add("**Error**: $($response.error)")
      $lines.Add("")
      continue
    }

    if ($response.response) {
      $lines.Add($response.response.ToString())
      $lines.Add("")
    }

    if ($response.context_data) {
      $lines.Add('<details>')
      $lines.Add('<summary>Context data</summary>')
      $lines.Add("")
      $lines.Add('```json')
      $lines.Add(($response.context_data | ConvertTo-Json -Depth 20))
      $lines.Add('```')
      $lines.Add("")
      $lines.Add('</details>')
      $lines.Add("")
    }
  }

  $lines.Add("### Evidence Expectations")
  foreach ($item in $Question.evidenceExpectations) {
    $lines.Add("- $item")
  }
  $lines.Add("")
  $lines.Add("### Gap Checks")
  foreach ($item in $Question.gapChecks) {
    $lines.Add("- $item")
  }
  $lines.Add("")

  return ($lines -join "`n")
}

if (-not $ApiBaseUrl) {
  throw "Set GRAPHRAG_API_URL or pass -ApiBaseUrl, e.g. http://localhost:8000."
}

$catalogue = Get-Content -Raw -LiteralPath $CataloguePath | ConvertFrom-Json
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$runDir = Join-Path $OutputDir $timestamp
New-Item -ItemType Directory -Force -Path $runDir | Out-Null

$memoSections = New-Object System.Collections.Generic.List[string]
$memoSections.Add("# Generated IC Retrieval Pack")
$memoSections.Add("")
$memoSections.Add("Generated: $(Get-Date -Format o)")
$memoSections.Add("API: $ApiBaseUrl")
$memoSections.Add("")

foreach ($section in $catalogue.sections) {
  $slug = $section.section.ToLowerInvariant()
  $slug = $slug -replace "[^a-z0-9]+", "-"
  $slug = $slug -replace "^-|-$", ""
  Write-Host "Running IC questions for $($section.section)"

  $responses = @{}
  if (-not $SkipGlobal) {
    $responses["global"] = Invoke-GraphRagSearch -BaseUrl $ApiBaseUrl -Mode "global" -Query $section.globalPrompt
  }
  if (-not $SkipLocal) {
    $responses["local"] = Invoke-GraphRagSearch -BaseUrl $ApiBaseUrl -Mode "local" -Query $section.localPrompt
  }
  if (-not $SkipDrift) {
    $responses["drift"] = Invoke-GraphRagSearch -BaseUrl $ApiBaseUrl -Mode "drift" -Query $section.driftPrompt
  }

  $jsonPath = Join-Path $runDir "$slug.json"
  $mdPath = Join-Path $runDir "$slug.md"
  $responses | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

  $sectionMarkdown = Convert-ResponseToMarkdown -Section $section.section -Question $section -Responses $responses
  Set-Content -LiteralPath $mdPath -Value $sectionMarkdown -Encoding UTF8
  $memoSections.Add($sectionMarkdown)
}

$memoPath = Join-Path $runDir "ic-retrieval-pack.md"
Set-Content -LiteralPath $memoPath -Value ($memoSections -join "`n") -Encoding UTF8

Write-Host "Wrote $memoPath"
