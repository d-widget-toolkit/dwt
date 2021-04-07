/*******************************************************************************
 * Copyright (c) 2000, 2015 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Red Hat Inc. - Bug 462631
 * Port to the D programming language:
 *     alice <stigma@disroot.org>
 *******************************************************************************/
module tests.PaletteData;

import java.lang.exceptions;

import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.graphics.RGB;

/**
 * Automated Test Suite for class org.eclipse.swt.graphics.PaletteData
 *
 * @see org.eclipse.swt.graphics.PaletteData
 */

@("test_Constructor$Lorg_eclipse_swt_graphics_RGB")
unittest
{
    try {
        new PaletteData(cast(RGB[])null);
        assert(false, "No exception thrown for rgb is null");
    } catch (IllegalArgumentException e) {
    }

    // D treats zero length arrays as null.
    // PaletteData data = new PaletteData(new RGB[] {});
    // assert(false == data.isDirect, ":a:");

    PaletteData data = new PaletteData([null, null]);
    assert(false == data.isDirect, ":b:");

    data = new PaletteData(new RGB(0, 0, 0), new RGB(255, 255, 255));
    assert(false == data.isDirect, ":c:");
}

@("test_ConstructorIII")
unittest
{
    PaletteData data = new PaletteData(0, 0, 0);
    assert(data.isDirect, ":a:");

    data = new PaletteData(-1, -1, -1);
    assert(data.isDirect, ":b:");

    data = new PaletteData(0xff0000, 0x00ff00, 0x0000ff);
    assert(data.isDirect, ":c:");
}

@("test_getPixelLorg_eclipse_swt_graphics_RGB")
unittest
{
    // indexed palette tests
    RGB[] rgbs = [new RGB(0, 0, 0), new RGB(255, 255, 255), new RGB(50, 100, 150)];
    PaletteData data = new PaletteData(rgbs);

    try {
        data.getPixel(null);
        assert(false, "No exception thrown for indexed palette with rgb == null");
    } catch (IllegalArgumentException e) {
    }

    try {
        data.getPixel(new RGB(0, 0, 1));
        assert(false, "No exception thrown for rgb not found");
    } catch (IllegalArgumentException e) {
    }

    assert((rgbs.length-1) == data.getPixel(rgbs[$ - 1]), ":a:");

    // direct palette tests
    RGB rgb = new RGB(0x32, 0x64, 0x96);
    data = new PaletteData(0xff0000, 0x00ff00, 0x0000ff);

    try {
        data.getPixel(null);
        assert(false, "No exception thrown for indexed palette with rgb == null");
    } catch (IllegalArgumentException e) {
    }

    assert(0x326496 == data.getPixel(rgb), ":b:");
}

@("test_getRGBI")
unittest
{
    // indexed palette tests
    RGB[] rgbs = [new RGB(0, 0, 0), new RGB(255, 255, 255), new RGB(50, 100, 150)];
    PaletteData data = new PaletteData(rgbs);

    try {
        data.getRGB(cast(int)rgbs.length);
        assert(false, "No exception thrown for nonexistent pixel");
    } catch (IllegalArgumentException e) {
    }

    assert(rgbs[$ - 1] == data.getRGB(cast(int)(rgbs.length) - 1), ":a:");

    // direct palette tests
    RGB rgb = new RGB(0x32, 0x64, 0x96);
    data = new PaletteData(0xff0000, 0x00ff00, 0x0000ff);

    assert(rgb == data.getRGB(0x326496));
}

@("test_getRGBs")
unittest
{
	// indexed palette tests
	RGB[] rgbs = [new RGB(0, 0, 0), new RGB(255, 255, 255)];
	PaletteData data = new PaletteData(rgbs);

	assert(rgbs == data.getRGBs(), ":a:");

	// direct palette tests
	data = new PaletteData(0xff0000, 0x00ff00, 0x0000ff);

    assert(data.getRGBs() == null, ":b:");
}
