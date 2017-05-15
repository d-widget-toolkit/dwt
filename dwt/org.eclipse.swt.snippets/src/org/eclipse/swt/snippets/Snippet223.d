﻿/*******************************************************************************
 * Copyright (c) 2000, 2006 IBM Corporation and others.
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
module org.eclipse.swt.snippets.Snippet223;
/* 
 * example snippet: ExpandBar example
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 * 
 * @since 3.2
 */

import org.eclipse.swt.SWT;
import java.io.ByteArrayInputStream;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.ExpandBar;
import org.eclipse.swt.widgets.ExpandItem;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Scale;
import org.eclipse.swt.widgets.Spinner;
import org.eclipse.swt.widgets.Slider;

void main () {
    auto display = new Display ();
    auto shell = new Shell (display);
    shell.setLayout(new FillLayout());
    shell.setText("ExpandBar Example");
    auto bar = new ExpandBar (shell, SWT.V_SCROLL);
    auto image = new Image(display, new ImageData(new ByteArrayInputStream( cast(byte[]) import("eclipse.png")))); 
    
    // First item
    Composite composite = new Composite (bar, SWT.NONE);
    GridLayout layout = new GridLayout ();
    layout.marginLeft = layout.marginTop = layout.marginRight = layout.marginBottom = 10;
    layout.verticalSpacing = 10;
    composite.setLayout(layout);
    Button button = new Button (composite, SWT.PUSH);
    button.setText("SWT.PUSH");
    button = new Button (composite, SWT.RADIO);
    button.setText("SWT.RADIO");
    button = new Button (composite, SWT.CHECK);
    button.setText("SWT.CHECK");
    button = new Button (composite, SWT.TOGGLE);
    button.setText("SWT.TOGGLE");
    ExpandItem item0 = new ExpandItem (bar, SWT.NONE, 0);
    item0.setText("What is your favorite button");
    item0.setHeight(composite.computeSize(SWT.DEFAULT, SWT.DEFAULT).y);
    item0.setControl(composite);
    item0.setImage(image);
    
    // Second item
    composite = new Composite (bar, SWT.NONE);
    layout = new GridLayout (2, false);
    layout.marginLeft = layout.marginTop = layout.marginRight = layout.marginBottom = 10;
    layout.verticalSpacing = 10;
    composite.setLayout(layout);    
    Label label = new Label (composite, SWT.NONE);
    label.setImage(display.getSystemImage(SWT.ICON_ERROR));
    label = new Label (composite, SWT.NONE);
    label.setText("SWT.ICON_ERROR");
    label = new Label (composite, SWT.NONE);
    label.setImage(display.getSystemImage(SWT.ICON_INFORMATION));
    label = new Label (composite, SWT.NONE);
    label.setText("SWT.ICON_INFORMATION");
    label = new Label (composite, SWT.NONE);
    label.setImage(display.getSystemImage(SWT.ICON_WARNING));
    label = new Label (composite, SWT.NONE);
    label.setText("SWT.ICON_WARNING");
    label = new Label (composite, SWT.NONE);
    label.setImage(display.getSystemImage(SWT.ICON_QUESTION));
    label = new Label (composite, SWT.NONE);
    label.setText("SWT.ICON_QUESTION");
    ExpandItem item1 = new ExpandItem (bar, SWT.NONE, 1);
    item1.setText("What is your favorite icon");
    item1.setHeight(composite.computeSize(SWT.DEFAULT, SWT.DEFAULT).y);
    item1.setControl(composite);
    item1.setImage(image);
    
    // Third item
    composite = new Composite (bar, SWT.NONE);
    layout = new GridLayout (2, true);
    layout.marginLeft = layout.marginTop = layout.marginRight = layout.marginBottom = 10;
    layout.verticalSpacing = 10;
    composite.setLayout(layout);
    label = new Label (composite, SWT.NONE);
    label.setText("Scale"); 
    new Scale (composite, SWT.NONE);
    label = new Label (composite, SWT.NONE);
    label.setText("Spinner");   
    new Spinner (composite, SWT.BORDER);
    label = new Label (composite, SWT.NONE);
    label.setText("Slider");    
    new Slider (composite, SWT.NONE);
    ExpandItem item2 = new ExpandItem (bar, SWT.NONE, 2);
    item2.setText("What is your favorite range widget");
    item2.setHeight(composite.computeSize(SWT.DEFAULT, SWT.DEFAULT).y);
    item2.setControl(composite);
    item2.setImage(image);
    
    item1.setExpanded(true);
    bar.setSpacing(8);
    shell.setSize(400, 350);
    shell.open();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) {
            display.sleep ();
        }
    }
    image.dispose();
    display.dispose();
}
