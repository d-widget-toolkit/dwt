=== DWT2 ===

* The original Eclipse sources:
    http://dev.eclipse.org/viewcvs/

* Requirements for D1+Tango:
    DMD 1.041
    Tango 0.99.8 is needed.
* Requirements for D2+Phobos:
    DMD 2.026
* Required build tool:
    Rake 0.8.X ( included in Ruby 1.9 )

The sc.ini/dmd.conf of the DMD in the PATH needs to have all
necessary parameters to build a application with the std lib.

E.g. for Tango it can look like this:
[Environment]
LINKCMD=%@P%\link.exe
LIB="%@P%\..\..\..\..\tango\lib"
DFLAGS="-I%@P%\..\..\..\..\tango" -version=Tango -defaultlib=tango-base-dmd.lib -debuglib=tango-base-dmd.lib 

To show the available Rake targets use:
$ rake -T

To build for example the SWT you need:
$ rake base swt

To enable debug build (symbols for debugging):
$ rake DEBUG=1 base swt
Alternatively you can set the environment variable DEBUG to '1'.

The example targets build a whole collection of examples.
To build an indiviual snippet from swtsnippets, do:
$ rake swtsnippets[Snippet107]


