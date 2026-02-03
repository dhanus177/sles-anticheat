@echo off
echo Building Client Scanner...
cd client-scanner
dotnet publish -c Release -r win-x64 --self-contained -p:PublishSingleFile=true

echo.
echo Build complete!
echo Output: client-scanner\bin\Release\net8.0-windows\win-x64\publish\ClientScanner.exe
echo.
echo Distribute this file to your players!
pause
