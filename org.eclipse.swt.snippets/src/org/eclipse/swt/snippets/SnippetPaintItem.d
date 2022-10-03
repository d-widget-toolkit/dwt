#!/usr/bin/env dub
/+
dub.sdl:
    name "snippet_paint_item"
    dependency "dwt" path="../../../../../../"
    stringImportPaths "../../../../../res"
    libs \
      "atk-1.0" \
      "cairo" \
      "dl" \
      "fontconfig" \
      "gdk-x11-2.0" \
      "gdk_pixbuf-2.0" \
      "gio-2.0" \
      "glib-2.0" \
      "gmodule-2.0" \
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
module org.eclipse.swt.snippets.SnippetPaintItem;

/*
 * Example for custom drawing a TableItem.
 *
 * For more information on custom drawing, see the this articles:
 * https://www.eclipse.org/articles/article.php?file=Article-CustomDrawingTableAndTreeItems/index.html
 */

import org.eclipse.swt.all;

import java.io.ByteArrayInputStream;
import java.lang.all;

void main() {
    auto d = new Display;
    auto s = new Shell(d);
    s.setText("SnippetPaintItem");
    s.setLayout(new FillLayout);
    s.setSize(200, 150);

    auto table = new Table(s, SWT.FULL_SELECTION);
    table.setHeaderVisible(true);
    auto column0 = new TableColumn(table, SWT.NONE);
    column0.setText("Column0");
    column0.setWidth(80);
    auto column1 = new TableColumn(table, SWT.NONE);
    column1.setText("Column1");
    column1.setWidth(80);

    auto image = new Image(d, new ImageData(new ByteArrayInputStream(cast(byte[])import("eclipse.png"))));
    auto item0 = new TableItem(table, SWT.NONE);
    item0.setImage(0, image);
    item0.setText(0, "TableItem - 0-0");
    item0.setText(1, "TableItem - 0-1");
    auto item1 = new TableItem(table, SWT.NONE);
    item1.setImage(1, image);
    item1.setText(0, "TableItem - 1-0");
    item1.setText(1, "TableItem - 1-1");
    auto item2 = new TableItem(table, SWT.NONE);
    item2.setText(0, "TableItem - 2-0");
    item2.setText(1, "TableItem - 2-1");

    table.addListener(SWT.EraseItem, new class Listener {
        override void handleEvent(Event e) {
            e.gc.fillRectangle(e.x, e.y, e.width, e.height);
            e.detail = e.detail & ~SWT.FOREGROUND;
        }
    });
    table.addListener(SWT.PaintItem, new class Listener {
        override void handleEvent(Event e) {
            auto item = cast(TableItem)e.item;
            auto column = e.index;
            auto index = table.indexOf(item);
            auto image = item.getImage(column);
            if (image) {
                auto imageBounds = item.getImageBounds(column);
                auto iconBounds = image.getBounds();
                if (column == 1) {
                    e.gc.setAlpha(128);
                }
                e.gc.drawImage(image, imageBounds.x, imageBounds.y + (imageBounds.height - iconBounds.height) / 2);
                e.gc.setAlpha(255);
            }
            auto textBounds = item.getTextBounds(column);
            string text;
            switch (index) {
            case 0:
                text = "one";
                break;
            case 1:
                text = "two";
                break;
            case 2:
                text = "three";
                break;
            default:
                assert (0);
            }
            if (column == 1) {
                text = "sub-" ~ text;
            }
            auto textHeight = e.gc.textExtent(text).y;
            e.gc.drawText(text, textBounds.x, textBounds.y + (textBounds.height - textHeight) / 2, true);
        }
    });

    s.open();
    while (!s.isDisposed()) {
        if (!d.readAndDispatch()) {
            d.sleep();
        }
    }
    image.dispose();
    d.dispose();
}
