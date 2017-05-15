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
module org.eclipse.swt.custom.StyledTextListener;


import org.eclipse.swt.events.VerifyEvent;
import org.eclipse.swt.internal.SWTEventListener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.custom.ExtendedModifyEvent;
import org.eclipse.swt.custom.ExtendedModifyListener;
import org.eclipse.swt.custom.StyledTextEvent;
import org.eclipse.swt.custom.LineBackgroundEvent;
import org.eclipse.swt.custom.BidiSegmentEvent;
import org.eclipse.swt.custom.LineStyleEvent;
import org.eclipse.swt.custom.PaintObjectEvent;
import org.eclipse.swt.custom.MovementEvent;
import org.eclipse.swt.custom.TextChangedEvent;
import org.eclipse.swt.custom.TextChangingEvent;
import org.eclipse.swt.custom.LineBackgroundListener;
import org.eclipse.swt.custom.BidiSegmentListener;
import org.eclipse.swt.custom.LineStyleListener;
import org.eclipse.swt.custom.PaintObjectListener;
import org.eclipse.swt.custom.VerifyKeyListener;
import org.eclipse.swt.custom.StyledTextContent;
import org.eclipse.swt.custom.TextChangeListener;
import org.eclipse.swt.custom.MovementListener;


class StyledTextListener : TypedListener {
/**
 */
this(SWTEventListener listener) {
    super(listener);
}
/**
 * Process StyledText events by invoking the event's handler.
 *
 * @param e the event to handle
 */
public override void handleEvent(Event e) {

    switch (e.type) {
        case StyledText.ExtendedModify:
            ExtendedModifyEvent extendedModifyEvent = new ExtendedModifyEvent(cast(StyledTextEvent) e);
            (cast(ExtendedModifyListener) eventListener).modifyText(extendedModifyEvent);
            break;
        case StyledText.LineGetBackground:
            LineBackgroundEvent lineBgEvent = new LineBackgroundEvent(cast(StyledTextEvent) e);
            (cast(LineBackgroundListener) eventListener).lineGetBackground(lineBgEvent);
            (cast(StyledTextEvent) e).lineBackground = lineBgEvent.lineBackground;
            break;
        case StyledText.LineGetSegments:
            BidiSegmentEvent segmentEvent = new BidiSegmentEvent(cast(StyledTextEvent) e);
            (cast(BidiSegmentListener) eventListener).lineGetSegments(segmentEvent);
            (cast(StyledTextEvent) e).segments = segmentEvent.segments;
            break;
        case StyledText.LineGetStyle:
            LineStyleEvent lineStyleEvent = new LineStyleEvent(cast(StyledTextEvent) e);
            (cast(LineStyleListener) eventListener).lineGetStyle(lineStyleEvent);
            (cast(StyledTextEvent) e).ranges = lineStyleEvent.ranges;
            (cast(StyledTextEvent) e).styles = lineStyleEvent.styles;
            (cast(StyledTextEvent) e).alignment = lineStyleEvent.alignment;
            (cast(StyledTextEvent) e).indent = lineStyleEvent.indent;
            (cast(StyledTextEvent) e).justify = lineStyleEvent.justify;
            (cast(StyledTextEvent) e).bullet = lineStyleEvent.bullet;
            (cast(StyledTextEvent) e).bulletIndex = lineStyleEvent.bulletIndex;
            break;
        case StyledText.PaintObject:
            PaintObjectEvent paintObjectEvent = new PaintObjectEvent(cast(StyledTextEvent) e);
            (cast(PaintObjectListener) eventListener).paintObject(paintObjectEvent);
            break;
        case StyledText.VerifyKey:
            VerifyEvent verifyEvent = new VerifyEvent(e);
            (cast(VerifyKeyListener) eventListener).verifyKey(verifyEvent);
            e.doit = verifyEvent.doit;
            break;
        case StyledText.TextChanged: {
            TextChangedEvent textChangedEvent = new TextChangedEvent(cast(StyledTextContent) e.data);
            (cast(TextChangeListener) eventListener).textChanged(textChangedEvent);
            break;
        }
        case StyledText.TextChanging:
            TextChangingEvent textChangingEvent = new TextChangingEvent(cast(StyledTextContent) e.data, cast(StyledTextEvent) e);
            (cast(TextChangeListener) eventListener).textChanging(textChangingEvent);
            break;
        case StyledText.TextSet: {
            TextChangedEvent textChangedEvent = new TextChangedEvent(cast(StyledTextContent) e.data);
            (cast(TextChangeListener) eventListener).textSet(textChangedEvent);
            break;
        }
        case StyledText.WordNext: {
            MovementEvent wordBoundaryEvent = new MovementEvent(cast(StyledTextEvent) e);
            (cast(MovementListener) eventListener).getNextOffset(wordBoundaryEvent);
            (cast(StyledTextEvent) e).end = wordBoundaryEvent.newOffset;
            break;
        }
        case StyledText.WordPrevious: {
            MovementEvent wordBoundaryEvent = new MovementEvent(cast(StyledTextEvent) e);
            (cast(MovementListener) eventListener).getPreviousOffset(wordBoundaryEvent);
            (cast(StyledTextEvent) e).end = wordBoundaryEvent.newOffset;
            break;
        }
        default:
    }
}
}


