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
module org.eclipse.swt.browser.Mozilla;

import java.lang.all;


version(Tango){
    import tango.text.locale.Core;
    import tango.sys.Environment;
    import tango.stdc.string;
} else { // Phobos
    import std.process: Environment = environment;
}

//import org.eclipse.swt.internal.c.gtk;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTError;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;

import org.eclipse.swt.browser.Browser;
import org.eclipse.swt.browser.WebBrowser;
import org.eclipse.swt.browser.MozillaDelegate;
import org.eclipse.swt.browser.AppFileLocProvider;
import org.eclipse.swt.browser.WindowCreator2;
import org.eclipse.swt.browser.PromptService2Factory;
import org.eclipse.swt.browser.HelperAppLauncherDialogFactory;
import org.eclipse.swt.browser.DownloadFactory;
import org.eclipse.swt.browser.DownloadFactory_1_8;
import org.eclipse.swt.browser.FilePickerFactory;
import org.eclipse.swt.browser.FilePickerFactory_1_8;
import org.eclipse.swt.browser.InputStream;
import org.eclipse.swt.browser.StatusTextEvent;
import org.eclipse.swt.browser.ProgressEvent;
import org.eclipse.swt.browser.LocationEvent;
import org.eclipse.swt.browser.WindowEvent;
import org.eclipse.swt.browser.TitleEvent;

import org.eclipse.swt.internal.Compatibility;
import org.eclipse.swt.internal.LONG;
import org.eclipse.swt.internal.Library;
import org.eclipse.swt.internal.gtk.OS;

import XPCOM = org.eclipse.swt.internal.mozilla.XPCOM;
import XPCOMInit = org.eclipse.swt.internal.mozilla.XPCOMInit;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsEmbedString;
import org.eclipse.swt.internal.mozilla.nsIAppShell;
import org.eclipse.swt.internal.mozilla.nsIBaseWindow;
import org.eclipse.swt.internal.mozilla.nsICategoryManager;
import org.eclipse.swt.internal.mozilla.nsIComponentManager;
import org.eclipse.swt.internal.mozilla.nsIComponentRegistrar;
import org.eclipse.swt.internal.mozilla.nsIContextMenuListener;
import org.eclipse.swt.internal.mozilla.nsICookie;
import org.eclipse.swt.internal.mozilla.nsICookieManager;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsIDOMNode;
import org.eclipse.swt.internal.mozilla.nsIDOMEvent;
import org.eclipse.swt.internal.mozilla.nsIDOMEventListener;
import org.eclipse.swt.internal.mozilla.nsIDOMEventTarget;
import org.eclipse.swt.internal.mozilla.nsIDOMKeyEvent;
import org.eclipse.swt.internal.mozilla.nsIDOMMouseEvent;
import org.eclipse.swt.internal.mozilla.nsIDOMSerializer;
import org.eclipse.swt.internal.mozilla.nsIDOMSerializer_1_7;
import org.eclipse.swt.internal.mozilla.nsIDOMWindow;
import org.eclipse.swt.internal.mozilla.nsIDOMWindowCollection;
import org.eclipse.swt.internal.mozilla.nsIDOMDocument;
import org.eclipse.swt.internal.mozilla.nsIDirectoryService;
import org.eclipse.swt.internal.mozilla.nsIDocShell;
import org.eclipse.swt.internal.mozilla.nsIEmbeddingSiteWindow;
import org.eclipse.swt.internal.mozilla.nsIFile;
import org.eclipse.swt.internal.mozilla.nsIFactory;
import org.eclipse.swt.internal.mozilla.nsIIOService;
import org.eclipse.swt.internal.mozilla.nsIInterfaceRequestor;
import org.eclipse.swt.internal.mozilla.nsIJSContextStack;
import org.eclipse.swt.internal.mozilla.nsILocalFile;
import org.eclipse.swt.internal.mozilla.nsIObserverService;
import org.eclipse.swt.internal.mozilla.nsIPrefBranch;
import org.eclipse.swt.internal.mozilla.nsIPrefLocalizedString;
import org.eclipse.swt.internal.mozilla.nsIPrefService;
import org.eclipse.swt.internal.mozilla.nsIProperties;
import org.eclipse.swt.internal.mozilla.nsIRequest;
import org.eclipse.swt.internal.mozilla.nsIServiceManager;
import org.eclipse.swt.internal.mozilla.nsISimpleEnumerator;
import org.eclipse.swt.internal.mozilla.nsIStreamListener;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsITooltipListener;
import org.eclipse.swt.internal.mozilla.nsIURI;
import org.eclipse.swt.internal.mozilla.nsIURIContentListener;
import org.eclipse.swt.internal.mozilla.nsIWeakReference;
import org.eclipse.swt.internal.mozilla.nsIWebBrowser;
import org.eclipse.swt.internal.mozilla.nsIWebBrowserChrome;
import org.eclipse.swt.internal.mozilla.nsIWebBrowserChromeFocus;
import org.eclipse.swt.internal.mozilla.nsIWebBrowserFocus;
import org.eclipse.swt.internal.mozilla.nsIWebNavigation;
import org.eclipse.swt.internal.mozilla.nsIWebNavigationInfo;
import org.eclipse.swt.internal.mozilla.nsIWebProgress;
import org.eclipse.swt.internal.mozilla.nsIWebProgressListener;
import org.eclipse.swt.internal.mozilla.nsIWindowWatcher;
import org.eclipse.swt.internal.mozilla.nsIWindowCreator;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Control;

