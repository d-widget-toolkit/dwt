/*******************************************************************************
 * Copyright (c) 2000, 2004 IBM Corporation and others.
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
module org.eclipse.swt.graphics.DeviceData;

import java.lang.all;

version(Tango){
} else { // Phobos
}

public class DeviceData {
    /*
    * The following fields are platform dependent.
    * <p>
    * <b>IMPORTANT:</b> These fields are <em>not</em> part of the SWT
    * public API. They are marked public only so that they can be shared
    * within the packages provided by SWT. They are not available on all
    * platforms and should never be accessed from application code.
    * </p>
    */
    public String display_name;
    public String application_name;
    public String application_class;

    /*
    * Debug fields - may not be honoured
    * on some SWT platforms.
    */
    public bool debugging;
    public bool tracking;
    public Exception [] errors;
    public Object [] objects;
}
