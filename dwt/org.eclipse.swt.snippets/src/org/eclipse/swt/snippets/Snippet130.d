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
module org.eclipse.swt.snippets.Snippet130;
/*
 * BusyIndicator example snippet: display busy cursor during long running task
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;


import org.eclipse.swt.custom.BusyIndicator;

import java.lang.all;
import java.lang.Thread;

void main() {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new GridLayout());
    Text text = new Text(shell, SWT.MULTI | SWT.BORDER | SWT.V_SCROLL);
    text.setLayoutData(new GridData(GridData.FILL_BOTH));
    int[] nextId = new int[1];
    Button b = new Button(shell, SWT.PUSH);
    b.setText("invoke long running job");

    b.addSelectionListener(new class SelectionAdapter {
        override
        public void widgetSelected(SelectionEvent e) {
            Runnable longJob = new class Runnable {
                bool done = false;
                int id;
                public void run() {
                    Thread thread = new Thread({
                        id = nextId[0]++;
                        display.syncExec(new class Runnable {
                            public void run() {
                            if (text.isDisposed()) return;
                            text.append(Format("\nStart long running task {}", id));
                            }
                            }); // display.syncExec
                        /*
                         * This crashes when more than 1 thread gets created. THD
                         for (int i = 0; i < 100000; i++) {
                         if (display.isDisposed()) return;
                         getDwtLogger().info(__FILE__, __LINE__, "do task that takes a long time in a separate thread {}", id);
                         }
                         */
                        // This runs fine
                        for (int i = 0; i < 6; i++) {
                            if (display.isDisposed()) return;
                            getDwtLogger().info( __FILE__, __LINE__, "do task that takes a long time in a separate thread {} {}/6", id, i);
                            Thread.sleep(500);
                        }

                        if (display.isDisposed()) return;
                        display.syncExec(new class Runnable {
                            public void run() {
                                if (text.isDisposed()) return;
                                text.append(Format("\nCompleted long running task {}", id));
                            }
                        }); // display.syncExec
                        done = true;
                        display.wake();
                    }); // thread = ...
                    thread.start();

                    while (!done && !shell.isDisposed()) {
                        if (!display.readAndDispatch())
                            display.sleep();
                    }
                }
            };  // Runnable longJob = ...
            BusyIndicator.showWhile(display, longJob);
        } // widgetSelected();
    }); // addSelectionListener


    shell.setSize(250, 150);
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    display.dispose();
}

void printStart(Text text, int id ) {
    if (text.isDisposed()) return;
    getDwtLogger().info( __FILE__, __LINE__, "Start long running task {}", id );
    text.append(Format("\nStart long running task {}", id));
}

void printEnd(Text text, int id ) {
    if (text.isDisposed()) return;
    getDwtLogger().info( __FILE__, __LINE__, "Completed long running task {}", id );
    text.append(Format("\nCompleted long running task {}", id));
}
