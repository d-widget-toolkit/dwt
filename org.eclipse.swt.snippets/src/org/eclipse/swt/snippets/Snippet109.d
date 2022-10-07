#!/usr/bin/env dub
/+
dub.sdl:
    name "snippet109"
    dependency "dwt" path="../../../../../../"
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

/*******************************************************************************
 * Copyright (c) 2000, 2004 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Bill Baxter
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet109;
 
/*
 * SashForm example snippet: create a sash form with three children
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.SashForm;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;

void main () {
    Display display = new Display ();
    Shell shell = new Shell(display);
    shell.setLayout (new FillLayout());

    SashForm form = new SashForm(shell,SWT.HORIZONTAL);
    form.setLayout(new FillLayout());
    
    Composite child1 = new Composite(form,SWT.NONE);
    child1.setLayout(new FillLayout());
    (new Label(child1,SWT.NONE)).setText("Label in pane 1");
    
    Composite child2 = new Composite(form,SWT.NONE);
    child2.setLayout(new FillLayout());
    (new Button(child2,SWT.PUSH)).setText("Button in pane2");

    Composite child3 = new Composite(form,SWT.NONE);
    child3.setLayout(new FillLayout());
    (new Label(child3,SWT.PUSH)).setText("Label in pane3");
    
    form.setWeights([30,40,30]);
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}

