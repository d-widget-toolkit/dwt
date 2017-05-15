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
module org.eclipse.swt.widgets.TypedListener;


import org.eclipse.swt.internal.SWTEventListener;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.events.ArmEvent;
import org.eclipse.swt.events.ArmListener;
import org.eclipse.swt.events.ControlEvent;
import org.eclipse.swt.events.ControlListener;
import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.events.DragDetectEvent;
import org.eclipse.swt.events.DragDetectListener;
import org.eclipse.swt.events.ExpandEvent;
import org.eclipse.swt.events.ExpandListener;
import org.eclipse.swt.events.FocusEvent;
import org.eclipse.swt.events.FocusListener;
import org.eclipse.swt.events.HelpEvent;
import org.eclipse.swt.events.HelpListener;
import org.eclipse.swt.events.KeyEvent;
import org.eclipse.swt.events.KeyListener;
import org.eclipse.swt.events.MenuEvent;
import org.eclipse.swt.events.MenuListener;
import org.eclipse.swt.events.MenuDetectEvent;
import org.eclipse.swt.events.MenuDetectListener;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseListener;
import org.eclipse.swt.events.MouseMoveListener;
import org.eclipse.swt.events.MouseTrackListener;
import org.eclipse.swt.events.MouseWheelListener;
import org.eclipse.swt.events.PaintEvent;
import org.eclipse.swt.events.PaintListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.events.ShellEvent;
import org.eclipse.swt.events.ShellListener;
import org.eclipse.swt.events.TraverseEvent;
import org.eclipse.swt.events.TraverseListener;
import org.eclipse.swt.events.TreeEvent;
import org.eclipse.swt.events.TreeListener;
import org.eclipse.swt.events.VerifyEvent;
import org.eclipse.swt.events.VerifyListener;
import org.eclipse.swt.graphics.GC;


/**
 * Instances of this class are <em>internal SWT implementation</em>
 * objects which provide a mapping between the typed and untyped
 * listener mechanisms that SWT supports.
 * <p>
 * <b>IMPORTANT:</b> This class is <em>not</em> part of the SWT
 * public API. It is marked public only so that it can be shared
 * within the packages provided by SWT. It should never be
 * referenced from application code.
 * </p>
 *
 * @see Listener
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class TypedListener : Listener {

    /**
     * The receiver's event listener
     */
    protected SWTEventListener eventListener;

/**
 * Constructs a new instance of this class for the given event listener.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the SWT
 * public API. It is marked public only so that it can be shared
 * within the packages provided by SWT. It should never be
 * referenced from application code.
 * </p>
 *
 * @param listener the event listener to store in the receiver
 */
public this (SWTEventListener listener) {
    eventListener = listener;
}

/**
 * Returns the receiver's event listener.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the SWT
 * public API. It is marked public only so that it can be shared
 * within the packages provided by SWT. It should never be
 * referenced from application code.
 * </p>
 *
 * @return the receiver's event listener
 */
public SWTEventListener getEventListener () {
    return eventListener;
}

/**
 * Handles the given event.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the SWT
 * public API. It is marked public only so that it can be shared
 * within the packages provided by SWT. It should never be
 * referenced from application code.
 * </p>
 * @param e the event to handle
 */
