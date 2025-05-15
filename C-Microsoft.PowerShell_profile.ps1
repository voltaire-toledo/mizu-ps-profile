# ╭─────────────────────────────────────╮
# │ PowerShell 7.x Profile - Windows    │
# ╰─────────────────────────────────────╯

#region Globals...
# Set the debug mode.  Use $DebugPreference for more control.
$DebugPreference = 'SilentlyContinue' # Or: 'Continue', 'Stop', 'Inquire'
$Global:CanConnectToGitHub = $false # Initialize, will be set in MAIN
# Admin Check and Prompt Customization
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
#endregion

#region Helper Functions...
function Write-RBox {
  <#
    .SYNOPSIS
        Displays a multi-line string within a decorated box.

    .DESCRIPTION
        This function takes a string, splits it into lines, and displays it
        within a box constructed of ASCII characters.  It handles ANSI
        escape codes for colored output and adjusts the box size to fit
        the longest line.

    .PARAMETER Text
        The string to display within the box.  Newlines (`n) are
        interpreted as line breaks.
    .PARAMETER BorderColor
        The color of the box border.  Default is Cyan.
        Use $PSStyle.Foreground.<ColorName> to set the color.

    .EXAMPLE
        Write-RBox -Text "This is a test`nwith multiple lines."
  #>
  param (
    [string]$Text,
    [string]$BorderColor = $PSStyle.Foreground.Cyan
  )

  # Decoration variables
  $RstC = $PSStyle.Reset

  # Handle the multiple lines split
  $Lines = $Text -split "`r?`n|`r"

  # Calculate the maximum length of the lines to adjust the box size
  $MaxLength = 0
  foreach ($Line in $Lines) {
    $PrintableLineLength = ($Line -replace "`e\[[\d;]*m", '').Length
    if ($PrintableLineLength -gt $MaxLength) {
      $MaxLength = $PrintableLineLength
    }
  }
    
  # Calculate the number of spaces needed for the box
  $Spaces = ($MaxLength + 2)

  # Print the top border
  Write-Host "$($BorderColor)╭$("─" * $($Spaces))╮$($RstC)"

  # Print the lines inside the box
  foreach ($Line in $Lines) {
    if ($Line.Contains("#divider#")) {
      Write-Host "$($BorderColor)├$("$($BorderColor)─" * $($Spaces))$($BorderColor)┤$($RstC)"
    }
    else {
      $LBorder = "$($BorderColor)│$($RstC) "
      $RBorder = " $($BorderColor)│$($RstC)"
      $PrintableLine = $Line -replace "`e\[[\d;]*m", ''       
      $PadSpaces = $(" " * $($MaxLength - $PrintableLine.Length))
      Write-Host "$($LBorder)$($Line)$($PadSpaces)$($RBorder)"
    }
  }
  # Print the bottom border
  Write-Host "$($PSStyle.Foreground.Cyan)╰$("─" * $($Spaces))$($PSStyle.Foreground.Cyan)╯"
}

function Show-Features {
  <#
    .SYNOPSIS
        Displays help information for the PowerShell profile.

    .DESCRIPTION
        This function displays a formatted help message, including
        available aliases, functions, and their descriptions.  It uses
        the Write-RBox function to present the information in a
        user-friendly box.

    .EXAMPLE
        Show-Help
  #>
  # Decoration variables
  $SecC = $PSStyle.Foreground.BrightMagenta
  $FunC = $PSStyle.Foreground.BrightYellow
  $ParC = $PSStyle.Foreground.Green + $PSStyle.Italic
  $RstC = $PSStyle.Reset

  # Use here-string for better multi-line string handling
  $HelpText = @"
$($SecC)PowerShell Profile Help$($RstC)

$($SecC)   Host:$($RstC) $($Host.Name)
$($SecC)Profile:$($RstC) $PROFILE
#divider#
$($SecC)Features:$($RstC)
  - Winget argument completer
  - Az CLI Argument Completer
  - Choco argument completer
  
$($SecC)Terraform Aliases:
  $($FunC)tf $($RstC)`t       ⁝ $($FunC)terraform         
  $($FunC)tfi$($RstC)`t       ⁝ $($FunC)terraform init -upgrade        
  $($FunC)tfp$($RstC)`t       ⁝ $($FunC)terraform plan        
  $($FunC)tfa$($RstC)`t       ⁝ $($FunC)terraform apply -auto-approve        
  $($FunC)tfd$($RstC)`t       ⁝ $($FunC)terraform destroy -auto-approve
  
$($SecC)Git/GitHub Aliases:
  $($FunC)g$($RstC)               ⁝ Changes to the GitHub directory.
  $($FunC)ga$($RstC)              ⁝ $($FunC)git add .
  $($FunC)gc $($ParC)message$($RstC)      ⁝ $($FunC)git commit -m$($RstC) with the commit's message.
  $($FunC)gcom $($ParC)message$($RstC)    ⁝ $($FunC)git add . && git commit -m$($RstC) with the commit's string.
  $($FunC)gp$($RstC)              ⁝ $($FunC)git push
  $($FunC)gs$($RstC)              ⁝ $($FunC)git status
  $($FunC)yeetg $($ParC)message$($RstC)   ⁝ Just $($FunC)add-commit-push$($RstC) and yeet that shit!
  
$($SecC)Other Functions:
  $($FunC)cpy $($ParC)[text]$($RstC)          ⁝ Copies text to the clipboard.
  $($FunC)df$($RstC)                  ⁝ Displays volume information.
  $($FunC)docs$($RstC)                ⁝ Changes to the Documents folder.
  $($FunC)dtop$($RstC)                ⁝ Changes to the Desktop folder.
  $($FunC)Edit-Profile$($RstC)        ⁝ Opens the CurrentUserCurrentHost PSProfile for editing.
  $($FunC)ep$($RstC)                  ⁝ Opens the CurrentUserAllHosts PSProfile for editing.
  $($FunC)export $($ParC)[env] [var]$($RstC)  ⁝ Sets an environment variable.
  $($FunC)ff $($ParC)[name]$($RstC)           ⁝ Finds files recursively.
  $($FunC)flushdns$($RstC)            ⁝ Clears the DNS cache.
  $($FunC)Get-PubIP$($RstC)           ⁝ Retrieves the public IP.
  $($FunC)grep $($ParC)[regex] [dir]$($RstC)  ⁝ Searches for a regex pattern.
  $($FunC)hb $($ParC)[file]$($RstC)           ⁝ Uploads to hastebin-like service.
  $($FunC)head$ $($ParC)[path] [n]$($RstC)    ⁝ Displays the first n lines.
  $($FunC)k9 $($ParC)[name]$($RstC)           ⁝ Kills a process by name.
  $($FunC)la$($RstC)                  ⁝ Lists files with details.
  $($FunC)ll$($RstC)                  ⁝ Lists all files (including hidden) with details.
  $($FunC)mkcd $($ParC)[dir]$($RstC)          ⁝ Creates and changes to a directory.
  $($FunC)nf $($ParC)[name]$($RstC)           ⁝ Creates a new file.
  $($FunC)o $($ParC)[dir]$($RstC)             ⁝ Open $($FunC)explorer.exe$($RstC) and set $($ParC)[dir]$($RstC) as the CWD
  $($FunC)pgrep $($ParC)[name]$($RstC)        ⁝ Lists processes by name.
  $($FunC)pkill $($ParC)[name]$($RstC)        ⁝ Kills processes by name.
  $($FunC)pst$($RstC)                 ⁝ Retrieves text from the clipboard.
  $($FunC)reload-profile$($RstC)      ⁝ Reloads the PowerShell profile.
  $($FunC)sed $($ParC){1} {2} {3}$($RstC)     ⁝ Replaces text in a file. Values are:
                        $($ParC){1}$($RstC)  $($ParC)File$($RstC) to replace text inside it
                        $($ParC){2}$($RstC) = $($ParC)String to find$($RstC) and replace
                        $($ParC){3}$($RstC) = $($ParC)String to replace$($RstC) what was found
  $($FunC)sysinfo$($RstC)             ⁝ Displays system information.
  $($FunC)tail $($ParC)[file] [n]$($RstC)     ⁝ Displays the last $($ParC)[n]$($RstC) lines of the $($ParC)[file]$($RstC).
  $($FunC)touch $($ParC)[file]$($RstC)        ⁝ Creates a new empty $($ParC)[file]$($RstC).
  $($FunC)unzip$ $($ParC)[file]$($RstC)       ⁝ Extracts a zip file.
  $($FunC)Update-PowerShell$($RstC)   ⁝ Checks for PowerShell updates.
  $($FunC)uptime$($RstC)              ⁝ Displays system uptime.
  $($FunC)which $($ParC)[command]$($RstC)     ⁝ Shows the path of the $($ParC)[command]$($RstC).
"@

  # Print the help text in a box
  Write-RBox -Text $HelpText
}
#endregion

#region PSProfile Management...
# ╭───────────────────────────────────────────────╮
# │ Update-Profile(): Update $PROFILE from GitHub │
# ╰───────────────────────────────────────────────╯
function Update-Profile {
  try {
    $url = "https://raw.githubusercontent.com/ChrisTitusTech/powershell-profile/main/Microsoft.PowerShell_profile.ps1"
    $oldhash = Get-FileHash $PROFILE
    Invoke-RestMethod $url -OutFile "$env:temp/Microsoft.PowerShell_profile.ps1"
    $newhash = Get-FileHash "$env:temp/Microsoft.PowerShell_profile.ps1"
    if ($newhash.Hash -ne $oldhash.Hash) {
      Copy-Item -Path "$env:temp/Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force
      Write-Host "Profile has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
    }
    else {
      Write-Host "Profile is up to date." -ForegroundColor Green
    }
  }
  catch {
    Write-Error "Unable to check for `$profile updates: $_"
  }
  finally {
    Remove-Item "$env:temp/Microsoft.PowerShell_profile.ps1" -ErrorAction SilentlyContinue
  }
}

