# Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
# Licensed under the MIT License. See LICENSE file in the project root for more information.

<#
.SYNOPSIS
Builds the release and packs it as the installer.

.DESCRIPTION
Stages the shared files through Build-Release.ps1, then compiles thumbico.iss into
build/installer/Thumbico-<version>-windows-x64-setup.exe. Nothing is added to the staged folder:
the settings file and the README the Portable package needs are exactly what an installed copy
must not have.

.PARAMETER Flutter
The flutter command to build with. Defaults to the main-channel SDK, whose prerelease Dart
pubspec.yaml requires.

.PARAMETER Iscc
The Inno Setup 7 command-line compiler. Defaults to the per-user install, which is neither on
PATH nor under Program Files.

.PARAMETER Fast
Skips compression, for iterating on the script.
#>

#Requires -Version 7

param(
  [string] $Flutter = 'C:\Programs\Develop\Flutter\main\bin\flutter.bat',
  [string] $Iscc = (Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 7\ISCC.exe'),
  [switch] $Fast
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Resolve-Path (Join-Path $PSScriptRoot '..' '..')
$output = Join-Path $root 'build' 'installer'
$files = Join-Path $output 'files'

$staged = & (Join-Path $PSScriptRoot '..' 'common' 'Build-Release.ps1') `
  -Destination $files -Flutter $Flutter

# The script holds no version and no absolute path; both arrive here
$options = @(
  "--define=AppVersion=$($staged.Version)"
  "--define=StagingDir=$($staged.Path)"
  "--output-dir=$output"
  '--messages-jsonl'
)
if ($Fast) {
  $options += '--no-compression'
}

& $Iscc @options (Join-Path $PSScriptRoot 'thumbico.iss') | Out-Host
if ($LASTEXITCODE -ne 0) {
  throw "ISCC failed with exit code $LASTEXITCODE"
}

Write-Host "Created $(Join-Path $output "Thumbico-$($staged.Version)-windows-x64-setup.exe")"
