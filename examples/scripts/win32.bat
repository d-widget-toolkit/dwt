@echo off

REM
REM Change to your environment
REM

set source=hello_dwt
set DWT="..\..\dwt"

echo Build and Run: %source%

if exist bin del bin\* /Q

dmd src\%source% res\resource.res -ofbin\%source% -release -O -boundscheck=off ^
    -J%DWT%\views ^
    -I%DWT%\base\src -I%DWT%\org.eclipse.swt.win32.win32.x86\src ^
    -L+%DWT%\lib\ -L+org.eclipse.swt.win32.win32.x86.lib -L+dwt-base.lib ^
	-L/SUBSYSTEM:WINDOWS

IF %0 == "%~0"  pause

start bin\%source%

