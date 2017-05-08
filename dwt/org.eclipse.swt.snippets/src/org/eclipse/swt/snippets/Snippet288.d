/*******************************************************************************
 * Copyright (c) 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet288;

/*
 * Create a ToolBar containing animated GIFs
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageLoader;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.ToolBar;
import org.eclipse.swt.widgets.ToolItem;
import org.eclipse.swt.widgets.FileDialog;

import java.lang.all;

version(Tango){
    import tango.io.FilePath;
    import tango.io.model.IFile;
    //import tango.core.Thread;
    import tango.io.Stdout;
    import tango.util.Convert;
    import tango.core.Exception;
} else { // Phobos
    import std.path;
    import std.stdio;
    import std.conv;
    import core.exception;
    import core.thread : ThreadException;
    struct FileConst {
        static const PathSeparatorChar = dirSeparator;
    }
}

mixin(gshared!("
Display display;
Shell shell;
GC shellGC;
Color shellBackground;
ImageLoader[] loader;
ImageData[][] imageDataArray;
Thread[] animateThread;
Image[][] image;
ToolItem[] item;
"));
const bool useGIFBackground = false;

void main () {
    display = new Display();
    Shell shell = new Shell (display);
    shellBackground = shell.getBackground();
    FileDialog dialog = new FileDialog(shell, SWT.OPEN | SWT.MULTI);
    dialog.setText("Select Multiple Animated GIFs");
    dialog.setFilterExtensions(["*.gif"]);
    String filename = dialog.open();
    String[] filenames = dialog.getFileNames();
    int numToolBarItems = cast(int)filenames.length;
    if (numToolBarItems > 0) {
        version(Tango){
            try {
                loadAllImages((new FilePath(filename)).parent, filenames);
            } catch (SWTException e) {
                Stdout.print("There was an error loading an image.").newline;
                e.printStackTrace();
            }
        } else { // Phobos
            try {
                loadAllImages(filename.dirName, filenames);
            } catch (SWTException e) {
                writeln("There was an error loading an image.");
                e.printStackTrace();
            }
        }
        ToolBar toolBar = new ToolBar (shell, SWT.FLAT | SWT.BORDER | SWT.WRAP);
        item = new ToolItem[numToolBarItems];
        for (int i = 0; i < numToolBarItems; i++) {
            item[i] = new ToolItem (toolBar, SWT.PUSH);
            item[i].setImage(image[i][0]);
        }
        toolBar.pack ();
        shell.open ();
			
        startAnimationThreads();
			
        while (!shell.isDisposed()) {
            if (!display.readAndDispatch ()) display.sleep ();
        }
			
        for (int i = 0; i < numToolBarItems; i++) {
            for (int j = 0; j < image[i].length; j++) {
                image[i][j].dispose();
            }
        }
        display.dispose ();
    }
    Thread.joinAll();
}

void loadAllImages(String directory, String[] filenames) {
    int numItems = cast(int)filenames.length;
    loader.length = numItems;
    imageDataArray.length = numItems;
    image.length = numItems;
    for (int i = 0; i < numItems; i++) {
        loader[i] = new ImageLoader();
        int fullWidth = loader[i].logicalScreenWidth;
        int fullHeight = loader[i].logicalScreenHeight;
        imageDataArray[i] = loader[i].load(directory ~ FileConst.PathSeparatorChar ~ filenames[i]);
        int numFramesOfAnimation = cast(int)imageDataArray[i].length;
        image[i] = new Image[numFramesOfAnimation];
        for (int j = 0; j < numFramesOfAnimation; j++) {
            if (j == 0) {
                //for the first frame of animation, just draw the first frame
                image[i][j] = new Image(display, imageDataArray[i][j]);
                fullWidth = imageDataArray[i][j].width;
                fullHeight = imageDataArray[i][j].height;
            }
            else {
                //after the first frame of animation, draw the background or previous frame first, then the new image data 
                image[i][j] = new Image(display, fullWidth, fullHeight);
                GC gc = new GC(image[i][j]);
                gc.setBackground(shellBackground);
                gc.fillRectangle(0, 0, fullWidth, fullHeight);
                ImageData imageData = imageDataArray[i][j];
                switch (imageData.disposalMethod) {
                case SWT.DM_FILL_BACKGROUND:
                    /* Fill with the background color before drawing. */
                    Color bgColor = null;
                    if (useGIFBackground && loader[i].backgroundPixel != -1) {
                        bgColor = new Color(display, imageData.palette.getRGB(loader[i].backgroundPixel));
                    }
                    gc.setBackground(bgColor !is null ? bgColor : shellBackground);
                    gc.fillRectangle(imageData.x, imageData.y, imageData.width, imageData.height);
                    if (bgColor !is null) bgColor.dispose();
                    break;
                default:
                    /* Restore the previous image before drawing. */
                    gc.drawImage(
                        image[i][j-1],
                        0,
                        0,
                        fullWidth,
                        fullHeight,
                        0,
                        0,
                        fullWidth,
                        fullHeight);
                    break;
                }
                Image newFrame = new Image(display, imageData);
                gc.drawImage(newFrame,
                             0,
                             0,
                             imageData.width,
                             imageData.height,
                             imageData.x,
                             imageData.y,
                             imageData.width,
                             imageData.height);
                newFrame.dispose();
                gc.dispose();
            }
        }
    }
}

void startAnimationThreads() {
    animateThread = new Thread[image.length];
    for (int ii = 0; ii < image.length; ii++) {
        animateThread[ii] = new class(ii) Thread {
            int imageDataIndex = 0;
            int id = 0;
            this(int _id) { 
                id = _id;
                //name = "Animation "~to!(char[])(ii);
                //isDaemon = true;
                super(&run);
            }
            override
            void run() {
                try {
                    int repeatCount = loader[id].repeatCount;
                    while (loader[id].repeatCount == 0 || repeatCount > 0) {
                        imageDataIndex = (imageDataIndex + 1) % cast(int)imageDataArray[id].length;
                        if (!display.isDisposed()) {
                            display.asyncExec(new class Runnable {
									public void run() {
										if (!item[id].isDisposed())
											item[id].setImage(image[id][imageDataIndex]);
									}
								});
                        }
							
                        /* Sleep for the specified delay time (adding commonly-used slow-down fudge factors). */
                        try {
                            int ms = imageDataArray[id][imageDataIndex].delayTime * 10;
                            if (ms < 20) ms += 30;
                            if (ms < 30) ms += 10;
                            Thread.sleep(1 * ms);
                        } catch (ThreadException e) {
                        }

                        /* If we have just drawn the last image, decrement the repeat count and start again. */
                        if (imageDataIndex == imageDataArray[id].length - 1) repeatCount--;
                    }
                } catch (SWTException ex) {
                    version(Tango){
                        Stdout.print("There was an error animating the GIF").newline;
                    } else { // Phobos
                        writeln("There was an error animating the GIF");
                    }
                    ex.printStackTrace();
                }
            }
        };
        animateThread[ii].start();
    }
}

