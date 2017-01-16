@echo off

echo ==============================================================
echo   Supreme Commander Forged Alliance - Cached shader clean up
echo ==============================================================
echo.
echo.
echo Forged Alliance caches shader files. Modifications to the
echo shader files are not (always) detected. This causes the game
echo to freeze as soon as the modified shader routines are used.
echo To fix this use this utility to delete the cached shader files
echo and force Forged Alliance to recache the shaders. This fixes
echo the problems.
echo.
echo Be sure to exit Forged Alliance before using this utility.
echo.
echo Hit the "y" button followed by the enter button to delete the
echo cache files. Any other action exits without deleting the files.
echo.
set /p OK=## 
echo.

if "%OK%"=="y" (
  echo Deleting files...
  del /F /Q "%LOCALAPPDATA%\Gas Powered Games\Supreme Commander Forged Alliance\cache\mesh.1.5.*" >nul 2>&1
  del /F /Q "%HOMEPATH%\Local Settings\Application Data\Gas Powered Games\Supreme Commander Forged Alliance\cache\mesh.1.5.*" >nul 2>&1
  del /F /Q "%LOCALAPPDATA%\Gas Powered Games\Supreme Commander Forged Alliance\cache\mesh.1.6.*" >nul 2>&1
  del /F /Q "%HOMEPATH%\Local Settings\Application Data\Gas Powered Games\Supreme Commander Forged Alliance\cache\mesh.1.6.*" >nul 2>&1
  echo Done
) else (
  echo Nothing deleted...
)

echo.
echo Exiting automatically in 15 seconds.
ping -n 15 127.0.0.1 >nul