class Mozilla : WebBrowser, 
                nsIWeakReference, 
                nsIWebProgressListener, 
                nsIWebBrowserChrome,
                nsIWebBrowserChromeFocus, 
                nsIEmbeddingSiteWindow, 
                nsIInterfaceRequestor, 
                nsISupportsWeakReference, 
                nsIContextMenuListener, 
                nsIURIContentListener,
                nsITooltipListener, 
                nsIDOMEventListener {
                    
    GtkWidget* embedHandle;
    nsIWebBrowser webBrowser;
    Object webBrowserObject;
    MozillaDelegate mozDelegate;

    int chromeFlags = nsIWebBrowserChrome.CHROME_DEFAULT;
    int refCount, lastKeyCode, lastCharCode;
    nsIRequest request;
    Point location, size;
    bool visible, isChild, ignoreDispose, awaitingNavigate;
    Shell tip = null;
    Listener listener;
    nsIDOMWindow[] unhookedDOMWindows;

    static nsIAppShell AppShell;
    static AppFileLocProvider LocationProvider;
    static WindowCreator2 WindowCreator;
    static int BrowserCount;
    static bool Initialized, IsPre_1_8, PerformedVersionCheck, XPCOMWasGlued, XPCOMInitWasGlued;

    /* XULRunner detect constants */
    static String GRERANGE_LOWER = "1.8.1.2"; //$NON-NLS-1$
    static String GRERANGE_LOWER_FALLBACK = "1.8"; //$NON-NLS-1$
    static const bool LowerRangeInclusive = true;
    static String GRERANGE_UPPER = "1.9.*"; //$NON-NLS-1$
    static const bool UpperRangeInclusive = true;

    static const int MAX_PORT = 65535;
    static String SEPARATOR_OS(){
        return System.getProperty ("file.separator"); //$NON-NLS-1$
    }
    static const String ABOUT_BLANK = "about:blank"; //$NON-NLS-1$
    static const String DISPOSE_LISTENER_HOOKED = "org.eclipse.swt.browser.Mozilla.disposeListenerHooked"; //$NON-NLS-1$
    static const String PREFIX_JAVASCRIPT = "javascript:"; //$NON-NLS-1$
    static const String PREFERENCE_CHARSET = "intl.charset.default"; //$NON-NLS-1$
    static const String PREFERENCE_DISABLEOPENDURINGLOAD = "dom.disable_open_during_load"; //$NON-NLS-1$
    static const String PREFERENCE_DISABLEWINDOWSTATUSCHANGE = "dom.disable_window_status_change"; //$NON-NLS-1$
    static const String PREFERENCE_LANGUAGES = "intl.accept_languages"; //$NON-NLS-1$
    static const String PREFERENCE_PROXYHOST_FTP = "network.proxy.ftp"; //$NON-NLS-1$
    static const String PREFERENCE_PROXYPORT_FTP = "network.proxy.ftp_port"; //$NON-NLS-1$
    static const String PREFERENCE_PROXYHOST_HTTP = "network.proxy.http"; //$NON-NLS-1$
    static const String PREFERENCE_PROXYPORT_HTTP = "network.proxy.http_port"; //$NON-NLS-1$
    static const String PREFERENCE_PROXYHOST_SSL = "network.proxy.ssl"; //$NON-NLS-1$
    static const String PREFERENCE_PROXYPORT_SSL = "network.proxy.ssl_port"; //$NON-NLS-1$
    static const String PREFERENCE_PROXYTYPE = "network.proxy.type"; //$NON-NLS-1$
    static const String PROFILE_AFTER_CHANGE = "profile-after-change"; //$NON-NLS-1$
    static const String PROFILE_BEFORE_CHANGE = "profile-before-change"; //$NON-NLS-1$
    static       String PROFILE_DIR; //= SEPARATOR_OS ~ "eclipse" ~ SEPARATOR_OS; //$NON-NLS-1$
    static const String PROFILE_DO_CHANGE = "profile-do-change"; //$NON-NLS-1$
    static const String PROPERTY_PROXYPORT = "network.proxy_port"; //$NON-NLS-1$
    static const String PROPERTY_PROXYHOST = "network.proxy_host"; //$NON-NLS-1$
    static const String SEPARATOR_LOCALE = "-"; //$NON-NLS-1$
    static const String SHUTDOWN_PERSIST = "shutdown-persist"; //$NON-NLS-1$
    static const String STARTUP = "startup"; //$NON-NLS-1$
    static const String TOKENIZER_LOCALE = ","; //$NON-NLS-1$
    static const String URI_FROMMEMORY = "file:///"; //$NON-NLS-1$
    static const String XULRUNNER_PATH = "org.eclipse.swt.browser.XULRunnerPath"; //$NON-NLS-1$

    // TEMPORARY CODE
    static const String GRE_INITIALIZED = "org.eclipse.swt.browser.XULRunnerInitialized"; //$NON-NLS-1$

    this () {
        PROFILE_DIR = SEPARATOR_OS ~ "eclipse" ~ SEPARATOR_OS;
        MozillaClearSessions = new class() Runnable {
            public void run () {
                if (!Initialized) return;
                nsIServiceManager serviceManager;
                int rc = XPCOM.NS_GetServiceManager (&serviceManager);
                if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                if (serviceManager is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

                nsICookieManager manager;
                rc = serviceManager.GetServiceByContractID (XPCOM.NS_COOKIEMANAGER_CONTRACTID.ptr, &nsICookieManager.IID, cast(void**)&manager);
                if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                if (manager is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
                serviceManager.Release ();

                nsISimpleEnumerator enumerator;
                rc = manager.GetEnumerator (&enumerator);
                if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                manager.Release ();

                PRBool moreElements;
                rc = enumerator.HasMoreElements (&moreElements);
                if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                while (moreElements !is 0) {
                    nsICookie cookie;
                    rc = enumerator.GetNext (cast(nsISupports*)&cookie);
                    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                    PRUint64 expires;
                    rc = cookie.GetExpires (&expires);
                    if (expires is 0) {
                        /* indicates a session cookie */
                        scope auto domain = new nsEmbedCString;
                        scope auto name = new nsEmbedCString;
                        scope auto path = new nsEmbedCString;
                        cookie.GetHost (cast(nsACString*)domain);
                        cookie.GetName (cast(nsACString*)name);
                        cookie.GetPath (cast(nsACString*)path);
                        rc = manager.Remove (cast(nsACString*)domain, cast(nsACString*)name, cast(nsACString*)path, 0);
                        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                    }
                    cookie.Release ();
                    rc = enumerator.HasMoreElements (&moreElements);
                    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                }
                enumerator.Release ();
            }
        };
    }

extern(D)
public void create (Composite parent, int style) {
    mozDelegate = new MozillaDelegate (super.browser);
    Display display = parent.getDisplay ();

    if (!Initialized) {
        bool initLoaded = false;
        bool IsXULRunner = false;

        String greInitialized = System.getProperty (GRE_INITIALIZED); 
        if ("true" == greInitialized) { //$NON-NLS-1$
            /* 
             * Another browser has already initialized xulrunner in this process,
             * so just bind to it instead of trying to initialize a new one.
             */
            Initialized = true;
        }
        String mozillaPath = System.getProperty (XULRUNNER_PATH);
        if (mozillaPath is null) {
            // we don't need to load an initial library in D, so set to "true"
            initLoaded = true;
        } else {
            mozillaPath ~= SEPARATOR_OS ~ mozDelegate.getLibraryName ();
            IsXULRunner = true;
        }
         
        if (initLoaded) {
            /* attempt to discover a XULRunner to use as the GRE */
            XPCOMInit.GREVersionRange range;

            range.lower = GRERANGE_LOWER.ptr;
            range.lowerInclusive = LowerRangeInclusive;

            range.upper = GRERANGE_UPPER.ptr;
            range.upperInclusive = UpperRangeInclusive;

            char[] greBuffer = new char[XPCOMInit.PATH_MAX];

            int rc = XPCOMInit.GRE_GetGREPathWithProperties (&range, 1, null, 0, greBuffer.ptr, greBuffer.length);

            /*
             * A XULRunner was not found that supports wrapping of XPCOM handles as JavaXPCOM objects.
             * Drop the lower version bound and try to detect an earlier XULRunner installation.
             */

            if (rc !is XPCOM.NS_OK) {
                range.lower = GRERANGE_LOWER_FALLBACK.ptr;
                rc = XPCOMInit.GRE_GetGREPathWithProperties (&range, 1, null, 0, greBuffer.ptr, greBuffer.length);
            }

            if (rc is XPCOM.NS_OK) {
                /* indicates that a XULRunner was found */
                mozillaPath = cast(String)greBuffer;
                IsXULRunner = mozillaPath.length > 0;

                /*
                 * Test whether the detected XULRunner can be used as the GRE before loading swt's
                 * XULRunner library.  If it cannot be used then fall back to attempting to use
                 * the GRE pointed to by MOZILLA_FIVE_HOME.
                 * 
                 * One case where this will fail is attempting to use a 64-bit xulrunner while swt
                 * is running in 32-bit mode, or vice versa.
                 */

                if (IsXULRunner) {
                    rc = XPCOMInit.XPCOMGlueStartup (mozillaPath.ptr);
                    if (rc !is XPCOM.NS_OK) {
                        mozillaPath = mozillaPath.substring (0, mozillaPath.lastIndexOf (SEPARATOR_OS));
                        if (Device.DEBUG) getDwtLogger().error (__FILE__, __LINE__, "cannot use detected XULRunner: {}", mozillaPath); //$NON-NLS-1$
                        
                        /* attempt to XPCOMGlueStartup the GRE pointed at by MOZILLA_FIVE_HOME */
                        auto ptr = Environment.get(XPCOM.MOZILLA_FIVE_HOME);
                        
                        if (ptr is null) {
                            IsXULRunner = false;
                        } else {
                            mozillaPath = ptr;
                            /*
                             * Attempting to XPCOMGlueStartup a mozilla-based GRE !is xulrunner can
                             * crash, so don't attempt unless the GRE appears to be xulrunner.
                             */
                            if (mozillaPath.indexOf("xulrunner") is -1) { //$NON-NLS-1$
                                IsXULRunner = false;    

                            } else {
                                mozillaPath ~= SEPARATOR_OS ~ mozDelegate.getLibraryName ();
                                rc = XPCOMInit.XPCOMGlueStartup (toStringz(mozillaPath));
                                if (rc !is XPCOM.NS_OK) {
                                    IsXULRunner = false;
                                    mozillaPath = mozillaPath.substring (0, mozillaPath.lastIndexOf (SEPARATOR_OS));
                                    if (Device.DEBUG) getDwtLogger().error( __FILE__, __LINE__, "failed to start as XULRunner: {}", mozillaPath); //$NON-NLS-1$
                                }
                            }
                        } 
                    }
                    if (IsXULRunner) {
                        XPCOMInitWasGlued = true;
                    }
                }
            }
        }

        if (IsXULRunner) {
            if (Device.DEBUG) getDwtLogger().error( __FILE__, __LINE__, "XULRunner path: {}", mozillaPath); //$NON-NLS-1$

            XPCOMWasGlued = true;

            /*
             * Remove the trailing xpcom lib name from mozillaPath because the
             * Mozilla.initialize and NS_InitXPCOM2 invocations require a directory name only.
             */
            mozillaPath = mozillaPath.substring (0, mozillaPath.lastIndexOf (SEPARATOR_OS));
        } else {
            if ((style & SWT.MOZILLA) !is 0) {
                browser.dispose ();
                String errorString = (mozillaPath !is null && mozillaPath.length > 0) ?
                    " [Failed to use detected XULRunner: " ~ mozillaPath ~ "]" :
                    " [Could not detect registered XULRunner to use]";  //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
                SWT.error (SWT.ERROR_NO_HANDLES, null, errorString);
            }

            /* attempt to use the GRE pointed at by MOZILLA_FIVE_HOME */
            auto mozFiveHome = Environment.get(XPCOM.MOZILLA_FIVE_HOME);
            if (mozFiveHome !is null) {
                mozillaPath = mozFiveHome;
            } else {
                browser.dispose ();
                SWT.error (SWT.ERROR_NO_HANDLES, null, " [Unknown Mozilla path (MOZILLA_FIVE_HOME not set)]"); //$NON-NLS-1$
            }
            if (Device.DEBUG) getDwtLogger().error( __FILE__, __LINE__, "Mozilla path: {}", mozillaPath); //$NON-NLS-1$

            /*
            * Note.  Embedding a Mozilla GTK1.2 causes a crash.  The workaround
            * is to check the version of GTK used by Mozilla by looking for
            * the libwidget_gtk.so library used by Mozilla GTK1.2. Mozilla GTK2
            * uses the libwidget_gtk2.so library.   
            */
            if (Compatibility.fileExists (mozillaPath, "components/libwidget_gtk.so")) { //$NON-NLS-1$
                browser.dispose ();
                SWT.error (SWT.ERROR_NO_HANDLES, null, " [Mozilla GTK2 required (GTK1.2 detected)]"); //$NON-NLS-1$                         
            }
        }

        if (!Initialized) {
            nsILocalFile localFile;
            scope auto pathString = new nsEmbedString (mozillaPath.toWCharArray());
            nsresult rc = XPCOM.NS_NewLocalFile (cast(nsAString*)pathString, 1, &localFile);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                error (rc, __FILE__, __LINE__);
            }
            if (localFile is null) {
                browser.dispose ();
                error (XPCOM.NS_ERROR_NULL_POINTER);
            }

            LocationProvider = new AppFileLocProvider (mozillaPath);
            LocationProvider.AddRef ();

            nsIDirectoryServiceProvider directoryServiceProvider;
            rc = LocationProvider.QueryInterface( &nsIDirectoryServiceProvider.IID, cast(void**)&directoryServiceProvider);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose();
                error(rc);
            }
            rc = XPCOM.NS_InitXPCOM2 (null, cast(nsIFile)localFile, directoryServiceProvider);
            localFile.Release ();
            LocationProvider.Release();
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                SWT.error (SWT.ERROR_NO_HANDLES, null, Format(" [MOZILLA_FIVE_HOME may not point at an embeddable GRE] [NS_InitEmbedding {0} error {1} ] ", mozillaPath, rc ) ); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            }
            System.setProperty (GRE_INITIALIZED, "true"); //$NON-NLS-1$
            if (IsXULRunner) {
                System.setProperty (XULRUNNER_PATH, mozillaPath);
            }
        }

        nsIComponentManager componentManager;
        int rc = XPCOM.NS_GetComponentManager (&componentManager);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        if (componentManager is null) {
            browser.dispose ();
            error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        }
        
        if (mozDelegate.needsSpinup ()) {
            /* nsIAppShell is discontinued as of xulrunner 1.9, so do not fail if it is not found */
            rc = componentManager.CreateInstance (&XPCOM.NS_APPSHELL_CID, null, &nsIAppShell.IID, cast(void**)&AppShell);
            if (rc !is XPCOM.NS_ERROR_NO_INTERFACE) {
                if (rc !is XPCOM.NS_OK) {
                    browser.dispose ();
                    error (rc, __FILE__, __LINE__);
                }
                if (AppShell is null) {
                    browser.dispose ();
                    error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
                }
    
                rc = AppShell.Create (null, null);
                if (rc !is XPCOM.NS_OK) {
                    browser.dispose ();
                    error (rc, __FILE__, __LINE__);
                }
                rc = AppShell.Spinup ();
                if (rc !is XPCOM.NS_OK) {
                    browser.dispose ();
                    error (rc, __FILE__, __LINE__);
                }
            }
        }

        WindowCreator = new WindowCreator2;
        WindowCreator.AddRef ();
        
        nsIServiceManager serviceManager;
        rc = XPCOM.NS_GetServiceManager (&serviceManager);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        if (serviceManager is null) {
            browser.dispose ();
            error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        }
        
        nsIWindowWatcher windowWatcher;
        rc = serviceManager.GetServiceByContractID (XPCOM.NS_WINDOWWATCHER_CONTRACTID.ptr, &nsIWindowWatcher.IID, cast(void**)&windowWatcher);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        if (windowWatcher is null) {
            browser.dispose ();
            error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);       
        }

        rc = windowWatcher.SetWindowCreator (cast(nsIWindowCreator)WindowCreator);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        windowWatcher.Release ();

        if (LocationProvider !is null) {
            nsIDirectoryService directoryService;
            rc = serviceManager.GetServiceByContractID (XPCOM.NS_DIRECTORYSERVICE_CONTRACTID.ptr, &nsIDirectoryService.IID, cast(void**)&directoryService);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                error (rc, __FILE__, __LINE__);
            }
            if (directoryService is null) {
                browser.dispose ();
                error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            }

            nsIProperties properties;
            rc = directoryService.QueryInterface (&nsIProperties.IID, cast(void**)&properties);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                error (rc, __FILE__, __LINE__);
            }
            if (properties is null) {
                browser.dispose ();
                error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            }
            directoryService.Release ();

            nsIFile profileDir;
            rc = properties.Get (XPCOM.NS_APP_APPLICATION_REGISTRY_DIR.ptr, &nsIFile.IID, cast(void**)&profileDir);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                error (rc, __FILE__, __LINE__);
            }
            if (profileDir is null) {
                browser.dispose ();
                error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            }
            properties.Release ();

            scope auto path = new nsEmbedCString;
            rc = profileDir.GetNativePath (cast(nsACString*)path);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                error (rc, __FILE__, __LINE__);
            }

            String profilePath = path.toString() ~ PROFILE_DIR;
            LocationProvider.setProfilePath (profilePath);
            LocationProvider.isXULRunner = IsXULRunner;

            profileDir.Release ();

            /* notify observers of a new profile directory being used */
            nsIObserverService observerService;
            rc = serviceManager.GetServiceByContractID (XPCOM.NS_OBSERVER_CONTRACTID.ptr, &nsIObserverService.IID, cast(void**)&observerService);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                error (rc, __FILE__, __LINE__);
            }
            if (observerService is null) {
                browser.dispose ();
                error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            }

            wchar* chars = STARTUP.toWCharArray().toString16z();
            rc = observerService.NotifyObservers (null, PROFILE_DO_CHANGE.ptr, chars);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                error (rc, __FILE__, __LINE__);
            }

            rc = observerService.NotifyObservers (null, PROFILE_AFTER_CHANGE.ptr, chars);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                error (rc, __FILE__, __LINE__);
            }
            observerService.Release ();
        }

        /*
         * As a result of using a common profile the user cannot change their locale
         * and charset.  The fix for this is to set mozilla's locale and charset
         * preference values according to the user's current locale and charset.
         */

        nsIPrefService prefService;
        rc = serviceManager.GetServiceByContractID (XPCOM.NS_PREFSERVICE_CONTRACTID.ptr, &nsIPrefService.IID, cast(void**)&prefService);
        serviceManager.Release ();
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        if (serviceManager is null) {
            browser.dispose ();
            error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        }

        char[1] buffer = new char[1];
        nsIPrefBranch prefBranch;
        rc = prefService.GetBranch (buffer.ptr, &prefBranch);    /* empty buffer denotes root preference level */
        prefService.Release ();
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        if (prefBranch is null) {
            browser.dispose ();
            error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        }

        /* get Mozilla's current locale preference value */
        String prefLocales = null;
        nsIPrefLocalizedString localizedString = null;
        //buffer = MozillaDelegate.wcsToMbcs (null, PREFERENCE_LANGUAGES, true);
        rc = prefBranch.GetComplexValue (PREFERENCE_LANGUAGES.ptr, &nsIPrefLocalizedString.IID, cast(void**)&localizedString);
        /* 
         * Feature of Debian.  For some reason attempting to query for the current locale
         * preference fails on Debian.  The workaround for this is to assume a value of
         * "en-us,en" since this is typically the default value when mozilla is used without
         * a profile.
         */
        if (rc !is XPCOM.NS_OK) {
            prefLocales = "en-us,en" ~ TOKENIZER_LOCALE;    //$NON-NLS-1$
        } else {
            if (localizedString is null) {
                browser.dispose ();
                error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            }
            PRUnichar* tmpChars;
            rc = localizedString.ToString (&tmpChars);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                error (rc, __FILE__, __LINE__);
            }
            if (tmpChars is null) {
                browser.dispose ();
                error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            }
            int span = XPCOM.strlen_PRUnichar (tmpChars);
            prefLocales = String_valueOf(tmpChars[0 .. span]) ~ TOKENIZER_LOCALE;
        }

        /*
         * construct the new locale preference value by prepending the
         * user's current locale and language to the original value 
         */

        version(Tango){
            String language = Culture.current.twoLetterLanguageName ();
            String country = Region.current.twoLetterRegionName ();
        } else { // Phobos
            implMissingInPhobos();
            String language = "en";
            String country = "us";
        }
        String stringBuffer = language._idup();

        stringBuffer ~= SEPARATOR_LOCALE;
        stringBuffer ~= country.toLowerCase ();
        stringBuffer ~= TOKENIZER_LOCALE;
        stringBuffer ~= language;
        stringBuffer ~= TOKENIZER_LOCALE;
        String newLocales = stringBuffer._idup();

        int start, end = -1;
        do {
            start = end + 1;
            end = prefLocales.indexOf (TOKENIZER_LOCALE, start);
            String token;
            if (end is -1) {
                token = prefLocales.substring (start);
            } else {
                token = prefLocales.substring (start, end);
            }
            if (token.length () > 0) {
                token = (token ~ TOKENIZER_LOCALE).trim ();
                /* ensure that duplicate locale values are not added */
                if (newLocales.indexOf (token) is -1) {
                    stringBuffer ~= token;
                }
            }
        } while (end !is -1);
        (cast(char[])newLocales)[] = stringBuffer[];
        if (!newLocales.equals (prefLocales)) {
            /* write the new locale value */
            newLocales = newLocales.substring (0, newLocales.length () - TOKENIZER_LOCALE.length ()); /* remove trailing tokenizer */
            if (localizedString is null) {
                rc = componentManager.CreateInstanceByContractID (XPCOM.NS_PREFLOCALIZEDSTRING_CONTRACTID.ptr, null, &nsIPrefLocalizedString.IID, cast(void**)&localizedString);
                if (rc !is XPCOM.NS_OK) {
                    browser.dispose ();
                    error (rc, __FILE__, __LINE__);
                }
                if (localizedString is null) {
                    browser.dispose ();
                    error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
                }
            }
            localizedString.SetDataWithLength (newLocales.length, newLocales.toWCharArray().toString16z());
            rc = prefBranch.SetComplexValue (PREFERENCE_LANGUAGES.ptr, &nsIPrefLocalizedString.IID, cast(nsISupports)localizedString);
        }
        if (localizedString !is null) {
            localizedString.Release ();
            localizedString = null;
        }

        /* get Mozilla's current charset preference value */
        String prefCharset = null;
        rc = prefBranch.GetComplexValue (PREFERENCE_CHARSET.ptr, &nsIPrefLocalizedString.IID, cast(void**)&localizedString);
        /* 
         * Feature of Debian.  For some reason attempting to query for the current charset
         * preference fails on Debian.  The workaround for this is to assume a value of
         * "ISO-8859-1" since this is typically the default value when mozilla is used
         * without a profile.
         */
        if (rc !is XPCOM.NS_OK) {
            prefCharset = "ISO-8859-1"; //$NON_NLS-1$
        } else {
            if (localizedString is null) {
                browser.dispose ();
                error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            }
            PRUnichar* tmpChar;
            rc = localizedString.ToString (&tmpChar);
            if (rc !is XPCOM.NS_OK) {
                browser.dispose ();
                error (rc, __FILE__, __LINE__);
            }
            if (tmpChar is null) {
                browser.dispose ();
                error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            }
            int span = XPCOM.strlen_PRUnichar (tmpChar);
            prefCharset = String_valueOf(tmpChar[0 .. span]);
        }

        String newCharset = System.getProperty ("file.encoding");   // $NON-NLS-1$
        if (!newCharset.equals (prefCharset)) {
            /* write the new charset value */
            if (localizedString is null) {
                rc = componentManager.CreateInstanceByContractID (XPCOM.NS_PREFLOCALIZEDSTRING_CONTRACTID.ptr, null, &nsIPrefLocalizedString.IID, cast(void**)&localizedString);
                if (rc !is XPCOM.NS_OK) {
                    browser.dispose ();
                    error (rc, __FILE__, __LINE__);
                }
                if (localizedString is null) {
                    browser.dispose ();
                    error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
                }
            }
            localizedString.SetDataWithLength (newCharset.length, newCharset.toWCharArray().toString16z());
            rc = prefBranch.SetComplexValue (PREFERENCE_CHARSET.ptr, &nsIPrefLocalizedString.IID, cast(nsISupports)localizedString);
        }
        if (localizedString !is null) localizedString.Release ();

        /*
        * Check for proxy values set as documented java properties and update mozilla's
        * preferences with these values if needed.
        */

        // NOTE: in org.eclipse.swt, these properties don't exist so both keys will return null
        // (which appears to be ok in this situaion)
        String proxyHost = System.getProperty (PROPERTY_PROXYHOST);
        String proxyPortString = System.getProperty (PROPERTY_PROXYPORT);

        int port = -1;
        if (proxyPortString !is null) {
            try {
                int value = Integer.valueOf (proxyPortString).intValue ();
                if (0 <= value && value <= MAX_PORT) port = value;
            } catch (NumberFormatException e) {
                /* do nothing, java property has non-integer value */
            }
        }

        if (proxyHost !is null) {
            rc = componentManager.CreateInstanceByContractID (XPCOM.NS_PREFLOCALIZEDSTRING_CONTRACTID.ptr, null, &nsIPrefLocalizedString.IID, cast(void**)&localizedString);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (localizedString is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

            rc = localizedString.SetDataWithLength (proxyHost.length, proxyHost.toWCharArray().toString16z());
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            rc = prefBranch.SetComplexValue (PREFERENCE_PROXYHOST_FTP.ptr, &nsIPrefLocalizedString.IID, cast(nsISupports)localizedString);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            rc = prefBranch.SetComplexValue (PREFERENCE_PROXYHOST_HTTP.ptr, &nsIPrefLocalizedString.IID, cast(nsISupports)localizedString);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            rc = prefBranch.SetComplexValue (PREFERENCE_PROXYHOST_SSL.ptr, &nsIPrefLocalizedString.IID, cast(nsISupports)localizedString);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            localizedString.Release ();
        }

        if (port !is -1) {
            rc = prefBranch.SetIntPref (PREFERENCE_PROXYPORT_FTP.ptr, port);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            rc = prefBranch.SetIntPref (PREFERENCE_PROXYPORT_HTTP.ptr, port);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            rc = prefBranch.SetIntPref (PREFERENCE_PROXYPORT_SSL.ptr, port);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        }

        if (proxyHost !is null || port !is -1) {
            rc = prefBranch.SetIntPref (PREFERENCE_PROXYTYPE.ptr, 1);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        }

        /*
        * Ensure that windows that are shown during page loads are not blocked.  Firefox may
        * try to block these by default since such windows are often unwelcome, but this
        * assumption should not be made in the Browser's context.  Since the Browser client
        * is responsible for creating the new Browser and Shell in an OpenWindowListener,
        * they should decide whether the new window is unwelcome or not and act accordingly. 
        */
        rc = prefBranch.SetBoolPref (PREFERENCE_DISABLEOPENDURINGLOAD.ptr, 0);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }

        /* Ensure that the status text can be set through means like javascript */ 
        rc = prefBranch.SetBoolPref (PREFERENCE_DISABLEWINDOWSTATUSCHANGE.ptr, 0);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }

        prefBranch.Release ();

        PromptService2Factory factory = new PromptService2Factory ();
        factory.AddRef ();

        nsIComponentRegistrar componentRegistrar;
        rc = componentManager.QueryInterface (&nsIComponentRegistrar.IID, cast(void**)&componentRegistrar);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        if (componentRegistrar is null) {
            browser.dispose ();
            error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        }
        
        String aClassName = "Prompt Service"; 

        rc = componentRegistrar.RegisterFactory (&XPCOM.NS_PROMPTSERVICE_CID, aClassName.ptr, XPCOM.NS_PROMPTSERVICE_CONTRACTID.ptr, cast(nsIFactory)factory);

        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        factory.Release ();

        /*
        * This Download factory will be used if the GRE version is < 1.8.
        * If the GRE version is 1.8.x then the Download factory that is registered later for
        *   contract "Transfer" will be used.
        * If the GRE version is >= 1.9 then no Download factory is registered because this
        *   functionality is provided by the GRE.
        */
        DownloadFactory downloadFactory = new DownloadFactory ();
        downloadFactory.AddRef ();
        aClassName = "Download";
        rc = componentRegistrar.RegisterFactory (&XPCOM.NS_DOWNLOAD_CID, aClassName.ptr, XPCOM.NS_DOWNLOAD_CONTRACTID.ptr, cast(nsIFactory)downloadFactory);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        downloadFactory.Release ();

        FilePickerFactory pickerFactory = IsXULRunner ? new FilePickerFactory_1_8 () : new FilePickerFactory ();
        pickerFactory.AddRef ();
        aClassName = "FilePicker";
        rc = componentRegistrar.RegisterFactory (&XPCOM.NS_FILEPICKER_CID, aClassName.ptr, XPCOM.NS_FILEPICKER_CONTRACTID.ptr, cast(nsIFactory)pickerFactory);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__, __LINE__);
        }
        pickerFactory.Release ();

        componentRegistrar.Release ();
        componentManager.Release ();

        Initialized = true;
    }

    if (display.getData (DISPOSE_LISTENER_HOOKED) is null) {
        display.setData (DISPOSE_LISTENER_HOOKED, stringcast(DISPOSE_LISTENER_HOOKED));
        display.addListener (SWT.Dispose, dgListener( &handleDisposeEvent, display )  );
    }

    BrowserCount++;
    nsIComponentManager componentManager;
    int rc = XPCOM.NS_GetComponentManager (&componentManager);
    if (rc !is XPCOM.NS_OK) {
        browser.dispose ();
        error (rc, __FILE__, __LINE__);
    }
    if (componentManager is null) {
        browser.dispose ();
        error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
    }
    
    nsID NS_IWEBBROWSER_CID = { 0xF1EAC761, 0x87E9, 0x11d3, [0xAF, 0x80, 0x00, 0xA0, 0x24, 0xFF, 0xC0, 0x8C] }; //$NON-NLS-1$
    rc = componentManager.CreateInstance (&NS_IWEBBROWSER_CID, null, &nsIWebBrowser.IID, cast(void**)&webBrowser);
    if (rc !is XPCOM.NS_OK) {
        browser.dispose ();
        error (rc, __FILE__, __LINE__);
    }
    if (webBrowser is null) {
        browser.dispose ();
        error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);   
    }
    
    this.AddRef ();

    rc = webBrowser.SetContainerWindow ( cast(nsIWebBrowserChrome)this );
    if (rc !is XPCOM.NS_OK) {
        browser.dispose ();
        error (rc, __FILE__, __LINE__);
    }
            
    nsIBaseWindow baseWindow;
    rc = webBrowser.QueryInterface (&nsIBaseWindow.IID, cast(void**)&baseWindow);
    if (rc !is XPCOM.NS_OK) {
        browser.dispose ();
        error (rc, __FILE__, __LINE__);
    }
    if (baseWindow is null) {
        browser.dispose ();
        error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    }
    
    Rectangle rect = browser.getClientArea ();
    if (rect.isEmpty ()) {
        rect.width = 1;
        rect.height = 1;
    }

    embedHandle = mozDelegate.getHandle ();

    rc = baseWindow.InitWindow (cast(void*)embedHandle, null, 0, 0, rect.width, rect.height);
    if (rc !is XPCOM.NS_OK) {
        browser.dispose ();
        error (XPCOM.NS_ERROR_FAILURE);
    }
    rc = baseWindow.Create ();
    if (rc !is XPCOM.NS_OK) {
        browser.dispose ();
        error (XPCOM.NS_ERROR_FAILURE);
    }
    rc = baseWindow.SetVisibility (1);
    if (rc !is XPCOM.NS_OK) {
        browser.dispose ();
        error (XPCOM.NS_ERROR_FAILURE);
    }
    baseWindow.Release ();

    if (!PerformedVersionCheck) {
        PerformedVersionCheck = true;
        
        nsIComponentRegistrar componentRegistrar;
        rc = componentManager.QueryInterface (&nsIComponentRegistrar.IID, cast(void**)&componentRegistrar);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc, __FILE__,__LINE__);
        }
        if (componentRegistrar is null) {
            browser.dispose ();
            error (XPCOM.NS_NOINTERFACE,__FILE__,__LINE__);
        }

        HelperAppLauncherDialogFactory dialogFactory = new HelperAppLauncherDialogFactory ();
        dialogFactory.AddRef ();
        String aClassName = "Helper App Launcher Dialog"; //$NON-NLS-1$
        rc = componentRegistrar.RegisterFactory (&XPCOM.NS_HELPERAPPLAUNCHERDIALOG_CID, aClassName.ptr, XPCOM.NS_HELPERAPPLAUNCHERDIALOG_CONTRACTID.ptr, cast(nsIFactory)dialogFactory);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (rc,__FILE__,__LINE__);
        }
        dialogFactory.Release ();

        /*
        * Check for the availability of the pre-1.8 implementation of nsIDocShell
        * to determine if the GRE's version is < 1.8.
        */
        nsIInterfaceRequestor interfaceRequestor;
        rc = webBrowser.QueryInterface (&nsIInterfaceRequestor.IID, cast(void**)&interfaceRequestor);
        if (rc !is XPCOM.NS_OK) {
            browser.dispose ();
            error (XPCOM.NS_ERROR_FAILURE);
        }
        if (interfaceRequestor is null) {
            browser.dispose ();
            error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
        }

        nsIDocShell docShell;
        rc = interfaceRequestor.GetInterface (&nsIDocShell.IID, cast(void**)&docShell);
        if (rc is XPCOM.NS_OK && docShell !is null) {
            IsPre_1_8 = true;
            docShell.Release ();
        }

        /*
        * A Download factory for contract "Transfer" must be registered iff the GRE's version is 1.8.x.
        *   Check for the availability of the 1.8 implementation of nsIDocShell to determine if the
        *   GRE's version is 1.8.x.
        * If the GRE version is < 1.8 then the previously-registered Download factory for contract
        *   "Download" will be used.
        * If the GRE version is >= 1.9 then no Download factory is registered because this
        *   functionality is provided by the GRE.
        */
        if (!IsPre_1_8) {
            nsIDocShell_1_8 docShell_1_8;
            rc = interfaceRequestor.GetInterface (&nsIDocShell_1_8.IID, cast(void**)&docShell_1_8);
            if (rc is XPCOM.NS_OK && docShell_1_8 !is null) { /* 1.8 */
                docShell_1_8.Release ();
 
                DownloadFactory_1_8 downloadFactory_1_8 = new DownloadFactory_1_8 ();
                downloadFactory_1_8.AddRef ();
                
                aClassName = "Transfer"; //$NON-NLS-1$
                rc = componentRegistrar.RegisterFactory (&XPCOM.NS_DOWNLOAD_CID, aClassName.ptr, XPCOM.NS_TRANSFER_CONTRACTID.ptr, cast(nsIFactory)downloadFactory_1_8);
                if (rc !is XPCOM.NS_OK) {
                    browser.dispose ();
                    error (rc, __FILE__, __LINE__);
                }
                downloadFactory_1_8.Release ();
                } else { /* >= 1.9 */
                /*
                 * Bug in XULRunner 1.9.  Mozilla no longer clears its background before initial content has
                 * been set.  As a result embedders appear broken if they do not immediately navigate to a url.
                 * The workaround for this is to navigate to about:blank immediately so that the background is
                 * cleared, but do not fire any corresponding events or allow Browser API calls to reveal this.
                 * Once the client does a proper navigate with either setUrl() or setText() then resume as
                 * normal.  The Mozilla bug for this is https://bugzilla.mozilla.org/show_bug.cgi?id=415789.
                 */
                awaitingNavigate = true;
                nsIWebNavigation webNavigation;
                rc = webBrowser.QueryInterface (&nsIWebNavigation.IID, cast(void**)&webNavigation);
                if (rc !is XPCOM.NS_OK) {
                    browser.dispose ();
                    error (rc, __FILE__, __LINE__);
                }
                if (webNavigation is null) {
                    browser.dispose ();
                    error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
                }
                rc = webNavigation.LoadURI (ABOUT_BLANK.toWCharArray().toString16z(), nsIWebNavigation.LOAD_FLAGS_NONE, null, null, null);
                webNavigation.Release ();
                dialogFactory.isPre_1_9 = false;
            }
        }
        interfaceRequestor.Release ();
        componentRegistrar.Release ();
    }
    componentManager.Release ();

    rc = webBrowser.AddWebBrowserListener (cast(nsIWeakReference)this, &nsIWebProgressListener.IID);
    if (rc !is XPCOM.NS_OK) {
        browser.dispose ();
        error (rc, __FILE__, __LINE__);
    }

    // TODO: Find appropriate place to "Release" uriContentListener -JJR
    nsIURIContentListener uriContentListener;
    this.QueryInterface(&nsIURIContentListener.IID, cast(void**)&uriContentListener);
    if (rc !is XPCOM.NS_OK) {
        browser.dispose();
        error(rc);
    }
    if (uriContentListener is null) {
        browser.dispose();
        error(XPCOM.NS_ERROR_NO_INTERFACE);
    }

    rc = webBrowser.SetParentURIContentListener (uriContentListener);
    if (rc !is XPCOM.NS_OK) {
        browser.dispose ();
        error (rc, __FILE__, __LINE__);
    }

    mozDelegate.init ();
        
    int[] folderEvents = [
        SWT.Dispose,
        SWT.Resize,  
        SWT.FocusIn,
        SWT.Activate,
        SWT.Deactivate,
        SWT.Show,
        SWT.KeyDown     // needed to make browser traversable
    ];
    
    for (int i = 0; i < folderEvents.length; i++) {
        browser.addListener (folderEvents[i], dgListener( &handleFolderEvent ));
    }
}

