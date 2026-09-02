#Requires -Version 5.1
# BeatForge installer: irm https://repousiosjim.github.io/beatforge-site/install.ps1 | iex
param([switch]$NoRun)
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$repo = "RepousiosJim/beatforge-site"
$release = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest" -Headers @{ "User-Agent" = "beatforge-install" }
$asset = $release.assets | Where-Object { $_.name -like "BeatForge-Setup-*.exe" } | Select-Object -First 1
if (-not $asset) { throw "No installer asset on release $($release.tag_name)" }
$manifest = ($release.assets | Where-Object { $_.name -eq "latest.yml" }).browser_download_url
$expected = [regex]::Match((Invoke-RestMethod $manifest), "(?m)^sha512:\s*(\S+)").Groups[1].Value.Trim()

$dir = Join-Path $env:TEMP "beatforge-install"
New-Item -ItemType Directory -Force $dir | Out-Null
$exe = Join-Path $dir $asset.name
Write-Host "Downloading BeatForge $($release.tag_name) ($([math]::Round($asset.size / 1MB)) MB)..."
Invoke-WebRequest $asset.browser_download_url -OutFile $exe -UseBasicParsing

$actual = [Convert]::ToBase64String([Security.Cryptography.SHA512]::Create().ComputeHash([IO.File]::ReadAllBytes($exe)))
if ($expected -and $actual -ne $expected) { Remove-Item $exe; throw "Checksum mismatch; download discarded." }

Write-Host "Installing..."
$p = Start-Process $exe -ArgumentList "/S" -Wait -PassThru
if ($p.ExitCode -ne 0) { throw "Installer exited with code $($p.ExitCode)" }
Remove-Item $exe

$app = Join-Path $env:LOCALAPPDATA "Programs\BeatForge\BeatForge.exe"
Write-Host "BeatForge $($release.tag_name) installed at $app"
if (-not $NoRun -and (Test-Path $app)) { Start-Process $app }
