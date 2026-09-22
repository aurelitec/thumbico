# Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
# Licensed under the MIT License. See LICENSE file in the project root for more information.

<#
.SYNOPSIS
Builds the release and packs it as the installer.

.DESCRIPTION
Stages the shared files through Build-Release.ps1, adds the end-user README written for an
installed copy, then compiles thumbico.iss into
build/installer/Thumbico-<version>-windows-x64-setup.exe. The settings file the Portable package
adds is deliberately absent, since it is what would send an installed copy's settings back beside
its own executable.

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

# What the user reads, written for an installed copy rather than a portable one, and with CRLF
# line endings as LICENSE.txt is
Get-Content (Join-Path $PSScriptRoot 'README.txt') | Set-Content (Join-Path $files 'README.txt')

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
