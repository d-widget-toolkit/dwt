@echo off

echo This example requires the DUB package dwtlib

rdmd rdub gui\hello_dwt.d --force

if %0 == "%~0"  pause