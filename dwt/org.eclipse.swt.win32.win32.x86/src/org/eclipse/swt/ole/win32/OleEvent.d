/*******************************************************************************
 * Copyright (c) 2000, 2003 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module org.eclipse.swt.ole.win32.OleEvent;

import org.eclipse.swt.ole.win32.Variant;

import org.eclipse.swt.widgets.Widget;

public class OleEvent {
    public int type;
    public Widget widget;
    public int detail;
    public bool doit = true;
    public Variant[] arguments;
}
