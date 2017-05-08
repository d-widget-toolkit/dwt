@echo off
REM Windows only, -m64 is not used on Posix
rdmd tools/build_dwtlib.d -m64
IF %0 == "%~0"  pause
