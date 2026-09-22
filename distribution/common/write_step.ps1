# Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
# Licensed under the MIT License. See LICENSE file in the project root for more information.

<#
.SYNOPSIS
Prints the heading of a release step, so each step stands apart in the console output.

.PARAMETER Text
What the step does, such as "Building the release".
#>

#Requires -Version 7

param(
  [Parameter(Mandatory)] [string] $Text
)

Write-Host ''
Write-Host "==> $Text" -ForegroundColor Cyan
