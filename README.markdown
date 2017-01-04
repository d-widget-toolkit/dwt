## DWT - D Widget Toolkit

DWT is a library for creating cross-platform GUI applications.
It's a port of the [SWT](http://www.eclipse.org/swt) Java library from Eclipse.
DWT is compatible with D2 using the standard library (Phobos) and D1 using
[Tango](http://dsource.org/projects/tango).

## Building


### <a id="building"></a>Building

1. Install all the [requirements](#requirements)
2. Clone the repository by running:

		$ git clone --recursive git://github.com/d-widget-toolkit/dwt.git

3. Compile the base and SWT library by running:

		$ ./build base swt

  ##### For Windows:

  If need 64-bit libraries, please add `-m64` flag to options:

		$ rdmd build base swt -m64

  If need 32-bit COFF libraries, please add `-m32mscoff` flag:

		$ rdmd base swt -m32mscoff

If you use D1 with Tango, please replace `./build` to `rake`.
For example:
	`$ ./build base swt` -> `$ rake base swt`

### <a id="requirements"></a>Requirements

#### Windows

All required files are included in the repository.

#### Linux

For Ubuntu, use the packages below. For other systems use the corresponding packages
available in the system package manager.

* libcairo2-dev
* libglib2.0-dev
* libpango1.0-dev
* libxfixes-dev
* libxdamage-dev
* libxcomposite-dev
* libxcursor-dev
* libxrandr-dev
* libxi-dev
* libxinerama-dev
* libxtst-dev
* libgtk2.0-dev
* libgnomeui-dev

#### For D1

* [Tango](http://dsource.org/projects/tango)
* Ruby
* Rake 0.8.x (included in Ruby 1.9)

### Building Hello World

1. Follow the [build instructions](#building) above
2. Enter the following code in a file called `main.d`:

	```d
	module main;

	import org.eclipse.swt.widgets.Display;
	import org.eclipse.swt.widgets.Shell;

	void main ()
	{
	    auto display = new Display;
	    auto shell = new Shell;
	    shell.open();

	    while (!shell.isDisposed)
	        if (!display.readAndDispatch())
	            display.sleep();

	    display.dispose();
	}
	```

3. Compile by running:<br />
For Windows:

  ```
  $ dmd main.d -I<dwt>\imp -J<dwt>\res -L+<dwt>\lib\ ^
    "-L+org.eclipse.swt.win32.win32.x86.lib" "-L+dwt-base.lib" ^
    -L/SUBSYSTEM:WINDOWS:4.0
  ```

  If you use Microsoft linker:

  ```
  $ dmd main.d -I<dwt>\imp -J<dwt>\res -L/LIBPATH:<dwt>\lib ^
    "-Lorg.eclipse.swt.win32.win32.x86.lib" "-Ldwt-base.lib" ^
    -L/SUBSYSTEM:Windows -L/ENTRY:mainCRTStartup -m64
  ```

  If use 32-bit COFF, replace `-m64` to `-m32mscoff`.

  For Linux:

  ```
  $ dmd main.d -I<dwt>/imp -J<dwt>/org.eclipse.swt.gtk.linux.x86/res -L-L<dwt>/lib \
    -L-l:org.eclipse.swt.gtk.linux.x86 \
    -L-l:dwt-base -L-lgtk-x11-2.0 -L-lgdk-x11-2.0 -L-latk-1.0 -L-lgdk_pixbuf-2.0 \
    -L-lgthread-2.0 -L-lpangocairo-1.0 -L-lfontconfig -L-lXtst -L-lXext -L-lXrender \
    -L-lXinerama -L-lXi -L-lXrandr -L-lXcursor -L-lXcomposite -L-lXdamage -L-lX11 \
    -L-lXfixes -L-lpango-1.0 -L-lgobject-2.0 -L-lgmodule-2.0 -L-ldl -L-lglib-2.0 \
    -L-lcairo -L-lgnomeui-2 -L-lgnomevfs-2
  ```

  Where `<dwt>` is the path to where DWT was cloned.

#### Updating the Repository

	$ git pull
	$ git submodule update --init --recursive

### Debugging
To enable debug build (symbols for debugging):

	$ ./build DEBUG=1 base swt

Alternatively you can set the environment variable DEBUG to '1'.

### Build the Snippets

	$ ./build swtsnippets

To build a single snippet run:

	$ ./build swtsnippets[Snippet107]

### Show Available Rake Tasks

	$ ./build -T
