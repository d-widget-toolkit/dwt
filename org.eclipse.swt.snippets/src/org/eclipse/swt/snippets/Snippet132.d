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
 *     Adam Chrapkowski <adam DOT chrapkowski AT gmail DOT com>
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet132;
  
/*
 * Printing example snippet: print "Hello World!" in black, outlined in red, to default printer
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
 
// org.eclipse.swt
import org.eclipse.swt.SWT;
// org.eclipse.swt.widgets
import org.eclipse.swt.widgets.Display,
       org.eclipse.swt.widgets.MessageBox,
       org.eclipse.swt.widgets.Shell;
// org.eclipse.swt.graphics
import org.eclipse.swt.graphics.Color,
       org.eclipse.swt.graphics.GC,
       org.eclipse.swt.graphics.Rectangle;
// org.eclipse.swt.printing
import org.eclipse.swt.printing.PrintDialog, 
       org.eclipse.swt.printing.Printer, 
       org.eclipse.swt.printing.PrinterData;
// java
import java.lang.all;

void main(){
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.open();
    PrinterData data = Printer.getDefaultPrinterData();
    if(data is null){
        MessageBox.showWarning("Warning: No default printer.");
        return;
    }
    Printer printer = new Printer(data);
    if(printer.startJob("SWT Printing Snippet")){
        Color black = printer.getSystemColor(SWT.COLOR_BLACK);
        Color white = printer.getSystemColor(SWT.COLOR_WHITE);
        Color red = printer.getSystemColor(SWT.COLOR_RED);
        Rectangle trim = printer.computeTrim(0, 0, 0, 0);
        Point dpi = printer.getDPI();
        int leftMargin = dpi.x + trim.x; // one inch from left side of paper
        int topMargin = dpi.y / 2 + trim.y; // one-half inch from top edge of paper
        GC gc = new GC(printer);
        if(printer.startPage()){
            gc.setBackground(white);
            gc.setForeground(black);
            String testString = "Hello World!";
            Point extent = gc.stringExtent(testString);
            gc.drawString(testString, leftMargin, topMargin);
            gc.setForeground(red);
            gc.drawRectangle(leftMargin, topMargin, extent.x, extent.y);
            printer.endPage();
        }
        gc.dispose();
        printer.endJob();
    }
    printer.dispose();
    while(!shell.isDisposed()){
      if(!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}
