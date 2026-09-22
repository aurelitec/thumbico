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

& (Join-Path $PSScriptRoot 'build_release.ps1')
& (Join-Path $PSScriptRoot 'installer' 'make_installer.ps1')
& (Join-Path $PSScriptRoot 'portable' 'make_portable.ps1')
