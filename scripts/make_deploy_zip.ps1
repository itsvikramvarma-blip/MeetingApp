<#
Creates a zip archive of the PHP API scaffold for easy download/deployment.

Usage (PowerShell):
  # from repository root
  .\scripts\make_deploy_zip.ps1

Output:
  - d:\Vikramvarma\copilot\api_php_deploy.zip

#>

param(
    [string]$SourceFolder = "api/php",
    [string]$DestinationZip = "api_php_deploy.zip",
    [switch]$Force
)

function Abort($msg) {
    Write-Error $msg
    exit 1
}

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sourcePath = Join-Path $repoRoot $SourceFolder
$destPath = Join-Path $repoRoot $DestinationZip

if (-not (Test-Path $sourcePath)) {
    Abort("Source folder not found: $sourcePath")
}

try {
    if (Test-Path $destPath) {
        if ($Force) {
            Remove-Item $destPath -Force
        } else {
            Write-Output "Destination already exists: $destPath"
            Write-Output "Re-run with -Force to overwrite, e.g. .\scripts\make_deploy_zip.ps1 -Force"
            exit 0
        }
    }

    Compress-Archive -Path (Join-Path $sourcePath '*') -DestinationPath $destPath -Force
    if (Test-Path $destPath) {
        $info = Get-Item $destPath
        Write-Output "ZIP CREATED: $($info.FullName)  ($([math]::Round($info.Length/1KB,2)) KB)"
        exit 0
    } else {
        Abort("Failed to create zip at $destPath")
    }
} catch {
    Abort("Error while creating zip: $($_.Exception.Message)")
}
