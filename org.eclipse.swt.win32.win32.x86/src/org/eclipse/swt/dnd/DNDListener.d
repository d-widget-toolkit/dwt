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
module org.eclipse.swt.dnd.DNDListener;


import org.eclipse.swt.internal.SWTEventListener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.dnd.DND;
import org.eclipse.swt.dnd.DNDEvent;
import org.eclipse.swt.dnd.DragSourceEvent;
import org.eclipse.swt.dnd.DragSourceEffect;
import org.eclipse.swt.dnd.DragSource;
import org.eclipse.swt.dnd.DragSourceListener;
import org.eclipse.swt.dnd.DropTargetEvent;
import org.eclipse.swt.dnd.DropTargetListener;
import org.eclipse.swt.dnd.DropTargetEffect;
import org.eclipse.swt.dnd.DropTarget;


class DNDListener : TypedListener {
    Widget dndWidget;
/**
 * DNDListener constructor comment.
 * @param listener org.eclipse.swt.internal.SWTEventListener
 */
this(SWTEventListener listener) {
    super(listener);
}
public override void handleEvent (Event e) {
    switch (e.type) {
        case DND.DragStart: {
            DragSourceEvent event = new DragSourceEvent(cast(DNDEvent)e);
            DragSourceEffect sourceEffect = (cast(DragSource) dndWidget).getDragSourceEffect();
            if (sourceEffect !is null) {
                sourceEffect.dragStart (event);
            }
            (cast(DragSourceListener) eventListener).dragStart (event);
            event.updateEvent(cast(DNDEvent)e);
            break;
        }
        case DND.DragEnd: {
            DragSourceEvent event = new DragSourceEvent(cast(DNDEvent)e);
            DragSourceEffect sourceEffect = (cast(DragSource) dndWidget).getDragSourceEffect();
            if (sourceEffect !is null) {
                sourceEffect.dragFinished (event);
            }
            (cast(DragSourceListener) eventListener).dragFinished (event);
            event.updateEvent(cast(DNDEvent)e);
            break;
        }
        case DND.DragSetData: {
            DragSourceEvent event = new DragSourceEvent(cast(DNDEvent)e);
            DragSourceEffect sourceEffect = (cast(DragSource) dndWidget).getDragSourceEffect();
            if (sourceEffect !is null) {
                sourceEffect.dragSetData (event);
            }
            (cast(DragSourceListener) eventListener).dragSetData (event);
            event.updateEvent(cast(DNDEvent)e);
            break;
        }
        case DND.DragEnter: {
            DropTargetEvent event = new DropTargetEvent(cast(DNDEvent)e);
            (cast(DropTargetListener) eventListener).dragEnter (event);
            DropTargetEffect dropEffect = (cast(DropTarget) dndWidget).getDropTargetEffect();
            if (dropEffect !is null) {
                dropEffect.dragEnter (event);
            }
            event.updateEvent(cast(DNDEvent)e);
            break;
        }
        case DND.DragLeave: {
            DropTargetEvent event = new DropTargetEvent(cast(DNDEvent)e);
            (cast(DropTargetListener) eventListener).dragLeave (event);
            DropTargetEffect dropEffect = (cast(DropTarget) dndWidget).getDropTargetEffect();
            if (dropEffect !is null) {
                dropEffect.dragLeave (event);
            }
            event.updateEvent(cast(DNDEvent)e);
            break;
        }
        case DND.DragOver: {
            DropTargetEvent event = new DropTargetEvent(cast(DNDEvent)e);
            (cast(DropTargetListener) eventListener).dragOver (event);
            DropTargetEffect dropEffect = (cast(DropTarget) dndWidget).getDropTargetEffect();
            if (dropEffect !is null) {
                dropEffect.dragOver (event);
            }
            event.updateEvent(cast(DNDEvent)e);
            break;
        }
        case DND.Drop: {
            DropTargetEvent event = new DropTargetEvent(cast(DNDEvent)e);
            (cast(DropTargetListener) eventListener).drop (event);
            DropTargetEffect dropEffect = (cast(DropTarget) dndWidget).getDropTargetEffect();
            if (dropEffect !is null) {
                dropEffect.drop (event);
            }
            event.updateEvent(cast(DNDEvent)e);
            break;
        }
        case DND.DropAccept: {
            DropTargetEvent event = new DropTargetEvent(cast(DNDEvent)e);
            (cast(DropTargetListener) eventListener).dropAccept (event);
            DropTargetEffect dropEffect = (cast(DropTarget) dndWidget).getDropTargetEffect();
            if (dropEffect !is null) {
                dropEffect.dropAccept (event);
            }
            event.updateEvent(cast(DNDEvent)e);
            break;
        }
        case DND.DragOperationChanged: {
            DropTargetEvent event = new DropTargetEvent(cast(DNDEvent)e);
            (cast(DropTargetListener) eventListener).dragOperationChanged (event);
            DropTargetEffect dropEffect = (cast(DropTarget) dndWidget).getDropTargetEffect();
            if (dropEffect !is null) {
                dropEffect.dragOperationChanged (event);
            }
            event.updateEvent(cast(DNDEvent)e);
            break;
        }
        default:

    }
}
}
