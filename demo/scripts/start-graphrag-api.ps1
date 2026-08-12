param(
  [string]$ProjectDir = "demo/graphrag/workspace",
  [int]$Port = 8000,
  [int]$CommunityLevel = 2,
  [string]$ResponseType = "Single Paragraph",
  [string]$Python = "demo/graphrag/workspace/.venv/Scripts/python.exe"
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "../..")
Set-Location $repoRoot

$pythonPath = Resolve-Path $Python
$projectPath = Resolve-Path $ProjectDir
$serverPath = Resolve-Path "demo/graphrag/api_server.py"

function Test-PythonModule {
  param([string]$Module)
  & $pythonPath -c "import $Module" *> $null
  return $LASTEXITCODE -eq 0
}

if (-not (Test-PythonModule "fastapi") -or -not (Test-PythonModule "uvicorn")) {
  if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    throw "Missing fastapi/uvicorn and uv is not installed. Install uv or add fastapi and uvicorn to $pythonPath."
  }

  Write-Host "Installing FastAPI/Uvicorn into GraphRAG venv..."
  uv pip install --python $pythonPath "fastapi~=0.112.0" "uvicorn~=0.30.5"
}

$env:GRAPHRAG_PROJECT_DIR = $projectPath
$env:GRAPHRAG_API_PORT = "$Port"
$env:GRAPHRAG_COMMUNITY_LEVEL = "$CommunityLevel"
$env:GRAPHRAG_RESPONSE_TYPE = $ResponseType

Write-Host "Starting GraphRAG API on http://localhost:$Port"
Write-Host "Project: $projectPath"
Write-Host "Demo graph routes: forterro-only-v1, proalpha-target-v2"
Write-Host "Docs:    http://localhost:$Port/docs"

& $pythonPath $serverPath