# Edit-Profile(): Edit the $PROFILE.CurrentUserAllHosts profile
function Edit-Profile {
  vim $PROFILE.CurrentUserAllHosts
}

# Edit-ThisProfile(): Edit the $PROFILE.CurrentUserAllHosts profile
function Edit-ThisProfile {
  vim $PROFILE.CurrentUserCurrentHost
}
#endregion

#region Aliases & Functions...
function touch($file) { 
  # touch -> Create a new empty file
  "" | Out-File $file -Encoding ASCII 
}

function ff($name) { 
  # ff -> Find files recursively
  Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "$($_.FullName)" } 
}

function Get-PublicIP { 
  # Get-PublicIP -> Get the public IP address
  (Invoke-WebRequest http://ifconfig.me/ip).Content 
}

function Update-Profile { 
  # Update-Profile -> Reload the current user's PowerShell profile
  & $profile 
}

function uptime {
  # uptime(): *NIX-style uptime 
  # uptime(): *NIX-style uptime 
  try {
    # find date/time format
    # find date/time format
    $dateFormat = [System.Globalization.CultureInfo]::CurrentCulture.DateTimeFormat.ShortDatePattern
    $timeFormat = [System.Globalization.CultureInfo]::CurrentCulture.DateTimeFormat.LongTimePattern
		
    # check powershell version
    # check powershell version
    if ($PSVersionTable.PSVersion.Major -eq 5) {
      $lastBoot = (Get-WmiObject win32_operatingsystem).LastBootUpTime
      $bootTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($lastBoot)

      # reformat lastBoot
      $lastBoot = $bootTime.ToString("$dateFormat $timeFormat")
    }
    else {
      $lastBoot = net statistics workstation | Select-String "since" | ForEach-Object { $_.ToString().Replace('Statistics since ', '') }
      $bootTime = [System.DateTime]::ParseExact($lastBoot, "$dateFormat $timeFormat", [System.Globalization.CultureInfo]::InvariantCulture)
    }

    # Format the start time
    $formattedBootTime = $bootTime.ToString("dddd, MMMM dd, yyyy HH:mm:ss", [System.Globalization.CultureInfo]::InvariantCulture) + " [$lastBoot]"
    Write-Host "System started on: $formattedBootTime" -ForegroundColor DarkGray

    # calculate uptime
    $uptime = (Get-Date) - $bootTime

    # Uptime in days, hours, minutes, and seconds
    $days = $uptime.Days
    $hours = $uptime.Hours
    $minutes = $uptime.Minutes
    $seconds = $uptime.Seconds

    # Uptime output
    Write-Host ("Uptime: {0} days, {1} hours, {2} minutes, {3} seconds" -f $days, $hours, $minutes, $seconds) -ForegroundColor Blue

  }
  catch {
    Write-Error "An error occurred while retrieving system uptime."
  }
}

function Update-PowerShell {
  # Update-PowerShell(): Update to the latest PowerShell 7.x release
  try {
    Write-Host "Checking for PowerShell updates..." -ForegroundColor Cyan
    $updateNeeded = $false
    $currentVersion = $PSVersionTable.PSVersion.ToString()
    $gitHubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
    $latestReleaseInfo = Invoke-RestMethod -Uri $gitHubApiUrl
    $latestVersion = $latestReleaseInfo.tag_name.Trim('v')
    if ($currentVersion -lt $latestVersion) {
      $updateNeeded = $true
    }
    
    if ($updateNeeded) {
      Write-Host "Updating PowerShell..." -ForegroundColor Yellow
      Start-Process powershell.exe -ArgumentList "-NoProfile -Command winget upgrade Microsoft.PowerShell --accept-source-agreements --accept-package-agreements" -Wait -NoNewWindow
      Write-Host "PowerShell has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
    }
    else {
      Write-Host "Your PowerShell is up to date." -ForegroundColor Green
    }
  }
  catch {
    Write-Error "Failed to update PowerShell. Error: $_"
  }
}

function Clear-Cache {
  # Clear-Cache(): Clear Windows Prefetch, Temp and Browser cache contents
  # add clear cache logic here
  Write-Host "Clearing cache..." -ForegroundColor Cyan

  # Clear Windows Prefetch
  Write-Host "Clearing Windows Prefetch..." -ForegroundColor Yellow
  Remove-Item -Path "$env:SystemRoot\Prefetch\*" -Force -ErrorAction SilentlyContinue

  # Clear Windows Temp
  Write-Host "Clearing Windows Temp..." -ForegroundColor Yellow
  Remove-Item -Path "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

  # Clear User Temp
  Write-Host "Clearing User Temp..." -ForegroundColor Yellow
  Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

  # Clear Internet Explorer Cache
  Write-Host "Clearing Internet Explorer Cache..." -ForegroundColor Yellow
  Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*" -Recurse -Force -ErrorAction SilentlyContinue

  Write-Host "Cache clearing completed." -ForegroundColor Green
}

function unzip ($file) {
  Write-Output("Extracting", $file, "to", $pwd)
  $fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }
  Expand-Archive -Path $fullFile -DestinationPath $pwd
}
function hb {
  if ($args.Length -eq 0) {
    Write-Error "No file path specified."
    return
  }
    
  $FilePath = $args[0]
    
  if (Test-Path $FilePath) {
    $Content = Get-Content $FilePath -Raw
  }
  else {
    Write-Error "File path does not exist."
    return
  }
    
  $uri = "http://bin.christitus.com/documents"
  try {
    $response = Invoke-RestMethod -Uri $uri -Method Post -Body $Content -ErrorAction Stop
    $hasteKey = $response.key
    $url = "http://bin.christitus.com/$hasteKey"
    Set-Clipboard $url
    Write-Output $url
  }
  catch {
    Write-Error "Failed to upload the document. Error: $_"
  }
}
function grep($regex, $dir) {
  if ( $dir ) {
    Get-ChildItem $dir | select-string $regex
    return
  }
  $input | select-string $regex
}

