#!/usr/bin/env dub
/+
dub.sdl:
    name "snippet_many_widgets"
    dependency "dwt" path="../../../../../../"
    stringImportPaths "../../../../../res"
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

/**
 * Author: kntroh
 * License: CC0(http://creativecommons.org/publicdomain/zero/1.0/)
 */
module org.eclipse.swt.snippets.SnippetManyWidget;

/**
 * This program snippet is a test for many widgets creation on GTK.
 */
import org.eclipse.swt.all;

void main() {
    auto d = new Display;
    auto s = new Shell(d);

    foreach (i; 0 .. 4097) {
        new Label(s, SWT.NONE);
    }

    s.open();
    while (!s.isDisposed()) {
        if (!d.readAndDispatch()) {
            d.sleep();
        }
    }
    d.dispose();
}

