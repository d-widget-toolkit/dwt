## DWT - D Widget Toolkit

DWT is a library for creating cross-platform GUI applications.
It's a port of the [SWT](http://www.eclipse.org/swt) Java library from Eclipse.
Current supported platforms are Windows, using Win32 and Linux, using GTK.

## Usage

1. Install all the [requirements](#requirements)
1. Enter the following code in a file called `main.d`:

    ```d
    /+
    dub.sdl:
        name "main"
        dependency "dwt" version="~>1.0.0"
        lflags "/subsystem:console:4" platform="x86_omf"
        libs \
          "atk-1.0" \
          "cairo" \
          "dl" \
          "fontconfig" \
          "gdk-x11-2.0" \
          "gdk_pixbuf-2.0" \
          "glib-2.0" \
          "gmodule-2.0" \
          "gnomeui-2" \
          "gnomevfs-2" \
          "gobject-2.0" \
          "gthread-2.0" \
          "gtk-x11-2.0" \
          "pango-1.0" \
          "pangocairo-1.0" \
          "X11" \
          "Xcomposite" \
          "Xcursor" \
          "Xdamage" \
          "Xext" \
          "Xfixes" \
          "Xi" \
          "Xinerama" \
          "Xrandr" \
          "Xrender" \
          "Xtst" \
          platform="linux"
    +/
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

1. Build and run by running: `dub --single main.d`

## Build all the Snippets

```
$ dub --single tools/build_snippets.d
```

## Documentation

For documentation, see any existing documentation or examples for SWT. See also
the [snippets](org.eclipse.swt.snippets/src/org/eclipse/swt/snippets) which
contains a bunch of the official SWT snippets ported to D.

## <a id="requirements"></a>Requirements

### Windows

All required files are included in the repository.

### Linux

For Ubuntu, use the packages below. For other systems use the corresponding
packages available in the system package manager.

* libcairo2-dev
* libglib2.0-dev
* libgnomeui-dev
* libgtk2.0-dev
* libpango1.0-dev
* libxcomposite-dev
* libxcursor-dev
* libxdamage-dev
* libxfixes-dev
* libxi-dev
* libxinerama-dev
* libxrandr-dev
* libxtst-dev
