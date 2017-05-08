## DWT - D Widget Toolkit

DWT is a library for creating cross-platform GUI applications.
It's a port of the [SWT](http://www.eclipse.org/swt) Java library from Eclipse.
DWT is compatible with D2 using the standard library (Phobos) and D1 using
[Tango](http://dsource.org/projects/tango).

## STATUS

The dub package repository is PENDING - will remove this note when online.

## Building

1. Install DMD (includes DUB)

    - Browse to http://dlang.org/
    - Click to download the lastest version (e.g. 2.074.0)
    - Open with Software install (Ubuntu)
    - Install

    Check Version
    
        $ dmd --version
        DMD32 D Compiler v2.074.0
        
        $ dub --version
        DUB version 1.3.0

    Quick Test
    
        $ rdmd examples/console/hello.d

2. Fetch the DUB package

		$ dub fetch dwt

3. Get the linux libraries (no extra libs required for Windows):

        $ cd /home/<USER>/.dub/packages/dwt-1.0.0/dwt/tools/get-libs

		$ bash ./get-libs.sh

4. Build the DWT static libraries:

		$ cd /home/<USER>/.dub/packages/dwt-1.0.0/dwt

		$ dub fetch dwt

		Ubuntu  32-bit and 64-bit: $ bash ./build_dwt.bat
		Windows 32-bit           : $ rdmd build_dwt.bat
		Windows 64-bit           : $ rdmd build_dwt.bat_m64

		$ cd ../examples

		Ubuntu : $ bash ./example.sh
		Windows: $ example.bat
	
5.	Add a dependency to your app's dub.json or dub.sdl, see the examples.
		
		dependency "dwt" version=">=1.0.0"

## Snippets

Run Snippets with rdub in the examples folder:

		Ubuntu : $ bash ./snippets_demo.sh
		Windows: $ snippets_demo.bat

## Other

The dwt/readme.markdown has instructions for using DWT as a GitHub clone.
        
