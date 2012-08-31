## DWT - D Widget Toolkit

DWT is a library for creating cross-platform GUI applications.
It's a port of the [SWT](http://www.eclipse.org/swt) Java library from Eclipse.
DWT is compatible with D2 using the standard library (Phobos) and D1 using
[Tango](http://dsource.org/projects/tango).

## Building

### Requirements

#### Windows

All require files contains in the repository.

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

### Building

If you use D1 with Tango, please replace 'rdmd build' to 'rake'.
For example:
	'$ rdmd build base swt' -> '$ rake base swt'

1. Install all the requirements
2. Clone the repository buy running:

		$ git clone --recursive git://github.com/d-widget-toolkit/dwt.git

3. Compile the base and SWT library by running:

		$ rdmd build base swt

#### Updating the Repository

	$ git pull
	$ git submodule update --init --recursive

### Debugging
To enable debug build (symbols for debugging):

	$ rdmd build DEBUG=1 base swt

Alternatively you can set the environment variable DEBUG to '1'.

### Build the Snippets

	$ rdmd build swtsnippets

To build a single snippet run:

	$ rdmd build swtsnippets[Snippet107]

### Show Available Rake Tasks

	$ rdmd build -T