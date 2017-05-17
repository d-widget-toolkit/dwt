/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
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
module org.eclipse.swt.custom.SashFormData;

import java.lang.all;

class SashFormData {

    long weight;

String getName () {
    String str = this.classinfo.name;
    int index = str.lastIndexOf ('.');
    if (index is -1) return str;
    return str[ index + 1 .. $ ];
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the event
 */
public override String toString () {
    return getName()~" {weight="~String_valueOf(weight)~"}"; //$NON-NLS-2$
}
}
