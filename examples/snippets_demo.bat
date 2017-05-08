@echo off

rdmd rdub snippets\Snippet223.d -y --force

rem rdmd rdub snippets\Snippet251.d -y --force

echo End of snippet demo.

if %0 == "%~0"  pause