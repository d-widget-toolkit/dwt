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

module org.eclipse.swt.snippets.Snippet96;

// http://dev.eclipse.org/viewcvs/index.cgi/org.eclipse.swt.snippets/src/org/eclipse/swt/snippets/Snippet96.java?view=co

/*
 * TableCursor example snippet: navigate a table cells with arrow keys.
 * Edit when user hits Return key.  Exit edit mode by hitting Escape (cancels edit)
 * or Return (applies edit to table).
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableItem;
import org.eclipse.swt.widgets.TableColumn;
import org.eclipse.swt.widgets.Text;

import org.eclipse.swt.custom.TableCursor;
import org.eclipse.swt.custom.ControlEditor;

import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;

import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.KeyEvent;
import org.eclipse.swt.events.KeyAdapter;
import org.eclipse.swt.events.FocusEvent;
import org.eclipse.swt.events.FocusAdapter;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseAdapter;

import java.lang.all;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}


void main() {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new GridLayout());

    // create a a table with 3 columns and fill with data
    Table table = new Table(shell, SWT.BORDER | SWT.MULTI | SWT.FULL_SELECTION);
    table.setLayoutData(new GridData(GridData.FILL_BOTH));
    TableColumn column1 = new TableColumn(table, SWT.NONE);
    TableColumn column2 = new TableColumn(table, SWT.NONE);
    TableColumn column3 = new TableColumn(table, SWT.NONE);
    for (int i = 0; i < 100; i++) {
        TableItem item = new TableItem(table, SWT.NONE);
        item.setText(["cell " ~ to!(String)(i) ~ " 0",  "cell " ~ to!(String)(i) ~ " 1", "cell " ~ to!(String)(i) ~ " 2" ]);
    }
    column1.pack();
    column2.pack();
    column3.pack();

    // create a TableCursor to navigate around the table
    TableCursor cursor = new TableCursor(table, SWT.NONE);
    // create an editor to edit the cell when the user hits "ENTER"
    // while over a cell in the table
    ControlEditor editor = new ControlEditor(cursor);
    editor.grabHorizontal = true;
    editor.grabVertical = true;

    cursor.addSelectionListener(new class SelectionAdapter {
        // when the TableEditor is over a cell, select the corresponding row in
        // the table
        override
        public void widgetSelected(SelectionEvent e) {
            table.setSelection([cursor.getRow()]);
        }
        // when the user hits "ENTER" in the TableCursor, pop up a text editor so that
        // they can change the text of the cell
        override
        public void widgetDefaultSelected(SelectionEvent e) {
            Text text = new Text(cursor, SWT.NONE);
            TableItem row = cursor.getRow();
            int column = cursor.getColumn();
            text.setText(row.getText(column));
            text.addKeyListener(new class(text, cursor) KeyAdapter {
                Text text;
                TableCursor cursor;
                this(Text text_, TableCursor cursor_)
                {
                    text = text_;
                    cursor = cursor_;
                }
                override
                public void keyPressed(KeyEvent e) {
                    // close the text editor and copy the data over
                    // when the user hits "ENTER"
                    if (e.character == SWT.CR) {
                        TableItem row = cursor.getRow();
                        int column = cursor.getColumn();
                        row.setText(column, text.getText());
                        text.dispose();
                    }
                    // close the text editor when the user hits "ESC"
                    if (e.character == SWT.ESC) {
                        text.dispose();
                    }
                }
            });
            // close the text editor when the user tabs away
            text.addFocusListener(new class(text) FocusAdapter {
                Text text;
                this(Text text_)
                {
                    text = text_;
                }
                override
                public void focusLost(FocusEvent e) {
                    text.dispose();
                }
            });
            editor.setEditor(text);
            text.setFocus();
        }
    });
    // Hide the TableCursor when the user hits the "CTRL" or "SHIFT" key.
    // This alows the user to select multiple items in the table.
    cursor.addKeyListener(new class KeyAdapter {
        override
        public void keyPressed(KeyEvent e) {
            if (e.keyCode == SWT.CTRL
                || e.keyCode == SWT.SHIFT
                || (e.stateMask & SWT.CONTROL) != 0
                || (e.stateMask & SWT.SHIFT) != 0) {
                cursor.setVisible(false);
            }
        }
    });
    // When the user double clicks in the TableCursor, pop up a text editor so that
    // they can change the text of the cell
    cursor.addMouseListener(new class MouseAdapter {
        override
        public void mouseDown(MouseEvent e) {
            Text text = new Text(cursor, SWT.NONE);
            TableItem row = cursor.getRow();
            int column = cursor.getColumn();
            text.setText(row.getText(column));
            text.addKeyListener(new class(text, cursor) KeyAdapter {
                Text text;
                TableCursor cursor;
                this(Text text_, TableCursor cursor_)
                {
                    text = text_;
                    cursor = cursor_;
                }
                override
                public void keyPressed(KeyEvent e) {
                    // close the text editor and copy the data over
                    // when the user hits "ENTER"
                    if (e.character == SWT.CR) {
                        TableItem row = cursor.getRow();
                        int column = cursor.getColumn();
                        row.setText(column, text.getText());
                        text.dispose();
                    }
                    // close the text editor when the user hits "ESC"
                    if (e.character == SWT.ESC) {
                        text.dispose();
                    }
                }
            });
            // close the text editor when the user clicks away
            text.addFocusListener(new class(text) FocusAdapter {
                Text text;
                this(Text text_)
                {
                    text = text_;
                }
                override
                public void focusLost(FocusEvent e) {
                    text.dispose();
                }
            });
            editor.setEditor(text);
            text.setFocus();
        }
    });

    // Show the TableCursor when the user releases the "SHIFT" or "CTRL" key.
    // This signals the end of the multiple selection task.
    table.addKeyListener(new class KeyAdapter {
        override
        public void keyReleased(KeyEvent e) {
            if (e.keyCode == SWT.CONTROL && (e.stateMask & SWT.SHIFT) != 0)
                return;
            if (e.keyCode == SWT.SHIFT && (e.stateMask & SWT.CONTROL) != 0)
                return;
            if (e.keyCode != SWT.CONTROL
                && (e.stateMask & SWT.CONTROL) != 0)
                return;
            if (e.keyCode != SWT.SHIFT && (e.stateMask & SWT.SHIFT) != 0)
                return;

            TableItem[] selection = table.getSelection();
            TableItem row = (selection.length == 0) ? table.getItem(table.getTopIndex()) : selection[0];
            table.showItem(row);
            cursor.setSelection(row, 0);
            cursor.setVisible(true);
            cursor.setFocus();
        }
    });

    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    display.dispose();
}
