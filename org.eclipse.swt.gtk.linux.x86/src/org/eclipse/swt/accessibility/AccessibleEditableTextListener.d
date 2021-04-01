/*******************************************************************************
 * Copyright (c) 2010, 2011 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     alice <stigma@disroot.org>
 *******************************************************************************/
module org.eclipse.swt.accessibility.AccessibleEditableTextListener;

import org.eclipse.swt.internal.SWTEventListener;

import org.eclipse.swt.accessibility.AccessibleEditableTextEvent;
import org.eclipse.swt.accessibility.AccessibleTextAttributeEvent;

/**
 * Classes which implement this interface provide methods
 * that handle AccessibleEditableText events.
 * <p>
 * After creating an instance of a class that implements
 * this interface it can be added to an accessible using the
 * <code>addAccessibleEditableTextListener</code> method and removed using
 * the <code>removeAccessibleEditableTextListener</code> method.
 * </p>
 *
 * @see AccessibleEditableTextAdapter
 * @see AccessibleEditableTextEvent
 * @see AccessibleTextAttributeEvent
 *
 * @since 3.7
 */
public interface AccessibleEditableTextListener : SWTEventListener {
    /**
     * Copies the substring beginning at the specified <code>start</code> offset
     * and extending to the character at offset <code>end - 1</code> to the clipboard.
     *
     * @param e an event object containing the following information:<ul>
     * <li>[in] start - the 0 based offset of the first character of the substring
     * 		to be copied to the clipboard</li>
     * <li>[in] end - the 0 based offset after the last character of the substring
     * 		to be copied to the clipboard</li>
     * <li>[out] result - set to {@link ACC#OK} if the operation was completed successfully</li>
     * </ul>
     */
    public void copyText(AccessibleEditableTextEvent e);

    /**
     * Moves the substring beginning at the specified <code>start</code> offset
     * and extending to the character at offset <code>end - 1</code> to the clipboard.
     *
     * @param e an event object containing the following information:<ul>
     * <li>[in] start - the 0 based offset of the first character of the substring
     * 		to be moved to the clipboard</li>
     * <li>[in] end - the 0 based offset after the last character of the substring
     * 		to be moved to the clipboard</li>
     * <li>[out] result - set to {@link ACC#OK} if the operation was completed successfully</li>
     * </ul>
     */
    public void cutText(AccessibleEditableTextEvent e);

    /**
     * Inserts the text in the clipboard at the leading edge of the specified <code>start</code> offset.
     *
     * @param e an event object containing the following information:<ul>
     * <li>[in] start - the offset at which to insert the text from the clipboard.
     * 		The valid range is 0..length</li>
     * <li>[out] result - set to {@link ACC#OK} if the operation was completed successfully</li>
     * </ul>
     */
    public void pasteText(AccessibleEditableTextEvent e);

    /**
     * Replaces the substring beginning at the specified <code>start</code> offset
     * and extending to the character at offset <code>end - 1</code> by the specified string.
     * <p>
     * This event notification is also used to delete text if <code>string</code> is an empty string,
     * or to insert text at the leading edge of the specified offset if <code>start</code> and <code>end</code> are equal.
     * </p>
     *
     * @param e an event object containing the following information:<ul>
     * <li>[in] start - the 0 based offset of the first character of the substring
     * 		to be replaced</li>
     * <li>[in] end - the 0 based offset after the last character of the substring
     * 		to be replaced</li>
     * <li>[in] string - the string that replaces the substring beginning at
     * 		<code>start</code> and extending to <code>end - 1</code></li>
     * <li>[out] result - set to {@link ACC#OK} if the operation was completed successfully</li>
     * </ul>
     */
    public void replaceText(AccessibleEditableTextEvent e);

    /**
     * Replaces the set of attributes of the substring beginning at the specified <code>start</code> offset
     * and extending to the character at offset <code>end - 1</code> by the specified set of attributes.
     *
     * @param e an event object containing the following information:<ul>
     * <li>[in] start - the 0 based offset of the first character of the substring
     * 		whose attributes are modified</li>
     * <li>[in] end - the 0 based offset after the last character of the substring
     * 		whose attributes are modified</li>
     * <li>[in] textStyle - the TextStyle which contains attributes that replace the old set of attributes.
     * 		The foreground, background, and font fields of this TextStyle are only valid for the duration of the event.
     * 		The value of this field may be null if none of the attributes to be set correspond to TextStyle fields.</li>
     * <li>[in] attributes - an array of alternating key and value Strings that represent the complete
     * 		set of attributes to replace the old set of attributes.
     * 		The value of this field may be null if no attributes are to be set.</li>
     * <li>[out] result - set to {@link ACC#OK} if the operation was completed successfully</li>
     * </ul>
     */
    public void setTextAttributes(AccessibleTextAttributeEvent e);
}
