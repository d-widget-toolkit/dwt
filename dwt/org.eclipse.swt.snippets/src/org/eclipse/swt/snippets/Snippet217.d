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
 *     yidabu at gmail dot com  ( D China http://www.d-programming-language-china.org/ )
 *******************************************************************************/

module org.eclipse.swt.snippets.Snippet217;
/**
 * StyledText snippet: embed controls
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 *
 * @since 3.2
 */

import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.custom.StyleRange;
import org.eclipse.swt.custom.PaintObjectEvent;
import org.eclipse.swt.custom.PaintObjectListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.graphics.FontData;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.GlyphMetrics;

import java.lang.all;
version(JIVE){
    import jive.stacktrace;
}

version(D_Version2)
{
const string OBJ_MARKER = "\uFFFC"; 
}
else
{
const char[] OBJ_MARKER = "\uFFFC"; //should be char[] because of dmd v1.069 @@@BUG@@@ Issue 6467    
}
void main() {
    static StyledText styledText;
    static String text =
        "This snippet shows how to embed widgets in a StyledText.\n" ~
        "Here is one: " ~ OBJ_MARKER ~ ", and here is another: " ~ OBJ_MARKER ~ ".";
    static int[] offsets;
    static Control[] controls;
    static const int MARGIN = 5;

    static void addControl(Control control, int offset) {
        StyleRange style = new StyleRange ();
        style.start = offset;
        style.length = OBJ_MARKER.length;
        control.pack();
        Rectangle rect = control.getBounds();
        int ascent = 2*rect.height/3;
        int descent = rect.height - ascent;
        style.metrics = new GlyphMetrics(ascent + MARGIN, descent + MARGIN, rect.width + 2*MARGIN);
        styledText.setStyleRange(style);
    }


    Display display = new Display();
    Font font = new Font(display, "Tahoma", 32f, SWT.NORMAL);
    Shell shell = new Shell(display);
    shell.setLayout(new GridLayout());
    styledText = new StyledText(shell, SWT.WRAP | SWT.BORDER);
    styledText.setFont(font);
    styledText.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));
    styledText.setText(text);
    controls = new Control[2];
    Button button = new Button(styledText, SWT.PUSH);
    button.setText("Button 1");
    controls[0] = button;
    Combo combo = new Combo(styledText, SWT.NONE);
    combo.add("item 1");
    combo.add("another item");
    controls[1] = combo;
    offsets = new int[controls.length];
    ptrdiff_t lastOffset = 0;
    for (int i = 0; i < controls.length; i++) {
        int offset = text.indexOf( OBJ_MARKER, cast(int)lastOffset);
        assert(offset != -1, "Can't find OBJ_MARKER");
        offsets[i] = offset;
        addControl(controls[i], offsets[i]);
        lastOffset = offset + OBJ_MARKER.length;
    }

    void onVerify(Event e) {
        int start = e.start;
        int replaceCharCount = e.end - e.start;
        ptrdiff_t newCharCount = e.text.length;
        for (int i = 0; i < offsets.length; i++) {
            int offset = offsets[i];
            if (start <= offset && offset < start + replaceCharCount) {
                // this widget is being deleted from the text
                if (controls[i] !is null && !controls[i].isDisposed()) {
                    controls[i].dispose();
                    controls[i] = null;
                }
                offset = -1;
            }
            if (offset != -1 && offset >= start) offset += newCharCount - replaceCharCount;
            offsets[i] = offset;
        }
    }
    // use a verify listener to keep the offsets up to date
    styledText.addListener(SWT.Verify, dgListener(&onVerify));

    // reposition widgets on paint event
    styledText.addPaintObjectListener(new class PaintObjectListener {
        public void paintObject(PaintObjectEvent event) {
            StyleRange style = event.style;
            int start = style.start;
            for (int i = 0; i < offsets.length; i++) {
                int offset = offsets[i];
                if (start == offset) {
                    Point pt = controls[i].getSize();
                    int x = event.x + MARGIN;
                    int y = event.y + event.ascent - 2*pt.y/3;
                    controls[i].setLocation(x, y);
                    break;
                }
            }
        }
    });

    shell.setSize(400, 400);
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    font.dispose();
    display.dispose();
}