function df {
  get-volume
}

function sed($file, $find, $replace) {
  (Get-Content $file).replace("$find", $replace) | Set-Content $file
}

function which($name) {
  Get-Command $name | Select-Object -ExpandProperty Definition
}

function export($name, $value) {
  set-item -force -path "env:$name" -value $value;
}

function pkill($name) {
  Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

function pgrep($name) {
  Get-Process $name
}

function head {
  param($Path, $n = 10)
  Get-Content $Path -Head $n
}

function tail {
  param($Path, $n = 10, [switch]$f = $false)
  Get-Content $Path -Tail $n -Wait:$f
}

# Quick File Creation
function nf { param($name) New-Item -ItemType "file" -Path . -Name $name }

# Directory Management
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }

function trash($path) {
  $fullPath = (Resolve-Path -Path $path).Path

  if (Test-Path $fullPath) {
    $item = Get-Item $fullPath

    if ($item.PSIsContainer) {
      # Handle directory
      $parentPath = $item.Parent.FullName
    }
    else {
      # Handle file
      $parentPath = $item.DirectoryName
    }

    $shell = New-Object -ComObject 'Shell.Application'
    $shellItem = $shell.NameSpace($parentPath).ParseName($item.Name)

    if ($item) {
      $shellItem.InvokeVerb('delete')
      Write-Host "Item '$fullPath' has been moved to the Recycle Bin."
    }
    else {
      Write-Host "Error: Could not find the item '$fullPath' to trash."
    }
  }
  else {
    Write-Host "Error: Item '$fullPath' does not exist."
  }
}

