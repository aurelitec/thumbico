# Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
# Licensed under the MIT License. See LICENSE file in the project root for more information.

<#
.SYNOPSIS
Builds the release and packs it as the Portable package.

.DESCRIPTION
Stages the shared files through Build-Release.ps1, adds the end-user README and the settings file
that makes the copy portable, then zips them into
build/portable/Thumbico-<version>-windows-x64-portable.zip.

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
$output = Join-Path $root 'build' 'portable'
$files = Join-Path $output 'files'

$staged = & (Join-Path $PSScriptRoot '..' 'common' 'Build-Release.ps1') `
  -Destination $files -Flutter $Flutter

# What the user reads
Copy-Item (Join-Path $PSScriptRoot 'README.txt') $files

# The settings file beside the executable is what makes this copy portable
Set-Content (Join-Path $files 'Thumbico.settings.json') '{}' -NoNewline

# Pack the folder's contents, with no folder of its own inside the zip
$zip = Join-Path $output "Thumbico-$($staged.Version)-windows-x64-portable.zip"
Compress-Archive -Path (Join-Path $files '*') -DestinationPath $zip -Force
Write-Host "Created $zip"
