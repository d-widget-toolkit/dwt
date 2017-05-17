/*******************************************************************************
 * Copyright (c) 2000, 2007 IBM Corporation and others.
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
module org.eclipse.swt.events.DragDetectListener;


public import org.eclipse.swt.internal.SWTEventListener;
public import org.eclipse.swt.events.DragDetectEvent;

/**
 * Classes which implement this interface provide methods
 * that deal with the events that are generated when a drag
 * gesture is detected.
 * <p>
 * After creating an instance of a class that :
 * this interface it can be added to a control using the
 * <code>addDragDetectListener</code> method and removed using
 * the <code>removeDragDetectListener</code> method. When the
 * drag is detected, the drageDetected method will be invoked.
 * </p>
 *
 * @see DragDetectEvent
 *
 * @since 3.3
 */
public interface DragDetectListener : SWTEventListener {

/**
 * Sent when a drag gesture is detected.
 *
 * @param e an event containing information about the drag
 */
public void dragDetected(DragDetectEvent e);
}
