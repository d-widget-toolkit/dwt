/*******************************************************************************
 * Copyright (c) 2003, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *      John Reimer <terminal.node@gmail.com>
 *******************************************************************************/
module org.eclipse.swt.browser.AppFileLocProvider;

version(Tango){
    import tango.sys.Environment;
} else { // Phobos
    import std.process: Environment = environment;
}

import java.lang.all;
import java.util.Vector;

import org.eclipse.swt.browser.Mozilla;
import org.eclipse.swt.browser.SimpleEnumerator;

import org.eclipse.swt.internal.Compatibility;

import XPCOM = org.eclipse.swt.internal.mozilla.XPCOM;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsISimpleEnumerator;
import org.eclipse.swt.internal.mozilla.nsEmbedString;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsIDirectoryService;
import org.eclipse.swt.internal.mozilla.nsIFile;
import org.eclipse.swt.internal.mozilla.nsILocalFile;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

class AppFileLocProvider : nsIDirectoryServiceProvider2 { 
    int refCount = 0;
    String mozillaPath, profilePath;
    String[] pluginDirs;
    bool isXULRunner;
    
    static       String SEPARATOR_OS;
    static const String CHROME_DIR = "chrome"; //$NON-NLS-1$
    static const String COMPONENTS_DIR = "components"; //$NON-NLS-1$
    static const String HISTORY_FILE = "history.dat"; //$NON-NLS-1$
    static const String LOCALSTORE_FILE = "localstore.rdf"; //$NON-NLS-1$
    static const String MIMETYPES_FILE = "mimeTypes.rdf"; //$NON-NLS-1$
    static const String PLUGINS_DIR = "plugins"; //$NON-NLS-1$
    static       String USER_PLUGINS_DIR;
    static const String PREFERENCES_FILE = "prefs.js"; //$NON-NLS-1$

static this () {
    SEPARATOR_OS = System.getProperty ("file.separator");
    USER_PLUGINS_DIR = ".mozilla" ~ SEPARATOR_OS ~ "plugins";
}

this (String path) {
    mozillaPath = path ~ SEPARATOR_OS;
}

extern(System)
nsrefcnt AddRef () {
    refCount++;
    return refCount;
}

extern(System)
nsresult QueryInterface (in cnsID* riid, void** ppvObject) {
    if (riid is null || ppvObject is null) return XPCOM.NS_ERROR_NO_INTERFACE;

    if (*riid == nsISupports.IID) {
        *ppvObject = cast(void*)cast(nsISupports)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIDirectoryServiceProvider.IID) {
        *ppvObject = cast(void*)cast(nsIDirectoryServiceProvider)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIDirectoryServiceProvider2.IID) {
        *ppvObject = cast(void*)cast(nsIDirectoryServiceProvider2)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    
    *ppvObject = null;
    return XPCOM.NS_ERROR_NO_INTERFACE;
}

extern(System)
nsrefcnt Release () {
    refCount--;
    if (refCount is 0) return 0;
    return refCount;
}

void setProfilePath (String path) {
    profilePath = path;
    if (!Compatibility.fileExists (path, "")) { //$NON-NLS-1$
        nsILocalFile file;
        scope nsEmbedString pathString = new nsEmbedString (toWCharArray(path));
        int rc = XPCOM.NS_NewLocalFile (cast(nsAString*)pathString, 1, &file);
        if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
        if (file is null) Mozilla.error (XPCOM.NS_ERROR_NULL_POINTER);

        rc = file.Create (nsILocalFile.DIRECTORY_TYPE, 0700);
        if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
        file.Release ();
    }
}

/* nsIDirectoryServiceProvider2 */
extern(System)
nsresult GetFiles (char* prop, nsISimpleEnumerator* _retval) {
    String propertyName = fromStringz(prop)._idup();
    String[] propertyValues = null;

    if (propertyName == XPCOM.NS_APP_PLUGINS_DIR_LIST) {
        if (pluginDirs is null) {
            int index = 0;
            /* set the first value(s) to the MOZ_PLUGIN_PATH environment variable value if it's defined */
            String value = Environment.get (XPCOM.MOZILLA_PLUGIN_PATH);
            if (value !is null) {
                if (value.length > 0) {
                    String separator = System.getProperty ("path.separator"); // $NON-NLS-1$
                    Vector segments = new Vector ();
                    int start, end = -1;
                    do {
                        start = end + 1;
                        end = value.indexOf (separator, start);
                        String segment;
                        if (end is -1) {
                            segment = value.substring (start);
                        } else {
                            segment = value.substring (start, end);
                        }
                        if (segment.length () > 0) segments.addElement (stringcast(segment));
                    } while (end !is -1);
                    int segmentsSize = segments.size ();
                    pluginDirs = new String [segmentsSize + 2];
                    for (index = 0; index < segmentsSize; index++) {
                        pluginDirs[index] = stringcast(segments.elementAt (index));
                    }
                }
            }
            if (pluginDirs is null) {
                pluginDirs = new String[2];
            }

            /* set the next value to the GRE path + "plugins" */
            pluginDirs[ index++ ] = mozillaPath ~ PLUGINS_DIR;

            /* set the next value to the home directory + "/.mozilla/plugins" */
            pluginDirs[ index++ ] = System.getProperty("user.home") ~ SEPARATOR_OS ~ USER_PLUGINS_DIR;
        }
        propertyValues = pluginDirs;
    }

    *_retval = null;
    //XPCOM.memmove(_retval, new ptrdiff_t[] {0}, C.PTR_SIZEOF);
    if (propertyValues !is null) {
        nsILocalFile localFile;
        nsIFile file;
        nsISupports[] files = new nsISupports [propertyValues.length];
        int index = 0;
        for (int i = 0; i < propertyValues.length; i++) {
            scope auto pathString = new nsEmbedString (toWCharArray(propertyValues[i]));
            int rc = XPCOM.NS_NewLocalFile (cast(nsAString*)pathString, 1, &localFile);
            if (rc !is XPCOM.NS_ERROR_FILE_UNRECOGNIZED_PATH) {
                /* value appears to be a valid pathname */
                if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
                if (localFile is null) Mozilla.error (XPCOM.NS_ERROR_NULL_POINTER);

                rc = localFile.QueryInterface (&nsIFile.IID, cast(void**)&file); 
                if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
                if (file is null) Mozilla.error (XPCOM.NS_ERROR_NO_INTERFACE);
                localFile.Release ();

                files[index++] = cast(nsISupports)file;
            }
        }

        if (index < propertyValues.length) {
            /* there were some invalid values so remove the trailing empty array slots */
            files = files[0..index];
        }

        auto enumerator = new SimpleEnumerator (files);
        enumerator.AddRef ();
        *_retval = cast(nsISimpleEnumerator)enumerator;
        return XPCOM.NS_OK;
    }

    return XPCOM.NS_ERROR_FAILURE;
}   
    
/* nsIDirectoryServiceProvider implementation */
extern(System)
nsresult GetFile(char* prop, PRBool* persistent, nsIFile* _retval) {
    String propertyName = fromStringz( prop )._idup();
    String propertyValue = null;

    if (propertyName == (XPCOM.NS_APP_HISTORY_50_FILE)) {
        propertyValue = profilePath ~ HISTORY_FILE;
    } else if (propertyName == (XPCOM.NS_APP_USER_MIMETYPES_50_FILE)) {
        propertyValue = profilePath ~ MIMETYPES_FILE;
    } else if (propertyName == (XPCOM.NS_APP_PREFS_50_FILE)) {
        propertyValue = profilePath ~ PREFERENCES_FILE;
    } else if (propertyName == (XPCOM.NS_APP_PREFS_50_DIR)) {
        propertyValue = profilePath;
    } else if (propertyName == (XPCOM.NS_APP_USER_CHROME_DIR)) {
        propertyValue = profilePath ~ CHROME_DIR;
    } else if (propertyName == (XPCOM.NS_APP_USER_PROFILE_50_DIR)) {
        propertyValue = profilePath;
    } else if (propertyName == (XPCOM.NS_APP_LOCALSTORE_50_FILE)) {
        propertyValue = profilePath ~ LOCALSTORE_FILE;
    } else if (propertyName == (XPCOM.NS_APP_CACHE_PARENT_DIR)) {
        propertyValue = profilePath;
    } else if (propertyName == (XPCOM.NS_OS_HOME_DIR)) {
        propertyValue = System.getProperty("user.home");    //$NON-NLS-1$
    } else if (propertyName == (XPCOM.NS_OS_TEMP_DIR)) {
        propertyValue = System.getProperty("java.io.tmpdir");   //$NON-NLS-1$
    } else if (propertyName == (XPCOM.NS_GRE_DIR)) {
        propertyValue = mozillaPath;
    } else if (propertyName == (XPCOM.NS_GRE_COMPONENT_DIR)) {
        propertyValue = mozillaPath ~ COMPONENTS_DIR;
    } else if (propertyName == (XPCOM.NS_XPCOM_INIT_CURRENT_PROCESS_DIR)) {
        propertyValue = mozillaPath;
    } else if (propertyName == (XPCOM.NS_OS_CURRENT_PROCESS_DIR)) {
        propertyValue = mozillaPath;
    } else if (propertyName == (XPCOM.NS_XPCOM_COMPONENT_DIR)) {
        propertyValue = mozillaPath ~ COMPONENTS_DIR;
    } else if (propertyName == (XPCOM.NS_XPCOM_CURRENT_PROCESS_DIR)) {
        propertyValue = mozillaPath;
    } else if (propertyName == (XPCOM.NS_APP_PREF_DEFAULTS_50_DIR)) {
        /*
        * Answering a value for this property causes problems in Mozilla versions
        * < 1.7.  Unfortunately this property is queried early enough in the
        * Browser creation process that the Mozilla version being used is not
        * yet determined.  However it is known if XULRunner is being used or not.
        * 
        * For now answer a value for this property iff XULRunner is the GRE.
        * If the range of Mozilla versions supported by the Browser is changed
        * in the future to be >= 1.7 then this value can always be answered.  
        */
        if (isXULRunner) propertyValue = profilePath;
    }

    *persistent = true; /* PRBool */
    *_retval = null;
    if (propertyValue !is null && propertyValue.length > 0) {
        nsILocalFile localFile;
        scope auto pathString = new nsEmbedString (propertyValue.toWCharArray());
        int rc = XPCOM.NS_NewLocalFile (cast(nsAString*)pathString, 1, &localFile);
        if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
        if (localFile is null) Mozilla.error (XPCOM.NS_ERROR_NULL_POINTER);
        
        nsIFile file;
        rc = localFile.QueryInterface (&nsIFile.IID, cast(void**)&file); 
        if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
        if (file is null) Mozilla.error (XPCOM.NS_ERROR_NO_INTERFACE);

        *_retval = file;
        localFile.Release ();
        return XPCOM.NS_OK;
    }

    return XPCOM.NS_ERROR_FAILURE;
}       
}
