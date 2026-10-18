@echo off
cd /d "%~dp0"
echo ===================================================
echo   CYBER AI - ONE-CLICK GITHUB UPLOAD
echo ===================================================
echo.
set /p REPO_URL="Paste your GitHub repository URL (e.g. https://github.com/USER/cyber-ai.git): "
if "%REPO_URL%"=="" (
    echo [ERROR] No repository URL was entered.
    pause
    exit /b 1
)

set "GIT_EXE=%LOCALAPPDATA%\Programs\MinGit\cmd\git.exe"
if not exist "%GIT_EXE%" set "GIT_EXE=git"

"%GIT_EXE%" remote remove origin >nul 2>&1
"%GIT_EXE%" remote add origin %REPO_URL%
"%GIT_EXE%" branch -M main
echo.
echo Pushing code to GitHub...
"%GIT_EXE%" push -u origin main

echo.
echo ===================================================
echo Upload complete!
echo Now open GitHub -> Click the 'Actions' tab to see the APK build.
echo ===================================================
pause
