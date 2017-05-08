/**
 * Author: kntroh
 * License: CC0(http://creativecommons.org/publicdomain/zero/1.0/)
 */
module org.eclipse.swt.snippets.SnippetDwt1;

/**
 * This program snippet is the test of displaying RLE4 bitmap and V4 Header bitmap.
 */
import org.eclipse.swt.all;
import java.io.ByteArrayInputStream;

void main() {
	auto d = new Display;
	auto s = new Shell(d);
	s.setLayout(new GridLayout(2, false));

	auto l = new Label(s, SWT.NONE);
	l.setText("RLE4");

	l = new Label(s, SWT.NONE);
	auto bin = new ByteArrayInputStream(cast(byte[])import("dwt1_rle4.bmp"));
	auto img1 = new Image(d, new ImageData(bin));
	l.setImage(img1);

	l = new Label(s, SWT.NONE);
	l.setText("V4 Header");

	l = new Label(s, SWT.NONE);
	bin = new ByteArrayInputStream(cast(byte[])import("dwt1_v4.bmp"));
	auto img2 = new Image(d, new ImageData(bin));
	l.setImage(img2);

	s.pack();
	s.open();

	while (!s.isDisposed())
		if (!d.readAndDispatch())
			d.sleep();

	img1.dispose();
	img2.dispose();
	d.dispose();
}
