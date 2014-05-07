/*******************************************************************************
 * Copyright (c) 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * D Port:
 *     Thomas Demmer <t_demmer AT web DOT de>
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippets282;

/*
 * Copy/paste image to/from clipboard.
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */

import org.eclipse.swt.SWT;
import org.eclipse.swt.dnd.Clipboard;
import org.eclipse.swt.dnd.ImageTransfer;
import org.eclipse.swt.dnd.Transfer;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.layout.GridData;

import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.FileDialog;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;

import java.lang.all;

void main() {
    //An org.eclipse.swt.graphics.Resource in DWT Windows (as against SWT) checks
    //in destructor if it has been disposed, so we are to watch imageButton's
    //image and dispose it after shell.isDisposed() or just disable this check
    version(Windows)
        Image.globalDisposeChecking = false;
    
    Display display = new Display();
    Clipboard clipboard = new Clipboard(display);
    Shell shell = new Shell(display, SWT.SHELL_TRIM);
    shell.setLayout(new GridLayout());
    shell.setText("Clipboard ImageTransfer");

    Button imageButton = new Button(shell, SWT.NONE );
    GridData gd = new GridData(SWT.FILL, SWT.FILL, true, true);
    gd.minimumHeight = 400;
    gd.minimumWidth = 600;
    imageButton.setLayoutData(gd);

    Composite buttons = new Composite(shell, SWT.NONE);
    buttons.setLayout(new GridLayout(4, true));
    Button button = new Button(buttons, SWT.PUSH);
    button.setText("Open");
    button.addListener(SWT.Selection, new class Listener {
            public void handleEvent(Event event) {
            FileDialog dialog = new FileDialog (shell, SWT.OPEN);
            dialog.setText("Open an image file or cancel");
            String string = dialog.open ();
            if (string !is null) {
            Image image = imageButton.getImage();
            if (image !is null) image.dispose();
            image = new Image(display, string);
            imageButton.setImage(image);
            }
            }
            });

    button = new Button(buttons, SWT.PUSH);
    button.setText("Copy");
    button.addListener(SWT.Selection, new class Listener {
            public void handleEvent(Event event) {
            Image image = imageButton.getImage();
            if (image !is null) {
            ImageTransfer transfer = ImageTransfer.getInstance();

            Transfer[] xfer = [ transfer ];
            Object[] td = [ image.getImageData ];

            clipboard.setContents(td,xfer);
            }
            }
            });
    button = new Button(buttons, SWT.PUSH);
    button.setText("Paste");
    button.addListener(SWT.Selection, new class Listener {
            public void handleEvent(Event event) {
            ImageTransfer transfer = ImageTransfer.getInstance();
            ImageData imageData = cast(ImageData)clipboard.getContents(transfer);
            if (imageData !is null) {
            imageButton.setText("");
            Image image = imageButton.getImage();
            if (image !is null) image.dispose();
            image = new Image(display, imageData);
            imageButton.setImage(image);
            } else {
            imageButton.setText("No image");
            }
            }
            });

    button = new Button(buttons, SWT.PUSH);
    button.setText("Clear");
    button.addListener(SWT.Selection, new class Listener {
            public void handleEvent(Event event) {
            imageButton.setText("");
            Image image = imageButton.getImage();
            if (image !is null) image.dispose();
            imageButton.setImage(null);
            }
            });
    shell.pack();
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    display.dispose();
}

