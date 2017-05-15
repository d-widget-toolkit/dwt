@"C:\Program Files\Microsoft SDKs\Windows\v6.0A\bin\rc" /foresource.res resource.rc
@if errorlevel 1 (
	echo Building failed!
	pause
)
