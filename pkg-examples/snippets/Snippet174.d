/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Sebastian Davids - initial implementation
 *     IBM Corporation
 * Port to the D programming language:
 *     Bill Baxter <bill@billbaxter.com>
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet174;

/*
 * SWT OpenGL snippet: draw a square
 * 
 * This snippet requires the experimental org.eclipse.swt.opengl plugin, which
 * is not included in SWT by default and should only be used with versions of
 * SWT prior to 3.2.  For information on using OpenGL in SWT see
 * http://www.eclipse.org/swt/opengl/ .
 * 
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 * 
 * @since 3.2
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.events.ControlEvent;
import org.eclipse.swt.events.ControlAdapter;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.opengl.GLCanvas;
import org.eclipse.swt.opengl.GLData;

import java.lang.all;

import derelict.opengl.gl;
import derelict.opengl.glu;

version(Tango){
    import Math = tango.math.Math;
} else { // Phobos
    import Math = std.algorithm;
}

void main() 
{
    DerelictGL.load();
    DerelictGLU.load();

    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setText("OpenGL in SWT");
    shell.setLayout(new FillLayout());
    GLData data = new GLData();
    data.doubleBuffer = true;
    GLCanvas canvas = new GLCanvas(shell, SWT.NO_BACKGROUND, data);
    canvas.addControlListener(new class ControlAdapter {
        public void controlResized(ControlEvent e) {
            resize(canvas);
        }
    });
    init(canvas);
    (new class Runnable {
        public void run() {
            if (canvas.isDisposed()) return;
            render();
            canvas.swapBuffers();
            canvas.getDisplay().timerExec(15, this);
        }
    }).run();
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}

void init(GLCanvas canvas) {
    canvas.setCurrent();
    resize(canvas);
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glColor3f(0.0f, 0.0f, 0.0f);
    glClearDepth(1.0f);
    glEnable(GL_DEPTH_TEST);
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
}

void render() {
    static int rot = 0;
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glLoadIdentity();
    glTranslatef(0.0f, 0.0f, -6.0f);
    glRotatef(rot++, 0,0,1);
    rot %= 360;
    glBegin(GL_QUADS);
    glVertex3f(-1.0f, 1.0f, 0.0f);
    glVertex3f(1.0f, 1.0f, 0.0f);
    glVertex3f(1.0f, -1.0f, 0.0f);
    glVertex3f(-1.0f, -1.0f, 0.0f);
    glEnd();
}

void resize(GLCanvas canvas) {
    canvas.setCurrent();
    Rectangle rect = canvas.getClientArea();
    int width = rect.width;
    int height = Math.max(rect.height, 1);
    glViewport(0, 0, width, height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    float aspect = cast(float) width / cast(float) height;
    gluPerspective(45.0f, aspect, 0.5f, 400.0f);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

