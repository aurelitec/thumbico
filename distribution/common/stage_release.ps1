# Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
# Licensed under the MIT License. See LICENSE file in the project root for more information.

<#
.SYNOPSIS
Stages the files every release package shares from the existing release build.

.DESCRIPTION
Fills Destination with the release folder that build_release.ps1 left, the three Visual C++
runtime DLLs the executable imports, and LICENSE.txt. Returns the version read from the built
executable and the staged path, so a caller names its output after what was actually built. Each
package adds its own extras afterwards.

.PARAMETER Destination
The folder to stage into. It is emptied first, so nothing from an earlier run is packed.
#>

#Requires -Version 7

param(
  [Parameter(Mandatory)] [string] $Destination
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = Resolve-Path (Join-Path $PSScriptRoot '..' '..')
$release = Join-Path $root 'build' 'windows' 'x64' 'runner' 'Release'
$exe = Join-Path $release 'thumbico.exe'

if (-not (Test-Path $exe)) {
  throw "No release build in $release. Run distribution/build_release.ps1 first."
}

# The numeric file version holds major, minor, and patch whether or not the pubspec version has a
# build suffix
$info = (Get-Item $exe).VersionInfo
$version = "$($info.FileMajorPart).$($info.FileMinorPart).$($info.FileBuildPart)"

# A version bumped after the build would otherwise name the package after a version it does not hold
$pubspec = Get-Content (Join-Path $root 'pubspec.yaml') -Raw
if ($pubspec -notmatch '(?m)^version:\s*(\d+\.\d+\.\d+)') {
  throw 'No version found in pubspec.yaml'
}
if ($Matches[1] -ne $version) {
  throw "The release build is version $version but pubspec.yaml says $($Matches[1]). " +
    'Run distribution/build_release.ps1 again.'
}

# Start from an empty folder, so nothing from an earlier run is packed
if (Test-Path $Destination) {
  Remove-Item $Destination -Recurse -Force
}
New-Item $Destination -ItemType Directory | Out-Null

# The app: the executable, the engine, and the data folder
Copy-Item (Join-Path $release '*') $Destination -Recurse

# The Visual C++ runtime beside the executable, for PCs that do not have it installed
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio' 'Installer' 'vswhere.exe'
$vs = & $vswhere -latest -products '*' `
  -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
$redistVersionFile = Join-Path $vs 'VC\Auxiliary\Build\Microsoft.VCRedistVersion.default.txt'
$redistVersion = (Get-Content $redistVersionFile).Trim()
$crt = Get-Item (Join-Path $vs "VC\Redist\MSVC\$redistVersion\x64\Microsoft.VC*.CRT")
foreach ($dll in 'msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll') {
  Copy-Item (Join-Path $crt $dll) $Destination
}

# What the user reads, rewritten with CRLF line endings: the repo keeps LF, which the Notepad of
# older Windows 10 builds shows as one line
Get-Content (Join-Path $root 'LICENSE') | Set-Content (Join-Path $Destination 'LICENSE.txt')

[PSCustomObject] @{
  Version = $version
  Path    = (Resolve-Path $Destination).Path
}
