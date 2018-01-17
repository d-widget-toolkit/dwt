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
module org.eclipse.swt.custom.DefaultContent;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.Compatibility;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.custom.StyledTextContent;
import org.eclipse.swt.custom.TextChangeListener;
import org.eclipse.swt.custom.StyledTextEvent;
import org.eclipse.swt.custom.StyledTextListener;
import org.eclipse.swt.custom.StyledText;

import java.lang.all;
import java.nonstandard.UnsafeUtf;

version(Tango){
    static import tango.io.model.IFile;
} else { // Phobos
    static import std.ascii;
    static import std.string;
}


class DefaultContent : StyledTextContent {
    version(Tango){
        private const static String LineDelimiter = tango.io.model.IFile.FileConst.NewlineString;
    } else { // Phobos
        private const static String LineDelimiter = std.ascii.newline;
    }

    StyledTextListener[] textListeners; // stores text listeners for event sending
    char[] textStore; // stores the actual text
    int gapStart = -1;  // the character position start of the gap
    int gapEnd = -1;    // the character position after the end of the gap
    int gapLine = -1;   // the line on which the gap exists, the gap will always be associated with one line
    int highWatermark = 300;
    int lowWatermark = 50;

    int[][] lines; // array of character positions and lengths representing the lines of text
    int lineCount_ = 0;  // the number of lines of text
    int expandExp = 1;  // the expansion exponent, used to increase the lines array exponentially
    int replaceExpandExp = 1;   // the expansion exponent, used to increase the lines array exponentially

/**
 * Creates a new DefaultContent and initializes it.  A <code>StyledTextContent</> will always have
 * at least one empty line.
 */
this() {
    lines = new int[][]( 50, 2 );
    setText("");
}
/**
 * Adds a line to the end of the line indexes array.  Increases the size of the array if necessary.
 * <code>lineCount</code> is updated to reflect the new entry.
 * <p>
 *
 * @param start the start of the line
 * @param length the length of the line
 */
void addLineIndex(int start, int length) {
    int size = cast(int)/*64bit*/lines.length;
    if (lineCount_ is size) {
        // expand the lines by powers of 2
        int[][] newLines = new int[][]( size+Compatibility.pow2(expandExp), 2 );
        System.arraycopy(lines, 0, newLines, 0, size);
        lines = newLines;
        expandExp++;
    }
    int[] range = [start, length];
    lines[lineCount_] = range;
    lineCount_++;
}
/**
 * Adds a line index to the end of <code>linesArray</code>.  Increases the
 * size of the array if necessary and returns a new array.
 * <p>
 *
 * @param start the start of the line
 * @param length the length of the line
 * @param linesArray the array to which to add the line index
 * @param count the position at which to add the line
 * @return a new array of line indexes
 */
int[][] addLineIndex(int start, int length, int[][] linesArray, int count) {
    int size = cast(int)/*64bit*/linesArray.length;
    int[][] newLines = linesArray;
    if (count is size) {
        newLines = new int[][]( size+Compatibility.pow2(replaceExpandExp), 2 );
        replaceExpandExp++;
        System.arraycopy(linesArray, 0, newLines, 0, size);
    }
    int[] range = [start, length];
    newLines[count] = range;
    return newLines;
}
/**
 * Adds a <code>TextChangeListener</code> listening for
 * <code>TextChangingEvent</code> and <code>TextChangedEvent</code>. A
 * <code>TextChangingEvent</code> is sent before changes to the text occur.
 * A <code>TextChangedEvent</code> is sent after changes to the text
 * occurred.
 * <p>
 *
 * @param listener the listener
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT when listener is null</li>
 * </ul>
 */
public void addTextChangeListener(TextChangeListener listener) {
    if (listener is null) error(SWT.ERROR_NULL_ARGUMENT);
    StyledTextListener typedListener = new StyledTextListener(listener);
    textListeners ~= typedListener;
}
/**
 * Adjusts the gap to accommodate a text change that is occurring.
 * <p>
 *
 * @param position the position at which a change is occurring
 * @param sizeHint the size of the change
 * @param line the line where the gap will go
 */
void adjustGap(int position, int sizeHint, int line) {
    if (position is gapStart) {
        // text is being inserted at the gap position
        int size = (gapEnd - gapStart) - sizeHint;
        if (lowWatermark <= size && size <= highWatermark)
            return;
    } else if ((position + sizeHint is gapStart) && (sizeHint < 0)) {
        // text is being deleted at the gap position
        int size = (gapEnd - gapStart) - sizeHint;
        if (lowWatermark <= size && size <= highWatermark)
            return;
    }
    moveAndResizeGap(position, sizeHint, line);
}
/**
 * Calculates the indexes of each line in the text store.  Assumes no gap exists.
 * Optimized to do less checking.
 */
void indexLines(){
    int start = 0;
    lineCount_ = 0;
    int textLength = cast(int)/*64bit*/textStore.length;
    int i;
    for (i = start; i < textLength; i++) {
        char ch = textStore[i];
        if (ch is SWT.CR) {
            // see if the next character is a LF
            if (i + 1 < textLength) {
                ch = textStore[i+1];
                if (ch is SWT.LF) {
                    i++;
                }
            }
            addLineIndex(start, i - start + 1);
            start = i + 1;
        } else if (ch is SWT.LF) {
            addLineIndex(start, i - start + 1);
            start = i + 1;
        }
    }
    addLineIndex(start, i - start);
}
/**
 * Returns whether or not the given character is a line delimiter.  Both CR and LF
 * are valid line delimiters.
 * <p>
 *
 * @param ch the character to test
 * @return true if ch is a delimiter, false otherwise
 */
bool isDelimiter(char ch) {
    if (ch is SWT.CR) return true;
    if (ch is SWT.LF) return true;
    return false;
}
/**
 * Determine whether or not the replace operation is valid.  DefaultContent will not allow
 * the /r/n line delimiter to be split or partially deleted.
 * <p>
 *
 * @param start start offset of text to replace
 * @param replaceLength start offset of text to replace
 * @param newText start offset of text to replace
 * @return a bool specifying whether or not the replace operation is valid
 */
protected bool isValidReplace(int start, int replaceLength, String newText){
    if (replaceLength is 0) {
        // inserting text, see if the \r\n line delimiter is being split
        if (start is 0) return true;
        if (start is getCharCount()) return true;
        char before = getTextRange(start - 1, 1)[0];
        if (before is '\r') {
            char after = getTextRange(start, 1)[0];
            if (after is '\n') return false;
        }
    } else {
        // deleting text, see if part of a \r\n line delimiter is being deleted
        char startChar = getTextRange(start, 1)[0];
        if (startChar is '\n') {
            // see if char before delete position is \r
            if (start !is 0) {
                char before = getTextRange(start - 1, 1)[0];
                if (before is '\r') return false;
            }
        }
        char endChar = getTextRange(start + replaceLength - 1, 1)[0];
        if (endChar is '\r') {
            // see if char after delete position is \n
            if (start + replaceLength !is getCharCount()) {
                char after = getTextRange(start + replaceLength, 1)[0];
                if (after is '\n') return false;
            }
        }
    }
    return true;
}
/**
 * Calculates the indexes of each line of text in the given range.
 * <p>
 *
 * @param offset the logical start offset of the text lineate
 * @param length the length of the text to lineate, includes gap
 * @param numLines the number of lines to initially allocate for the line index array,
 *  passed in for efficiency (the exact number of lines may be known)
 * @return a line indexes array where each line is identified by a start offset and
 *  a length
 */
int[][] indexLines(int offset, int length, int numLines){
    int[][] indexedLines = new int[][]( numLines, 2 );
    int start = 0;
    int lineCount_ = 0;
    int i;
    replaceExpandExp = 1;
    for (i = start; i < length; i++) {
        int location = i + offset;
        if ((location >= gapStart) && (location < gapEnd)) {
            // ignore the gap
        } else {
            char ch = textStore[location];
            if (ch is SWT.CR) {
                // see if the next character is a LF
                if (location+1 < textStore.length) {
                    ch = textStore[location+1];
                    if (ch is SWT.LF) {
                        i++;
                    }
                }
                indexedLines = addLineIndex(start, i - start + 1, indexedLines, lineCount_);
                lineCount_++;
                start = i + 1;
            } else if (ch is SWT.LF) {
                indexedLines = addLineIndex(start, i - start + 1, indexedLines, lineCount_);
                lineCount_++;
                start = i + 1;
            }
        }
    }
    int[][] newLines = new int[][]( lineCount_+1, 2 );
    System.arraycopy(indexedLines, 0, newLines, 0, lineCount_);
    int[] range = [start, i - start];
    newLines[lineCount_] = range;
    return newLines;
}
/**
 * Inserts text.
 * <p>
 *
 * @param position the position at which to insert the text
 * @param text the text to insert
 */
void insert(int position, String text) {
    if (text.length is 0) return;

    int startLine = getLineAtOffset(position);
    int change = cast(int)/*64bit*/text.length;
    bool endInsert = position is getCharCount();
    adjustGap(position, change, startLine);

    // during an insert the gap will be adjusted to start at
    // position and it will be associated with startline, the
    // inserted text will be placed in the gap
    int startLineOffset = getOffsetAtLine(startLine);
    // at this point, startLineLength will include the start line
    // and all of the newly inserted text
    int startLineLength = cast(int)/*64bit*/getPhysicalLine(startLine).length;

    if (change > 0) {
        // shrink gap
        gapStart += (change);
        for (int i = 0; i < text.length; i++) {
            textStore[position + i]= text[i];
        }
    }

    // figure out the number of new lines that have been inserted
    int [][] newLines = indexLines(startLineOffset, startLineLength, 10);
    // only insert an empty line if it is the last line in the text
    int numNewLines = cast(int)/*64bit*/newLines.length - 1;
    if (newLines[numNewLines][1] is 0) {
        // last inserted line is a new line
        if (endInsert) {
            // insert happening at end of the text, leave numNewLines as
            // is since the last new line will not be concatenated with another
            // line
            numNewLines += 1;
        } else {
            numNewLines -= 1;
        }
    }

    // make room for the new lines
    expandLinesBy(numNewLines);
    // shift down the lines after the replace line
    for (int i = lineCount_ - 1; i > startLine; i--) {
        lines[i + numNewLines]=lines[i];
    }
    // insert the new lines
    for (int i = 0; i < numNewLines; i++) {
        newLines[i][0] += startLineOffset;
        lines[startLine + i]=newLines[i];
    }
    // update the last inserted line
    if (numNewLines < newLines.length) {
        newLines[numNewLines][0] += startLineOffset;
        lines[startLine + numNewLines] = newLines[numNewLines];
    }

    lineCount_ += numNewLines;
    gapLine = getLineAtPhysicalOffset(gapStart);
}
/**
 * Moves the gap and adjusts its size in anticipation of a text change.
 * The gap is resized to actual size + the specified size and moved to the given
 * position.
 * <p>
 *
 * @param position the position at which a change is occurring
 * @param size the size of the change
 * @param newGapLine the line where the gap should be put
 */
void moveAndResizeGap(int position, int size, int newGapLine) {
    char[] content = null;
    int oldSize = gapEnd - gapStart;
    int newSize;
    if (size > 0) {
        newSize = highWatermark + size;
    } else {
        newSize = lowWatermark - size;
    }
    // remove the old gap from the lines information
    if (gapExists()) {
        // adjust the line length
        lines[gapLine][1] = lines[gapLine][1] - oldSize;
        // adjust the offsets of the lines after the gapLine
        for (int i = gapLine + 1; i < lineCount_; i++) {
            lines[i][0] = lines[i][0] - oldSize;
        }
    }

    if (newSize < 0) {
        if (oldSize > 0) {
            // removing the gap
            content = new char[textStore.length - oldSize];
            System.arraycopy(textStore, 0, content, 0, gapStart);
            System.arraycopy(textStore, gapEnd, content, gapStart, content.length - gapStart);
            textStore = content;
        }
        gapStart = gapEnd = position;
        return;
    }
    content = new char[textStore.length + (newSize - oldSize)];
    int newGapStart = position;
    int newGapEnd = newGapStart + newSize;
    if (oldSize is 0) {
        System.arraycopy(textStore, 0, content, 0, newGapStart);
        System.arraycopy(textStore, newGapStart, content, newGapEnd, content.length - newGapEnd);
    } else if (newGapStart < gapStart) {
        int delta = gapStart - newGapStart;
        System.arraycopy(textStore, 0, content, 0, newGapStart);
        System.arraycopy(textStore, newGapStart, content, newGapEnd, delta);
        System.arraycopy(textStore, gapEnd, content, newGapEnd + delta, textStore.length - gapEnd);
    } else {
        int delta = newGapStart - gapStart;
        System.arraycopy(textStore, 0, content, 0, gapStart);
        System.arraycopy(textStore, gapEnd, content, gapStart, delta);
        System.arraycopy(textStore, gapEnd + delta, content, newGapEnd, content.length - newGapEnd);
    }
    textStore = content;
    gapStart = newGapStart;
    gapEnd = newGapEnd;

    // add the new gap to the lines information
    if (gapExists()) {
        gapLine = newGapLine;
        // adjust the line length
        int gapLength = gapEnd - gapStart;
        lines[gapLine][1] = lines[gapLine][1] + (gapLength);
        // adjust the offsets of the lines after the gapLine
        for (int i = gapLine + 1; i < lineCount_; i++) {
            lines[i][0] = lines[i][0] + gapLength;
        }
    }
}
/**
 * Returns the number of lines that are in the specified text.
 * <p>
 *
 * @param startOffset the start of the text to lineate
 * @param length the length of the text to lineate
 * @return number of lines
 */
int lineCount(int startOffset, int length){
    if (length is 0) {
        return 0;
    }
    int lineCount_ = 0;
    int count = 0;
    int i = startOffset;
    if (i >= gapStart) {
        i += gapEnd - gapStart;
    }
    while (count < length) {
        if ((i >= gapStart) && (i < gapEnd)) {
            // ignore the gap
        } else {
            char ch = textStore[i];
            if (ch is SWT.CR) {
                // see if the next character is a LF
                if (i + 1 < textStore.length) {
                    ch = textStore[i+1];
                    if (ch is SWT.LF) {
                        i++;
                        count++;
                    }
                }
                lineCount_++;
            } else if (ch is SWT.LF) {
                lineCount_++;
            }
            count++;
        }
        i++;
    }
    return lineCount_;
}
/**
 * Returns the number of lines that are in the specified text.
 * <p>
 *
 * @param text the text to lineate
 * @return number of lines in the text
 */
int lineCount(String text){
    int lineCount_ = 0;
    int length = cast(int)/*64bit*/text.length;
    for (int i = 0; i < length; i++) {
        char ch = text[i];
        if (ch is SWT.CR) {
            if (i + 1 < length && text[i + 1] is SWT.LF) {
                i++;
            }
            lineCount_++;
        } else if (ch is SWT.LF) {
            lineCount_++;
        }
    }
    return lineCount_;
}
/**
 * @return the logical length of the text store
 */
public int getCharCount() {
    int length = gapEnd - gapStart;
    return (cast(int)/*64bit*/textStore.length - length);
}
/**
 * Returns the line at <code>index</code> without delimiters.
 * <p>
 *
 * @param index the index of the line to return
 * @return the logical line text (i.e., without the gap)
 * @exception IllegalArgumentException <ul>
 *   <li>ERROR_INVALID_ARGUMENT when index is out of range</li>
 * </ul>
 */
public String getLine(int index) {
    if ((index >= lineCount_) || (index < 0)) error(SWT.ERROR_INVALID_ARGUMENT);
    int start = lines[index][0];
    int length_ = lines[index][1];
    int end = start + length_ - 1;
    if (!gapExists() || (end < gapStart) || (start >= gapEnd)) {
        // line is before or after the gap
        while ((length_ - 1 >= 0) && isDelimiter(textStore[start+length_-1])) {
            length_--;
        }
        return textStore[ start .. start + length_]._idup();
    } else {
        // gap is in the specified range, strip out the gap
        StringBuffer buf = new StringBuffer();
        int gapLength = gapEnd - gapStart;
        buf.append(textStore[ start .. gapStart ] );
        buf.append(textStore[ gapEnd .. gapEnd + length_ - gapLength - (gapStart - start) ]);
        length_ = buf.length;
        while ((length_ - 1 >=0) && isDelimiter(buf.slice[length_ - 1])) {
            length_--;
        }
        return buf.slice()[ 0 .. length_ ]._idup();
    }
}
/**
 * Returns the line delimiter that should be used by the StyledText
 * widget when inserting new lines.  This delimiter may be different than the
 * delimiter that is used by the <code>StyledTextContent</code> interface.
 * <p>
 *
 * @return the platform line delimiter as specified in the line.separator
 *  system property.
 */
public String getLineDelimiter() {
    return LineDelimiter;
}
/**
 * Returns the line at the given index with delimiters.
 * <p>
 * @param index the index of the line to return
 * @return the logical line text (i.e., without the gap) with delimiters
 */
String getFullLine(int index) {
    int start = lines[index][0];
    int length_ = lines[index][1];
    int end = start + length_ - 1;
    if (!gapExists() || (end < gapStart) || (start >= gapEnd)) {
        // line is before or after the gap
        return textStore[ start .. start + length_ ]._idup();
    } else {
        // gap is in the specified range, strip out the gap
        StringBuffer buffer = new StringBuffer();
        int gapLength = gapEnd - gapStart;
        buffer.append(textStore[ start .. gapStart ]);
        buffer.append(textStore[ gapEnd .. gapEnd + length_ - gapLength - (gapStart - start) ]);
        return buffer.toString();
    }
}
/**
 * Returns the physical line at the given index (i.e., with delimiters and the gap).
 * <p>
 *
 * @param index the line index
 * @return the physical line
 */
String getPhysicalLine(int index) {
    int start = lines[index][0];
    int length_ = lines[index][1];
    return getPhysicalText(start, length_);
}
/**
 * @return the number of lines in the text store
 */
public int getLineCount(){
    return lineCount_;
}
/**
 * Returns the line at the given offset.
 * DWT: index can be an invalid UTF-8 index
 * <p>
 *
 * @param charPosition logical character offset (i.e., does not include gap)
 * @return the line index
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT when charPosition is out of range</li>
 * </ul>
 */
public int getLineAtOffset(int charPosition){
    if ((charPosition > getCharCount()) || (charPosition < 0)) error(SWT.ERROR_INVALID_ARGUMENT);
    int position;
    if (charPosition < gapStart) {
        // position is before the gap
        position = charPosition;
    } else {
        // position includes the gap
        position = charPosition + (gapEnd - gapStart);
    }

    // if last line and the line is not empty you can ask for
    // a position that doesn't exist (the one to the right of the
    // last character) - for inserting
    if (lineCount_ > 0) {
        int lastLine = lineCount_ - 1;
        if (position is lines[lastLine][0] + lines[lastLine][1])
            return lastLine;
    }

    int high = lineCount_;
    int low = -1;
    int index = lineCount_;
    while (high - low > 1) {
        index = (high + low) / 2;
        int lineStart = lines[index][0];
        int lineEnd = lineStart + lines[index][1] - 1;
        if (position <= lineStart) {
            high = index;
        } else if (position <= lineEnd) {
            high = index;
            break;
        } else {
            low = index;
        }
    }
    return high;
}
/**
 * Returns the line index at the given physical offset.
 * <p>
 *
 * @param position physical character offset (i.e., includes gap)
 * @return the line index
 */
int getLineAtPhysicalOffset(int position){
    int high = lineCount_;
    int low = -1;
    int index = lineCount_;
    while (high - low > 1) {
        index = (high + low) / 2;
        int lineStart = lines[index][0];
        int lineEnd = lineStart + lines[index][1] - 1;
        if (position <= lineStart) {
            high = index;
        } else if (position <= lineEnd) {
            high = index;
            break;
        } else {
            low = index;
        }
    }
    return high;
}
/**
 * Returns the logical offset of the given line.
 * <p>
 *
 * @param lineIndex index of line
 * @return the logical starting offset of the line.  When there are not any lines,
 *  getOffsetAtLine(0) is a valid call that should answer 0.
 * @exception IllegalArgumentException <ul>
 *   <li>ERROR_INVALID_ARGUMENT when lineIndex is out of range</li>
 * </ul>
 */
public int getOffsetAtLine(int lineIndex) {
    if (lineIndex is 0) return 0;
    if ((lineIndex >= lineCount_) || (lineIndex < 0)) error(SWT.ERROR_INVALID_ARGUMENT);
    int start = lines[lineIndex][0];
    if (start > gapEnd) {
        return start - (gapEnd - gapStart);
    } else {
        return start;
    }
}
/**
 * Increases the line indexes array to accommodate more lines.
 * <p>
 *
 * @param numLines the number to increase the array by
 */
void expandLinesBy(int numLines) {
    int size = cast(int)/*64bit*/lines.length;
    if (size - lineCount_ >= numLines) {
        return;
    }
    int[][] newLines = new int[][]( size+Math.max(10, numLines), 2 );
    System.arraycopy(lines, 0, newLines, 0, size);
    lines = newLines;
}
/**
 * Reports an SWT error.
 * <p>
 *
 * @param code the error code
 */
void error (int code) {
    SWT.error(code);
}
/**
 * Returns whether or not a gap exists in the text store.
 * <p>
 *
 * @return true if gap exists, false otherwise
 */
bool gapExists() {
    return gapStart !is gapEnd;
}
/**
 * Returns a string representing the continuous content of
 * the text store.
 * <p>
 *
 * @param start the physical start offset of the text to return
 * @param length the physical length of the text to return
 * @return the text
 */
String getPhysicalText(int start, int length_) {
    return textStore[ start .. start + length_ ]._idup();
}
/**
 * Returns a string representing the logical content of
 * the text store (i.e., gap stripped out).
 * <p>
 *
 * @param start the logical start offset of the text to return
 * @param length the logical length of the text to return
 * @return the text
 */
public String getTextRange(int start, int length_) {
    if (textStore is null)
        return "";
    if (length_ is 0)
        return "";
    int end= start + length_;
    if (!gapExists() || (end < gapStart))
        return textStore[ start .. start + length_]._idup();
    if (gapStart < start) {
        int gapLength= gapEnd - gapStart;
        return textStore[ start + gapLength .. start + gapLength + length_ ]._idup();
    }
    StringBuffer buf = new StringBuffer();
    buf.append(textStore[ start .. start + gapStart - start ] );
    buf.append(textStore[ gapEnd .. gapEnd + end - gapStart ] );
    return buf.toString();
}
/**
 * Removes the specified <code>TextChangeListener</code>.
 * <p>
 *
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT when listener is null</li>
 * </ul>
 */
public void removeTextChangeListener(TextChangeListener listener){
    if (listener is null) error(SWT.ERROR_NULL_ARGUMENT);
    for (int i = 0; i < textListeners.length; i++) {
        TypedListener typedListener = cast(TypedListener) textListeners[i];
        if (typedListener.getEventListener () is listener) {
            textListeners = textListeners[ 0 .. i ] ~ textListeners[ i+1 .. $ ];
            break;
        }
    }
}
/**
 * Replaces the text with <code>newText</code> starting at position <code>start</code>
 * for a length of <code>replaceLength</code>.  Notifies the appropriate listeners.
 * <p>
 *
 * When sending the TextChangingEvent, <code>newLineCount</code> is the number of
 * lines that are going to be inserted and <code>replaceLineCount</code> is
 * the number of lines that are going to be deleted, based on the change
 * that occurs visually.  For example:
 * <ul>
 * <li>(replaceText,newText) is> (replaceLineCount,newLineCount)
 * <li>("","\n") is> (0,1)
 * <li>("\n\n","a") is> (2,0)
 * </ul>
 * </p>
 *
 * @param start start offset of text to replace
 * @param replaceLength start offset of text to replace
 * @param newText start offset of text to replace
 *
 * @exception SWTException <ul>
 *   <li>ERROR_INVALID_ARGUMENT when the text change results in a multi byte
 *      line delimiter being split or partially deleted.  Splitting a line
 *      delimiter by inserting text between the CR and LF characters of the
 *      \r\n delimiter or deleting part of this line delimiter is not supported</li>
 * </ul>
 */
public void replaceTextRange(int start, int replaceLength, String newText){
    // check for invalid replace operations
    if (!isValidReplace(start, replaceLength, newText)) SWT.error(SWT.ERROR_INVALID_ARGUMENT);

    // inform listeners
    StyledTextEvent event = new StyledTextEvent(this);
    event.type = StyledText.TextChanging;
    event.start = start;
    event.replaceLineCount = lineCount(start, replaceLength);
    event.text = newText;
    event.newLineCount = lineCount(newText);
    event.replaceCharCount = replaceLength;
    event.newCharCount = cast(int)/*64bit*/newText.length;
    sendTextEvent(event);

    // first delete the text to be replaced
    delete_(start, replaceLength, event.replaceLineCount + 1);
    // then insert the new text
    insert(start, newText);
    // inform listeners
    event = new StyledTextEvent(this);
    event.type = StyledText.TextChanged;
    sendTextEvent(event);
}
/**
 * Sends the text listeners the TextChanged event.
 */
void sendTextEvent(StyledTextEvent event) {
    for (int i = 0; i < textListeners.length; i++) {
        (cast(StyledTextListener)textListeners[i]).handleEvent(event);
    }
}
/**
 * Sets the content to text and removes the gap since there are no sensible predictions
 * about where the next change will occur.
 * <p>
 *
 * @param text the text
 */
public void setText (String text){
    textStore = text.dup;
    gapStart = -1;
    gapEnd = -1;
    expandExp = 1;
    indexLines();
    StyledTextEvent event = new StyledTextEvent(this);
    event.type = StyledText.TextSet;
    event.text = "";
    sendTextEvent(event);
}
/**
 * Deletes text.
 * <p>
 * @param position the position at which the text to delete starts
 * @param length the length of the text to delete
 * @param numLines the number of lines that are being deleted
 */
void delete_(int position, int length_, int numLines) {
    if (length_ is 0) return;

    int startLine = getLineAtOffset(position);
    int startLineOffset = getOffsetAtLine(startLine);
    int endLine = getLineAtOffset(position + length_);

    String endText = "";
    bool splittingDelimiter = false;
    if (position + length_ < getCharCount()) {
        endText = getTextRange(position + length_ - 1, 2);
        if ((endText[0] is SWT.CR) && (endText[1] is SWT.LF)) {
            splittingDelimiter = true;
        }
    }

    adjustGap(position + length_, -length_, startLine);
    int [][] oldLines = indexLines(position, length_ + (gapEnd - gapStart), numLines);

    // enlarge the gap - the gap can be enlarged either to the
    // right or left
    if (position + length_ is gapStart) {
        gapStart -= length_;
    } else {
        gapEnd += length_;
    }

    // figure out the length of the new concatenated line, do so by
    // finding the first line delimiter after position
    int j = position;
    bool eol = false;
    while (j < textStore.length && !eol) {
        if (j < gapStart || j >= gapEnd) {
            char ch = textStore[j];
            if (isDelimiter(ch)) {
                if (j + 1 < textStore.length) {
                    if (ch is SWT.CR && (textStore[j+1] is SWT.LF)) {
                        j++;
                    }
                }
                eol = true;
            }
        }
        j++;
    }
    // update the line where the deletion started
    lines[startLine][1] = (position - startLineOffset) + (j - position);
    // figure out the number of lines that have been deleted
    int numOldLines = cast(int)/*64bit*/oldLines.length - 1;
    if (splittingDelimiter) numOldLines -= 1;
    // shift up the lines after the last deleted line, no need to update
    // the offset or length of the lines
    for (int i = endLine + 1; i < lineCount_; i++) {
        lines[i - numOldLines] = lines[i];
    }
    lineCount_ -= numOldLines;
    gapLine = getLineAtPhysicalOffset(gapStart);
}


}
