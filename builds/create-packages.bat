@echo off
REM Create deployment packages for Tactical RMM Agent

echo Creating Tactical RMM Agent deployment packages...

REM Create Linux package
echo Creating Linux package...
if not exist "tactical-rmm-agent-linux" mkdir "tactical-rmm-agent-linux"
copy "tacticalrmm-linux-*" "tactical-rmm-agent-linux\"
copy "install-linux.sh" "tactical-rmm-agent-linux\"
copy "uninstall-linux.sh" "tactical-rmm-agent-linux\"
copy "configure-linux.sh" "tactical-rmm-agent-linux\"
copy "make-executable.sh" "tactical-rmm-agent-linux\"
copy "tacticalagent.service" "tactical-rmm-agent-linux\"
copy "README-Linux.md" "tactical-rmm-agent-linux\README.md"

REM Create Windows package
echo Creating Windows package...
if not exist "tactical-rmm-agent-windows" mkdir "tactical-rmm-agent-windows"
copy "tacticalrmm-windows-*.exe" "tactical-rmm-agent-windows\"

REM Create macOS package
echo Creating macOS package...
if not exist "tactical-rmm-agent-macos" mkdir "tactical-rmm-agent-macos"
copy "tacticalrmm-macos-*" "tactical-rmm-agent-macos\"

echo.
echo Packages created successfully!
echo.
echo Linux package: tactical-rmm-agent-linux\
echo Windows package: tactical-rmm-agent-windows\
echo macOS package: tactical-rmm-agent-macos\
echo.
echo For Linux installation:
echo 1. Copy the tactical-rmm-agent-linux folder to your Linux server
echo 2. Run: chmod +x *.sh
echo 3. Run: sudo ./install-linux.sh
echo 4. Run: sudo ./configure-linux.sh --configure
echo 5. Run: sudo ./configure-linux.sh --start

pause