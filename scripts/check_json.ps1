foreach ($f in 'en','ar','fr') {
    try {
        $content = [IO.File]::ReadAllText("c:\dev\flutter-apps\driver_movirooo_app-main\data\translations\$f.json")
        $null = [System.Text.Json.JsonDocument]::Parse($content)
        Write-Output "[$f] VALID JSON"
    } catch { Write-Output "[$f] INVALID: $_" }
}
foreach ($f in 'en','ar','fr') {
    Write-Output "--- $f last 4 lines ---"
    Get-Content "c:\dev\flutter-apps\driver_movirooo_app-main\data\translations\$f.json" | Select-Object -Last 4
}
