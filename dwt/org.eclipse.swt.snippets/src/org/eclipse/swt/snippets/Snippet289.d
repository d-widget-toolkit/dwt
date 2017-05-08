/*******************************************************************************
 * Copyright (c) 2000, 2004 IBM Corporation and others.
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
module org.eclipse.swt.snippets.Snippet289;

/*
 * Combo example snippet: add an item to a combo box
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.TraverseListener;
import org.eclipse.swt.events.VerifyListener;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import java.lang.all;

void main() {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new FillLayout());
    Combo combo = new Combo(shell, SWT.NONE);
    combo.setItems(["1111", "2222", "3333", "4444"]);
    combo.setText(combo.getItem(0));
    combo.addVerifyListener(new class VerifyListener{
        public void verifyText(VerifyEvent e) {
            String newText = e.text;
            try {
                Integer.parseInt(newText);
            } catch (NumberFormatException ex) {
                e.doit = false;
            }
        }
    });
    combo.addTraverseListener(new class TraverseListener {
        public void keyTraversed(TraverseEvent e) {
            if (e.detail == SWT.TRAVERSE_RETURN) {
                e.doit = false;
                e.detail = SWT.TRAVERSE_NONE;
                String newText = combo.getText();
                try {
                    Integer.parseInt(newText);
                    combo.add(newText);
                    combo.setSelection(new Point(0, cast(int)newText.length));
                } catch (NumberFormatException ex) {
                }
            }
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