### Quality of Life Aliases

# Navigation Shortcuts
function docs { 
  $docs = if (([Environment]::GetFolderPath("MyDocuments"))) { ([Environment]::GetFolderPath("MyDocuments")) } else { $HOME + "\Documents" }
  Set-Location -Path $docs
}
    
function dtop { 
  $dtop = if ([Environment]::GetFolderPath("Desktop")) { [Environment]::GetFolderPath("Desktop") } else { $HOME + "\Documents" }
  Set-Location -Path $dtop
}

# Simplified Process Management
function k9 { Stop-Process -Name $args[0] }

# Enhanced Listing
function la { Get-ChildItem | Format-Table -AutoSize }
function ll { Get-ChildItem -Force | Format-Table -AutoSize }

# Git Shortcuts
function gs { git status }

function ga { git add . }

function gc { param($m) git commit -m "$m" }

function gp { git push }

function gcl { git clone "$args" }

function gcom {
  git add .
  git commit -m "$args"
}
function lazyg {
  git add .
  git commit -m "$args"
  git push
}

# Quick Access to System Information
function sysinfo { Get-ComputerInfo }

# Networking Utilities
function flushdns {
  Clear-DnsClientCache
  Write-Host "DNS has been flushed"
}

# Clipboard Utilities
function cpy { Set-Clipboard $args[0] }

