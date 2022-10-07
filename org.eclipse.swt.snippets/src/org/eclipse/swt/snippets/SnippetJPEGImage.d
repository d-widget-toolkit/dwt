#!/usr/bin/env dub
/+
dub.sdl:
    name "snippet_jpeg_image"
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
module org.eclipse.swt.snippets.SnippetJPEGImage;

/**
 * This program snippet is the test of displaying a JPEG image.
 */
import org.eclipse.swt.all;
import java.io.ByteArrayInputStream;

void main() {
	auto d = new Display;
	auto s = new Shell(d);
	s.setText("JPEG Image");
	s.setLayout(new GridLayout(1, false));

	auto l = new Label(s, SWT.NONE);
	auto bin = new ByteArrayInputStream(cast(byte[])import("jpegimage.jpg"));
	auto img = new Image(d, new ImageData(bin));
	l.setImage(img);

	s.pack();
	s.open();

	while (!s.isDisposed())
		if (!d.readAndDispatch())
			d.sleep();

	img.dispose();
	d.dispose();
}
