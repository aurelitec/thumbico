# Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
# Licensed under the MIT License. See LICENSE file in the project root for more information.

<#
.SYNOPSIS
Builds the release and packs it as the Portable package.

.DESCRIPTION
Prepares the package's files in build/portable/files, then zips them into
build/portable/Thumbico-<version>-windows-x64-portable.zip, with the version from pubspec.yaml.

.PARAMETER Flutter
The flutter command to build with. Defaults to the main-channel SDK, whose prerelease Dart
pubspec.yaml requires.
#>

#Requires -Version 7

param(
  [string] $Flutter = 'C:\Programs\Develop\Flutter\main\bin\flutter.bat'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Resolve-Path (Join-Path $PSScriptRoot '..' '..')
$release = Join-Path $root 'build' 'windows' 'x64' 'runner' 'Release'
$output = Join-Path $root 'build' 'portable'
$files = Join-Path $output 'files'

# The zip is named for the version in pubspec.yaml
$pubspec = Get-Content (Join-Path $root 'pubspec.yaml') -Raw
if ($pubspec -notmatch '(?m)^version:\s*(\d+\.\d+\.\d+)') {
  throw 'No version found in pubspec.yaml'
}
$version = $Matches[1]
$zip = Join-Path $output "Thumbico-$version-windows-x64-portable.zip"

# Build the release
Push-Location $root
try {
  & $Flutter build windows --release
  if ($LASTEXITCODE -ne 0) {
    throw "flutter build failed with exit code $LASTEXITCODE"
  }
} finally {
  Pop-Location
}

# Start from an empty folder, so nothing from an earlier run is packed
if (Test-Path $files) {
  Remove-Item $files -Recurse -Force
}
New-Item $files -ItemType Directory | Out-Null

# The app: the executable, the engine, and the data folder
Copy-Item (Join-Path $release '*') $files -Recurse

# The Visual C++ runtime beside the executable, for PCs that do not have it installed
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio' 'Installer' 'vswhere.exe'
$vs = & $vswhere -latest -products '*' `
  -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
$redistVersionFile = Join-Path $vs 'VC\Auxiliary\Build\Microsoft.VCRedistVersion.default.txt'
$redistVersion = (Get-Content $redistVersionFile).Trim()
$crt = Get-Item (Join-Path $vs "VC\Redist\MSVC\$redistVersion\x64\Microsoft.VC*.CRT")
foreach ($dll in 'msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll') {
  Copy-Item (Join-Path $crt $dll) $files
}

# What the user reads
Copy-Item (Join-Path $root 'LICENSE') (Join-Path $files 'LICENSE.txt')
Copy-Item (Join-Path $PSScriptRoot 'README.txt') $files

# The settings file beside the executable is what makes this copy portable
Set-Content (Join-Path $files 'Thumbico.settings.json') '{}' -NoNewline

# Pack the folder's contents, with no folder of its own inside the zip
Compress-Archive -Path (Join-Path $files '*') -DestinationPath $zip -Force
Write-Host "Created $zip"
