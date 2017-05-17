@echo off

echo Start DUB Build...

dub -b=release-nobounds --force

echo End DUB Build.

IF %0 == "%~0"  pause