public void handleEvent (Event e) {
    switch (e.type) {
        case SWT.Activate: {
            (cast(ShellListener) eventListener).shellActivated(new ShellEvent(e));
            break;
        }
        case SWT.Arm: {
            (cast(ArmListener) eventListener).widgetArmed (new ArmEvent (e));
            break;
        }
        case SWT.Close: {
            /* Fields set by Decorations */
            ShellEvent event = new ShellEvent (e);
            (cast(ShellListener) eventListener).shellClosed(event);
            e.doit = event.doit;
            break;
        }
        case SWT.Collapse: {
            if ( auto l = cast(TreeListener)eventListener ) {
                l.treeCollapsed(new TreeEvent(e));
            } else {
                (cast(ExpandListener) eventListener).itemCollapsed(new ExpandEvent(e));
            }
            break;
        }
        case SWT.Deactivate: {
            (cast(ShellListener) eventListener).shellDeactivated(new ShellEvent(e));
            break;
        }
        case SWT.Deiconify: {
            (cast(ShellListener) eventListener).shellDeiconified(new ShellEvent(e));
            break;
        }
        case SWT.DefaultSelection: {
            (cast(SelectionListener)eventListener).widgetDefaultSelected(new SelectionEvent(e));
            break;
        }
        case SWT.Dispose: {
            (cast(DisposeListener) eventListener).widgetDisposed(new DisposeEvent(e));
            break;
        }
        case SWT.DragDetect: {
            (cast(DragDetectListener) eventListener).dragDetected(new DragDetectEvent(e));
            break;
        }
        case SWT.Expand: {
            if (auto l = cast(TreeListener)eventListener ) {
                l.treeExpanded(new TreeEvent(e));
            } else {
                (cast(ExpandListener) eventListener).itemExpanded(new ExpandEvent(e));
            }
            break;
        }
        case SWT.FocusIn: {
            (cast(FocusListener) eventListener).focusGained(new FocusEvent(e));
            break;
        }
        case SWT.FocusOut: {
            (cast(FocusListener) eventListener).focusLost(new FocusEvent(e));
            break;
        }
        case SWT.Help: {
            (cast(HelpListener) eventListener).helpRequested (new HelpEvent (e));
            break;
        }
        case SWT.Hide: {
            (cast(MenuListener) eventListener).menuHidden(new MenuEvent(e));
            break;
        }
        case SWT.Iconify: {
            (cast(ShellListener) eventListener).shellIconified(new ShellEvent(e));
            break;
        }
        case SWT.KeyDown: {
            /* Fields set by Control */
            KeyEvent event = new KeyEvent(e);
            (cast(KeyListener) eventListener).keyPressed(event);
            e.doit = event.doit;
            break;
        }
        case SWT.KeyUp: {
            /* Fields set by Control */
            KeyEvent event = new KeyEvent(e);
            (cast(KeyListener) eventListener).keyReleased(event);
            e.doit = event.doit;
            break;
        }
        case SWT.Modify: {
            (cast(ModifyListener) eventListener).modifyText(new ModifyEvent(e));
            break;
        }
        case SWT.MenuDetect: {
            MenuDetectEvent event = new MenuDetectEvent(e);
            (cast(MenuDetectListener) eventListener).menuDetected(event);
            e.x = event.x;
            e.y = event.y;
            e.doit = event.doit;
            break;
        }
        case SWT.MouseDown: {
            (cast(MouseListener) eventListener).mouseDown(new MouseEvent(e));
            break;
        }
        case SWT.MouseDoubleClick: {
            (cast(MouseListener) eventListener).mouseDoubleClick(new MouseEvent(e));
            break;
        }
        case SWT.MouseEnter: {
            (cast(MouseTrackListener) eventListener).mouseEnter (new MouseEvent (e));
            break;
        }
        case SWT.MouseExit: {
            (cast(MouseTrackListener) eventListener).mouseExit (new MouseEvent (e));
            break;
        }
        case SWT.MouseHover: {
            (cast(MouseTrackListener) eventListener).mouseHover (new MouseEvent (e));
            break;
        }
        case SWT.MouseMove: {
            (cast(MouseMoveListener) eventListener).mouseMove(new MouseEvent(e));
            return;
        }
        case SWT.MouseWheel: {
            (cast(MouseWheelListener) eventListener).mouseScrolled(new MouseEvent(e));
            return;
        }
        case SWT.MouseUp: {
            (cast(MouseListener) eventListener).mouseUp(new MouseEvent(e));
            break;
        }
        case SWT.Move: {
            (cast(ControlListener) eventListener).controlMoved(new ControlEvent(e));
            break;
        }
        case SWT.Paint: {
            /* Fields set by Control */
            PaintEvent event = new PaintEvent (e);
            (cast(PaintListener) eventListener).paintControl (event);
            e.gc = event.gc;
            break;
        }
        case SWT.Resize: {
            (cast(ControlListener) eventListener).controlResized(new ControlEvent(e));
            break;
        }
        case SWT.Selection: {
            /* Fields set by Sash */
            SelectionEvent event = new SelectionEvent (e);
            (cast(SelectionListener) eventListener).widgetSelected (event);
            e.x = event.x;
            e.y = event.y;
            e.doit = event.doit;
            break;
        }
        case SWT.Show: {
            (cast(MenuListener) eventListener).menuShown(new MenuEvent(e));
            break;
        }
        case SWT.Traverse: {
            /* Fields set by Control */
            TraverseEvent event = new TraverseEvent (e);
            (cast(TraverseListener) eventListener).keyTraversed (event);
            e.detail = event.detail;
            e.doit = event.doit;
            break;
        }
        case SWT.Verify: {
            /* Fields set by Text, RichText */
            VerifyEvent event = new VerifyEvent (e);
            (cast(VerifyListener) eventListener).verifyText (event);
            e.text = event.text;
            e.doit = event.doit;
            break;
        }
        default:
    }
}

}