/*******************************************************************************

    Event Handlers for the Mozilla Class:
    
    These represent replacements for SWT's anonymous classes as used within
    the Mozilla class.  Since D 1.0x anonymous classes do not work equivalently 
    to Java's, we replace the anonymous classes with D delegates and templates
    (ie dgListener which wrap the delegate in a class).  This circumvents some
    nasty, evasive bugs.
    
    extern(D) becomes a necessary override on these methods because this class 
    implements a XPCOM/COM interface resulting in all class methods defaulting
    to extern(System). -JJR

 ******************************************************************************/

extern(D)
private void handleDisposeEvent (Event event, Display display) {
    if (BrowserCount > 0) return; /* another display is still active */

    nsIServiceManager serviceManager;

    int rc = XPCOM.NS_GetServiceManager (&serviceManager);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (serviceManager is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

    nsIObserverService observerService;
    rc = serviceManager.GetServiceByContractID (XPCOM.NS_OBSERVER_CONTRACTID.ptr, &nsIObserverService.IID, cast(void**)&observerService);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (observerService is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

    rc = observerService.NotifyObservers (null, PROFILE_BEFORE_CHANGE.ptr, SHUTDOWN_PERSIST.toWCharArray().toString16z());
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    observerService.Release ();

    if (LocationProvider !is null) {
        String prefsLocation = LocationProvider.profilePath ~ AppFileLocProvider.PREFERENCES_FILE;
        scope auto pathString = new nsEmbedString (prefsLocation.toWCharArray());
        nsILocalFile localFile;
        rc = XPCOM.NS_NewLocalFile (cast(nsAString*)pathString, 1, &localFile);
        if (rc !is XPCOM.NS_OK) Mozilla.error (rc, __FILE__, __LINE__);
        if (localFile is null) Mozilla.error (XPCOM.NS_ERROR_NULL_POINTER);

        nsIFile prefFile;
        rc = localFile.QueryInterface (&nsIFile.IID, cast(void**)&prefFile); 
        if (rc !is XPCOM.NS_OK) Mozilla.error (rc, __FILE__, __LINE__);
        if (prefFile is null) Mozilla.error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
        localFile.Release ();

        nsIPrefService prefService;
        rc = serviceManager.GetServiceByContractID (XPCOM.NS_PREFSERVICE_CONTRACTID.ptr, &nsIPrefService.IID, cast(void**)&prefService);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (prefService is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

        rc = prefService.SavePrefFile(prefFile);
        prefService.Release ();
        prefFile.Release ();
    }
    serviceManager.Release ();

    if (XPCOMWasGlued) {
        /*
         * XULRunner 1.9 can crash on Windows if XPCOMGlueShutdown is invoked here,
         * presumably because one or more of its unloaded symbols are referenced when
         * this callback returns.  The workaround is to delay invoking XPCOMGlueShutdown
         * so that its symbols are still available once this callback returns.
         */
         display.asyncExec (new class() Runnable {
             public void run () {
                 XPCOMInit.XPCOMGlueShutdown ();
             }
         });
         XPCOMWasGlued = XPCOMInitWasGlued = false;
    } 

    Initialized = false;
}
  
        
extern(D)
private void handleFolderEvent (Event event) {
            Control control = cast(Control)browser;
            switch (event.type) {
                case SWT.Dispose: {
                    /* make this handler run after other dispose listeners */
                    if (ignoreDispose) {
                        ignoreDispose = false;
                        break;
                    }
                    ignoreDispose = true;
                    browser.notifyListeners (event.type, event);
                    event.type = SWT.NONE;
                    onDispose (event.display);
                    break;
                }
                case SWT.Resize: onResize (); break;
                case SWT.FocusIn: Activate (); break;
                case SWT.Activate: Activate (); break;
                case SWT.Deactivate: {
                    Display display = event.display;
                    if (control is display.getFocusControl ()) Deactivate ();
                    break;
                }
                case SWT.Show: {
                    /*
                    * Feature in GTK Mozilla.  Mozilla does not show up when
                    * its container (a GTK fixed handle) is made visible
                    * after having been hidden.  The workaround is to reset
                    * its size after the container has been made visible. 
                    */
                    Display display = event.display;
                    display.asyncExec(new class () Runnable {
                        public void run() {
                            if (browser.isDisposed ()) return;
                            onResize ();
                        }
                    });
                    break;
                }
                default: break;
            }
        }

/*******************************************************************************

*******************************************************************************/
    
extern(D)
public bool back () {
    if (awaitingNavigate) return false;

    //ptrdiff_t[] result = new ptrdiff_t[1];
    nsIWebNavigation webNavigation;
    int rc = webBrowser.QueryInterface (&nsIWebNavigation.IID, cast(void**)&webNavigation);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (webNavigation is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIWebNavigation webNavigation = new nsIWebNavigation (result[0]);          
    rc = webNavigation.GoBack ();   
    webNavigation.Release ();
    return rc is XPCOM.NS_OK;
}

extern(D)
public bool execute (String script) {
    if (awaitingNavigate) return false;

    String url = PREFIX_JAVASCRIPT ~ script ~ ";void(0);";  //$NON-NLS-1$
    //ptrdiff_t[] result = new ptrdiff_t[1];
    nsIWebNavigation webNavigation;
    int rc = webBrowser.QueryInterface (&nsIWebNavigation.IID, cast(void**)&webNavigation);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (webNavigation is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

    //nsIWebNavigation webNavigation = new nsIWebNavigation (result[0]);
    //char[] arg = url.toCharArray (); 
    //char[] c = new char[arg.length+1];
    //System.arraycopy (arg, 0, c, 0, arg.length);
    rc = webNavigation.LoadURI (url.toWCharArray().toString16z(), nsIWebNavigation.LOAD_FLAGS_NONE, null, null, null);
    webNavigation.Release ();
    return rc is XPCOM.NS_OK;
}

extern(D)
static Browser findBrowser (void* handle) {
    return MozillaDelegate.findBrowser (cast(GtkWidget*)handle);
}

extern(D)
public bool forward () {
    if (awaitingNavigate) return false;

    //ptrdiff_t[] result = new ptrdiff_t[1];
    nsIWebNavigation webNavigation;
    int rc = webBrowser.QueryInterface (&nsIWebNavigation.IID, cast(void**)&webNavigation);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (webNavigation is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIWebNavigation webNavigation = new nsIWebNavigation (result[0]);
    rc = webNavigation.GoForward ();
    webNavigation.Release ();

    return rc is XPCOM.NS_OK;
}

extern(D)
public String getText () {
    if (awaitingNavigate) return ""; //$NON-NLS-1$

    //ptrdiff_t[] result = new ptrdiff_t[1];
    nsIDOMWindow window;
    int rc = webBrowser.GetContentDOMWindow (&window);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (window is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

    //nsIDOMWindow window = new nsIDOMWindow (result[0]);
    //result[0] = 0;
    nsIDOMDocument document;
    rc = window.GetDocument (&document);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (document is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
    window.Release ();

    //ptrdiff_t document = result[0];
    //result[0] = 0;
    nsIComponentManager componentManager;
    rc = XPCOM.NS_GetComponentManager (&componentManager);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (componentManager is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

    //nsIComponentManager componentManager = new nsIComponentManager (result[0]);
    //result[0] = 0;
    //byte[] contractID = MozillaDelegate.wcsToMbcs (null, XPCOM.NS_DOMSERIALIZER_CONTRACTID, true);
    String chars = null;
    nsIDOMSerializer_1_7 serializer_1_7;
    rc = componentManager.CreateInstanceByContractID (XPCOM.NS_DOMSERIALIZER_CONTRACTID.ptr, null, &nsIDOMSerializer_1_7.IID, cast(void**)&serializer_1_7);
    if (rc is XPCOM.NS_OK) {    /* mozilla >= 1.7 */
        if (serializer_1_7 is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

        //nsIDOMSerializer_1_7 serializer = new nsIDOMSerializer_1_7 (result[0]);
        //result[0] = 0;
        scope auto string = new nsEmbedString;
        rc = serializer_1_7.SerializeToString (cast(nsIDOMNode)document, cast(nsAString*) string);
        serializer_1_7.Release ();

        //int length = XPCOM.nsEmbedString_Length (string);
        //ptrdiff_t buffer = XPCOM.nsEmbedString_get (string);
        //chars = new char[length];
        //XPCOM.memmove (chars, buffer, length * 2);
        //XPCOM.nsEmbedString_delete (string);
        chars = string.toString();
    } else {    /* mozilla < 1.7 */
        nsIDOMSerializer serializer;
        rc = componentManager.CreateInstanceByContractID (XPCOM.NS_DOMSERIALIZER_CONTRACTID.ptr, null, &nsIDOMSerializer.IID, cast(void**)&serializer);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (serializer is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        // TODO: Lookup SerializeToString contract. Find out if the string must provide it's own memory to the method. -JJR
        PRUnichar* string;
        //nsIDOMSerializer serializer = new nsIDOMSerializer (result[0]);
        //result[0] = 0;
        rc = serializer.SerializeToString (cast(nsIDOMNode)document, &string );
        serializer.Release ();

        //int length = XPCOM.strlen_PRUnichar (string);
        //chars = new char[length];
        //XPCOM.memmove (chars, result[0], length * 2);
        chars = String_valueOf(fromString16z(string));
    }

    componentManager.Release ();
    document.Release ();
    return chars._idup();
}

extern(D)
public String getUrl () {
    if (awaitingNavigate) return ""; //$NON-NLS-1$

    //ptrdiff_t[] result = new ptrdiff_t[1];
    nsIWebNavigation webNavigation;
    int rc = webBrowser.QueryInterface (&nsIWebNavigation.IID, cast(void**)&webNavigation);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (webNavigation is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

    //nsIWebNavigation webNavigation = new nsIWebNavigation (result[0]);
    nsIURI aCurrentURI;
    rc = webNavigation.GetCurrentURI (&aCurrentURI);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    webNavigation.Release ();

    String location = null;
    if (aCurrentURI !is null) {
        //nsIURI uri = new nsIURI (aCurrentURI[0]);
        scope auto aSpec = new nsEmbedCString;
        rc = aCurrentURI.GetSpec (cast(nsACString*)aSpec);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        //int length = XPCOM.nsEmbedCString_Length (aSpec);
        //ptrdiff_t buffer = XPCOM.nsEmbedCString_get (aSpec);
        location = aSpec.toString;
        //XPCOM.memmove (dest, buffer, length);
        //XPCOM.nsEmbedCString_delete (aSpec);
        aCurrentURI.Release ();
    }
    if (location is null) return ""; //$NON-NLS-1$

    /*
     * If the URI indicates that the page is being rendered from memory
     * (via setText()) then set it to about:blank to be consistent with IE.
     */
    if (location.equals (URI_FROMMEMORY)) location = ABOUT_BLANK;
    return location;
}

extern(D)
public Object getWebBrowser () {
    if ((browser.getStyle () & SWT.MOZILLA) is 0) return null;
    if (webBrowserObject !is null) return webBrowserObject;
    implMissing(__FILE__,__LINE__);
/+
    try {
        // TODO: this references the JavaXPCOM browser... not sure what needs to be done here,
        // but I don't think this method is necessary.
        Class clazz = Class.forName ("org.mozilla.xpcom.Mozilla"); //$NON-NLS-1$
        Method method = clazz.getMethod ("getInstance", new Class[0]); //$NON-NLS-1$
        Object mozilla = method.invoke (null, new Object[0]);
        method = clazz.getMethod ("wrapXPCOMObject", new Class[] {Long.TYPE, String.class}); //$NON-NLS-1$
        webBrowserObject = webBrowser.getAddress ()), nsIWebBrowser.NS_IWEBBROWSER_IID_STR});
        /*
         * The following AddRef() is needed to offset the automatic Release() that
         * will be performed by JavaXPCOM when webBrowserObject is finalized.
         */
        webBrowser.AddRef ();
        return webBrowserObject;
   } catch (ClassNotFoundException e) {
   } catch (NoSuchMethodException e) {
   } catch (IllegalArgumentException e) {
   } catch (IllegalAccessException e) {
   } catch (InvocationTargetException e) {
   }
+/
   return null;
}

extern(D)
public bool isBackEnabled () {
    if (awaitingNavigate) return false;

    //ptrdiff_t[] result = new ptrdiff_t[1];
    nsIWebNavigation webNavigation;
    int rc = webBrowser.QueryInterface (&nsIWebNavigation.IID, cast(void**)&webNavigation);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (webNavigation is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIWebNavigation webNavigation = new nsIWebNavigation (result[0]);
    PRBool aCanGoBack; /* PRBool */
    rc = webNavigation.GetCanGoBack (&aCanGoBack);   
    webNavigation.Release ();
    return aCanGoBack !is 0;
}

extern(D)
public bool isForwardEnabled () {
    if (awaitingNavigate) return false;

    //ptrdiff_t[] result = new ptrdiff_t[1];
    nsIWebNavigation webNavigation;
    int rc = webBrowser.QueryInterface (&nsIWebNavigation.IID, cast(void**)&webNavigation);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (webNavigation is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIWebNavigation webNavigation = new nsIWebNavigation (result[0]);
    PRBool aCanGoForward; /* PRBool */
    rc = webNavigation.GetCanGoForward (&aCanGoForward);
    webNavigation.Release ();
    return aCanGoForward !is 0;
}

extern(D)
static void error (int code ) {
    error ( code, "NOT GIVEN", 0 );
}

extern(D)
static void error (int code, String file, int line) {
    getDwtLogger().info( __FILE__, __LINE__,  "File: {}  Line: {}", file, line);
    throw new SWTError ("XPCOM error " ~ Integer.toString(code)); //$NON-NLS-1$
}

extern(D)
void onDispose (Display display) {
    int rc = webBrowser.RemoveWebBrowserListener (cast(nsIWeakReference)this, &nsIWebProgressListener.IID);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);

    rc = webBrowser.SetParentURIContentListener (null);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    
    unhookDOMListeners ();
    if (listener !is null) {
        int[] folderEvents = [
            SWT.Dispose,
            SWT.Resize,  
            SWT.FocusIn,
            SWT.Activate,
            SWT.Deactivate,
            SWT.Show,
            SWT.KeyDown,
        ];
        for (int i = 0; i < folderEvents.length; i++) {
            browser.removeListener (folderEvents[i], listener);
        }
        listener = null;
    }

    //ptrdiff_t[] result = new ptrdiff_t[1];
    nsIBaseWindow baseWindow;
    rc = webBrowser.QueryInterface (&nsIBaseWindow.IID, cast(void**)&baseWindow);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (baseWindow is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

    //nsIBaseWindow baseWindow = new nsIBaseWindow (result[0]);
    rc = baseWindow.Destroy ();
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    baseWindow.Release ();

    Release ();
    webBrowser.Release ();
    webBrowser = null;
    webBrowserObject = null;

    if (tip !is null && !tip.isDisposed ()) tip.dispose ();
    tip = null;
    location = size = null;

    //Enumeration elements = unhookedDOMWindows.elements ();
    foreach (win ; unhookedDOMWindows) {
        //LONG ptrObject = (LONG)elements.nextElement ();
        win.Release ();
    }
    unhookedDOMWindows = null;

    mozDelegate.onDispose (embedHandle);
    mozDelegate = null;

    embedHandle = null;
    BrowserCount--;
}

extern(D)
void Activate () {
    //ptrdiff_t[] result = new ptrdiff_t[1];
    nsIWebBrowserFocus webBrowserFocus;
    int rc = webBrowser.QueryInterface (&nsIWebBrowserFocus.IID, cast(void**)&webBrowserFocus);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (webBrowserFocus is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIWebBrowserFocus webBrowserFocus = new nsIWebBrowserFocus (result[0]);
    rc = webBrowserFocus.Activate ();
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    webBrowserFocus.Release ();
}

extern(D)
void Deactivate () {
    //ptrdiff_t[] result = new ptrdiff_t[1];
    nsIWebBrowserFocus webBrowserFocus;
    int rc = webBrowser.QueryInterface (&nsIWebBrowserFocus.IID, cast(void**)&webBrowserFocus);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (webBrowserFocus is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIWebBrowserFocus webBrowserFocus = new nsIWebBrowserFocus (result[0]);
    rc = webBrowserFocus.Deactivate ();
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    webBrowserFocus.Release ();
}

extern(D)
void onResize () {
    Rectangle rect = browser.getClientArea ();
    int width = Math.max (1, rect.width);
    int height = Math.max (1, rect.height);

    //ptrdiff_t[] result = new ptrdiff_t[1];
    nsIBaseWindow baseWindow;
    int rc = webBrowser.QueryInterface (&nsIBaseWindow.IID, cast(void**)&baseWindow);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (baseWindow is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

    mozDelegate.setSize (embedHandle, width, height);
    //nsIBaseWindow baseWindow = new nsIBaseWindow (result[0]);
    rc = baseWindow.SetPositionAndSize (0, 0, width, height, 1);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    baseWindow.Release ();
}

extern(D)
public void refresh () {
    if (awaitingNavigate) return;

    //ptrdiff_t[] result = new ptrdiff_t[1];
    nsIWebNavigation webNavigation;
    int rc = webBrowser.QueryInterface (&nsIWebNavigation.IID, cast(void**)&webNavigation);
    if (rc !is XPCOM.NS_OK) error(rc);
    if (webNavigation is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIWebNavigation webNavigation = new nsIWebNavigation (result[0]);          
    rc = webNavigation.Reload (nsIWebNavigation.LOAD_FLAGS_NONE);
    webNavigation.Release ();
    if (rc is XPCOM.NS_OK) return;
    /*
    * Feature in Mozilla.  Reload returns an error code NS_ERROR_INVALID_POINTER
    * when it is called immediately after a request to load a new document using
    * LoadURI.  The workaround is to ignore this error code.
    *
    * Feature in Mozilla.  Attempting to reload a file that no longer exists
    * returns an error code of NS_ERROR_FILE_NOT_FOUND.  This is equivalent to
    * attempting to load a non-existent local url, which is not a Browser error,
    * so this error code should be ignored. 
    */
    if (rc !is XPCOM.NS_ERROR_INVALID_POINTER && rc !is XPCOM.NS_ERROR_FILE_NOT_FOUND) error (rc, __FILE__, __LINE__);
}

extern(D)
public bool setText (String html) {
    /*
    *  Feature in Mozilla.  The focus memory of Mozilla must be 
    *  properly managed through the nsIWebBrowserFocus interface.
    *  In particular, nsIWebBrowserFocus.deactivate must be called
    *  when the focus moves from the browser (or one of its children
    *  managed by Mozilla to another widget.  We currently do not
    *  get notified when a widget takes focus away from the Browser.
    *  As a result, deactivate is not properly called. This causes
    *  Mozilla to retake focus the next time a document is loaded.
    *  This breaks the case where the HTML loaded in the Browser 
    *  varies while the user enters characters in a text widget. The text
    *  widget loses focus every time new content is loaded.
    *  The current workaround is to call deactivate everytime if 
    *  the browser currently does not have focus. A better workaround
    *  would be to have a way to call deactivate when the Browser
    *  or one of its children loses focus.
    */
    if (browser !is browser.getDisplay().getFocusControl ()) {
        Deactivate ();
    }
    /* convert the String containing HTML to an array of bytes with UTF-8 data */
    /+
    byte[] data = null;
    try {
        data = html.getBytes ("UTF-8"); //$NON-NLS-1$
    } catch (UnsupportedEncodingException e) {
        return false;
    }
    +/
    awaitingNavigate = false;

    //byte[] contentTypeBuffer = MozillaDelegate.wcsToMbcs (null, "text/html", true); // $NON-NLS-1$
    scope auto aContentType = new nsEmbedCString ("text/html");
    //byte[] contentCharsetBuffer = MozillaDelegate.wcsToMbcs (null, "UTF-8", true);  //$NON-NLS-1$
    scope auto aContentCharset = new nsEmbedCString ("UTF-8");

    //ptrdiff_t[] result = new ptrdiff_t[1];
    nsIServiceManager serviceManager;
    int rc = XPCOM.NS_GetServiceManager (&serviceManager);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (serviceManager is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

    //nsIServiceManager serviceManager = new nsIServiceManager (result[0]);
    //result[0] = 0;
    nsIIOService ioService;
    rc = serviceManager.GetService (&XPCOM.NS_IOSERVICE_CID, &nsIIOService.IID, cast(void**)&ioService);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (ioService is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
    serviceManager.Release ();

    //nsIIOService ioService = new nsIIOService (result[0]);
    //result[0] = 0;
    /*
    * Note.  Mozilla ignores LINK tags used to load CSS stylesheets
    * when the URI protocol for the nsInputStreamChannel
    * is about:blank.  The fix is to specify the file protocol.
    */
    //byte[] aString = MozillaDelegate.wcsToMbcs (null, URI_FROMMEMORY, false);
    scope auto aSpec = new nsEmbedCString(URI_FROMMEMORY);
    nsIURI uri;
    rc = ioService.NewURI (cast(nsACString*)aSpec, null, null, &uri);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (uri is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
    //XPCOM.nsEmbedCString_delete (aSpec);
    ioService.Release ();

    //nsIURI uri = new nsIURI (result[0]);
    //result[0] = 0;
    nsIInterfaceRequestor interfaceRequestor;
    rc = webBrowser.QueryInterface (&nsIInterfaceRequestor.IID, cast(void**)&interfaceRequestor);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (interfaceRequestor is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    //nsIInterfaceRequestor interfaceRequestor = new nsIInterfaceRequestor (result[0]);
    //result[0] = 0;

    /*
    * Feature in Mozilla. LoadStream invokes the nsIInputStream argument
    * through a different thread.  The callback mechanism must attach 
    * a non java thread to the JVM otherwise the nsIInputStream Read and
    * Close methods never get called.
    */
    
    // Using fully qualified name for disambiguation with java.io.InputStream -JJR
    auto inputStream = new org.eclipse.swt.browser.InputStream.InputStream (cast(byte[])html);
    inputStream.AddRef ();

    nsIDocShell_1_9 docShell_1_9;
    rc = interfaceRequestor.GetInterface (&nsIDocShell_1_9.IID, cast(void**)&docShell_1_9);
    if (rc is XPCOM.NS_OK) {
        if (docShell_1_9 is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
        //nsIDocShell_1_9 docShell = new nsIDocShell_1_9 (result[0]);
        rc = docShell_1_9.LoadStream (inputStream, uri, cast(nsACString*)aContentType,  cast(nsACString*)aContentCharset, null);
        docShell_1_9.Release ();
    } else {
        //result[0] = 0;
        nsIDocShell_1_8 docShell_1_8;
        rc = interfaceRequestor.GetInterface (&nsIDocShell_1_8.IID, cast(void**)&docShell_1_8);
        if (rc is XPCOM.NS_OK) {    
            if (docShell_1_8 is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
            //nsIDocShell_1_8 docShell = new nsIDocShell_1_8 (result[0]);
            rc = docShell_1_8.LoadStream (inputStream, uri, cast(nsACString*)aContentType,  cast(nsACString*)aContentCharset, null);
            docShell_1_8.Release ();
        } else {
            //result[0] = 0;
            nsIDocShell docShell;
            rc = interfaceRequestor.GetInterface (&nsIDocShell.IID, cast(void**)&docShell);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (docShell is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
            //nsIDocShell docShell = new nsIDocShell (result[0]);
            rc = docShell.LoadStream (inputStream, uri, cast(nsACString*) aContentType,  cast(nsACString*)aContentCharset, null);
            docShell.Release ();
        }
    }
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    //result[0] = 0;

    inputStream.Release ();
    interfaceRequestor.Release ();
    uri.Release ();
    //XPCOM.nsEmbedCString_delete (aContentCharset);
    //XPCOM.nsEmbedCString_delete (aContentType);
    return true;
}

extern(D)
public bool setUrl (String url) {
    awaitingNavigate = false;

    nsIWebNavigation webNavigation;
    int rc = webBrowser.QueryInterface (&nsIWebNavigation.IID, cast(void**)&webNavigation);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (webNavigation is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

    rc = webNavigation.LoadURI (url.toWCharArray().toString16z(), nsIWebNavigation.LOAD_FLAGS_NONE, null, null, null);
    webNavigation.Release ();
    return rc is XPCOM.NS_OK;
}

extern(D)
public void stop () {
    if (awaitingNavigate) return;

    nsIWebNavigation webNavigation;
    //ptrdiff_t[] result = new ptrdiff_t[1];
    int rc = webBrowser.QueryInterface (&nsIWebNavigation.IID, cast(void**)&webNavigation);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (webNavigation is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIWebNavigation webNavigation = new nsIWebNavigation (result[0]);      
    rc = webNavigation.Stop (nsIWebNavigation.STOP_ALL);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    webNavigation.Release ();
}

extern(D)
void hookDOMListeners (nsIDOMEventTarget target, bool isTop) {
    scope auto string = new nsEmbedString (XPCOM.DOMEVENT_FOCUS.toWCharArray());
    target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_UNLOAD.toWCharArray());
    target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEDOWN.toWCharArray());
    target.AddEventListener (cast(nsAString*)string,cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEUP.toWCharArray());
    target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEMOVE.toWCharArray());
    target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEWHEEL.toWCharArray());
    target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEDRAG.toWCharArray());
    target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();

    /*
    * Only hook mouseover and mouseout if the target is a top-level frame, so that mouse moves
    * between frames will not generate events.
    */
    if (isTop && mozDelegate.hookEnterExit ()) {
        string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEOVER.toWCharArray());
        target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
        //string.dispose ();
        string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEOUT.toWCharArray());
        target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
        //string.dispose ();
    }

    string = new nsEmbedString (XPCOM.DOMEVENT_KEYDOWN.toWCharArray());
    target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_KEYPRESS.toWCharArray());
    target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_KEYUP.toWCharArray());
    target.AddEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
}

extern(D)
void unhookDOMListeners () {
    //ptrdiff_t[] result = new ptrdiff_t[1];
    nsIDOMWindow window;
    int rc = webBrowser.GetContentDOMWindow (&window);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (window is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

    //nsIDOMWindow window = new nsIDOMWindow (result[0]);
    //result[0] = 0;
    nsIDOMEventTarget target;
    rc = window.QueryInterface (&nsIDOMEventTarget.IID, cast(void**)&target);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (target is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

    //nsIDOMEventTarget target = new nsIDOMEventTarget (result[0]);
    //result[0] = 0;
    unhookDOMListeners (target);
    target.Release ();

    /* Listeners must be unhooked in pages contained in frames */
    nsIDOMWindowCollection frames;
    rc = window.GetFrames (&frames);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (frames is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    //nsIDOMWindowCollection frames = new nsIDOMWindowCollection (result[0]);
    //result[0] = 0;
    PRUint32 count;
    rc = frames.GetLength (&count); /* PRUint32 */
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    //int count = frameCount[0];

    if (count > 0) {
        nsIDOMWindow frame;
        for (int i = 0; i < count; i++) {
            rc = frames.Item (i, &frame);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (frame is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

            //nsIDOMWindow frame = new nsIDOMWindow (result[0]);
            //result[0] = 0;
            rc = frame.QueryInterface (&nsIDOMEventTarget.IID, cast(void**)&target);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (target is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

            //target = new nsIDOMEventTarget (result[0]);
            //result[0] = 0;
            unhookDOMListeners (target);
            target.Release ();
            frame.Release ();
        }
    }
    frames.Release ();
    window.Release ();
}

extern(D)
void unhookDOMListeners (nsIDOMEventTarget target) {
    scope auto string = new nsEmbedString (XPCOM.DOMEVENT_FOCUS.toWCharArray());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_UNLOAD.toWCharArray());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEDOWN.toWCharArray());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEUP.toWCharArray());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEMOVE.toWCharArray());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEWHEEL.toWCharArray());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEDRAG.toWCharArray());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEOVER.toWCharArray());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_MOUSEOUT.toWCharArray());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_KEYDOWN.toWCharArray());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_KEYPRESS.toWCharArray());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
    string = new nsEmbedString (XPCOM.DOMEVENT_KEYUP.toWCharArray());
    target.RemoveEventListener (cast(nsAString*)string, cast(nsIDOMEventListener)this, 0);
    //string.dispose ();
}

/* nsISupports */

extern(System)
nsresult QueryInterface (in nsID* riid, void** ppvObject) {
    if (riid is null || ppvObject is null) return XPCOM.NS_ERROR_NO_INTERFACE;

    if (*riid == nsISupports.IID) {
        *ppvObject = cast(void*)cast(nsISupports)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIWeakReference.IID) {
        *ppvObject = cast(void*)cast(nsIWeakReference)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIWebProgressListener.IID) {
        *ppvObject = cast(void*)cast(nsIWebProgressListener)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIWebBrowserChrome.IID) {
        *ppvObject = cast(void*)cast(nsIWebBrowserChrome)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIWebBrowserChromeFocus.IID) {
        *ppvObject = cast(void*)cast(nsIWebBrowserChromeFocus)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIEmbeddingSiteWindow.IID) {
        *ppvObject = cast(void*)cast(nsIEmbeddingSiteWindow)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIInterfaceRequestor.IID) {
        *ppvObject = cast(void*)cast(nsIInterfaceRequestor)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsISupportsWeakReference.IID) {
        *ppvObject = cast(void*)cast(nsISupportsWeakReference)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIContextMenuListener.IID) {
        *ppvObject = cast(void*)cast(nsIContextMenuListener)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIURIContentListener.IID) {
        *ppvObject = cast(void*)cast(nsIURIContentListener)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsITooltipListener.IID) {
        *ppvObject = cast(void*)cast(nsITooltipListener)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    *ppvObject = null;
    return XPCOM.NS_ERROR_NO_INTERFACE;
}

extern(System)
nsrefcnt AddRef () {
    refCount++;
    return refCount;
}

extern(System)
nsrefcnt Release () {
    refCount--;
    if (refCount is 0) return 0;
    return refCount;
}

/* nsIWeakReference */  

extern(System)
nsresult QueryReferent (nsID* riid, void** ppvObject) {
    return QueryInterface (riid, ppvObject);
}

/* nsIInterfaceRequestor */

extern(System)
nsresult GetInterface ( in nsID* riid, void** ppvObject) {
    if (riid is null || ppvObject is null) return XPCOM.NS_ERROR_NO_INTERFACE;
    //nsID guid = new nsID ();
    //XPCOM.memmove (guid, riid, nsID.sizeof);
    if (*riid == nsIDOMWindow.IID) {
        nsIDOMWindow aContentDOMWindow;
        //ptrdiff_t[] aContentDOMWindow = new ptrdiff_t[1];
        int rc = webBrowser.GetContentDOMWindow (&aContentDOMWindow);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (aContentDOMWindow is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
        *ppvObject = cast(void*)aContentDOMWindow;
        //XPCOM.memmove (ppvObject, aContentDOMWindow, C.PTR_SIZEOF);
        return rc;
    }
    return QueryInterface (riid, ppvObject);
}

extern(System)
nsresult GetWeakReference (nsIWeakReference* ppvObject) {
    *ppvObject = cast(nsIWeakReference)this;
    //XPCOM.memmove (ppvObject, new ptrdiff_t[] {weakReference.getAddress ()}, C.PTR_SIZEOF);
    AddRef ();
    return XPCOM.NS_OK;
}

/* nsIWebProgressListener */

extern(System)
nsresult OnStateChange (nsIWebProgress aWebProgress, nsIRequest aRequest, PRUint32 aStateFlags, nsresult aStatus) {
    if ((aStateFlags & nsIWebProgressListener.STATE_IS_DOCUMENT) is 0) return XPCOM.NS_OK;
    if ((aStateFlags & nsIWebProgressListener.STATE_START) !is 0) {
        if (request is null) request = aRequest;

        if (!awaitingNavigate) {
            /*
             * Add the page's nsIDOMWindow to the collection of windows that will
             * have DOM listeners added to them later on in the page loading
             * process.  These listeners cannot be added yet because the
             * nsIDOMWindow is not ready to take them at this stage.
             */
            //ptrdiff_t[] result = new ptrdiff_t[1];
            nsIDOMWindow window;
            //nsIWebProgress progress = new nsIWebProgress (aWebProgress);
            int rc = aWebProgress.GetDOMWindow (&window);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (window is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            unhookedDOMWindows ~= window;
        }
    } else if ((aStateFlags & nsIWebProgressListener.STATE_REDIRECTING) !is 0) {
        if (request is aRequest) request = null;
    } else if ((aStateFlags & nsIWebProgressListener.STATE_STOP) !is 0) {
        /*
        * If this page's nsIDOMWindow handle is still in unhookedDOMWindows then
        * add its DOM listeners now.  It's possible for this to happen since
        * there is no guarantee that a STATE_TRANSFERRING state change will be
        * received for every window in a page, which is when these listeners
        * are typically added.
        */
        //ptrdiff_t[] result = new ptrdiff_t[1];
        //nsIWebProgress progress = new nsIWebProgress (aWebProgress);
        nsIDOMWindow domWindow;
        int rc = aWebProgress.GetDOMWindow (&domWindow);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (domWindow is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        //nsIDOMWindow domWindow = new nsIDOMWindow (result[0]);

        //LONG ptrObject = new LONG (result[0]);
        //result[0] = 0;
        int index = unhookedDOMWindows.arrayIndexOf (domWindow);
        if (index !is -1) {
            nsIDOMWindow contentWindow;
            rc = webBrowser.GetContentDOMWindow (&contentWindow);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (contentWindow is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
            bool isTop = contentWindow is domWindow;
            contentWindow.Release ();
            //result[0] = 0;
            nsIDOMEventTarget target;
            rc = domWindow.QueryInterface (&nsIDOMEventTarget.IID, cast(void**)&target);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (target is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

            //nsIDOMEventTarget target = new nsIDOMEventTarget (result[0]);
            //result[0] = 0;
            hookDOMListeners (target, isTop);
            target.Release ();

            /*
            * Remove and unreference the nsIDOMWindow from the collection of windows
            * that are waiting to have DOM listeners hooked on them. 
            */
            unhookedDOMWindows = unhookedDOMWindows.arrayIndexRemove (index);
            domWindow.Release ();
        }
        domWindow.Release ();

        /*
        * Feature in Mozilla.  When a request is redirected (STATE_REDIRECTING),
        * it never reaches the state STATE_STOP and it is replaced with a new request.
        * The new request is received when it is in the state STATE_STOP.
        * To handle this case,  the variable request is set to 0 when the corresponding
        * request is redirected. The following request received with the state STATE_STOP
        * - the new request resulting from the redirection - is used to send
        * the ProgressListener.completed event.
        */
        if (request is aRequest || request is null) {
            request = null;
            if (!awaitingNavigate) {
                StatusTextEvent event = new StatusTextEvent (browser);
                event.display = browser.getDisplay ();
                event.widget = browser;
                event.text = ""; //$NON-NLS-1$
                for (int i = 0; i < statusTextListeners.length; i++) {
                    statusTextListeners[i].changed (event);
                }
                ProgressEvent event2 = new ProgressEvent (browser);
                event2.display = browser.getDisplay ();
                event2.widget = browser;
                for (int i = 0; i < progressListeners.length; i++) {
                    progressListeners[i].completed (event2);
                }
            }
        }
    } else if ((aStateFlags & nsIWebProgressListener.STATE_TRANSFERRING) !is 0) {
        /*
        * Hook DOM listeners to the page's nsIDOMWindow here because this is
        * the earliest opportunity to do so.    
        */
        //ptrdiff_t[] result = new ptrdiff_t[1];
       // nsIWebProgress progress = new nsIWebProgress (aWebProgress);
        nsIDOMWindow domWindow;
        int rc = aWebProgress.GetDOMWindow (&domWindow);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (domWindow is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        //nsIDOMWindow domWindow = new nsIDOMWindow (result[0]);

        //LONG ptrObject = new LONG (result[0]);
        //result[0] = 0;
        int index = unhookedDOMWindows.arrayIndexOf ( domWindow);
        if (index !is -1) {
            nsIDOMWindow contentWindow;
            rc = webBrowser.GetContentDOMWindow (&contentWindow);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (contentWindow is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
            bool isTop = contentWindow is domWindow;
            contentWindow.Release ();
            //result[0] = 0;
            nsIDOMEventTarget target;
            rc = domWindow.QueryInterface (&nsIDOMEventTarget.IID, cast(void**)&target);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (target is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);

            //nsIDOMEventTarget target = new nsIDOMEventTarget (result[0]);
            //result[0] = 0;
            hookDOMListeners (target, isTop);
            target.Release ();

            /*
            * Remove and unreference the nsIDOMWindow from the collection of windows
            * that are waiting to have DOM listeners hooked on them. 
            */
            unhookedDOMWindows = unhookedDOMWindows.arrayIndexRemove(index);
            domWindow.Release ();
        }
        domWindow.Release ();
    }
    return XPCOM.NS_OK;
}

extern(System)
nsresult OnProgressChange (nsIWebProgress aWebProgress, nsIRequest aRequest, PRInt32 aCurSelfProgress, PRInt32 aMaxSelfProgress, PRInt32 aCurTotalProgress, PRInt32 aMaxTotalProgress) {
    if (awaitingNavigate || super.progressListeners.length is 0) return XPCOM.NS_OK;
    ProgressEvent event = new ProgressEvent (browser);
    event.display = browser.getDisplay ();
    event.widget = browser;
    event.current = aCurTotalProgress;
    event.total = aMaxTotalProgress;
    for (int i = 0; i < super.progressListeners.length; i++) {
        super.progressListeners[i].changed (event);
    }
    return XPCOM.NS_OK;
}

extern(System)
nsresult OnLocationChange (nsIWebProgress aWebProgress, nsIRequest aRequest, nsIURI aLocation) {
    /*
    * Feature in Mozilla.  When a page is loaded via setText before a previous
    * setText page load has completed, the expected OnStateChange STATE_STOP for the
    * original setText never arrives because it gets replaced by the OnStateChange
    * STATE_STOP for the new request.  This results in the request field never being
    * cleared because the original request's OnStateChange STATE_STOP is still expected
    * (but never arrives).  To handle this case, the request field is updated to the new
    * overriding request since its OnStateChange STATE_STOP will be received next.
    */
    if (request !is null && request !is aRequest) request = aRequest;

    if (awaitingNavigate || locationListeners.length is 0) return XPCOM.NS_OK;

    //nsIWebProgress webProgress = new nsIWebProgress (aWebProgress);
    
    nsIDOMWindow domWindow;
    //ptrdiff_t[] aDOMWindow = new ptrdiff_t[1];
    int rc = aWebProgress.GetDOMWindow (&domWindow);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (domWindow is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIDOMWindow domWindow = new nsIDOMWindow (aDOMWindow[0]);
    //ptrdiff_t[] aTop = new ptrdiff_t[1];
    nsIDOMWindow topWindow;
    rc = domWindow.GetTop (&topWindow);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (topWindow is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    domWindow.Release ();
    
    //nsIDOMWindow topWindow = new nsIDOMWindow (aTop[0]);
    topWindow.Release ();
    
    //nsIURI location = new nsIURI (aLocation);
    scope auto aSpec = new nsEmbedCString;
    aLocation.GetSpec (cast(nsACString*)aSpec);
    //int length = XPCOM.nsEmbedCString_Length (aSpec);
    //ptrdiff_t buffer = XPCOM.nsEmbedCString_get (aSpec);
    //byte[] dest = new byte[length];
    //XPCOM.memmove (dest, buffer, length);
    //XPCOM.nsEmbedCString_delete (aSpec);
    String url = aSpec.toString;

    /*
     * As of Mozilla 1.8, the first time that a page is displayed, regardless of
     * whether it's via Browser.setURL() or Browser.setText(), the GRE navigates
     * to about:blank and fires the corresponding navigation events.  Do not send
     * this event on to the user since it is not expected.
     */
    if (!IsPre_1_8 && aRequest is null && url.startsWith (ABOUT_BLANK)) return XPCOM.NS_OK;

    LocationEvent event = new LocationEvent (browser);
    event.display = browser.getDisplay ();
    event.widget = browser;
    event.location = url;
    /*
     * If the URI indicates that the page is being rendered from memory
     * (via setText()) then set it to about:blank to be consistent with IE.
     */
    if (event.location.equals (URI_FROMMEMORY)) event.location = ABOUT_BLANK;
    event.top = topWindow is domWindow;
    for (int i = 0; i < locationListeners.length; i++) {
        locationListeners[i].changed (event);
    }
    return XPCOM.NS_OK;
}

extern(System)
nsresult OnStatusChange (nsIWebProgress aWebProgress, nsIRequest aRequest, nsresult aStatus, PRUnichar* aMessage) {
    if (awaitingNavigate || statusTextListeners.length is 0) return XPCOM.NS_OK;
    StatusTextEvent event = new StatusTextEvent (browser);
    event.display = browser.getDisplay ();
    event.widget = browser;
    //int length = XPCOM.strlen_PRUnichar (aMessage);
    //char[] dest = new char[length];
    //XPCOM.memmove (dest, aMessage, length * 2);
    event.text = String_valueOf(fromString16z(aMessage));
    for (int i = 0; i < statusTextListeners.length; i++) {
        statusTextListeners[i].changed (event);
    }
    return XPCOM.NS_OK;
}       

extern(System)
nsresult OnSecurityChange (nsIWebProgress aWebProgress, nsIRequest aRequest, PRUint32 state) {
    return XPCOM.NS_OK;
}

/* nsIWebBrowserChrome */

extern(System)
nsresult SetStatus (PRUint32 statusType, PRUnichar* status) {
    if (awaitingNavigate || statusTextListeners.length is 0) return XPCOM.NS_OK;
    StatusTextEvent event = new StatusTextEvent (browser);
    event.display = browser.getDisplay ();
    event.widget = browser;
    //int length = XPCOM.strlen_PRUnichar (status);
    //char[] dest = new char[length];
    //XPCOM.memmove (dest, status, length * 2);
    //String string = new String (dest);
    event.text = String_valueOf(fromString16z(status));
    for (int i = 0; i < statusTextListeners.length; i++) {
        statusTextListeners[i].changed (event);
    }
    return XPCOM.NS_OK;
}

extern(System)
nsresult GetWebBrowser (nsIWebBrowser* aWebBrowser) {
    //ptrdiff_t[] ret = new ptrdiff_t[1];   
    if (webBrowser !is null) {
        webBrowser.AddRef ();
        *aWebBrowser = webBrowser;  
    }
    //XPCOM.memmove (aWebBrowser, ret, C.PTR_SIZEOF);
    return XPCOM.NS_OK;
}

extern(System)
nsresult SetWebBrowser (nsIWebBrowser aWebBrowser) {
    if (webBrowser !is null) webBrowser.Release ();
    webBrowser = aWebBrowser !is null ? cast(nsIWebBrowser)cast(void*)aWebBrowser : null;                
    return XPCOM.NS_OK;
}

extern(System)
nsresult GetChromeFlags (PRUint32* aChromeFlags) {
    //int[] ret = new int[1];
    *aChromeFlags = chromeFlags;
    //XPCOM.memmove (aChromeFlags, ret, 4); /* PRUint32 */
    return XPCOM.NS_OK;
}

extern(System)
nsresult SetChromeFlags (PRUint32 aChromeFlags) {
    chromeFlags = aChromeFlags;
    return XPCOM.NS_OK;
}

extern(System)
nsresult DestroyBrowserWindow () {
    WindowEvent newEvent = new WindowEvent (browser);
    newEvent.display = browser.getDisplay ();
    newEvent.widget = browser;
    for (int i = 0; i < closeWindowListeners.length; i++) {
        closeWindowListeners[i].close (newEvent);
    }
    /*
    * Note on Mozilla.  The DestroyBrowserWindow notification cannot be cancelled.
    * The browser widget cannot be used after this notification has been received.
    * The application is advised to close the window hosting the browser widget.
    * The browser widget must be disposed in all cases.
    */
    browser.dispose ();
    return XPCOM.NS_OK;
}

extern(System)
nsresult SizeBrowserTo (PRInt32 aCX, PRInt32 aCY) {
    size = new Point (aCX, aCY);
    bool isChrome = (chromeFlags & nsIWebBrowserChrome.CHROME_OPENAS_CHROME) !is 0;
    if (isChrome) {
        Shell shell = browser.getShell ();
        shell.setSize (shell.computeSize (size.x, size.y));
    }
    return XPCOM.NS_OK;
}

extern(System)
nsresult ShowAsModal () {
    //ptrdiff_t[] result = new ptrdiff_t[1];
    nsIServiceManager serviceManager;
    int rc = XPCOM.NS_GetServiceManager (&serviceManager);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (serviceManager is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

    //nsIServiceManager serviceManager = new nsIServiceManager (result[0]);
    //result[0] = 0;
    //byte[] aContractID = MozillaDelegate.wcsToMbcs (null, XPCOM.NS_CONTEXTSTACK_CONTRACTID, true);
    nsIJSContextStack stack;
    rc = serviceManager.GetServiceByContractID (XPCOM.NS_CONTEXTSTACK_CONTRACTID.ptr, &nsIJSContextStack.IID, cast(void**)&stack);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (stack is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
    serviceManager.Release ();

    //nsIJSContextStack stack = new nsIJSContextStack (result[0]);
    //result[0] = 0;
    rc = stack.Push (null);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);

    Shell shell = browser.getShell ();
    Display display = browser.getDisplay ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    JSContext* result;
    rc = stack.Pop (&result);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    stack.Release ();
    return XPCOM.NS_OK;
}

extern(System)
nsresult IsWindowModal (PRBool* retval) {
    *retval = (chromeFlags & nsIWebBrowserChrome.CHROME_MODAL) !is 0 ? 1 : 0;
    //XPCOM.memmove (retval, new int[] {result}, 4); /* PRBool */
    return XPCOM.NS_OK;
}

extern(System)
nsresult ExitModalEventLoop (nsresult aStatus) {
    return XPCOM.NS_OK;
}

/* nsIEmbeddingSiteWindow */ 

extern(System)
nsresult SetDimensions (PRUint32 flags, PRInt32 x, PRInt32 y, PRInt32 cx, PRInt32 cy) {
    if ((flags & nsIEmbeddingSiteWindow.DIM_FLAGS_POSITION) !is 0) {
        location = new Point (x, y);
        browser.getShell ().setLocation (x, y);
    }
    if ((flags & nsIEmbeddingSiteWindow.DIM_FLAGS_SIZE_INNER) !is 0) {
        browser.setSize (cx, cy);
    }
    if ((flags & nsIEmbeddingSiteWindow.DIM_FLAGS_SIZE_OUTER) !is 0) {
        browser.getShell ().setSize (cx, cy);
    }
    return XPCOM.NS_OK;
}

extern(System)
nsresult GetDimensions (PRUint32 flags, PRInt32* x, PRInt32* y, PRInt32* cx, PRInt32* cy) {
    if ((flags & nsIEmbeddingSiteWindow.DIM_FLAGS_POSITION) !is 0) {
        Point location = browser.getShell ().getLocation ();
        if (x !is null) *x = location.x; /* PRInt32 */
        if (y !is null) *y = location.y; /* PRInt32 */
    }
    if ((flags & nsIEmbeddingSiteWindow.DIM_FLAGS_SIZE_INNER) !is 0) {
        Point size = browser.getSize ();
        if (cx !is null) *cx = size.x; /* PRInt32 */
        if (cy !is null) *cy = size.y; /* PRInt32 */
    }
    if ((flags & nsIEmbeddingSiteWindow.DIM_FLAGS_SIZE_OUTER) !is 0) {
        Point size = browser.getShell().getSize ();
        if (cx !is null) *cx = size.x; /* PRInt32 */
        if (cy !is null) *cy = size.y; /* PRInt32 */
    }
    return XPCOM.NS_OK;
}

extern(System)
nsresult SetFocus () {
    //ptrdiff_t[] result = new ptrdiff_t[1];
    nsIBaseWindow baseWindow;
    int rc = webBrowser.QueryInterface (&nsIBaseWindow.IID, cast(void**)&baseWindow);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (baseWindow is null) error (XPCOM.NS_ERROR_NO_INTERFACE, __FILE__, __LINE__);
    
    //nsIBaseWindow baseWindow = new nsIBaseWindow (result[0]);
    rc = baseWindow.SetFocus ();
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    baseWindow.Release ();

    /*
    * Note. Mozilla notifies here that one of the children took
    * focus. This could or should be used to fire an SWT.FOCUS_IN
    * event on Browser focus listeners.
    */
    return XPCOM.NS_OK;         
}   

extern(System)
nsresult GetVisibility (PRBool* aVisibility) {
    bool visible = browser.isVisible () && !browser.getShell ().getMinimized ();
    *aVisibility = visible ? 1 : 0;
    //XPCOM.memmove (aVisibility, new int[] {visible ? 1 : 0}, 4); /* PRBool */
    return XPCOM.NS_OK;
}

extern(System)
nsresult SetVisibility (PRBool aVisibility) {
    if (isChild) {
        WindowEvent event = new WindowEvent (browser);
        event.display = browser.getDisplay ();
        event.widget = browser;
        if (aVisibility !is 0) {
            /*
            * Bug in Mozilla.  When the JavaScript window.open is executed, Mozilla
            * fires multiple SetVisibility 1 notifications.  The workaround is
            * to ignore subsequent notifications. 
            */
            if (!visible) {
                visible = true;
                event.location = location;
                event.size = size;
                event.addressBar = (chromeFlags & nsIWebBrowserChrome.CHROME_LOCATIONBAR) !is 0;
                event.menuBar = (chromeFlags & nsIWebBrowserChrome.CHROME_MENUBAR) !is 0;
                event.statusBar = (chromeFlags & nsIWebBrowserChrome.CHROME_STATUSBAR) !is 0;
                event.toolBar = (chromeFlags & nsIWebBrowserChrome.CHROME_TOOLBAR) !is 0;
                for (int i = 0; i < visibilityWindowListeners.length; i++) {
                    visibilityWindowListeners[i].show (event);
                }
                location = null;
                size = null;
            }
        } else {
            visible = false;
            for (int i = 0; i < visibilityWindowListeners.length; i++) {
                visibilityWindowListeners[i].hide (event);
            }
        }
    } else {
        visible = aVisibility !is 0;
    }
    return XPCOM.NS_OK;         
}

extern(System)
nsresult GetTitle (PRUnichar** aTitle) {
    return XPCOM.NS_OK;         
}
 
extern(System)
nsresult SetTitle (PRUnichar* aTitle) {
    if (awaitingNavigate || titleListeners.length is 0) return XPCOM.NS_OK;
    TitleEvent event = new TitleEvent (browser);
    event.display = browser.getDisplay ();
    event.widget = browser;
    /*
    * To be consistent with other platforms the title event should
    * contain the page's url if the page does not contain a <title>
    * tag. 
    */
    int length = XPCOM.strlen_PRUnichar (aTitle);
    if (length > 0) {
        //char[] dest = new char[length];
        //XPCOM.memmove (dest, aTitle, length * 2);
        event.title = String_valueOf(fromString16z(aTitle));
    } else {
        event.title = getUrl ();
    }
    for (int i = 0; i < titleListeners.length; i++) {
        titleListeners[i].changed (event);
    }
    return XPCOM.NS_OK;         
}

extern(System)
nsresult GetSiteWindow (void** aSiteWindow) {
    /*
    * Note.  The handle is expected to be an HWND on Windows and
    * a GtkWidget* on GTK.  This callback is invoked on Windows
    * when the javascript window.print is invoked and the print
    * dialog comes up. If no handle is returned, the print dialog
    * does not come up on this platform.  
    */
    *aSiteWindow = cast(void*) embedHandle;
    return XPCOM.NS_OK;         
}  
 
/* nsIWebBrowserChromeFocus */

extern(System)
nsresult FocusNextElement () {
    /*
    * Bug in Mozilla embedding API.  Mozilla takes back the focus after sending
    * this event.  This prevents tabbing out of Mozilla. This behaviour can be reproduced
    * with the Mozilla application TestGtkEmbed.  The workaround is to
    * send the traversal notification after this callback returns.
    */
    browser.getDisplay ().asyncExec (new class() Runnable {
        public void run () {
            if (browser.isDisposed ()) return;
            browser.traverse (SWT.TRAVERSE_TAB_NEXT);
        }
    });
    return XPCOM.NS_OK;  
}

extern(System)
nsresult FocusPrevElement () {
    /*
    * Bug in Mozilla embedding API.  Mozilla takes back the focus after sending
    * this event.  This prevents tabbing out of Mozilla. This behaviour can be reproduced
    * with the Mozilla application TestGtkEmbed.  The workaround is to
    * send the traversal notification after this callback returns.
    */
    browser.getDisplay ().asyncExec (new class() Runnable {
        public void run () {
            if (browser.isDisposed ()) return;
            browser.traverse (SWT.TRAVERSE_TAB_PREVIOUS);
        }
    });
    return XPCOM.NS_OK;         
}

/* nsIContextMenuListener */

extern(System)
nsresult OnShowContextMenu (PRUint32 aContextFlags, nsIDOMEvent aEvent, nsIDOMNode aNode) {
    if (awaitingNavigate) return XPCOM.NS_OK;

    //nsIDOMEvent domEvent = new nsIDOMEvent (aEvent);
    //ptrdiff_t[] result = new ptrdiff_t[1];
    nsIDOMMouseEvent domMouseEvent;
    int rc = aEvent.QueryInterface (&nsIDOMMouseEvent.IID, cast(void**)&domMouseEvent);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (domMouseEvent is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

    //nsIDOMMouseEvent domMouseEvent = new nsIDOMMouseEvent (result[0]);
    PRInt32 aScreenX, aScreenY;
    rc = domMouseEvent.GetScreenX (&aScreenX);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    rc = domMouseEvent.GetScreenY (&aScreenY);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    domMouseEvent.Release ();
    
    auto event = new Event;
    event.x = aScreenX;
    event.y = aScreenY;
    browser.notifyListeners (SWT.MenuDetect, event);
    if (!event.doit) return XPCOM.NS_OK;
    Menu menu = browser.getMenu ();
    if (menu !is null && !menu.isDisposed ()) {
        if (aScreenX !is event.x || aScreenY !is event.y) {
            menu.setLocation (event.x, event.y);
        }
        menu.setVisible (true);
    }
    return XPCOM.NS_OK;         
}

/* nsIURIContentListener */

extern(System)
nsresult OnStartURIOpen (nsIURI aURI, PRBool* retval) {
    if (awaitingNavigate || locationListeners.length is 0) {
        *retval = 0;
        //XPCOM.memmove (retval, new int[] {0}, 4); /* PRBool */
        return XPCOM.NS_OK;
    }
    //nsIURI location = new nsIURI (aURI);
    scope auto aSpec = new nsEmbedCString;
    aURI.GetSpec (cast(nsACString*)aSpec);
    //int length = XPCOM.nsEmbedCString_Length (aSpec);
    //ptrdiff_t buffer = XPCOM.nsEmbedCString_get (aSpec);
    //buffer = XPCOM.nsEmbedCString_get (aSpec);
    //byte[] dest = new byte[length];
    //XPCOM.memmove (dest, buffer, length);
    //XPCOM.nsEmbedCString_delete (aSpec);
    String value = aSpec.toString;
    bool doit = true;
    if (request is null) {
        /* 
         * listeners should not be notified of internal transitions like "javascipt:..."
         * because this is an implementation side-effect, not a true navigate
         */
        if (!value.startsWith (PREFIX_JAVASCRIPT)) {
            LocationEvent event = new LocationEvent (browser);
            event.display = browser.getDisplay();
            event.widget = browser;
            event.location = value;
            /*
             * If the URI indicates that the page is being rendered from memory
             * (via setText()) then set it to about:blank to be consistent with IE.
             */
            if (event.location.equals (URI_FROMMEMORY)) event.location = ABOUT_BLANK;
            event.doit = doit;
            for (int i = 0; i < locationListeners.length; i++) {
                locationListeners[i].changing (event);
            }
            doit = event.doit && !browser.isDisposed();
        }
    }
    *retval = doit ? 0 : 1;
    //XPCOM.memmove (retval, new int[] {doit ? 0 : 1}, 4); /* PRBool */
    return XPCOM.NS_OK;
}

extern(System)
nsresult DoContent (char* aContentType, PRBool aIsContentPreferred, nsIRequest aRequest, nsIStreamListener* aContentHandler, PRBool* retval) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult IsPreferred (char* aContentType, char** aDesiredContentType, PRBool* retval) {
    bool preferred = false;
    auto size = OS.strlen (aContentType);
    if (size > 0) {
        //byte[] typeBytes = new byte[size + 1];
        //XPCOM.memmove (typeBytes, aContentType, size);
        String contentType = fromStringz(aContentType)._idup();

        /* do not attempt to handle known problematic content types */
        if (!contentType.equals (XPCOM.CONTENT_MAYBETEXT) && !contentType.equals (XPCOM.CONTENT_MULTIPART)) {
            /* determine whether browser can handle the content type */
            // ptrdiff_t[] result = new ptrdiff_t[1];
            nsIServiceManager serviceManager;
            int rc = XPCOM.NS_GetServiceManager (&serviceManager);
            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
            if (serviceManager is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
            //nsIServiceManager serviceManager = new nsIServiceManager (result[0]);
            //result[0] = 0;

            /* First try to use the nsIWebNavigationInfo if it's available (>= mozilla 1.8) */
            //byte[] aContractID = MozillaDelegate.wcsToMbcs (null, XPCOM.NS_WEBNAVIGATIONINFO_CONTRACTID, true);
            nsIWebNavigationInfo info;
            rc = serviceManager.GetServiceByContractID (XPCOM.NS_WEBNAVIGATIONINFO_CONTRACTID.ptr, &nsIWebNavigationInfo.IID, cast(void**)&info);
            if (rc is XPCOM.NS_OK) {
                //byte[] bytes = MozillaDelegate.wcsToMbcs (null, contentType, true);
                scope auto typePtr = new nsEmbedCString(contentType);
                //nsIWebNavigationInfo info = new nsIWebNavigationInfo (result[0]);
                //result[0] = 0;
                PRUint32 isSupportedResult; /* PRUint32 */
                rc = info.IsTypeSupported (cast(nsACString*)typePtr, null, &isSupportedResult);
                if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                info.Release ();
                //XPCOM.nsEmbedCString_delete (typePtr);
                preferred = isSupportedResult !is 0;
            } else {
                /* nsIWebNavigationInfo is not available, so do the type lookup */
                //result[0] = 0;
                nsICategoryManager categoryManager;
                rc = serviceManager.GetService (&XPCOM.NS_CATEGORYMANAGER_CID, &nsICategoryManager.IID, cast(void**)&categoryManager);
                if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                if (categoryManager is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

                //nsICategoryManager categoryManager = new nsICategoryManager (result[0]);
                //result[0] = 0;
                auto categoryBytes = "Gecko-Content-Viewers".ptr; //$NON-NLS-1$
                char* result;
                rc = categoryManager.GetCategoryEntry (categoryBytes, aContentType, &result);
                categoryManager.Release ();
                /* if no viewer for the content type is registered then rc is XPCOM.NS_ERROR_NOT_AVAILABLE */
                preferred = rc is XPCOM.NS_OK;
            }
            serviceManager.Release ();
        }
    }

    *retval = preferred ? 1 : 0; /* PRBool */
    if (preferred) {
        *aDesiredContentType = null;
    }
    return XPCOM.NS_OK;
}

extern(System)
nsresult CanHandleContent (char* aContentType, PRBool aIsContentPreferred, char** aDesiredContentType, PRBool* retval) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetLoadCookie (nsISupports* aLoadCookie) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult SetLoadCookie (nsISupports aLoadCookie) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetParentContentListener (nsIURIContentListener* aParentContentListener) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult SetParentContentListener (nsIURIContentListener aParentContentListener) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

/* nsITooltipListener */

extern(System)
nsresult OnShowTooltip (PRInt32 aXCoords, PRInt32 aYCoords, PRUnichar* aTipText) {
    if (awaitingNavigate) return XPCOM.NS_OK;

    //int length = XPCOM.strlen_PRUnichar (aTipText);
    //char[] dest = new char[length];
    //XPCOM.memmove (dest, aTipText, length * 2);
    String text = String_valueOf(fromString16z(aTipText));
    if (tip !is null && !tip.isDisposed ()) tip.dispose ();
    Display display = browser.getDisplay ();
    Shell parent = browser.getShell ();
    tip = new Shell (parent, SWT.ON_TOP);
    tip.setLayout (new FillLayout());
    Label label = new Label (tip, SWT.CENTER);
    label.setForeground (display.getSystemColor (SWT.COLOR_INFO_FOREGROUND));
    label.setBackground (display.getSystemColor (SWT.COLOR_INFO_BACKGROUND));
    label.setText (text);
    /*
    * Bug in Mozilla embedded API.  Tooltip coordinates are wrong for 
    * elements inside an inline frame (IFrame tag).  The workaround is 
    * to position the tooltip based on the mouse cursor location.
    */
    Point point = display.getCursorLocation ();
    /* Assuming cursor is 21x21 because this is the size of
     * the arrow cursor on Windows
     */ 
    point.y += 21;
    tip.setLocation (point);
    tip.pack ();
    tip.setVisible (true);
    return XPCOM.NS_OK;
}

extern(System)
nsresult OnHideTooltip () {
    if (tip !is null && !tip.isDisposed ()) tip.dispose ();
    tip = null;
    return XPCOM.NS_OK;
}

/* nsIDOMEventListener */

extern(System)
nsresult HandleEvent (nsIDOMEvent event) {
    //nsIDOMEvent domEvent = new nsIDOMEvent (event);

    scope auto type = new nsEmbedString;
    int rc = event.GetType (cast(nsAString*)type);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    //int length = XPCOM.nsEmbedString_Length (type);
    //ptrdiff_t buffer = XPCOM.nsEmbedString_get (type);
    //char[] chars = new char[length];
    //XPCOM.memmove (chars, buffer, length * 2);
    String typeString = type.toString;
    //XPCOM.nsEmbedString_delete (type);

    if (XPCOM.DOMEVENT_UNLOAD.equals (typeString)) {
        //ptrdiff_t[] result = new ptrdiff_t[1];
        nsIDOMEventTarget target;
        rc = event.GetCurrentTarget (&target);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (target is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);

        //nsIDOMEventTarget target = new nsIDOMEventTarget (result[0]);
        unhookDOMListeners (target);
        target.Release ();
        return XPCOM.NS_OK;
    }

    if (XPCOM.DOMEVENT_FOCUS.equals (typeString)) {
        mozDelegate.handleFocus ();
        return XPCOM.NS_OK;
    }

    if (XPCOM.DOMEVENT_KEYDOWN.equals (typeString)) {
        //ptrdiff_t[] result = new ptrdiff_t[1];
        nsIDOMKeyEvent domKeyEvent;
        rc = event.QueryInterface (&nsIDOMKeyEvent.IID, cast(void**)&domKeyEvent);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (domKeyEvent is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        //nsIDOMKeyEvent domKeyEvent = new nsIDOMKeyEvent (result[0]);
        //result[0] = 0;

        PRUint32 aKeyCode; /* PRUint32 */
        rc = domKeyEvent.GetKeyCode (&aKeyCode);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        int keyCode = super.translateKey (aKeyCode);

        /*
        * if keyCode is lastKeyCode then either a repeating key like Shift
        * is being held or a key for which key events are not sent has been
        * pressed.  In both of these cases a KeyDown should not be sent.
        */
        if (keyCode !is lastKeyCode) {
            lastKeyCode = keyCode;
            switch (keyCode) {
                case SWT.SHIFT:
                case SWT.CONTROL:
                case SWT.ALT:
                case SWT.CAPS_LOCK:
                case SWT.NUM_LOCK:
                case SWT.SCROLL_LOCK:
                case SWT.COMMAND: {
                    /* keypress events will not be received for these keys, so send KeyDowns for them now */
                    PRBool aAltKey, aCtrlKey, aShiftKey, aMetaKey; /* PRBool */
                    rc = domKeyEvent.GetAltKey (&aAltKey);
                    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                    rc = domKeyEvent.GetCtrlKey (&aCtrlKey);
                    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                    rc = domKeyEvent.GetShiftKey (&aShiftKey);
                    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                    rc = domKeyEvent.GetMetaKey (&aMetaKey);
                    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);

                    Event keyEvent = new Event ();
                    keyEvent.widget = browser;
                    keyEvent.type = SWT.KeyDown;
                    keyEvent.keyCode = keyCode;
                    keyEvent.stateMask = (aAltKey !is 0 ? SWT.ALT : 0) | (aCtrlKey !is 0 ? SWT.CTRL : 0) | (aShiftKey !is 0 ? SWT.SHIFT : 0) | (aMetaKey !is 0 ? SWT.COMMAND : 0);
                    keyEvent.stateMask &= ~keyCode;     /* remove current keydown if it's a state key */
                    browser.notifyListeners (keyEvent.type, keyEvent);
                    if (!keyEvent.doit) {
                        event.PreventDefault ();
                    }
                    break;
                }
                default: {
                    /* 
                    * If the keydown has Meta (but not Meta+Ctrl) as a modifier then send a KeyDown event for it here
                    * because a corresponding keypress event will not be received for it from the DOM.  If the keydown
                    * does not have Meta as a modifier, or has Meta+Ctrl as a modifier, then then do nothing here
                    * because its KeyDown event will be sent from the keypress listener.
                    */
                    PRBool aMetaKey; /* PRBool */
                    rc = domKeyEvent.GetMetaKey (&aMetaKey);
                    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                    if (aMetaKey !is 0) {
                        PRBool aCtrlKey; /* PRBool */
                        rc = domKeyEvent.GetCtrlKey (&aCtrlKey);
                        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                        if (aCtrlKey is 0) {
                            PRBool aAltKey, aShiftKey; /* PRBool */
                            rc = domKeyEvent.GetAltKey (&aAltKey);
                            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
                            rc = domKeyEvent.GetShiftKey (&aShiftKey);
                            if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);

                            Event keyEvent = new Event ();
                            keyEvent.widget = browser;
                            keyEvent.type = SWT.KeyDown;
                            keyEvent.keyCode = lastKeyCode;
                            keyEvent.stateMask = (aAltKey !is 0 ? SWT.ALT : 0) | (aCtrlKey !is 0? SWT.CTRL : 0) | (aShiftKey !is 0? SWT.SHIFT : 0) | (aMetaKey !is 0? SWT.COMMAND : 0);
                            browser.notifyListeners (keyEvent.type, keyEvent);
                            if (!keyEvent.doit) {
                                event.PreventDefault ();
                            }
                        }
                    }
                }
            }
        }

        domKeyEvent.Release ();
        return XPCOM.NS_OK;
    }

    if (XPCOM.DOMEVENT_KEYPRESS.equals (typeString)) {
        /*
        * if keydown could not determine a keycode for this key then it's a
        * key for which key events are not sent (eg.- the Windows key)
        */
        if (lastKeyCode is 0) return XPCOM.NS_OK;

        /*
        * On linux only, unexpected keypress events are received for some
        * modifier keys.  The workaround is to ignore these events since
        * KeyDown events are sent for these keys in the keydown listener.  
        */
        switch (lastKeyCode) {
            case SWT.CAPS_LOCK:
            case SWT.NUM_LOCK:
            case SWT.SCROLL_LOCK: return XPCOM.NS_OK;
            default: break;
        }

        //ptrdiff_t[] result = new ptrdiff_t[1];
        nsIDOMKeyEvent domKeyEvent;
        rc = event.QueryInterface (&nsIDOMKeyEvent.IID, cast(void**)&domKeyEvent);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (domKeyEvent is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        //nsIDOMKeyEvent domKeyEvent = new nsIDOMKeyEvent (result[0]);
        //result[0] = 0;

        PRBool aAltKey, aCtrlKey, aShiftKey, aMetaKey; /* PRBool */
        rc = domKeyEvent.GetAltKey (&aAltKey);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        rc = domKeyEvent.GetCtrlKey (&aCtrlKey);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        rc = domKeyEvent.GetShiftKey (&aShiftKey);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        rc = domKeyEvent.GetMetaKey (&aMetaKey);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        domKeyEvent.Release ();

        PRUint32 aCharCode; /* PRUint32 */
        rc = domKeyEvent.GetCharCode (&aCharCode);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        lastCharCode = aCharCode;
        if (lastCharCode is 0) {
            switch (lastKeyCode) {
                case SWT.TAB: lastCharCode = SWT.TAB; break;
                case SWT.CR: lastCharCode = SWT.CR; break;
                case SWT.BS: lastCharCode = SWT.BS; break;
                case SWT.ESC: lastCharCode = SWT.ESC; break;
                case SWT.DEL: lastCharCode = SWT.DEL; break;
                default: break;
            }
        }
        if (aCtrlKey !is 0 && (0 <= lastCharCode && lastCharCode <= 0x7F)) {
            if ('a'  <= lastCharCode && lastCharCode <= 'z') lastCharCode -= 'a' - 'A';
            if (64 <= lastCharCode && lastCharCode <= 95) lastCharCode -= 64;
        }

        Event keyEvent = new Event ();
        keyEvent.widget = browser;
        keyEvent.type = SWT.KeyDown;
        keyEvent.keyCode = lastKeyCode;
        keyEvent.character = cast(wchar)lastCharCode;
        keyEvent.stateMask = (aAltKey !is 0 ? SWT.ALT : 0) | (aCtrlKey !is 0 ? SWT.CTRL : 0) | (aShiftKey !is 0 ? SWT.SHIFT : 0) | (aMetaKey !is 0 ? SWT.COMMAND : 0);
        browser.notifyListeners (keyEvent.type, keyEvent);
        if (!keyEvent.doit) {
            event.PreventDefault ();
        }
        return XPCOM.NS_OK;
    }

    if (XPCOM.DOMEVENT_KEYUP.equals (typeString)) {
        //ptrdiff_t[] result = new ptrdiff_t[1];
        nsIDOMKeyEvent domKeyEvent;
        rc = event.QueryInterface (&nsIDOMKeyEvent.IID, cast(void**)&domKeyEvent);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (domKeyEvent is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
        //nsIDOMKeyEvent domKeyEvent = new nsIDOMKeyEvent (result[0]);
        //result[0] = 0;

        PRUint32 aKeyCode; /* PRUint32 */
        rc = domKeyEvent.GetKeyCode (&aKeyCode);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        int keyCode = super.translateKey (aKeyCode);
        if (keyCode is 0) {
            /* indicates a key for which key events are not sent */
            domKeyEvent.Release ();
            return XPCOM.NS_OK;
        }
        if (keyCode !is lastKeyCode) {
            /* keyup does not correspond to the last keydown */
            lastKeyCode = keyCode;
            lastCharCode = 0;
        }

        PRBool aAltKey, aCtrlKey, aShiftKey, aMetaKey; /* PRBool */
        rc = domKeyEvent.GetAltKey (&aAltKey);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        rc = domKeyEvent.GetCtrlKey (&aCtrlKey);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        rc = domKeyEvent.GetShiftKey (&aShiftKey);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        rc = domKeyEvent.GetMetaKey (&aMetaKey);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        domKeyEvent.Release ();

        Event keyEvent = new Event ();
        keyEvent.widget = browser;
        keyEvent.type = SWT.KeyUp;
        keyEvent.keyCode = lastKeyCode;
        keyEvent.character = cast(wchar)lastCharCode;
        keyEvent.stateMask = (aAltKey !is 0 ? SWT.ALT : 0) | (aCtrlKey !is 0 ? SWT.CTRL : 0) | (aShiftKey !is 0 ? SWT.SHIFT : 0) | (aMetaKey !is 0 ? SWT.COMMAND : 0);
        switch (lastKeyCode) {
            case SWT.SHIFT:
            case SWT.CONTROL:
            case SWT.ALT:
            case SWT.COMMAND: {
                keyEvent.stateMask |= lastKeyCode;
            }
            default: break;
        }
        browser.notifyListeners (keyEvent.type, keyEvent);
        if (!keyEvent.doit) {
            event.PreventDefault ();
        }
        lastKeyCode = lastCharCode = 0;
        return XPCOM.NS_OK;
    }

    /* mouse event */

    //ptrdiff_t[] result = new ptrdiff_t[1];
    nsIDOMMouseEvent domMouseEvent;
    rc = event.QueryInterface (&nsIDOMMouseEvent.IID, cast(void**)&domMouseEvent);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    if (domMouseEvent is null) error (XPCOM.NS_NOINTERFACE, __FILE__, __LINE__);
    //nsIDOMMouseEvent domMouseEvent = new nsIDOMMouseEvent (result[0]);
    //result[0] = 0;

    /*
     * MouseOver and MouseOut events are fired any time the mouse enters or exits
     * any element within the Browser.  To ensure that SWT events are only
     * fired for mouse movements into or out of the Browser, do not fire an
     * event if the element being exited (on MouseOver) or entered (on MouseExit)
     * is within the Browser.
     */
    if (XPCOM.DOMEVENT_MOUSEOVER.equals (typeString) || XPCOM.DOMEVENT_MOUSEOUT.equals (typeString)) {
        nsIDOMEventTarget eventTarget;
        rc = domMouseEvent.GetRelatedTarget (&eventTarget);
        if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
        if (eventTarget !is null) {
            domMouseEvent.Release ();
            return XPCOM.NS_OK;
        }
    }

    PRInt32 aClientX, aClientY, aDetail; /* PRInt32 */
    rc = domMouseEvent.GetClientX (&aClientX);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    rc = domMouseEvent.GetClientY (&aClientY);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    rc = domMouseEvent.GetDetail (&aDetail);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    PRUint16 aButton; /* PRUint16 */
    rc = domMouseEvent.GetButton (&aButton);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    PRBool aAltKey, aCtrlKey, aShiftKey, aMetaKey; /* PRBool */
    rc = domMouseEvent.GetAltKey (&aAltKey);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    rc = domMouseEvent.GetCtrlKey (&aCtrlKey);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    rc = domMouseEvent.GetShiftKey (&aShiftKey);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    rc = domMouseEvent.GetMetaKey (&aMetaKey);
    if (rc !is XPCOM.NS_OK) error (rc, __FILE__, __LINE__);
    domMouseEvent.Release ();

    Event mouseEvent = new Event ();
    mouseEvent.widget = browser;
    mouseEvent.x = aClientX; mouseEvent.y = aClientY;
    mouseEvent.stateMask = (aAltKey !is 0 ? SWT.ALT : 0) | (aCtrlKey !is 0 ? SWT.CTRL : 0) | (aShiftKey !is 0 ? SWT.SHIFT : 0) | (aMetaKey !is 0 ? SWT.COMMAND : 0);

    if (XPCOM.DOMEVENT_MOUSEDOWN.equals (typeString)) {
        mozDelegate.handleMouseDown ();
        mouseEvent.type = SWT.MouseDown;
        mouseEvent.button = aButton + 1;
        mouseEvent.count = aDetail;
    } else if (XPCOM.DOMEVENT_MOUSEUP.equals (typeString)) {
        /*
         * Bug on OSX.  For some reason multiple mouseup events come from the DOM
         * when button 3 is released on OSX.  The first of these events has a count
         * detail and the others do not.  The workaround is to not fire received
         * button 3 mouseup events that do not have a count since mouse events
         * without a click count are not valid.
         */
        int button = aButton + 1;
        int count = aDetail;
        if (count is 0 && button is 3) return XPCOM.NS_OK;
        mouseEvent.type = SWT.MouseUp;
        mouseEvent.button = button;
        mouseEvent.count = count;
    } else if (XPCOM.DOMEVENT_MOUSEMOVE.equals (typeString)) {
        mouseEvent.type = SWT.MouseMove;
    } else if (XPCOM.DOMEVENT_MOUSEWHEEL.equals (typeString)) {
        mouseEvent.type = SWT.MouseWheel;
        mouseEvent.count = -aDetail;
    } else if (XPCOM.DOMEVENT_MOUSEOVER.equals (typeString)) {
        mouseEvent.type = SWT.MouseEnter;
    } else if (XPCOM.DOMEVENT_MOUSEOUT.equals (typeString)) {
        mouseEvent.type = SWT.MouseExit;
    } else if (XPCOM.DOMEVENT_MOUSEDRAG.equals (typeString)) {
        mouseEvent.type = SWT.DragDetect;
        mouseEvent.button = aButton + 1;
        switch (mouseEvent.button) {
            case 1: mouseEvent.stateMask |= SWT.BUTTON1; break;
            case 2: mouseEvent.stateMask |= SWT.BUTTON2; break;
            case 3: mouseEvent.stateMask |= SWT.BUTTON3; break;
            case 4: mouseEvent.stateMask |= SWT.BUTTON4; break;
            case 5: mouseEvent.stateMask |= SWT.BUTTON5; break;
            default: break;
        }
    }

    browser.notifyListeners (mouseEvent.type, mouseEvent);
    if (aDetail is 2 && XPCOM.DOMEVENT_MOUSEDOWN.equals (typeString)) {
        mouseEvent = new Event ();
        mouseEvent.widget = browser;
        mouseEvent.x = aClientX; mouseEvent.y = aClientY;
        mouseEvent.stateMask = (aAltKey !is 0 ? SWT.ALT : 0) | (aCtrlKey !is 0 ? SWT.CTRL : 0) | (aShiftKey !is 0 ? SWT.SHIFT : 0) | (aMetaKey !is 0 ? SWT.COMMAND : 0);
        mouseEvent.type = SWT.MouseDoubleClick;
        mouseEvent.button = aButton + 1;
        mouseEvent.count = aDetail;
        browser.notifyListeners (mouseEvent.type, mouseEvent);  
    }
    return XPCOM.NS_OK;
}
}
