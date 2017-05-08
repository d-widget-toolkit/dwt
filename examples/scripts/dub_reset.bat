@echo off

if exist bin rmdir /S /Q bin

if exist .dub rmdir /S /Q .dub

if exist dub.selections.json del /Q dub.selections.json

echo Dub reset finished.

if %0 == "%~0"  pause

