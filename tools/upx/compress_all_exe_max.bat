REM Runs upx.exe to compress all .exe files in current directory

@echo off

REM must have upx in your PATH

for %%f in (*.exe) do (

	REM for nomal compression
	REM upx.exe %%f -o %%f_upx.exe

	REM for maximum compression
	    upx.exe --brute %%f -o %%f_upx_max.exe
)

pause
