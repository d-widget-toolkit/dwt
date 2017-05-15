/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
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
module org.eclipse.swt.graphics.GCData;


import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.win32.WINTYPES;
import org.eclipse.swt.internal.gdip.Gdip;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.graphics.Pattern;
import org.eclipse.swt.graphics.Font;

/**
 * Instances of this class are descriptions of GCs in terms
 * of unallocated platform-specific data fields.
 * <p>
 * <b>IMPORTANT:</b> This class is <em>not</em> part of the public
 * API for SWT. It is marked public only so that it can be shared
 * within the packages provided by SWT. It is not available on all
 * platforms, and should never be called from application code.
 * </p>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public final class GCData {
    public Device device;
    public int style, state = -1;
    public int foreground = -1;
    public int background = -1;
    public Font font;
    public Pattern foregroundPattern;
    public Pattern backgroundPattern;
    public int lineStyle = SWT.LINE_SOLID;
    public float lineWidth = 0;
    public int lineCap = SWT.CAP_FLAT;
    public int lineJoin = SWT.JOIN_MITER;
    public float lineDashesOffset = 0;
    public float[] lineDashes;
    public float lineMiterLimit = 10;
    public int alpha = 0xFF;

    public Image image;
    public HPEN hPen, hOldPen;
    public HBRUSH hBrush, hOldBrush;
    public HBITMAP hNullBitmap;
    public HWND hwnd;
    public PAINTSTRUCT* ps;
    public int layout = -1;
    public Gdip.Graphics gdipGraphics;
    public Gdip.Pen gdipPen;
    public Gdip.Brush gdipBrush;
    public Gdip.SolidBrush gdipFgBrush;
    public Gdip.SolidBrush gdipBgBrush;
    public Gdip.Font gdipFont;
    public float gdipXOffset = 0, gdipYOffset = 0;
    public int uiState = 0;
    public bool focusDrawn;
}

