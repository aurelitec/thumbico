# Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
# Licensed under the MIT License. See LICENSE file in the project root for more information.

<#
.SYNOPSIS
Packs the existing release build as the installer.

.DESCRIPTION
Stages the shared files through stage_release.ps1, adds the end-user README written for an
installed copy, then compiles thumbico.iss into
build/installer/Thumbico-<version>-windows-x64-setup.exe. Nothing is built here; run
build_release.ps1 first, or make_release.ps1 for both packages. The settings file the Portable
package adds is deliberately absent, since it is what would send an installed copy's settings back
beside its own executable.

.PARAMETER Iscc
The Inno Setup 7 command-line compiler. Defaults to the per-user install, which is neither on
PATH nor under Program Files.
#>

#Requires -Version 7

param(
  [string] $Iscc = (Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 7\ISCC.exe')
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Resolve-Path (Join-Path $PSScriptRoot '..' '..')
$output = Join-Path $root 'build' 'installer'
$files = Join-Path $output 'files'

& (Join-Path $PSScriptRoot '..' 'common' 'write_step.ps1') 'Making the installer'

$staged = & (Join-Path $PSScriptRoot '..' 'common' 'stage_release.ps1') -Destination $files

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

& $Iscc @options (Join-Path $PSScriptRoot 'thumbico.iss') | Out-Host
if ($LASTEXITCODE -ne 0) {
  throw "ISCC failed with exit code $LASTEXITCODE"
}

Write-Host "Created $(Join-Path $output "Thumbico-$($staged.Version)-windows-x64-setup.exe")"
