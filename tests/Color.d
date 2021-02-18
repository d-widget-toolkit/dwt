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
 * Port to the D Programming Language:
 *     alice <stigma@disroot.org>
 *******************************************************************************/
module tests.Color;

import java.lang.exceptions : IllegalArgumentException;

import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.RGBA;
import org.eclipse.swt.widgets.Display;

/**
 * Automated Test Suite for class org.eclipse.swt.graphics.Color
 *
 * @see org.eclipse.swt.graphics.Color
 */

@("test_ConstructorLorg_eclipse_swt_graphics_DeviceIII")
unittest
{
    // Test new Color(Device device, int red, int green, int blue)
    // IllegalArgumentException if the red, green or blue argument is not between 0 and 255

    Display display = Display.getDefault();

    // valid color (black)
    Color color = new Color(display, 0, 0, 0);
    color.dispose();

    // valid color (black with alpha)
    color = new Color(display, 0, 0, 0, 0);
    color.dispose();

    // valid color (white)
    color = new Color(display, 255, 255, 255);
    color.dispose();

    // valid color (white with alpha)
    color = new Color(display, 255, 255, 255, 0);
    color.dispose();

    // valid color (random grey)
    color = new Color(display, 20, 20, 20);
    color.dispose();

    // valid color (random grey with alpha)
    color = new Color(display, 20, 20, 20, 0);
    color.dispose();

    // valid color (random)
    color = new Color(display, 102, 255, 0);
    color.dispose();

    // valid color (random with alpha)
    color = new Color(display, 102, 255, 0, 0);
    color.dispose();

    // device == null (valid)
    color = new Color(null, 0, 0, 0);
    color.dispose();

    // device == null (valid with alpha)
    color = new Color(null, 0, 0, 0, 0);
    color.dispose();

    // illegal argument, rgb < 0
    try {
        color = new Color(display, -10, -10, -10);
        color.dispose();
        assert(false, "No exception thrown for rgb < 0");
    } catch (IllegalArgumentException e) {
    }

    // illegal argument, alpha < 0
    try {
        color = new Color(display, 0, 0, 0, -10);
        color.dispose();
        assert(false, "No exception thrown for rgba < 0");
    } catch (IllegalArgumentException e) {
    }

    // illegal argument, rgb > 255
    try {
        color = new Color(display, 1000, 2000, 3000);
        color.dispose();
        assert(false, "No exception thrown for rgb > 255");
    } catch (IllegalArgumentException e) {
    }

    // illegal argument, rgba > 255
    try {
        color = new Color(display, 1000, 2000, 3000, 4000);
        color.dispose();
        assert(false, "No exception thrown for rgba > 255");
    } catch (IllegalArgumentException e) {
    }

    // illegal argument, blue > 255
    try {
        color = new Color(display, 10, 10, 256);
        color.dispose();
        assert(false, "No exception thrown for blue > 255");
    } catch (IllegalArgumentException e) {
    }

    // illegal argument, alpha > 255
    try {
        color = new Color(display, 10, 10, 10, 256);
        color.dispose();
        assert(false, "No exception thrown for alpha > 255");
    } catch (IllegalArgumentException e) {
    }
}