function pst { Get-Clipboard }

function tf { terraform $args }

function tfi { terraform init -upgrade $args }
# set-alias -Name "tfi"  -Value func-tfi

function tfp { terraform plan $args }
# set-alias -Name "tfp"  -Value func-tfp

function tfa { terraform apply -auto-approve $args }
# set-alias -Name "tfa"  -Value func-tfa

function tfd { terraform destroy -auto-approve $args }

function o { explorer.exe $args }
#endregion

#region Main()
# ╭────────────────────────────────╮
# │ Profile Processing begins here │
# ╰────────────────────────────────╯
#opt-out of telemetry before doing anything, only if PowerShell is run as admin
if ([bool]([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsSystem) {
  [System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', 'true', [System.EnvironmentVariableTarget]::Machine)
}

# Initial GitHub.com connectivity check with 1 second timeout
$global:canConnectToGitHub = Test-Connection github.com -Count 1 -Quiet -TimeoutSeconds 1

# Ensure Terminal-Icons module is installed before importing 
if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
  try {
    Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
  }
  catch {
    if ($debug) {
      Print-RBox "$($PSStyle.Foreground.Red)Failed to install Terminal-Icons module. Error: $_"
    }
  }
}
else {
  try {
    Import-Module -Name Terminal-Icons -Force
  }
  catch {
    if ($debug) {
      Print-RBox "$($PSStyle.Foreground.Red)Failed to import Terminal-Icons module. Error: $_"
    }
  }
}

# Import the $ChocolateyProfile PSM1 if available 
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}


# function prompt {
#   if ($isAdmin) { "[" + (Get-Location) + "] # " } else { "[" + (Get-Location) + "] $ " }
# }
# $adminSuffix = if ($isAdmin) { " [ADMIN]" } else { "" }
# $Host.UI.RawUI.WindowTitle = "PowerShell {0}$adminSuffix" -f $PSVersionTable.PSVersion.ToString()

# # Utility Functions
# function Test-CommandExists {
#   param($command)
#   $exists = $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
#   return $exists
# }

# # Editor Configuration
# $EDITOR = if (Test-CommandExists nvim) { 'nvim' }
# elseif (Test-CommandExists pvim) { 'pvim' }
# elseif (Test-CommandExists vim) { 'vim' }
# elseif (Test-CommandExists vi) { 'vi' }
# elseif (Test-CommandExists code) { 'code' }
# elseif (Test-CommandExists notepad++) { 'notepad++' }
# elseif (Test-CommandExists sublime_text) { 'sublime_text' }
# else { 'notepad' }
# Set-Alias -Name vim -Value $EDITOR

# # System Utilities
# function admin {
#   if ($args.Count -gt 0) {
#     $argList = $args -join ' '
#     Start-Process wt -Verb runAs -ArgumentList "pwsh.exe -NoExit -Command $argList"
#   }
#   else {
#     Start-Process wt -Verb runAs
#   }
# }

# # Set UNIX-like aliases for the admin command, so sudo <command> will run the command with elevated rights.
# Set-Alias -Name su -Value admin



# Enhanced PowerShell Experience
# Enhanced PSReadLine Configuration
$PSReadLineOptions = @{
  EditMode                      = 'Windows'
  HistoryNoDuplicates           = $true
  HistorySearchCursorMovesToEnd = $true
  Colors                        = @{
    Command   = '#87CEEB'  # SkyBlue (pastel)
    Parameter = '#98FB98'  # PaleGreen (pastel)
    Operator  = '#FFB6C1'  # LightPink (pastel)
    Variable  = '#DDA0DD'  # Plum (pastel)
    String    = '#FFDAB9'  # PeachPuff (pastel)
    Number    = '#B0E0E6'  # PowderBlue (pastel)
    Type      = '#F0E68C'  # Khaki (pastel)
    Comment   = '#D3D3D3'  # LightGray (pastel)
    Keyword   = '#8367c7'  # Violet (pastel)
    Error     = '#FF6347'  # Tomato (keeping it close to red for visibility)
  }
  PredictionSource              = 'History'
  PredictionViewStyle           = 'ListView'
  BellStyle                     = 'None'
}
Set-PSReadLineOption @PSReadLineOptions

# Custom key handlers
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord
Set-PSReadLineKeyHandler -Chord 'Alt+d' -Function DeleteWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+LeftArrow' -Function BackwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+RightArrow' -Function ForwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
Set-PSReadLineKeyHandler -Chord 'Ctrl+y' -Function Redo

# Custom functions for PSReadLine
Set-PSReadLineOption -AddToHistoryHandler {
  param($line)
  $sensitive = @('password', 'secret', 'token', 'apikey', 'connectionstring')
  $hasSensitive = $sensitive | Where-Object { $line -match $_ }
  return ($null -eq $hasSensitive)
}

# Improved prediction settings
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -MaximumHistoryCount 10000

# Custom completion for common commands
$scriptblock = {
  param($wordToComplete, $commandAst, $cursorPosition)
  $customCompletions = @{
    'git'  = @('status', 'add', 'commit', 'push', 'pull', 'clone', 'checkout')
    'npm'  = @('install', 'start', 'run', 'test', 'build')
    'deno' = @('run', 'compile', 'bundle', 'test', 'lint', 'fmt', 'cache', 'info', 'doc', 'upgrade')
  }
    
  $command = $commandAst.CommandElements[0].Value
  if ($customCompletions.ContainsKey($command)) {
    $customCompletions[$command] | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
      [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
  }
}
Register-ArgumentCompleter -Native -CommandName git, npm, deno -ScriptBlock $scriptblock

$scriptblock = {
  param($wordToComplete, $commandAst, $cursorPosition)
  dotnet complete --position $cursorPosition $commandAst.ToString() |
  ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock $scriptblock

# ╭───────────────────────────╮
# │ Winget argument completer │
# ╰───────────────────────────╯
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)
  [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
  $Local:word = $wordToComplete.Replace('"', '""')
  $Local:ast = $commandAst.ToString().Replace('"', '""')
  winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}

# ╭──────────────────────────╮
# │ Choco argument completer │
# ╰──────────────────────────╯
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# ╭─────────────────────────────────╮
# │ Oh-My-Posh default prompt theme │
# ╰─────────────────────────────────╯
# oh-my-posh init pwsh | Invoke-Expression
# oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/cobalt2.omp.json | Invoke-Expression
oh-my-posh init pwsh --config https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/cloud-native-azure.omp.json | Invoke-Expression

# Remind the user of the 
Write-RBox "Run $($PSStyle.Foreground.Yellow)Show-Features$($PSStyle.Reset) to display the list of supported features."
