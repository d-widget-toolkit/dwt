#!/usr/bin/env dub
/+
dub.sdl:
    name "snippet8"
    dependency "dwt" path="../../../../../../" version="*"
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

/*******************************************************************************
 * Copyright (c) 2000, 2016 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * D Port:
 *     Jesse Phillips <Jesse.K.Phillips+D> gmail.com
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet8;

/*
 * Tree example snippet: create a tree (lazy)
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */

import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.swt.widgets.TreeItem;

import java.lang.all;

import std.file;
import std.path;

/* DWT Compatibility */
class FileSystem {
    static string[] roots() {return [absolutePath(dirSeparator)];}
}
class FilePath {
    string path;
    this (string path) {this.path = path;}
    FilePath[] toList() {
        FilePath[] r;
        foreach (string file; dirEntries(path, SpanMode.shallow)) {
            r ~= new FilePath(std.path.buildPath(path, file));
        }
        return r;
    }
    bool isFolder() {return exists(path) && isDir(path);}
    override
    string toString() {return path;}
}

void main () {
    auto display = new Display ();
    auto shell = new Shell (display);
    shell.setText ("Lazy Tree");
    shell.setLayout (new FillLayout ());
    auto tree = new Tree (shell, SWT.BORDER);
    auto roots = FileSystem.roots();
    foreach (file; roots) {
        auto root = new TreeItem (tree, 0);
        root.setText (file);
        root.setData (new FilePath(file));
        new TreeItem (root, 0);
    }
    tree.addListener (SWT.Expand, new class Listener {
        public void handleEvent (Event event) {
            auto root = cast(TreeItem) event.item;
            auto items = root.getItems ();
            foreach(item; items) {
                if (item.getData () !is null) return;
                item.dispose ();
            }
            auto file = cast(FilePath) root.getData ();
            auto files = file.toList();
            if (files is null) return;
            foreach (f; files) {
                TreeItem item = new TreeItem (root, 0);
                item.setText (f.toString());
                item.setData (f);
                if (f.isFolder()) {
                    new TreeItem (item, 0);
                }
            }
        }
    });
    auto size = tree.computeSize (300, SWT.DEFAULT);
    auto width = Math.max (300, size.x);
    auto height = Math.max (300, size.y);
    shell.setSize (shell.computeSize (width, height));
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