@("test_ConstructorLorg_eclipse_swt_graphics_DeviceLorg_eclipse_swt_graphics_RGB")
unittest
{
    // Test new Color(Device device, RGB rgb)
    // IllegalArgumentException if the red, green or blue argument is not between 0 and 255; or rgb is null

    Display display = Display.getDefault();

    // valid color (black)
    Color color = new Color(display, new RGB(0, 0, 0));
    color.dispose();

    // valid color (black with alpha)
    color = new Color(display, new RGB(0, 0, 0), 0);
    color.dispose();

    // valid color (white)
    color = new Color(display, new RGB(255, 255, 255));
    color.dispose();

    // valid color (white with alpha)
    color = new Color(display, new RGB(255, 255, 255), 0);
    color.dispose();

    // valid color (random grey)
    color = new Color(display, new RGB(10, 10, 10));
    color.dispose();

    // valid color (random grey with alpha)
    color = new Color(display, new RGB(10, 10, 10), 0);
    color.dispose();

    // valid color (random)
    color = new Color(display, new RGB(102, 255, 0));
    color.dispose();

    // valid color (random with alpha)
    color = new Color(display, new RGB(102, 255, 0), 0);
    color.dispose();

    // device == null (valid)
    color = new Color(null, new RGB(0, 0, 0));
    color.dispose();

    // device == null (valid with alpha)
    color = new Color(null, new RGB(0, 0, 0), 0);
    color.dispose();

    // illegal argument, rgb < 0
    try {
        color = new Color(display, new RGB(-10, -10, -10));
        color.dispose();
        assert(false, "No exception thrown for rgb < 0");
    }
    catch (IllegalArgumentException e) {
    }
    // illegal argument, alpha < 0
    try {
        color = new Color(display, new RGB(0, 0, 0), -10);
        color.dispose();
        assert(false, "No exception thrown for rgba < 0");
    }
    catch (IllegalArgumentException e) {
    }
    // illegal argument, rgb > 255
    try {
        color = new Color(display, new RGB(1000, 2000, 3000));
        color.dispose();
        assert(false, "No exception thrown for rgb > 255");
    }
    catch (IllegalArgumentException e) {
    }
    // illegal argument, rgba > 255
    try {
        color = new Color(display, new RGB(1000, 2000, 3000), 4000);
        color.dispose();
        assert(false, "No exception thrown for rgba > 255");
    }
    catch (IllegalArgumentException e) {
    }
    // illegal argument, blue > 255
    try {
        color = new Color(display, new RGB(10, 10, 256));
        color.dispose();
        assert(false, "No exception thrown for blue > 255");
    }
    catch (IllegalArgumentException e) {
    }
    // illegal argument, alpha > 255
    try {
        color = new Color(display, new RGB(10, 10, 10), 256);
        color.dispose();
        assert(false, "No exception thrown for alpha > 255");
    }
    catch (IllegalArgumentException e) {
    }
    // illegal argument, rgb == null with alpha
    try {
        color = new Color(display, null, 0);
        color.dispose();
        assert(false, "No exception thrown for rgb == null with alpha");
    }
    catch (IllegalArgumentException e) {
    }
}

@("test_ConstructorLorg_eclipse_swt_graphics_DeviceLorg_eclipse_swt_graphics_RGBA")
unittest
{
    // Test new Color(Device device, RGBA rgba)
    // IllegalArgumentException if the red, green, blue or alpha argument is not between 0 and 255; or rgba is null

    Display display = Display.getDefault();

    // valid color (black)
    Color color = new Color(display, new RGBA(0, 0, 0, 255));
    color.dispose();

    // valid color (black with alpha)
    color = new Color(display, new RGBA(0, 0, 0, 0));
    color.dispose();

    // valid color (white)
    color = new Color(display, new RGBA(255, 255, 255, 255));
    color.dispose();

    // valid color (white with alpha)
    color = new Color(display, new RGBA(255, 255, 255, 0));
    color.dispose();

    // valid color (random grey)
    color = new Color(display, new RGBA(10, 10, 10, 10));
    color.dispose();

    // valid color (random grey with alpha)
    color = new Color(display, new RGBA(10, 10, 10, 0));
    color.dispose();

    // valid color (random)
    color = new Color(display, new RGBA(102, 255, 0, 255));
    color.dispose();

    // valid color (random with alpha)
    color = new Color(display, new RGBA(102, 255, 0, 0));
    color.dispose();

    // device == null (valid)
    color = new Color(null, new RGBA(0, 0, 0, 255));
    color.dispose();

    // device == null (valid with alpha)
    color = new Color(null, new RGBA(0, 0, 0, 0));
    color.dispose();

    // illegal argument, rgba < 0
    try {
        color = new Color(display, new RGBA(-10, -10, -10, -10));
        color.dispose();
        assert(false, "No exception thrown for rgba < 0");
    }
    catch (IllegalArgumentException e) {
    }
    // illegal argument, alpha < 0
    try {
        color = new Color(display, new RGBA(0, 0, 0, -10));
        color.dispose();
        assert(false, "No exception thrown for alpha < 0");
    }
    catch (IllegalArgumentException e) {
    }
    // illegal argument, rgba > 255
    try {
        color = new Color(display, new RGBA(1000, 2000, 3000, 4000));
        color.dispose();
        assert(false, "No exception thrown for rgba > 255");
    }
    catch (IllegalArgumentException e) {
    }
    // illegal argument, blue > 255
    try {
        color = new Color(display, new RGBA(10, 10, 256, 10));
        color.dispose();
        assert(false, "No exception thrown for blue > 255");
    }
    catch (IllegalArgumentException e) {
    }
    // illegal argument, alpha > 255
    try {
        color = new Color(display, new RGBA(10, 10, 10, 256));
        color.dispose();
        assert(false, "No exception thrown for alpha > 255");
    }
    catch (IllegalArgumentException e) {
    }
}

