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
module org.eclipse.swt.dnd.TransferData;

import java.lang.all;


/**
 * The <code>TransferData</code> class is a platform specific data structure for
 * describing the type and the contents of data being converted by a transfer agent.
 *
 * <p>As an application writer, you do not need to know the specifics of
 * TransferData.  TransferData instances are passed to a subclass of Transfer
 * and the Transfer object manages the platform specific issues.
 * You can ask a Transfer subclass if it can handle this data by calling
 * Transfer.isSupportedType(transferData).</p>
 *
 * <p>You should only need to become familiar with the fields in this class if you
 * are implementing a Transfer subclass and you are unable to subclass the
 * ByteArrayTransfer class.</p>
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class TransferData {
    /**
     * The type is a unique identifier of a system format or user defined format.
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public void* type;

    /**
     * Specifies the number of units in pValue.
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     *
     * @see TransferData#format for the size of one unit
     */
    public int length;

    /**
     * Specifies the size in bits of a single unit in pValue.
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     *
     * This is most commonly 8 bits.
     */
    public int format;

    /**
     * Pointer to the data being transferred.
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public char* pValue;

    /**
     * The result field contains the result of converting a
     * java data type into a platform specific value.
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     * <p>The value of result is 1 if the conversion was successful.
     * The value of result is 0 if the conversion failed.</p>
     */
    public int result;

}
