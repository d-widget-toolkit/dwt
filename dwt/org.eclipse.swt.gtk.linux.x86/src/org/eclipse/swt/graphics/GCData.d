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

import java.lang.all;

import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.graphics.Pattern;
import org.eclipse.swt.graphics.Image;
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
    public GdkColor* foreground;
    public GdkColor* background;
    public Font font;
    public Pattern foregroundPattern;
    public Pattern backgroundPattern;
    public GdkRegion* clipRgn;
    public float lineWidth = 0;
    public int lineStyle = SWT.LINE_SOLID;
    public float[] lineDashes;
    public float lineDashesOffset = 0;
    public float lineMiterLimit = 10;
    public int lineCap = SWT.CAP_FLAT;
    public int lineJoin = SWT.JOIN_MITER;
    public bool xorMode;
    public int alpha = 0xFF;
    public int interpolation = SWT.DEFAULT;

    public PangoContext* context;
    public PangoLayout* layout;
    public GdkRegion* damageRgn;
    public Image image;
    public GdkDrawable* drawable;
    public cairo_t* cairo;
    public double cairoXoffset = 0, cairoYoffset = 0;
    public bool disposeCairo;
    public double[] clippingTransform;
    public String str;
    public int stringWidth = -1;
    public int stringHeight = -1;
    public int drawFlags;
    public bool realDrawable;
    public int width = -1, height = -1;
}

