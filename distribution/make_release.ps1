# Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
# Licensed under the MIT License. See LICENSE file in the project root for more information.

<#
.SYNOPSIS
Builds the release from a clean tree and packs it as both the installer and the Portable package.

.DESCRIPTION
Runs build_release.ps1 once, then make_installer.ps1 and make_portable.ps1, so both packages hold
the same build. Each script can also be run on its own.
#>

#Requires -Version 7

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$timer = [Diagnostics.Stopwatch]::StartNew()

& (Join-Path $PSScriptRoot 'build_release.ps1')
& (Join-Path $PSScriptRoot 'installer' 'make_installer.ps1')
& (Join-Path $PSScriptRoot 'portable' 'make_portable.ps1')

# The clean at the start leaves this run's two packages as the only ones under build/
$build = Join-Path $PSScriptRoot '..' 'build'
$packages = @(
  Get-Item (Join-Path $build 'installer' '*-setup.exe')
  Get-Item (Join-Path $build 'portable' '*-portable.zip')
)

Write-Host ''
Write-Host "Done in $($timer.Elapsed.Minutes) min $($timer.Elapsed.Seconds) s" -ForegroundColor Green
$width = ($packages.Name | Measure-Object -Property Length -Maximum).Maximum
foreach ($package in $packages) {
  Write-Host ('  {0}  {1,7:N1} MB' -f $package.Name.PadRight($width), ($package.Length / 1MB)) `
    -ForegroundColor Green
}
Write-Host "  in $((Resolve-Path $build).Path)" -ForegroundColor Green
