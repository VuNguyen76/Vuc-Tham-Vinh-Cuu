@echo off
echo ========================================================
echo     DANG MO GODOT EDITOR CHO QUAI VAT VINH CUU (QVVC)
echo ========================================================
set "GODOT_MCP_HOST=http://localhost:20692"
set "GODOT_MCP_AUTH_OPTION=None"
set "GODOT_MCP_CONNECTION_MODE=Custom"
start "" "C:\Users\Admin\scoop\apps\godot\current\godot.console.exe" --editor --path "%~dp0."
exit
