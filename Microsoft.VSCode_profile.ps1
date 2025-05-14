# ╭───────────────────────────────────────────╮
# │ Helper Function: Print-RBox               │
# │                  RBox a Multi-Line String │
# ╰───────────────────────────────────────────╯
function Print-RBox {
    param (
        [string]$Text
    )

    # Handle the multiple lines split
    $Lines = $Text -split "`n"

    # Calculate the number of lines
    $LinesCount = $Lines.Count

    # Calculate the maximum length of the lines to adjust the box size
    $MaxLength = 0
    $MaxLength = $Lines | Measure-Object -Maximum Length | Select-Object -ExpandProperty Maximum
    # foreach ($Line in $Lines) {
    #     if ($Line.Length -gt $MaxLength) {
    #         $MaxLength = $Line.Length
    #     }
    # }

    # Calculate the number of spaces needed for the box
    $Spaces = ($MaxLength + 2)

    # Print the top border
    Write-Host "$($PSStyle.Foreground.Cyan)╭" -NoNewline
    Write-Host "$($PSStyle.Foreground.Cyan)$("─" * ($MaxLength + 2))" -NoNewline
    Write-Host "╮$($PSStyle.Reset)"

    #Print the lines inside the box
    foreach ($Line in $Lines) {
        Write-Host "$($PSStyle.Foreground.Cyan)│ $($PSStyle.Reset)" -NoNewline
        Write-Host ($Line.PadRight($MaxLength)) -NoNewline
        Write-Host "$($PSStyle.Foreground.Cyan) │$($PSStyle.Reset)"
    }
    # Print the bottom border
    Write-Host "$($PSStyle.Foreground.Cyan)╰" -NoNewline
   Write-Host "$($PSStyle.Foreground.Cyan)$("─" * ($MaxLength + 2))" -NoNewline
    Write-Host "╯$($PSStyle.Reset)"
}

# ╭────────────────────────────╮
# │ Helper Function: Show-Help │
# ╰────────────────────────────╯
function Show-Help {
  Print-RBox @"
PowerShell Profile Help

Features: 
  - Winget argument completer
  - Az CLI Argument Completer
  - Choco argument completer
  
Aliases & Functions:
  -  tf:  terraform
  - tfi: terraform init -upgrade
  - tfp: terraform plan
  - tfa: terraform apply -auto-approve
  - tfd: terraform destroy -auto-approve
  -   o:   open explorer.exe
"@
}

########################################################################

# ╭─────────────────────────────────╮
# │ Oh-My-Posh default prompt theme │
# ╰─────────────────────────────────╯
oh-my-posh init pwsh | Invoke-Expression

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


# ╭─────────────────────╮
# │ Functions & Aliases │
# ╰─────────────────────╯
function tf { terraform $args }

function tfi { terraform init -upgrade $args }
# set-alias -Name "tfi"  -Value func-tfi

function tfp { terraform plan $args }
# set-alias -Name "tfp"  -Value func-tfp

function tfa { terraform apply -auto-approve $args }
# set-alias -Name "tfa"  -Value func-tfa

function tfd { terraform destroy -auto-approve $args }

function o { explorer.exe $args }

########################################################################

# ╭──────────────╮
# │Final Message │
# ╰──────────────╯
Write-Host " "
Write-Host "Loaded `$PROFILE: $PROFILE" -ForegroundColor DarkGray
Write-Host "Run Show-Help to display features from this `$PROFILE." -ForegroundColor Yellow

