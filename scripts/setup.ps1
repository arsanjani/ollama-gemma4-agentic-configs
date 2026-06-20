# Setup Script for Gemma 4 Cline Configuration
# This script automates the creation of the custom Ollama model profile based on the optimized Modelfile.

Write-Host "Starting deployment of gemma4-cline configuration..." -ForegroundColor Cyan

try {
    # Ensure we are in the repository root
    $repoRoot = Get-Location
    $modelfilePath = Join-Path $repoRoot "configs\Modelfile"
    
    if (-not (Test-Path $modelfilePath)) {
        throw "Modelfile not found at $modelfilePath. Please ensure you are in the repository root."
    }

    Write-Host "Compiling modified configuration profile into Ollama..." -ForegroundColor Yellow
    # Using Resolve-Path to handle any potential pathing issues with Ollama CLI
    $fullModelfilePath = (Resolve-Path $modelfilePath).Path
    ollama create gemma4-cline -f "$fullModelfilePath"
    
    if ($LASTEXITCODE -ne 0) {
        throw "Ollama create command failed. Please ensure Ollama is installed and running."
    }

    Write-Host "`nDeployment successful! Target 'gemma4-cline' as the designated model inside the Cline API Provider menu." -ForegroundColor Green
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}