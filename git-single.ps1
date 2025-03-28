#Requires -Version 7.0

$VERSION = "1.0.3"
$INSTALL_PATH = "$env:ProgramFiles\git-single\git-single.ps1"
$LOG_FILE = "$env:USERPROFILE\.git-single.log"

function Write-Log {
    param([string]$Message)
    Add-Content -Path $LOG_FILE -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
}

# Ensure dependencies exist
function Test-Dependency {
    param([string]$Command)
    try {
        $null = Get-Command $Command -ErrorAction Stop
    } catch {
        Write-Log "Error: $Command is not installed."
        Write-Host "Error: $Command is required but not installed." -ForegroundColor Red
        exit 1
    }
}

Test-Dependency "git"
Test-Dependency "curl"

# Update function
function Update-Script {
    Write-Log "Updating git-single..."
    try {
        $tempFile = [System.IO.Path]::GetTempFileName()
        Invoke-WebRequest "https://raw.githubusercontent.com/btigi/git-single/main/git-single.ps1" -OutFile $tempFile
        if (-not (Test-Path "$env:ProgramFiles\git-single")) {
            New-Item -ItemType Directory -Path "$env:ProgramFiles\git-single" -Force | Out-Null
        }
        Move-Item $tempFile $INSTALL_PATH -Force
        Write-Log "Update successful."
        Write-Host "git-single updated to version $VERSION"
    } catch {
        Write-Log "Error: Update failed."
        exit 2
    }
    exit 0
}

# Uninstall function
function Uninstall-Script {
    Write-Log "Uninstalling git-single..."
    try {
        Remove-Item $INSTALL_PATH -Force
        Write-Log "Uninstallation successful."
        Write-Host "git-single has been removed."
    } catch {
        Write-Log "Error: Uninstallation failed."
        exit 1
    }
    exit 0
}

# Print help message
function Show-Help {
    Write-Host @"
Usage: git-single <GitHub File or Directory URL>
       git-single ---update       # Update git-single
       git-single ---uninstall    # Uninstall git-single
       git-single ---version      # Show version
       git-single ---help         # Show this help message
"@
    exit 0
}

# Handle script arguments
switch ($args[0]) {
    "---update" { Update-Script }
    "---uninstall" { Uninstall-Script }
    "---version" { Write-Host "git-single version $VERSION"; exit 0 }
    "---help" { Show-Help }
    "" { Write-Host "Error: No argument provided. Use ---help for usage." -ForegroundColor Red; exit 1 }
}

$URL = $args[0]
Write-Log "Processing URL: $URL"

# Extract repository details dynamically
if ($URL -match '^https://github.com/([^/]+)/([^/]+)/blob/([^/]+)/(.+)$') {
    $USER = $Matches[1]
    $REPO = $Matches[2]
    $BRANCH = $Matches[3]
    $FILE_PATH = $Matches[4]
    $RAW_URL = "https://raw.githubusercontent.com/$USER/$REPO/$BRANCH/$FILE_PATH"
    $OUTPUT_FILE = [System.IO.Path]::GetFileName($FILE_PATH)

    Write-Log "Fetching raw file from $RAW_URL"
    try {
        Invoke-WebRequest $RAW_URL -OutFile $OUTPUT_FILE
        Write-Log "File downloaded: $OUTPUT_FILE"
    } catch {
        Write-Log "Error: Failed to download file."
        exit 2
    }
    exit 0
} elseif ($URL -match '^https://github.com/([^/]+)/([^/]+)/tree/([^/]+)/(.+)$') {
    $USER = $Matches[1]
    $REPO = $Matches[2]
    $BRANCH = $Matches[3]
    $TARGET_PATH = $Matches[4]
    $REPO_URL = "https://github.com/$USER/$REPO.git"

    Write-Log "Cloning repository: $REPO_URL"
    try {
        git clone --depth=1 --filter=blob:none --sparse $REPO_URL
        if (-not $?) { throw }
    } catch {
        Write-Log "Error: Git clone failed."
        exit 3
    }

    try {
        Push-Location $REPO
        Write-Log "Setting sparse checkout for $TARGET_PATH"
        git sparse-checkout set $TARGET_PATH
        if (-not $?) { throw }

        Move-Item $TARGET_PATH ..\
        Write-Log "Directory moved: $TARGET_PATH"
    } catch {
        Write-Log "Error: Sparse checkout failed."
        exit 1
    } finally {
        Pop-Location
    }

    Remove-Item $REPO -Recurse -Force
    Write-Log "Cleanup completed."
    exit 0
} else {
    Write-Log "Error: Invalid GitHub URL format."
    Write-Host "Error: Invalid GitHub URL format. Use ---help for details." -ForegroundColor Red
    exit 1
}
