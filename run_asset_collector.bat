@echo off
REM Asset Collector Download and Run Script
REM This script downloads the latest Asset Collector from GitHub, runs it, and cleans up
REM Author: Marvin De Los Angeles, CIT Automation / AI / UX
REM Repository: https://github.com/emulexoar/Asset_Collector

echo ======================================================
echo    Asset Collector - Download and Run Script
echo ======================================================
echo.
echo This script will:
echo 1. Download Asset_Collector from GitHub
echo 2. Extract the files
echo 3. Run the asset collection process
echo 4. Clean up temporary files
echo.
echo Repository: https://github.com/emulexoar/Asset_Collector
echo.

REM Set variables
set "DOWNLOAD_URL=https://github.com/emulexoar/Asset_Collector/archive/refs/heads/main.zip"
set "ZIP_FILE=Asset_Collector-main.zip"
set "EXTRACT_FOLDER=Asset_Collector-main"
set "TEMP_DIR=%TEMP%\AssetCollector_%RANDOM%"

REM Create temporary directory
echo Creating temporary directory...
mkdir "%TEMP_DIR%" 2>nul
if not exist "%TEMP_DIR%" (
    echo ERROR: Failed to create temporary directory
    pause
    exit /b 1
)

echo Changing to temporary directory: %TEMP_DIR%
cd /d "%TEMP_DIR%"

REM Download the ZIP file using PowerShell
echo.
echo Downloading Asset Collector from GitHub...
echo URL: %DOWNLOAD_URL%
powershell -ExecutionPolicy Bypass -Command "try { Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%ZIP_FILE%' -UseBasicParsing; Write-Host 'Download completed successfully.' } catch { Write-Host 'ERROR: Download failed -' $_.Exception.Message; exit 1 }"

if not exist "%ZIP_FILE%" (
    echo ERROR: Download failed - ZIP file not found
    cd /d "%~dp0"
    rmdir /s /q "%TEMP_DIR%" 2>nul
    pause
    exit /b 1
)

REM Extract the ZIP file using PowerShell
echo.
echo Extracting files...
powershell -ExecutionPolicy Bypass -Command "try { Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '.' -Force; Write-Host 'Extraction completed successfully.' } catch { Write-Host 'ERROR: Extraction failed -' $_.Exception.Message; exit 1 }"

if not exist "%EXTRACT_FOLDER%" (
    echo ERROR: Extraction failed - folder not found
    cd /d "%~dp0"
    rmdir /s /q "%TEMP_DIR%" 2>nul
    pause
    exit /b 1
)

REM Change to extracted folder
echo Changing to extracted folder...
cd "%EXTRACT_FOLDER%"

REM Check if asset_scan.bat exists
if not exist "asset_scan.bat" (
    echo ERROR: asset_scan.bat not found in extracted folder
    cd /d "%~dp0"
    rmdir /s /q "%TEMP_DIR%" 2>nul
    pause
    exit /b 1
)

REM Run the asset scan directly with PowerShell (bypassing asset_scan.bat)
echo.
echo ======================================================
echo Running Asset Collection Process...
echo ======================================================
echo.
echo Running PowerShell script with execution policy bypass...
powershell -ExecutionPolicy Bypass -File "asset_collect.ps1"

REM Check if the PowerShell script ran successfully
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ======================================================
    echo Asset collection completed successfully!
    echo ======================================================
    echo.
    echo Cleaning up asset files...
    del /f /q "asset_report.csv" 2>nul
    del /f /q "asset_collect.ps1" 2>nul
    echo.
    echo Cleaning up temporary files...
    
    REM Return to original directory before cleanup
    cd /d "%~dp0"
    
    REM Clean up temporary directory
    rmdir /s /q "%TEMP_DIR%" 2>nul
    if exist "%TEMP_DIR%" (
        echo Warning: Could not completely remove temporary directory: %TEMP_DIR%
        echo You may need to delete it manually.
    ) else (
        echo Cleanup completed successfully.
    )
    
    echo.
    echo All done! The asset report has been sent to the IT team.
) else (
    echo.
    echo ======================================================
    echo Asset collection encountered an error!
    echo ======================================================
    echo.
    echo Temporary files are located at: %TEMP_DIR%
    echo You may want to check the logs or run the script manually.
    echo.
    echo Cleaning up temporary files...
    
    REM Return to original directory before cleanup
    cd /d "%~dp0"
    
    REM Clean up temporary directory even on error
    rmdir /s /q "%TEMP_DIR%" 2>nul
    if exist "%TEMP_DIR%" (
        echo Warning: Could not completely remove temporary directory: %TEMP_DIR%
    )
)

echo.
echo Press any key to exit...
pause
