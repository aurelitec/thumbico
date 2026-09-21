; Copyright (c) 2011-2026 Aurelitec <https://www.aurelitec.com>
; Licensed under the MIT License. See LICENSE file in the project root for more information.

; Built by make_installer.ps1, which stages the files and passes the version in.

#ifndef AppVersion
  #error AppVersion is not defined. Run make_installer.ps1 rather than compiling this by hand.
#endif
#ifndef StagingDir
  #error StagingDir is not defined. Run make_installer.ps1 rather than compiling this by hand.
#endif

[Setup]
; Never change AppId: it is how Windows recognises an existing install.
AppId={{C2BC5DDB-A953-494B-9EE3-285A618D2B97}
AppName=Thumbico
AppVersion={#AppVersion}
AppPublisher=Aurelitec
AppCopyright=Copyright © 2011-2026 Aurelitec
AppPublisherURL=https://www.aurelitec.com/
AppSupportURL=https://www.aurelitec.com/thumbico/help/
AppUpdatesURL=https://www.aurelitec.com/thumbico/

; Without this, Apps & features shows "Thumbico 2.0.0" beside a version column already reading 2.0.0
UninstallDisplayName=Thumbico
UninstallDisplayIcon={app}\thumbico.exe

; The icon the app already ships, referenced in place so the two cannot drift
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
VersionInfoDescription=Thumbico Setup

; Also sets ArchitecturesAllowed and ArchitecturesInstallIn64BitMode to x64compatible
SetupArchitecture=x64
MinVersion=10.0

; Per-user without a UAC prompt, with a dialog offering an install for all users
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
DefaultDirName={autopf}\Aurelitec\Thumbico
DisableProgramGroupPage=yes
LicenseFile={#StagingDir}\LICENSE.txt

WizardStyle=modern dynamic windows11

Compression=lzma2/max
SolidCompression=yes
OutputBaseFilename=Thumbico-{#AppVersion}-windows-x64-setup

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; The staged folder is the install image, so nothing is named: a list would miss whatever a
; future Flutter release adds beside the executable.
Source: "{#StagingDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Thumbico"; Filename: "{app}\thumbico.exe"
Name: "{autodesktop}\Thumbico"; Filename: "{app}\thumbico.exe"; Tasks: desktopicon

[Run]
; runasoriginaluser is already the default for a postinstall entry, so an all-users install
; still starts Thumbico with the user's own credentials.
Filename: "{app}\thumbico.exe"; Description: "{cm:LaunchProgram,Thumbico}"; Flags: nowait postinstall skipifsilent
