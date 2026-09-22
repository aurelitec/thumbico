# Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
# Licensed under the MIT License. See LICENSE file in the project root for more information.

<#
.SYNOPSIS
Builds the Windows release from a clean tree, for the package scripts to pack.

.DESCRIPTION
Runs flutter clean, then flutter build windows --release. The clean also deletes the packages an
earlier run left under build/. make_installer.ps1 and make_portable.ps1 pack the result without
building, so a change to a file only a package ships needs no new build.

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

$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$step = Join-Path $PSScriptRoot 'common' 'write_step.ps1'

Push-Location $root
try {
  & $step 'Cleaning the previous build'
  & $Flutter clean
  if ($LASTEXITCODE -ne 0) {
    throw "flutter clean failed with exit code $LASTEXITCODE"
  }

  & $step 'Building the release'
  & $Flutter build windows --release
  if ($LASTEXITCODE -ne 0) {
    throw "flutter build failed with exit code $LASTEXITCODE"
  }
} finally {
  Pop-Location
}
