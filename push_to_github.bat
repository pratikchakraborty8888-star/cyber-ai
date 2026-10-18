@echo off
cd /d "%~dp0"
echo ===================================================
echo   CYBER AI - PUSH TO GITHUB
echo ===================================================
echo.
echo Target Repository: https://github.com/pratikchakraborty8888-star/cyber-ai.git
echo.
echo Pushing project to GitHub main branch...
echo (If prompted, enter your GitHub Username and Personal Access Token)
echo.

set "GIT_EXE=%LOCALAPPDATA%\Programs\MinGit\cmd\git.exe"
if not exist "%GIT_EXE%" set "GIT_EXE=git"

"%GIT_EXE%" push -u origin main

if %ERRORLEVEL% equ 0 (
    echo.
    echo ===================================================
    echo SUCCESS: Project pushed to GitHub!
    echo.
    echo Now open your browser:
    echo https://github.com/pratikchakraborty8888-star/cyber-ai/actions
    echo.
    echo Your release APK is building right now!
    echo ===================================================
) else (
    echo.
    echo [NOTE] If GitHub asked for a password, GitHub requires a Personal Access Token:
    echo 1. Go to https://github.com/settings/tokens
    echo 2. Generate a Classic token with "repo" permission.
    echo 3. Paste the token as the password when prompted.
)

pause
