# Start Godot-MCP Server & Editor for QVVC
param (
    [string]$ProjectPath = "$PSScriptRoot"
)

$ServerExe = "$ProjectPath\.ai-game-dev\server\gamedev-mcp-server.exe"
$GodotBin = "C:\Users\Admin\scoop\apps\godot\current\godot.console.exe"
$Port = 20692

Write-Host "=== Starting Godot-MCP cho Quái Vật Vĩnh Cửu ===" -ForegroundColor Cyan

# 1. Start MCP Server if not running
$existingServer = Get-Process -Name "gamedev-mcp-server" -ErrorAction SilentlyContinue
if (-not $existingServer -and (Test-Path $ServerExe)) {
    Write-Host "[1/2] Starting local MCP Server on port $Port..." -ForegroundColor Yellow
    Start-Process -FilePath $ServerExe -ArgumentList "--port=$Port" -WindowStyle Minimized
    Start-Sleep -Seconds 2
} else {
    Write-Host "[1/2] MCP Server ready or already running" -ForegroundColor Green
}

# 2. Launch Godot Editor with MCP Connection
Write-Host "[2/2] Launching Godot Editor..." -ForegroundColor Yellow
$env:GODOT_MCP_HOST = "http://localhost:$Port"
$env:GODOT_MCP_AUTH_OPTION = "None"
$env:GODOT_MCP_CONNECTION_MODE = "Custom"
$env:GODOT_BIN = $GodotBin

Start-Process -FilePath $GodotBin -ArgumentList "--editor", "--path", "`"$ProjectPath`""
Write-Host "Godot Editor opened for $ProjectPath" -ForegroundColor Green
