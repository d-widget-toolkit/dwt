@echo off

rdmd rdub console\hello --force

if %0 == "%~0"  pause
