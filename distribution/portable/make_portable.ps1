# Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
# Licensed under the MIT License. See LICENSE file in the project root for more information.

<#
.SYNOPSIS
Packs the existing release build as the Portable package.

.DESCRIPTION
Stages the shared files through stage_release.ps1, adds the end-user README and the settings file
that makes the copy portable, then zips them into
build/portable/Thumbico-<version>-windows-x64-portable.zip. Nothing is built here; run
build_release.ps1 first, or make_release.ps1 for both packages.
#>

#Requires -Version 7

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Resolve-Path (Join-Path $PSScriptRoot '..' '..')
$output = Join-Path $root 'build' 'portable'
$files = Join-Path $output 'files'

$staged = & (Join-Path $PSScriptRoot '..' 'common' 'stage_release.ps1') -Destination $files

# What the user reads, with CRLF line endings as LICENSE.txt is
Get-Content (Join-Path $PSScriptRoot 'README.txt') | Set-Content (Join-Path $files 'README.txt')

# The settings file beside the executable is what makes this copy portable
Set-Content (Join-Path $files 'Thumbico.settings.json') '{}' -NoNewline

# Pack the folder's contents, with no folder of its own inside the zip
$zip = Join-Path $output "Thumbico-$($staged.Version)-windows-x64-portable.zip"
Compress-Archive -Path (Join-Path $files '*') -DestinationPath $zip -Force
Write-Host "Created $zip"