@("test_equalsLjava_lang_Object")
unittest
{
    Display display = Display.getDefault();
    Color color = new Color(display, 1, 2, 3);
    Color sameColor = new Color(display, 1, 2, 3);
    Color sameColor2 = new Color(display, new RGB(1, 2, 3));
    Color otherColor = new Color(display, 5, 6, 7);
    try {
        // Test Color.opEquals(Object)
        assert(color != cast(Object)null, "color != cast(Object)null");

        // Test Color.opEquals(Color)
        assert(color != cast(Color)null, "color != cast(Color)null");
        assert(color == color, "color == color");
        assert(color == sameColor, "color == sameColor");
        assert(color == sameColor2, "color == sameColor2");
        assert(color != otherColor, "color != otherColor");

    } finally {
        color.dispose();
        sameColor.dispose();
        sameColor2.dispose();
        otherColor.dispose();
    }


    // With alpha
    color = new Color(display, 1, 2, 3, 0);
    sameColor = new Color(display, 1, 2, 3, 0);
    sameColor2 = new Color(display, new RGB(1, 2, 3), 0);
    otherColor = new Color(display, 5, 6, 7, 0);
    try {
        // Test Color.opEquals(Object)
        assert(color != cast(Object)null, "color != cast(Object)null");

        // Test Color.opEquals(Color)
        assert(color != cast(Color)null, "color != cast(Color)null");
        assert(color == color, "color == color");
        assert(color == sameColor, "color == sameColor");
        assert(color == sameColor2, "color == sameColor2");
        assert(color != otherColor, "color != otherColor");
    } finally {
        color.dispose();
        sameColor.dispose();
        sameColor2.dispose();
        otherColor.dispose();
    }
}

@("test_getBlue")
unittest
{
    // Test Color.getBlue()
    Display display = Display.getDefault();
    Color color = new Color(display, 0, 0, 255);

    try {
        assert(color.getBlue() == 255, "color.getBlue()");
    } finally {
        color.dispose();
    }
}

@("test_getGreen")
unittest
{
    // Test Color.getGreen()
    Display display = Display.getDefault();
    Color color = new Color(display, 0, 255, 0);

    try {
        assert(color.getGreen() == 255, "color.getGreen()");
    } finally {
        color.dispose();
    }
}

@("test_getRGB")
unittest
{
    Display display = Display.getDefault();
    Color color = new Color(display, 255, 255, 255);
    assert(color.getRGB() !is null);
    assert(color.getRGB == new RGB(255, 255, 255));
    color.dispose();
}

@("test_getRed")
unittest
{
    // Test Color.getRed()
    Display display = Display.getDefault();
    Color color = new Color(display, 255, 0, 0);

    try {
        assert(color.getRed() == 255, "color.getRed()");
    } finally {
        color.dispose();
    }
}

@("test_getAlpha")
unittest
{
    // Test Color.getAlpha
    Display display = Display.getDefault();
    Color color = new Color(display, 255, 0, 0, 0);

    try {
        assert(color.getAlpha() == 0, "color.getAlpha()");
    } finally {
        color.dispose();
    }
}

@("test_hashCode")
unittest
{
    Display display = Display.getDefault();
    Color color = new Color(display, 12, 36, 54, 0);
    Color otherColor = new Color(display, 12, 26, 54, 0);
    if (color == otherColor) {
        assert(color.toHash() == otherColor.toHash(), "Hash codes of equal objects should be equal");
    }
    color.dispose();
    otherColor.dispose();
}

@("test_isDisposed")
unittest
{
    // Test Color.isDisposed()
    Display display = Display.getDefault();
    Color color = new Color(display, 34, 67, 98, 0);
    try {
        assert(!color.isDisposed(), "Color should not be disposed");
    } finally {
        // Test Color.isDisposed() true
        color.dispose();
        assert(color.isDisposed(), "Color should be disposed");
    }
}

@("test_toString")
unittest
{
    Display display = Display.getDefault();
    Color color = new Color(display, 0, 0, 255, 255);
    try {
        assert(color.toString() !is null);
        assert(color.toString().length > 0);
        assert(color.toString() == "Color {0, 0, 255, 255}");
    } finally {
        color.dispose();
    }
}
