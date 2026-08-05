@echo off

call build.bat

if errorLevel 1 (
    echo Build failed, aborting.
    exit /b 1
)

pushd ..\build
win32_handmade.exe
popd
