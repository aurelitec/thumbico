# Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
# Licensed under the MIT License. See LICENSE file in the project root for more information.

<#
.SYNOPSIS
Builds the release and stages the files every release package shares.

.DESCRIPTION
Builds the Windows release, then fills Destination with the release folder, the three Visual C++
runtime DLLs the executable imports, and LICENSE.txt. Returns the version read from pubspec.yaml
and the staged path, so a caller names its output without parsing the pubspec again. Each package
adds its own extras afterwards.

.PARAMETER Destination
The folder to stage into. It is emptied first, so nothing from an earlier run is packed.

.PARAMETER Flutter
The flutter command to build with. Defaults to the main-channel SDK, whose prerelease Dart
pubspec.yaml requires.
#>

#Requires -Version 7

param(
  [Parameter(Mandatory)] [string] $Destination,
  [string] $Flutter = 'C:\Programs\Develop\Flutter\main\bin\flutter.bat'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Resolve-Path (Join-Path $PSScriptRoot '..' '..')

# Read before building, so a malformed pubspec fails in seconds rather than after a full build
$pubspec = Get-Content (Join-Path $root 'pubspec.yaml') -Raw
if ($pubspec -notmatch '(?m)^version:\s*(\d+\.\d+\.\d+)') {
  throw 'No version found in pubspec.yaml'
}
$version = $Matches[1]

# Piped to Out-Host so the build's own output stays out of this script's return value
Push-Location $root
try {
  & $Flutter build windows --release | Out-Host
  if ($LASTEXITCODE -ne 0) {
    throw "flutter build failed with exit code $LASTEXITCODE"
  }
} finally {
  Pop-Location
}

# Start from an empty folder, so nothing from an earlier run is packed
if (Test-Path $Destination) {
  Remove-Item $Destination -Recurse -Force
}
New-Item $Destination -ItemType Directory | Out-Null

# The app: the executable, the engine, and the data folder
$release = Join-Path $root 'build' 'windows' 'x64' 'runner' 'Release'
Copy-Item (Join-Path $release '*') $Destination -Recurse

# The Visual C++ runtime beside the executable, for PCs that do not have it installed
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio' 'Installer' 'vswhere.exe'
$vs = & $vswhere -latest -products '*' `
  -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
$redistVersionFile = Join-Path $vs 'VC\Auxiliary\Build\Microsoft.VCRedistVersion.default.txt'
$redistVersion = (Get-Content $redistVersionFile).Trim()
$crt = Get-Item (Join-Path $vs "VC\Redist\MSVC\$redistVersion\x64\Microsoft.VC*.CRT")
foreach ($dll in 'msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll') {
  Copy-Item (Join-Path $crt $dll) $Destination
}

# What the user reads, rewritten with CRLF line endings: the repo keeps LF, which the Notepad of
# older Windows 10 builds shows as one line
Get-Content (Join-Path $root 'LICENSE') | Set-Content (Join-Path $Destination 'LICENSE.txt')

[PSCustomObject] @{
  Version = $version
  Path    = (Resolve-Path $Destination).Path
}
