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
module org.eclipse.swt.accessibility.Accessible;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.ole.win32.COM;
import org.eclipse.swt.internal.ole.win32.OAIDL;
import org.eclipse.swt.internal.ole.win32.ifs;
import org.eclipse.swt.internal.ole.win32.extras;
import org.eclipse.swt.internal.win32.OS;
import org.eclipse.swt.internal.SWTEventListener;
import org.eclipse.swt.ole.win32.OLE;
import org.eclipse.swt.ole.win32.Variant;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableItem;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.swt.widgets.TreeItem;
import org.eclipse.swt.widgets.Widget;

import org.eclipse.swt.accessibility.ACC;
import org.eclipse.swt.accessibility.AccessibleControlListener;
import org.eclipse.swt.accessibility.AccessibleListener;
import org.eclipse.swt.accessibility.AccessibleTextListener;
import org.eclipse.swt.accessibility.AccessibleControlEvent;
import org.eclipse.swt.accessibility.AccessibleEvent;

import java.lang.all;
import java.util.Vector;
import java.lang.Thread;

/**
 * Instances of this class provide a bridge between application
 * code and assistive technology clients. Many platforms provide
 * default accessible behavior for most widgets, and this class
 * allows that default behavior to be overridden. Applications
 * can get the default Accessible object for a control by sending
 * it <code>getAccessible</code>, and then add an accessible listener
 * to override simple items like the name and help string, or they
 * can add an accessible control listener to override complex items.
 * As a rule of thumb, an application would only want to use the
 * accessible control listener to implement accessibility for a
 * custom control.
 *
 * @see Control#getAccessible
 * @see AccessibleListener
 * @see AccessibleEvent
 * @see AccessibleControlListener
 * @see AccessibleControlEvent
 * @see <a href="http://www.eclipse.org/swt/snippets/#accessibility">Accessibility snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 2.0
 */
public class Accessible {
    int refCount = 0, enumIndex = 0;
    _IAccessibleImpl objIAccessible;
    _IEnumVARIANTImpl objIEnumVARIANT;
    IAccessible iaccessible;
    Vector accessibleListeners;
    Vector accessibleControlListeners;
    Vector textListeners;
    Object[] variants;
    Control control;

    this(Control control) {
        accessibleListeners = new Vector();
        accessibleControlListeners = new Vector();
        textListeners = new Vector ();
        this.control = control;
        ptrdiff_t [] ppvObject = new ptrdiff_t [1];
        /* CreateStdAccessibleObject([in] hwnd, [in] idObject, [in] riidInterface, [out] ppvObject).
         * AddRef has already been called on ppvObject by the callee and must be released by the caller.
         */
        HRESULT result = COM.CreateStdAccessibleObject(control.handle, COM.OBJID_CLIENT, &COM.IIDIAccessible, cast(void**)&iaccessible);
        /* The object needs to be checked, because if the CreateStdAccessibleObject()
         * symbol is not found, the return value is S_OK.
         */
        if (iaccessible is null) return;
        if (result !is COM.S_OK) OLE.error(OLE.ERROR_CANNOT_CREATE_OBJECT, result);

        objIAccessible = new _IAccessibleImpl(this);

//PORTING_FIXME: i don't understand this...
/+
        ptrdiff_t ppVtable = objIAccessible.ppVtable;
        ptrdiff_t [] pVtable = new ptrdiff_t [1];
        COM.MoveMemory(pVtable, ppVtable, OS.PTR_SIZEOF);
        ptrdiff_t [] funcs = new ptrdiff_t [28];
        COM.MoveMemory(funcs, pVtable[0], OS.PTR_SIZEOF * funcs.length);
        funcs[9] = COM.get_accChild_CALLBACK(funcs[9]);
        funcs[10] = COM.get_accName_CALLBACK(funcs[10]);
        funcs[11] = COM.get_accValue_CALLBACK(funcs[11]);
        funcs[12] = COM.get_accDescription_CALLBACK(funcs[12]);
        funcs[13] = COM.get_accRole_CALLBACK(funcs[13]);
        funcs[14] = COM.get_accState_CALLBACK(funcs[14]);
        funcs[15] = COM.get_accHelp_CALLBACK(funcs[15]);
        funcs[16] = COM.get_accHelpTopic_CALLBACK(funcs[16]);
        funcs[17] = COM.get_accKeyboardShortcut_CALLBACK(funcs[17]);
        funcs[20] = COM.get_accDefaultAction_CALLBACK(funcs[20]);
        funcs[21] = COM.accSelect_CALLBACK(funcs[21]);
        funcs[22] = COM.accLocation_CALLBACK(funcs[22]);
        funcs[23] = COM.accNavigate_CALLBACK(funcs[23]);
        funcs[25] = COM.accDoDefaultAction_CALLBACK(funcs[25]);
        funcs[26] = COM.put_accName_CALLBACK(funcs[26]);
        funcs[27] = COM.put_accValue_CALLBACK(funcs[27]);
        COM.MoveMemory(pVtable[0], funcs, OS.PTR_SIZEOF * funcs.length);
+/

        objIEnumVARIANT = new _IEnumVARIANTImpl(this) ;
        AddRef();
    }

    /**
     * Invokes platform specific functionality to allocate a new accessible object.
     * <p>
     * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
     * API for <code>Accessible</code>. It is marked public only so that it
     * can be shared within the packages provided by SWT. It is not
     * available on all platforms, and should never be called from
     * application code.
     * </p>
     *
     * @param control the control to get the accessible object for
     * @return the platform specific accessible object
     */
    public static Accessible internal_new_Accessible(Control control) {
        return new Accessible(control);
    }

    /**
     * Adds the listener to the collection of listeners who will
     * be notified when an accessible client asks for certain strings,
     * such as name, description, help, or keyboard shortcut. The
     * listener is notified by sending it one of the messages defined
     * in the <code>AccessibleListener</code> interface.
     *
     * @param listener the listener that should be notified when the receiver
     * is asked for a name, description, help, or keyboard shortcut string
     *
     * @exception IllegalArgumentException <ul>
     *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
     * </ul>
     * @exception SWTException <ul>
     *    <li>ERROR_WIDGET_DISPOSED - if the receiver's control has been disposed</li>
     *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver's control</li>
     * </ul>
     *
     * @see AccessibleListener
     * @see #removeAccessibleListener
     */
    public void addAccessibleListener(AccessibleListener listener) {
        checkWidget();
        if (listener is null) SWT.error(__FILE__, __LINE__, SWT.ERROR_NULL_ARGUMENT);
        accessibleListeners.addElement(cast(Object)listener);
    }

    /**
     * Adds the listener to the collection of listeners who will
     * be notified when an accessible client asks for custom control
     * specific information. The listener is notified by sending it
     * one of the messages defined in the <code>AccessibleControlListener</code>
     * interface.
     *
     * @param listener the listener that should be notified when the receiver
     * is asked for custom control specific information
     *
     * @exception IllegalArgumentException <ul>
     *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
     * </ul>
     * @exception SWTException <ul>
     *    <li>ERROR_WIDGET_DISPOSED - if the receiver's control has been disposed</li>
     *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver's control</li>
     * </ul>
     *
     * @see AccessibleControlListener
     * @see #removeAccessibleControlListener
     */
    public void addAccessibleControlListener(AccessibleControlListener listener) {
        checkWidget();
        if (listener is null) SWT.error(__FILE__, __LINE__, SWT.ERROR_NULL_ARGUMENT);
        accessibleControlListeners.addElement(cast(Object)listener);
    }

    /**
     * Adds the listener to the collection of listeners who will
     * be notified when an accessible client asks for custom text control
     * specific information. The listener is notified by sending it
     * one of the messages defined in the <code>AccessibleTextListener</code>
     * interface.
     *
     * @param listener the listener that should be notified when the receiver
     * is asked for custom text control specific information
     *
     * @exception IllegalArgumentException <ul>
     *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
     * </ul>
     * @exception SWTException <ul>
     *    <li>ERROR_WIDGET_DISPOSED - if the receiver's control has been disposed</li>
     *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver's control</li>
     * </ul>
     *
     * @see AccessibleTextListener
     * @see #removeAccessibleTextListener
     *
     * @since 3.0
     */
    public void addAccessibleTextListener (AccessibleTextListener listener) {
        checkWidget ();
        if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
        textListeners.addElement(cast(Object)listener);
    }

    /**
     * Returns the control for this Accessible object.
     *
     * @return the receiver's control
     * @since 3.0
     */
    public Control getControl() {
        return control;
    }

    /**
     * Invokes platform specific functionality to dispose an accessible object.
     * <p>
     * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
     * API for <code>Accessible</code>. It is marked public only so that it
     * can be shared within the packages provided by SWT. It is not
     * available on all platforms, and should never be called from
     * application code.
     * </p>
     */
    public void internal_dispose_Accessible() {
        if (iaccessible !is null) {
            iaccessible.Release();
        }
        iaccessible = null;
        Release();
    }

    /**
     * Invokes platform specific functionality to handle a window message.
     * <p>
     * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
     * API for <code>Accessible</code>. It is marked public only so that it
     * can be shared within the packages provided by SWT. It is not
     * available on all platforms, and should never be called from
     * application code.
     * </p>
     */
    public ptrdiff_t internal_WM_GETOBJECT (WPARAM wParam, LPARAM lParam) {
        if (objIAccessible is null) return 0;
        if (lParam is COM.OBJID_CLIENT) {
            /* LresultFromObject([in] riid, [in] wParam, [in] pAcc)
             * The argument pAcc is owned by the caller so reference count does not
             * need to be incremented.
             */
            return COM.LresultFromObject(&COM.IIDIAccessible, wParam, cast(IAccessible)objIAccessible);
        }
        return 0;
    }

    /**
     * Removes the listener from the collection of listeners who will
     * be notified when an accessible client asks for certain strings,
     * such as name, description, help, or keyboard shortcut.
     *
     * @param listener the listener that should no longer be notified when the receiver
     * is asked for a name, description, help, or keyboard shortcut string
     *
     * @exception IllegalArgumentException <ul>
     *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
     * </ul>
     * @exception SWTException <ul>
     *    <li>ERROR_WIDGET_DISPOSED - if the receiver's control has been disposed</li>
     *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver's control</li>
     * </ul>
     *
     * @see AccessibleListener
     * @see #addAccessibleListener
     */
    public void removeAccessibleListener(AccessibleListener listener) {
        checkWidget();
        if (listener is null) SWT.error(__FILE__, __LINE__, SWT.ERROR_NULL_ARGUMENT);
        accessibleListeners.removeElement(cast(Object)listener);
    }

    /**
     * Removes the listener from the collection of listeners who will
     * be notified when an accessible client asks for custom control
     * specific information.
     *
     * @param listener the listener that should no longer be notified when the receiver
     * is asked for custom control specific information
     *
     * @exception IllegalArgumentException <ul>
     *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
     * </ul>
     * @exception SWTException <ul>
     *    <li>ERROR_WIDGET_DISPOSED - if the receiver's control has been disposed</li>
     *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver's control</li>
     * </ul>
     *
     * @see AccessibleControlListener
     * @see #addAccessibleControlListener
     */
    public void removeAccessibleControlListener(AccessibleControlListener listener) {
        checkWidget();
        if (listener is null) SWT.error(__FILE__, __LINE__, SWT.ERROR_NULL_ARGUMENT);
        accessibleControlListeners.removeElement(cast(Object)listener);
    }

    /**
     * Removes the listener from the collection of listeners who will
     * be notified when an accessible client asks for custom text control
     * specific information.
     *
     * @param listener the listener that should no longer be notified when the receiver
     * is asked for custom text control specific information
     *
     * @exception IllegalArgumentException <ul>
     *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
     * </ul>
     * @exception SWTException <ul>
     *    <li>ERROR_WIDGET_DISPOSED - if the receiver's control has been disposed</li>
     *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver's control</li>
     * </ul>
     *
     * @see AccessibleTextListener
     * @see #addAccessibleTextListener
     *
     * @since 3.0
     */
    public void removeAccessibleTextListener (AccessibleTextListener listener) {
        checkWidget ();
        if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
        textListeners.removeElement (cast(Object)listener);
    }

    /**
     * Sends a message to accessible clients that the child selection
     * within a custom container control has changed.
     *
     * @exception SWTException <ul>
     *    <li>ERROR_WIDGET_DISPOSED - if the receiver's control has been disposed</li>
     *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver's control</li>
     * </ul>
     *
     * @since 3.0
     */
    public void selectionChanged () {
        checkWidget();
        COM.NotifyWinEvent (COM.EVENT_OBJECT_SELECTIONWITHIN, control.handle, COM.OBJID_CLIENT, COM.CHILDID_SELF);
    }

    /**
     * Sends a message to accessible clients indicating that the focus
     * has changed within a custom control.
     *
     * @param childID an identifier specifying a child of the control
     *
     * @exception SWTException <ul>
     *    <li>ERROR_WIDGET_DISPOSED - if the receiver's control has been disposed</li>
     *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver's control</li>
     * </ul>
     */
    public void setFocus(int childID) {
        checkWidget();
        COM.NotifyWinEvent (COM.EVENT_OBJECT_FOCUS, control.handle, COM.OBJID_CLIENT, childIDToOs(childID));
    }

    /**
     * Sends a message to accessible clients that the text
     * caret has moved within a custom control.
     *
     * @param index the new caret index within the control
     *
     * @exception SWTException <ul>
     *    <li>ERROR_WIDGET_DISPOSED - if the receiver's control has been disposed</li>
     *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver's control</li>
     * </ul>
     *
     * @since 3.0
     */
    public void textCaretMoved (int index) {
        checkWidget();
        COM.NotifyWinEvent (COM.EVENT_OBJECT_LOCATIONCHANGE, control.handle, COM.OBJID_CARET, COM.CHILDID_SELF);
    }

    /**
     * Sends a message to accessible clients that the text
     * within a custom control has changed.
     *
     * @param type the type of change, one of <code>ACC.NOTIFY_TEXT_INSERT</code>
     * or <code>ACC.NOTIFY_TEXT_DELETE</code>
     * @param startIndex the text index within the control where the insertion or deletion begins
     * @param length the non-negative length in characters of the insertion or deletion
     *
     * @exception SWTException <ul>
     *    <li>ERROR_WIDGET_DISPOSED - if the receiver's control has been disposed</li>
     *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver's control</li>
     * </ul>
     *
     * @see ACC#TEXT_INSERT
     * @see ACC#TEXT_DELETE
     *
     * @since 3.0
     */
    public void textChanged (int type, int startIndex, int length) {
        checkWidget();
        COM.NotifyWinEvent (COM.EVENT_OBJECT_VALUECHANGE, control.handle, COM.OBJID_CLIENT, COM.CHILDID_SELF);
    }

    /**
     * Sends a message to accessible clients that the text
     * selection has changed within a custom control.
     *
     * @exception SWTException <ul>
     *    <li>ERROR_WIDGET_DISPOSED - if the receiver's control has been disposed</li>
     *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver's control</li>
     * </ul>
     *
     * @since 3.0
     */
    public void textSelectionChanged () {
        checkWidget();
        // not an MSAA event
    }

    /* QueryInterface([in] iid, [out] ppvObject)
     * Ownership of ppvObject transfers from callee to caller so reference count on ppvObject
     * must be incremented before returning.  Caller is responsible for releasing ppvObject.
     */
    HRESULT QueryInterface(REFCIID riid, void** ppvObject) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;

        if (COM.IsEqualGUID(riid, &COM.IIDIUnknown)) {
            *ppvObject = cast(void*)cast(IUnknown)  objIAccessible;
            AddRef();
            return COM.S_OK;
        }

        if (COM.IsEqualGUID(riid, &COM.IIDIDispatch)) {
            *ppvObject = cast(void*)cast(IDispatch) objIAccessible;
            AddRef();
            return COM.S_OK;
        }

        if (COM.IsEqualGUID(riid, &COM.IIDIAccessible)) {
            *ppvObject = cast(void*)cast(IAccessible) objIAccessible;
            AddRef();
            return COM.S_OK;
        }

        if (COM.IsEqualGUID(riid, &COM.IIDIEnumVARIANT)) {
            *ppvObject = cast(void*)cast(IEnumVARIANT) objIEnumVARIANT;
            AddRef();
            enumIndex = 0;
            return COM.S_OK;
        }

        HRESULT result = iaccessible.QueryInterface(riid, ppvObject);
        return result;
    }

    ULONG AddRef() {
        refCount++;
        return refCount;
    }

    ULONG Release() {
        refCount--;

        if (refCount is 0) {
            objIAccessible = null;
            objIEnumVARIANT = null;
        }
        return refCount;
    }

    HRESULT accDoDefaultAction(VARIANT variant) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;
        // Currently, we don't let the application override this. Forward to the proxy.
        int code = iaccessible.accDoDefaultAction(variant);
        if (code is COM.E_INVALIDARG) code = COM.S_FALSE; // proxy doesn't know about app childID
        return code;
    }

    HRESULT accHitTest(LONG xLeft, LONG yTop, VARIANT* pvarChild) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;
        if (accessibleControlListeners.size() is 0) {
            return iaccessible.accHitTest(xLeft, yTop, pvarChild);
        }

        AccessibleControlEvent event = new AccessibleControlEvent(this);
        event.childID = ACC.CHILDID_NONE;
        event.x = xLeft;
        event.y = yTop;
        for (int i = 0; i < accessibleControlListeners.size(); i++) {
            AccessibleControlListener listener = cast(AccessibleControlListener) accessibleControlListeners.elementAt(i);
            listener.getChildAtPoint(event);
        }
        int childID = event.childID;
        if (childID is ACC.CHILDID_NONE) {
            return iaccessible.accHitTest(xLeft, yTop, pvarChild);
        }
        //TODO - use VARIANT structure
        pvarChild.vt = COM.VT_I4;
        pvarChild.lVal = childIDToOs(childID);
        return COM.S_OK;
    }

    HRESULT accLocation(LONG* pxLeft, LONG* pyTop, LONG* pcxWidth, LONG* pcyHeight, VARIANT variant) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;
        VARIANT* v = &variant;
        //COM.MoveMemory(v, variant, VARIANT.sizeof);
        if ((v.vt & 0xFFFF) !is COM.VT_I4) return COM.E_INVALIDARG;

        /* Get the default location from the OS. */
        int osLeft = 0, osTop = 0, osWidth = 0, osHeight = 0;
        int code = iaccessible.accLocation(pxLeft, pyTop, pcxWidth, pcyHeight, variant);
        if (code is COM.E_INVALIDARG) code = COM.S_FALSE; // proxy doesn't know about app childID
        if (accessibleControlListeners.size() is 0) return code;
        if (code is COM.S_OK) {
            int[1] pLeft, pTop, pWidth, pHeight;
            COM.MoveMemory(pLeft.ptr, pxLeft, 4);
            COM.MoveMemory(pTop.ptr, pyTop, 4);
            COM.MoveMemory(pWidth.ptr, pcxWidth, 4);
            COM.MoveMemory(pHeight.ptr, pcyHeight, 4);
            osLeft = pLeft[0]; osTop = pTop[0]; osWidth = pWidth[0]; osHeight = pHeight[0];
        }

        AccessibleControlEvent event = new AccessibleControlEvent(this);
        event.childID = osToChildID(v.lVal);
        event.x = osLeft;
        event.y = osTop;
        event.width = osWidth;
        event.height = osHeight;
        for (int i = 0; i < accessibleControlListeners.size(); i++) {
            AccessibleControlListener listener = cast(AccessibleControlListener) accessibleControlListeners.elementAt(i);
            listener.getLocation(event);
        }
        OS.MoveMemory(pxLeft, &event.x, 4);
        OS.MoveMemory(pyTop, &event.y, 4);
        OS.MoveMemory(pcxWidth, &event.width, 4);
        OS.MoveMemory(pcyHeight, &event.height, 4);
        return COM.S_OK;
    }

    HRESULT accNavigate(LONG navDir, VARIANT variant, VARIANT* pvarEndUpAt) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;
        // Currently, we don't let the application override this. Forward to the proxy.
        int code = iaccessible.accNavigate(navDir, variant, pvarEndUpAt);
        if (code is COM.E_INVALIDARG) code = COM.S_FALSE; // proxy doesn't know about app childID
        return code;
    }

    HRESULT accSelect(LONG flagsSelect, VARIANT variant) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;
        // Currently, we don't let the application override this. Forward to the proxy.
        int code = iaccessible.accSelect(flagsSelect, variant);
        if (code is COM.E_INVALIDARG) code = COM.S_FALSE; // proxy doesn't know about app childID
        return code;
    }

    /* get_accChild([in] varChild, [out] ppdispChild)
     * Ownership of ppdispChild transfers from callee to caller so reference count on ppdispChild
     * must be incremented before returning.  The caller is responsible for releasing ppdispChild.
     */
    HRESULT get_accChild(VARIANT variant, LPDISPATCH* ppdispChild) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;
        VARIANT* v = &variant;
        //COM.MoveMemory(v, variant, VARIANT.sizeof);
        if ((v.vt & 0xFFFF) !is COM.VT_I4) return COM.E_INVALIDARG;
        if (accessibleControlListeners.size() is 0) {
            int code = iaccessible.get_accChild(variant, ppdispChild);
            if (code is COM.E_INVALIDARG) code = COM.S_FALSE; // proxy doesn't know about app childID
            return code;
        }

        AccessibleControlEvent event = new AccessibleControlEvent(this);
        event.childID = osToChildID(v.lVal);
        for (int i = 0; i < accessibleControlListeners.size(); i++) {
            AccessibleControlListener listener = cast(AccessibleControlListener) accessibleControlListeners.elementAt(i);
            listener.getChild(event);
        }
        Accessible accessible = event.accessible;
        if (accessible !is null) {
            accessible.AddRef();
            *ppdispChild = accessible.objIAccessible;
            return COM.S_OK;
        }
        return COM.S_FALSE;
    }

    HRESULT get_accChildCount(LONG* pcountChildren) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;

        /* Get the default child count from the OS. */
        int osChildCount = 0;
        int code = iaccessible.get_accChildCount(pcountChildren);
        if (accessibleControlListeners.size() is 0) return code;
        if (code is COM.S_OK) {
            int[1] pChildCount;
            COM.MoveMemory(pChildCount.ptr, pcountChildren, 4);
            osChildCount = pChildCount[0];
        }

        AccessibleControlEvent event = new AccessibleControlEvent(this);
        event.childID = ACC.CHILDID_SELF;
        event.detail = osChildCount;
        for (int i = 0; i < accessibleControlListeners.size(); i++) {
            AccessibleControlListener listener = cast(AccessibleControlListener) accessibleControlListeners.elementAt(i);
            listener.getChildCount(event);
        }

        *pcountChildren = event.detail;
        return COM.S_OK;
    }

    HRESULT get_accDefaultAction(VARIANT variant, BSTR* pszDefaultAction) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;
        VARIANT* v = &variant;
        //COM.MoveMemory(v, variant, VARIANT.sizeof);
        if ((v.vt & 0xFFFF) !is COM.VT_I4) return COM.E_INVALIDARG;

        /* Get the default defaultAction from the OS. */
        String osDefaultAction = null;
        int code = iaccessible.get_accDefaultAction(variant, pszDefaultAction);
        if (code is COM.E_INVALIDARG) code = COM.S_FALSE; // proxy doesn't know about app childID
        if (accessibleControlListeners.size() is 0) return code;
        if (code is COM.S_OK) {
            osDefaultAction = BSTRToStr( *pszDefaultAction, true );
        }

        AccessibleControlEvent event = new AccessibleControlEvent(this);
        event.childID = osToChildID(v.lVal);
        event.result = osDefaultAction;
        for (int i = 0; i < accessibleControlListeners.size(); i++) {
            AccessibleControlListener listener = cast(AccessibleControlListener) accessibleControlListeners.elementAt(i);
            listener.getDefaultAction(event);
        }
        if (event.result is null) return code;
        auto ptr = COM.SysAllocString(StrToWCHARz(event.result));
        *pszDefaultAction = ptr;
        return COM.S_OK;
    }

    HRESULT get_accDescription(VARIANT variant, BSTR* pszDescription) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;
        VARIANT* v = &variant;
        //COM.MoveMemory(v, variant, VARIANT.sizeof);
        if ((v.vt & 0xFFFF) !is COM.VT_I4) return COM.E_INVALIDARG;

        /* Get the default description from the OS. */
        String osDescription = null;
        int code = iaccessible.get_accDescription(variant, pszDescription);
        if (code is COM.E_INVALIDARG) code = COM.S_FALSE; // proxy doesn't know about app childID
        // TEMPORARY CODE - process tree even if there are no apps listening
        if (accessibleListeners.size() is 0 && !( null is cast(Tree)control )) return code;
        if (code is COM.S_OK) {
            int size = COM.SysStringByteLen(*pszDescription);
            if (size > 0) {
                size = (size + 1) /2;
                osDescription = WCHARzToStr(*pszDescription, size);
            }
        }

        AccessibleEvent event = new AccessibleEvent(this);
        event.childID = osToChildID(v.lVal);
        event.result = osDescription;

        // TEMPORARY CODE
        /* Currently our tree columns are emulated using custom draw,
         * so we need to create the description using the tree column
         * header text and tree item text. */
        if (v.lVal !is COM.CHILDID_SELF) {
            if (auto tree = cast(Tree)control ) {
                int columnCount = tree.getColumnCount ();
                if (columnCount > 1) {
                    HWND hwnd = control.handle;
                    ptrdiff_t hItem;
                    if (OS.COMCTL32_MAJOR >= 6) {
                        hItem = OS.SendMessage (hwnd, OS.TVM_MAPACCIDTOHTREEITEM, v.lVal, 0);
                    } else {
                        hItem = v.lVal;
                    }
                    Widget widget = tree.getDisplay ().findWidget (hwnd, hItem);
                    event.result = "";
                    if (widget !is null ) if( auto item = cast(TreeItem) widget ) {
                        for (int i = 1; i < columnCount; i++) {
                            event.result ~= tree.getColumn(i).getText() ~ ": " ~ item.getText(i);
                            if (i + 1 < columnCount) event.result ~= ", ";
                        }
                    }
                }
            }
        }
        for (int i = 0; i < accessibleListeners.size(); i++) {
            AccessibleListener listener = cast(AccessibleListener) accessibleListeners.elementAt(i);
            listener.getDescription(event);
        }
        if (event.result is null) return code;
        auto ptr = COM.SysAllocString(StrToWCHARz(event.result));
        *pszDescription = ptr;
        return COM.S_OK;
    }

    /* get_accFocus([out] int pvarChild)
     * Ownership of pvarChild transfers from callee to caller so reference count on pvarChild
     * must be incremented before returning.  The caller is responsible for releasing pvarChild.
     */
    HRESULT get_accFocus(VARIANT* pvarChild) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;

        /* Get the default focus child from the OS. */
        int osChild = ACC.CHILDID_NONE;
        int code = iaccessible.get_accFocus(pvarChild);
        if (accessibleControlListeners.size() is 0) return code;
        if (code is COM.S_OK) {
            //TODO - use VARIANT structure
            short[1] pvt;
            COM.MoveMemory(pvt.ptr, pvarChild, 2);
            if (pvt[0] is COM.VT_I4) {
                int[1] pChild;
                COM.MoveMemory(pChild.ptr, pvarChild + 8, 4);
                osChild = osToChildID(pChild[0]);
            }
        }

        AccessibleControlEvent event = new AccessibleControlEvent(this);
        event.childID = osChild;
        for (int i = 0; i < accessibleControlListeners.size(); i++) {
            AccessibleControlListener listener = cast(AccessibleControlListener) accessibleControlListeners.elementAt(i);
            listener.getFocus(event);
        }
        Accessible accessible = event.accessible;
        if (accessible !is null) {
            accessible.AddRef();
            pvarChild.vt = COM.VT_DISPATCH;
            pvarChild.byRef = cast(void*)cast(IDispatch)accessible.objIAccessible;
            return COM.S_OK;
        }
        int childID = event.childID;
        if (childID is ACC.CHILDID_NONE) {
            pvarChild.vt = COM.VT_EMPTY;
            return COM.S_FALSE;
        }
        if (childID is ACC.CHILDID_SELF) {
            AddRef();
            pvarChild.vt = COM.VT_DISPATCH;
            pvarChild.byRef = cast(void*)cast(IDispatch)objIAccessible;
            return COM.S_OK;
        }
        pvarChild.vt = COM.VT_I4;
        pvarChild.lVal = childIDToOs(childID);
        return COM.S_OK;
    }

    HRESULT get_accHelp(VARIANT variant, BSTR* pszHelp) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;
        VARIANT* v = &variant;
        //COM.MoveMemory(v, variant, VARIANT.sizeof);
        if ((v.vt & 0xFFFF) !is COM.VT_I4) return COM.E_INVALIDARG;

        /* Get the default help string from the OS. */
        String osHelp = null;
        int code = iaccessible.get_accHelp(variant, pszHelp);
        if (code is COM.E_INVALIDARG) code = COM.S_FALSE; // proxy doesn't know about app childID
        if (accessibleListeners.size() is 0) return code;
        if (code is COM.S_OK) {
            // the original SysString is clearuped and bstr set to null
            osHelp = BSTRToStr(*pszHelp, true);
        }

        AccessibleEvent event = new AccessibleEvent(this);
        event.childID = osToChildID(v.lVal);
        event.result = osHelp;
        for (int i = 0; i < accessibleListeners.size(); i++) {
            AccessibleListener listener = cast(AccessibleListener) accessibleListeners.elementAt(i);
            listener.getHelp(event);
        }
        if (event.result is null) return code;
        auto ptr = COM.SysAllocString(StrToWCHARz(event.result));
        *pszHelp = ptr;
        return COM.S_OK;
    }

    HRESULT get_accHelpTopic(BSTR* pszHelpFile, VARIANT variant, LONG* pidTopic) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;
        // Currently, we don't let the application override this. Forward to the proxy.
        int code = iaccessible.get_accHelpTopic(pszHelpFile, variant, pidTopic);
        if (code is COM.E_INVALIDARG) code = COM.S_FALSE; // proxy doesn't know about app childID
        return code;
    }

    HRESULT get_accKeyboardShortcut(VARIANT variant, BSTR* pszKeyboardShortcut) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;
        VARIANT* v = &variant;
        //COM.MoveMemory(v, variant, VARIANT.sizeof);
        if ((v.vt & 0xFFFF) !is COM.VT_I4) return COM.E_INVALIDARG;

        /* Get the default keyboard shortcut from the OS. */
        String osKeyboardShortcut = null;
        int code = iaccessible.get_accKeyboardShortcut(variant, pszKeyboardShortcut);
        if (code is COM.E_INVALIDARG) code = COM.S_FALSE; // proxy doesn't know about app childID
        if (accessibleListeners.size() is 0) return code;
        if (code is COM.S_OK) {
            // the original SysString is clearuped and bstr set to null
            osKeyboardShortcut = BSTRToStr(*pszKeyboardShortcut, true);
        }

        AccessibleEvent event = new AccessibleEvent(this);
        event.childID = osToChildID(v.lVal);
        event.result = osKeyboardShortcut;
        for (int i = 0; i < accessibleListeners.size(); i++) {
            AccessibleListener listener = cast(AccessibleListener) accessibleListeners.elementAt(i);
            listener.getKeyboardShortcut(event);
        }
        if (event.result is null) return code;
        auto ptr = COM.SysAllocString(StrToWCHARz(event.result));
        *pszKeyboardShortcut = ptr;
        return COM.S_OK;
    }

    HRESULT get_accName(VARIANT variant, BSTR* pszName) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;
        VARIANT* v = &variant;
        //COM.MoveMemory(v, variant, VARIANT.sizeof);
        if ((v.vt & 0xFFFF) !is COM.VT_I4) return COM.E_INVALIDARG;

        /* Get the default name from the OS. */
        String osName = null;
        int code = iaccessible.get_accName(variant, pszName);
        if (code is COM.E_INVALIDARG) code = COM.S_FALSE; // proxy doesn't know about app childID
        if (accessibleListeners.size() is 0) return code;
        if (code is COM.S_OK) {
            // the original SysString is clearuped and bstr set to null
            osName = BSTRToStr(*pszName, true);
        }

        AccessibleEvent event = new AccessibleEvent(this);
        event.childID = osToChildID(v.lVal);
        event.result = osName;
        for (int i = 0; i < accessibleListeners.size(); i++) {
            AccessibleListener listener = cast(AccessibleListener) accessibleListeners.elementAt(i);
            listener.getName(event);
        }
        if (event.result is null) return code;
        auto ptr = COM.SysAllocString(StrToWCHARz(event.result));
        *pszName = ptr;
        return COM.S_OK;
    }

    /* get_accParent([out] ppdispParent)
     * Ownership of ppdispParent transfers from callee to caller so reference count on ppdispParent
     * must be incremented before returning.  The caller is responsible for releasing ppdispParent.
     */
    HRESULT get_accParent(LPDISPATCH* ppdispParent) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;
        // Currently, we don't let the application override this. Forward to the proxy.
        return iaccessible.get_accParent(ppdispParent);
    }

    HRESULT get_accRole(VARIANT variant, VARIANT* pvarRole) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;
        VARIANT* v = &variant;
        //COM.MoveMemory(v, variant, VARIANT.sizeof);
        if ((v.vt & 0xFFFF) !is COM.VT_I4) return COM.E_INVALIDARG;

        /* Get the default role from the OS. */
        int osRole = COM.ROLE_SYSTEM_CLIENT;
        int code = iaccessible.get_accRole(variant, pvarRole);
        if (code is COM.E_INVALIDARG) code = COM.S_FALSE; // proxy doesn't know about app childID
        // TEMPORARY CODE - process tree and table even if there are no apps listening
        if (accessibleControlListeners.size() is 0 && !( null !is cast(Tree)control || null !is cast(Table)control )) return code;
        if (code is COM.S_OK) {
            //TODO - use VARIANT structure
            short[1] pvt;
            COM.MoveMemory(pvt.ptr, pvarRole, 2);
            if (pvt[0] is COM.VT_I4) {
                int[1] pRole;
                COM.MoveMemory(pRole.ptr, pvarRole + 8, 4);
                osRole = pRole[0];
            }
        }

        AccessibleControlEvent event = new AccessibleControlEvent(this);
        event.childID = osToChildID(v.lVal);
        event.detail = osToRole(osRole);
        // TEMPORARY CODE
        /* Currently our checkbox table and tree are emulated using state mask
         * images, so we need to specify 'checkbox' role for the items. */
        if (v.lVal !is COM.CHILDID_SELF) {
            if ( null !is cast(Tree)control || null !is cast(Table)control ) {
                if ((control.getStyle() & SWT.CHECK) !is 0) event.detail = ACC.ROLE_CHECKBUTTON;
            }
        }
        for (int i = 0; i < accessibleControlListeners.size(); i++) {
            AccessibleControlListener listener = cast(AccessibleControlListener) accessibleControlListeners.elementAt(i);
            listener.getRole(event);
        }
        int role = roleToOs(event.detail);
        pvarRole.vt = COM.VT_I4;
        pvarRole.lVal = role;
        return COM.S_OK;
    }

    /* get_accSelection([out] pvarChildren)
     * Ownership of pvarChildren transfers from callee to caller so reference count on pvarChildren
     * must be incremented before returning.  The caller is responsible for releasing pvarChildren.
     */
    HRESULT get_accSelection(VARIANT* pvarChildren) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;

        /* Get the default selection from the OS. */
        int osChild = ACC.CHILDID_NONE;
        int code = iaccessible.get_accSelection(pvarChildren);
        if (accessibleControlListeners.size() is 0) return code;
        if (code is COM.S_OK) {
            //TODO - use VARIANT structure
            short[1] pvt;
            COM.MoveMemory(pvt.ptr, pvarChildren, 2);
            if (pvt[0] is COM.VT_I4) {
                int[1] pChild;
                COM.MoveMemory(pChild.ptr, pvarChildren + 8, 4);
                osChild = osToChildID(pChild[0]);
            } else if (pvt[0] is COM.VT_UNKNOWN) {
                osChild = ACC.CHILDID_MULTIPLE;
                /* Should get IEnumVARIANT from punkVal field, and enumerate children... */
            }
        }

        AccessibleControlEvent event = new AccessibleControlEvent(this);
        event.childID = osChild;
        for (int i = 0; i < accessibleControlListeners.size(); i++) {
            AccessibleControlListener listener = cast(AccessibleControlListener) accessibleControlListeners.elementAt(i);
            listener.getSelection(event);
        }
        Accessible accessible = event.accessible;
        if (accessible !is null) {
            accessible.AddRef();
            pvarChildren.vt = COM.VT_DISPATCH;
            pvarChildren.byRef = cast(void*)cast(IDispatch)accessible.objIAccessible;
            return COM.S_OK;
        }
        int childID = event.childID;
        if (childID is ACC.CHILDID_NONE) {
            pvarChildren.vt = COM.VT_EMPTY;
            return COM.S_FALSE;
        }
        if (childID is ACC.CHILDID_MULTIPLE) {
            AddRef();
            pvarChildren.vt = COM.VT_UNKNOWN;
            pvarChildren.byRef = cast(void*)cast(IUnknown)objIAccessible;
            return COM.S_OK;
        }
        if (childID is ACC.CHILDID_SELF) {
            AddRef();
            pvarChildren.vt = COM.VT_DISPATCH;
            pvarChildren.byRef = cast(void*)cast(IDispatch)objIAccessible;
            return COM.S_OK;
        }
        pvarChildren.vt = COM.VT_I4;
        pvarChildren.lVal = childIDToOs(childID);
        return COM.S_OK;
    }

    HRESULT get_accState(VARIANT variant, VARIANT* pvarState) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;
        VARIANT* v = &variant;
        //COM.MoveMemory(v, variant, VARIANT.sizeof);
        if ((v.vt & 0xFFFF) !is COM.VT_I4) return COM.E_INVALIDARG;

        /* Get the default state from the OS. */
        int osState = 0;
        int code = iaccessible.get_accState(variant, pvarState);
        if (code is COM.E_INVALIDARG) code = COM.S_FALSE; // proxy doesn't know about app childID
        // TEMPORARY CODE - process tree and table even if there are no apps listening
        if (accessibleControlListeners.size() is 0 && !( null !is cast(Tree)control || null !is cast(Table)control )) return code;
        if (code is COM.S_OK) {
            //TODO - use VARIANT structure
            short[1] pvt;
            COM.MoveMemory(pvt.ptr, pvarState, 2);
            if (pvt[0] is COM.VT_I4) {
                int[1] pState;
                COM.MoveMemory(pState.ptr, pvarState + 8, 4);
                osState = pState[0];
            }
        }
        bool grayed = false;
        AccessibleControlEvent event = new AccessibleControlEvent(this);
        event.childID = osToChildID(v.lVal);
        event.detail = osToState(osState);
        // TEMPORARY CODE
        /* Currently our checkbox table and tree are emulated using state mask
         * images, so we need to determine if the item state is 'checked'. */
        if (v.lVal !is COM.CHILDID_SELF) {
            if (null !is cast(Tree)control && (control.getStyle() & SWT.CHECK) !is 0) {
                auto hwnd = control.handle;
                TVITEM tvItem;
                tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_STATE;
                tvItem.stateMask = OS.TVIS_STATEIMAGEMASK;
                if (OS.COMCTL32_MAJOR >= 6) {
                    tvItem.hItem = cast(HTREEITEM) OS.SendMessage (hwnd, OS.TVM_MAPACCIDTOHTREEITEM, v.lVal, 0);
                } else {
                    tvItem.hItem = cast(HTREEITEM) v.lVal;
                }
                auto result = OS.SendMessage (hwnd, OS.TVM_GETITEM, 0, &tvItem);
                bool checked = (result !is 0) && (((tvItem.state >> 12) & 1) is 0);
                if (checked) event.detail |= ACC.STATE_CHECKED;
                grayed = tvItem.state >> 12 > 2;
            } else if (null !is cast(Table)control && (control.getStyle() & SWT.CHECK) !is 0) {
                Table table = cast(Table) control;
                int index = event.childID;
                if (0 <= index && index < table.getItemCount()) {
                    TableItem item = table.getItem(index);
                    if (item.getChecked()) event.detail |= ACC.STATE_CHECKED;
                    if (item.getGrayed()) grayed = true;
                }
            }
        }
        for (int i = 0; i < accessibleControlListeners.size(); i++) {
            AccessibleControlListener listener = cast(AccessibleControlListener) accessibleControlListeners.elementAt(i);
            listener.getState(event);
        }
        int state = stateToOs(event.detail);
        if ((state & ACC.STATE_CHECKED) !is 0 && grayed) {
            state &= ~ COM.STATE_SYSTEM_CHECKED;
            state |= COM.STATE_SYSTEM_MIXED;
        }
        pvarState.vt = COM.VT_I4;
        pvarState.lVal = state;
        return COM.S_OK;
    }

    HRESULT get_accValue(VARIANT variant, BSTR* pszValue) {
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;
        VARIANT* v = &variant;
        //COM.MoveMemory(v, variant, VARIANT.sizeof);
        if ((v.vt & 0xFFFF) !is COM.VT_I4) return COM.E_INVALIDARG;

        /* Get the default value string from the OS. */
        String osValue = null;
        int code = iaccessible.get_accValue(variant, pszValue);
        if (code is COM.E_INVALIDARG) code = COM.S_FALSE; // proxy doesn't know about app childID
        if (accessibleControlListeners.size() is 0) return code;
        if (code is COM.S_OK) {
            int size = COM.SysStringByteLen(*pszValue);
            if (size > 0) {
                osValue = WCHARsToStr((*pszValue)[ 0 .. size ]);
            }
        }

        AccessibleControlEvent event = new AccessibleControlEvent(this);
        event.childID = osToChildID(v.lVal);
        event.result = osValue;
        for (int i = 0; i < accessibleControlListeners.size(); i++) {
            AccessibleControlListener listener = cast(AccessibleControlListener) accessibleControlListeners.elementAt(i);
            listener.getValue(event);
        }
        if (event.result is null) return code;
        auto ptr = COM.SysAllocString(StrToWCHARz(event.result));
        *pszValue = ptr;
        return COM.S_OK;
    }

    HRESULT put_accName(VARIANT variant, BSTR* szName) {
        // MSAA: this method is no longer supported
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;
        // We don't implement this. Forward to the proxy.
        int code = iaccessible.put_accName(variant, szName);
        if (code is COM.E_INVALIDARG) code = COM.S_FALSE; // proxy doesn't know about app childID
        return code;
    }

    HRESULT put_accValue(VARIANT variant, BSTR* szValue) {
        // MSAA: this method is typically only used for edit controls
        if (iaccessible is null) return COM.CO_E_OBJNOTCONNECTED;
        // We don't implement this. Forward to the proxy.
        int code = iaccessible.put_accValue(variant, szValue);
        if (code is COM.E_INVALIDARG) code = COM.S_FALSE; // proxy doesn't know about app childID
        return code;
    }

    /* IEnumVARIANT methods: Next, Skip, Reset, Clone */
    /* Retrieve the next celt items in the enumeration sequence.
     * If there are fewer than the requested number of elements left
     * in the sequence, retrieve the remaining elements.
     * The number of elements actually retrieved is returned in pceltFetched
     * (unless the caller passed in NULL for that parameter).
     */

     /* Next([in] celt, [out] rgvar, [in, out] pceltFetched)
     * Ownership of rgvar transfers from callee to caller so reference count on rgvar
     * must be incremented before returning.  The caller is responsible for releasing rgvar.
     */
    HRESULT Next(ULONG celt, VARIANT *rgvar, ULONG *pceltFetched) {
        /* If there are no listeners, query the proxy for
         * its IEnumVariant, and get the Next items from it.
         */
        if (accessibleControlListeners.size() is 0) {
            IEnumVARIANT ienumvariant;
            int code = iaccessible.QueryInterface(&COM.IIDIEnumVARIANT, cast(void**)&ienumvariant);
            if (code !is COM.S_OK) return code;
            uint[1] celtFetched;
            code = ienumvariant.Next(celt, rgvar, celtFetched.ptr);
            ienumvariant.Release();
            COM.MoveMemory(pceltFetched, celtFetched.ptr, 4);
            return code;
        }

        if (rgvar is null) return COM.E_INVALIDARG;
        if (pceltFetched is null && celt !is 1) return COM.E_INVALIDARG;
        if (enumIndex is 0) {
            AccessibleControlEvent event = new AccessibleControlEvent(this);
            event.childID = ACC.CHILDID_SELF;
            for (int i = 0; i < accessibleControlListeners.size(); i++) {
                AccessibleControlListener listener = cast(AccessibleControlListener) accessibleControlListeners.elementAt(i);
                listener.getChildren(event);
            }
            variants = event.children;
        }
        Object[] nextItems = null;
        if (variants !is null && celt >= 1) {
            int endIndex = enumIndex + celt - 1;
            if (endIndex > (variants.length - 1)) endIndex = cast(int)/*64bit*/variants.length - 1;
            if (enumIndex <= endIndex) {
                nextItems = new Object[endIndex - enumIndex + 1];
                for (int i = 0; i < nextItems.length; i++) {
                    Object child = variants[enumIndex];
                    if (auto val = cast(Integer)child ) {
                        nextItems[i] = new Integer(childIDToOs(val.intValue()));
                    } else {
                        nextItems[i] = child;
                    }
                    enumIndex++;
                }
            }
        }
        if (nextItems !is null) {
            for (int i = 0; i < nextItems.length; i++) {
                Object nextItem = nextItems[i];
                if (auto val = cast(Integer)nextItem ) {
                    int item = val.intValue();
                    rgvar[i].vt = COM.VT_I4;
                    rgvar[i].byRef = cast(void*)item;
                    COM.MoveMemory(rgvar + i * VARIANT.sizeof + 8, &item, 4);
                } else {
                    Accessible accessible = cast(Accessible) nextItem;
                    accessible.AddRef();
                    rgvar[i].vt = COM.VT_DISPATCH;
                    rgvar[i].byRef = cast(void*)accessible.objIAccessible;
                }
            }
            if (pceltFetched !is null)
                *pceltFetched = cast(int)/*64bit*/nextItems.length;
            if (nextItems.length is celt) return COM.S_OK;
        } else {
            if (pceltFetched !is null){
                int zero = 0;
                *pceltFetched = 0;
            }
        }
        return COM.S_FALSE;
    }

    /* Skip over the specified number of elements in the enumeration sequence. */
    HRESULT Skip(ULONG celt)  {
        /* If there are no listeners, query the proxy
         * for its IEnumVariant, and tell it to Skip.
         */
        if (accessibleControlListeners.size() is 0) {
            IEnumVARIANT ienumvariant;
            int code = iaccessible.QueryInterface(&COM.IIDIEnumVARIANT, cast(void**)&ienumvariant);
            if (code !is COM.S_OK) return code;
            code = ienumvariant.Skip(celt);
            ienumvariant.Release();
            return code;
        }

        if (celt < 1 ) return COM.E_INVALIDARG;
        enumIndex += celt;
        if (enumIndex > (variants.length - 1)) {
            enumIndex = cast(int)/*64bit*/variants.length - 1;
            return COM.S_FALSE;
        }
        return COM.S_OK;
    }

    /* Reset the enumeration sequence to the beginning. */
    HRESULT Reset() {
        /* If there are no listeners, query the proxy
         * for its IEnumVariant, and tell it to Reset.
         */
        if (accessibleControlListeners.size() is 0) {
            IEnumVARIANT ienumvariant;
            int code = iaccessible.QueryInterface(&COM.IIDIEnumVARIANT, cast(void**)&ienumvariant);
            if (code !is COM.S_OK) return code;
            code = ienumvariant.Reset();
            ienumvariant.Release();
            return code;
        }

        enumIndex = 0;
        return COM.S_OK;
    }

     /* Clone([out] ppEnum)
     * Ownership of ppEnum transfers from callee to caller so reference count on ppEnum
     * must be incremented before returning.  The caller is responsible for releasing ppEnum.
     */
    int Clone(IEnumVARIANT* ppEnum) {
        /* If there are no listeners, query the proxy for
         * its IEnumVariant, and get the Clone from it.
         */
        if (accessibleControlListeners.size() is 0) {
            IEnumVARIANT ienumvariant;
            int code = iaccessible.QueryInterface(&COM.IIDIEnumVARIANT, cast(void**)&ienumvariant);
            if (code !is COM.S_OK) return code;
            IEnumVARIANT[1] pEnum;
            code = ienumvariant.Clone(pEnum.ptr);
            ienumvariant.Release();
            COM.MoveMemory(ppEnum, pEnum.ptr, (void*).sizeof);
            return code;
        }

        if (ppEnum is null) return COM.E_INVALIDARG;
        *ppEnum = objIEnumVARIANT;
        AddRef();
        return COM.S_OK;
    }

    int childIDToOs(int childID) {
        if (childID is ACC.CHILDID_SELF) return COM.CHILDID_SELF;
        /*
        * Feature of Windows:
        * In Windows XP, tree item ids are 1-based indices. Previous versions
        * of Windows use the tree item handle for the accessible child ID.
        * For backward compatibility, we still take a handle childID for tree
        * items on XP. All other childIDs are 1-based indices.
        */
        if (!(cast(Tree)control )) return childID + 1;
        if (OS.COMCTL32_MAJOR < 6) return childID;
        return cast(int)/*64bit*/OS.SendMessage (control.handle, OS.TVM_MAPHTREEITEMTOACCID, childID, 0);
    }

    int osToChildID(int osChildID) {
        if (osChildID is COM.CHILDID_SELF) return ACC.CHILDID_SELF;
        /*
        * Feature of Windows:
        * In Windows XP, tree item ids are 1-based indices. Previous versions
        * of Windows use the tree item handle for the accessible child ID.
        * For backward compatibility, we still take a handle childID for tree
        * items on XP. All other childIDs are 1-based indices.
        */
        if (!(cast(Tree)control )) return osChildID - 1;
        if (OS.COMCTL32_MAJOR < 6) return osChildID;
        return cast(int)/*64bit*/OS.SendMessage (control.handle, OS.TVM_MAPACCIDTOHTREEITEM, osChildID, 0);
    }

    int stateToOs(int state) {
        int osState = 0;
        if ((state & ACC.STATE_SELECTED) !is 0) osState |= COM.STATE_SYSTEM_SELECTED;
        if ((state & ACC.STATE_SELECTABLE) !is 0) osState |= COM.STATE_SYSTEM_SELECTABLE;
        if ((state & ACC.STATE_MULTISELECTABLE) !is 0) osState |= COM.STATE_SYSTEM_MULTISELECTABLE;
        if ((state & ACC.STATE_FOCUSED) !is 0) osState |= COM.STATE_SYSTEM_FOCUSED;
        if ((state & ACC.STATE_FOCUSABLE) !is 0) osState |= COM.STATE_SYSTEM_FOCUSABLE;
        if ((state & ACC.STATE_PRESSED) !is 0) osState |= COM.STATE_SYSTEM_PRESSED;
        if ((state & ACC.STATE_CHECKED) !is 0) osState |= COM.STATE_SYSTEM_CHECKED;
        if ((state & ACC.STATE_EXPANDED) !is 0) osState |= COM.STATE_SYSTEM_EXPANDED;
        if ((state & ACC.STATE_COLLAPSED) !is 0) osState |= COM.STATE_SYSTEM_COLLAPSED;
        if ((state & ACC.STATE_HOTTRACKED) !is 0) osState |= COM.STATE_SYSTEM_HOTTRACKED;
        if ((state & ACC.STATE_BUSY) !is 0) osState |= COM.STATE_SYSTEM_BUSY;
        if ((state & ACC.STATE_READONLY) !is 0) osState |= COM.STATE_SYSTEM_READONLY;
        if ((state & ACC.STATE_INVISIBLE) !is 0) osState |= COM.STATE_SYSTEM_INVISIBLE;
        if ((state & ACC.STATE_OFFSCREEN) !is 0) osState |= COM.STATE_SYSTEM_OFFSCREEN;
        if ((state & ACC.STATE_SIZEABLE) !is 0) osState |= COM.STATE_SYSTEM_SIZEABLE;
        if ((state & ACC.STATE_LINKED) !is 0) osState |= COM.STATE_SYSTEM_LINKED;
        return osState;
    }

    int osToState(int osState) {
        int state = ACC.STATE_NORMAL;
        if ((osState & COM.STATE_SYSTEM_SELECTED) !is 0) state |= ACC.STATE_SELECTED;
        if ((osState & COM.STATE_SYSTEM_SELECTABLE) !is 0) state |= ACC.STATE_SELECTABLE;
        if ((osState & COM.STATE_SYSTEM_MULTISELECTABLE) !is 0) state |= ACC.STATE_MULTISELECTABLE;
        if ((osState & COM.STATE_SYSTEM_FOCUSED) !is 0) state |= ACC.STATE_FOCUSED;
        if ((osState & COM.STATE_SYSTEM_FOCUSABLE) !is 0) state |= ACC.STATE_FOCUSABLE;
        if ((osState & COM.STATE_SYSTEM_PRESSED) !is 0) state |= ACC.STATE_PRESSED;
        if ((osState & COM.STATE_SYSTEM_CHECKED) !is 0) state |= ACC.STATE_CHECKED;
        if ((osState & COM.STATE_SYSTEM_EXPANDED) !is 0) state |= ACC.STATE_EXPANDED;
        if ((osState & COM.STATE_SYSTEM_COLLAPSED) !is 0) state |= ACC.STATE_COLLAPSED;
        if ((osState & COM.STATE_SYSTEM_HOTTRACKED) !is 0) state |= ACC.STATE_HOTTRACKED;
        if ((osState & COM.STATE_SYSTEM_BUSY) !is 0) state |= ACC.STATE_BUSY;
        if ((osState & COM.STATE_SYSTEM_READONLY) !is 0) state |= ACC.STATE_READONLY;
        if ((osState & COM.STATE_SYSTEM_INVISIBLE) !is 0) state |= ACC.STATE_INVISIBLE;
        if ((osState & COM.STATE_SYSTEM_OFFSCREEN) !is 0) state |= ACC.STATE_OFFSCREEN;
        if ((osState & COM.STATE_SYSTEM_SIZEABLE) !is 0) state |= ACC.STATE_SIZEABLE;
        if ((osState & COM.STATE_SYSTEM_LINKED) !is 0) state |= ACC.STATE_LINKED;
        return state;
    }

    int roleToOs(int role) {
        switch (role) {
            case ACC.ROLE_CLIENT_AREA: return COM.ROLE_SYSTEM_CLIENT;
            case ACC.ROLE_WINDOW: return COM.ROLE_SYSTEM_WINDOW;
            case ACC.ROLE_MENUBAR: return COM.ROLE_SYSTEM_MENUBAR;
            case ACC.ROLE_MENU: return COM.ROLE_SYSTEM_MENUPOPUP;
            case ACC.ROLE_MENUITEM: return COM.ROLE_SYSTEM_MENUITEM;
            case ACC.ROLE_SEPARATOR: return COM.ROLE_SYSTEM_SEPARATOR;
            case ACC.ROLE_TOOLTIP: return COM.ROLE_SYSTEM_TOOLTIP;
            case ACC.ROLE_SCROLLBAR: return COM.ROLE_SYSTEM_SCROLLBAR;
            case ACC.ROLE_DIALOG: return COM.ROLE_SYSTEM_DIALOG;
            case ACC.ROLE_LABEL: return COM.ROLE_SYSTEM_STATICTEXT;
            case ACC.ROLE_PUSHBUTTON: return COM.ROLE_SYSTEM_PUSHBUTTON;
            case ACC.ROLE_CHECKBUTTON: return COM.ROLE_SYSTEM_CHECKBUTTON;
            case ACC.ROLE_RADIOBUTTON: return COM.ROLE_SYSTEM_RADIOBUTTON;
            case ACC.ROLE_COMBOBOX: return COM.ROLE_SYSTEM_COMBOBOX;
            case ACC.ROLE_TEXT: return COM.ROLE_SYSTEM_TEXT;
            case ACC.ROLE_TOOLBAR: return COM.ROLE_SYSTEM_TOOLBAR;
            case ACC.ROLE_LIST: return COM.ROLE_SYSTEM_LIST;
            case ACC.ROLE_LISTITEM: return COM.ROLE_SYSTEM_LISTITEM;
            case ACC.ROLE_TABLE: return COM.ROLE_SYSTEM_TABLE;
            case ACC.ROLE_TABLECELL: return COM.ROLE_SYSTEM_CELL;
            case ACC.ROLE_TABLECOLUMNHEADER: return COM.ROLE_SYSTEM_COLUMNHEADER;
            case ACC.ROLE_TABLEROWHEADER: return COM.ROLE_SYSTEM_ROWHEADER;
            case ACC.ROLE_TREE: return COM.ROLE_SYSTEM_OUTLINE;
            case ACC.ROLE_TREEITEM: return COM.ROLE_SYSTEM_OUTLINEITEM;
            case ACC.ROLE_TABFOLDER: return COM.ROLE_SYSTEM_PAGETABLIST;
            case ACC.ROLE_TABITEM: return COM.ROLE_SYSTEM_PAGETAB;
            case ACC.ROLE_PROGRESSBAR: return COM.ROLE_SYSTEM_PROGRESSBAR;
            case ACC.ROLE_SLIDER: return COM.ROLE_SYSTEM_SLIDER;
            case ACC.ROLE_LINK: return COM.ROLE_SYSTEM_LINK;
            default:
        }
        return COM.ROLE_SYSTEM_CLIENT;
    }

    int osToRole(int osRole) {
        switch (osRole) {
            case COM.ROLE_SYSTEM_CLIENT: return ACC.ROLE_CLIENT_AREA;
            case COM.ROLE_SYSTEM_WINDOW: return ACC.ROLE_WINDOW;
            case COM.ROLE_SYSTEM_MENUBAR: return ACC.ROLE_MENUBAR;
            case COM.ROLE_SYSTEM_MENUPOPUP: return ACC.ROLE_MENU;
            case COM.ROLE_SYSTEM_MENUITEM: return ACC.ROLE_MENUITEM;
            case COM.ROLE_SYSTEM_SEPARATOR: return ACC.ROLE_SEPARATOR;
            case COM.ROLE_SYSTEM_TOOLTIP: return ACC.ROLE_TOOLTIP;
            case COM.ROLE_SYSTEM_SCROLLBAR: return ACC.ROLE_SCROLLBAR;
            case COM.ROLE_SYSTEM_DIALOG: return ACC.ROLE_DIALOG;
            case COM.ROLE_SYSTEM_STATICTEXT: return ACC.ROLE_LABEL;
            case COM.ROLE_SYSTEM_PUSHBUTTON: return ACC.ROLE_PUSHBUTTON;
            case COM.ROLE_SYSTEM_CHECKBUTTON: return ACC.ROLE_CHECKBUTTON;
            case COM.ROLE_SYSTEM_RADIOBUTTON: return ACC.ROLE_RADIOBUTTON;
            case COM.ROLE_SYSTEM_COMBOBOX: return ACC.ROLE_COMBOBOX;
            case COM.ROLE_SYSTEM_TEXT: return ACC.ROLE_TEXT;
            case COM.ROLE_SYSTEM_TOOLBAR: return ACC.ROLE_TOOLBAR;
            case COM.ROLE_SYSTEM_LIST: return ACC.ROLE_LIST;
            case COM.ROLE_SYSTEM_LISTITEM: return ACC.ROLE_LISTITEM;
            case COM.ROLE_SYSTEM_TABLE: return ACC.ROLE_TABLE;
            case COM.ROLE_SYSTEM_CELL: return ACC.ROLE_TABLECELL;
            case COM.ROLE_SYSTEM_COLUMNHEADER: return ACC.ROLE_TABLECOLUMNHEADER;
            case COM.ROLE_SYSTEM_ROWHEADER: return ACC.ROLE_TABLEROWHEADER;
            case COM.ROLE_SYSTEM_OUTLINE: return ACC.ROLE_TREE;
            case COM.ROLE_SYSTEM_OUTLINEITEM: return ACC.ROLE_TREEITEM;
            case COM.ROLE_SYSTEM_PAGETABLIST: return ACC.ROLE_TABFOLDER;
            case COM.ROLE_SYSTEM_PAGETAB: return ACC.ROLE_TABITEM;
            case COM.ROLE_SYSTEM_PROGRESSBAR: return ACC.ROLE_PROGRESSBAR;
            case COM.ROLE_SYSTEM_SLIDER: return ACC.ROLE_SLIDER;
            case COM.ROLE_SYSTEM_LINK: return ACC.ROLE_LINK;
            default:
        }
        return ACC.ROLE_CLIENT_AREA;
    }

    /* checkWidget was copied from Widget, and rewritten to work in this package */
    void checkWidget () {
        if (!isValidThread ()) SWT.error (SWT.ERROR_THREAD_INVALID_ACCESS);
        if (control.isDisposed ()) SWT.error (SWT.ERROR_WIDGET_DISPOSED);
    }

    /* isValidThread was copied from Widget, and rewritten to work in this package */
    WINBOOL isValidThread () {
        return control.getDisplay ().getThread () is Thread.currentThread ();
    }
}

class _IAccessibleImpl : IAccessible {

    Accessible  parent;
    this(Accessible p) { parent = p; }
extern (Windows):
    // interface of IUnknown
    HRESULT QueryInterface(REFCIID riid, void ** ppvObject) { return parent.QueryInterface(riid, ppvObject); }
    ULONG AddRef()  { return parent.AddRef(); }
    ULONG Release() { return parent.Release(); }

    // interface of IDispatch
    HRESULT GetTypeInfoCount(UINT * pctinfo) { return COM.E_NOTIMPL; }
    HRESULT GetTypeInfo(UINT iTInfo, LCID lcid, ITypeInfo * ppTInfo) { return COM.E_NOTIMPL; }
    HRESULT GetIDsOfNames(REFCIID riid, LPCOLESTR * rgszNames, UINT cNames, LCID lcid, DISPID * rgDispId) { return COM.E_NOTIMPL; }
    HRESULT Invoke(DISPID dispIdMember,REFIID riid,LCID lcid,WORD wFlags,DISPPARAMS* pDispParams,VARIANT* pVarResult,EXCEPINFO* pExcepInfo,UINT* puArgErr) { return COM.E_NOTIMPL; }

    // interface of IAccessible
    HRESULT get_accParent(LPDISPATCH * ppdispParent) { return parent.get_accParent(ppdispParent); }
    HRESULT get_accChildCount(LONG* pcountChildren) { return parent.get_accChildCount(pcountChildren); }
    HRESULT get_accChild(VARIANT varChildID, LPDISPATCH* ppdispChild) {
        return parent.get_accChild(varChildID, ppdispChild);
    }
    HRESULT get_accName(VARIANT varID, BSTR* pszName) {
        return parent.get_accName(varID, pszName);
    }
    HRESULT get_accValue(VARIANT varID, BSTR* pszValue) {
        return parent.get_accValue(varID, pszValue);
    }
    HRESULT get_accDescription(VARIANT varID,BSTR* pszDescription) {
        return parent.get_accDescription(varID, pszDescription);
    }
    HRESULT get_accRole(VARIANT varID, VARIANT* pvarRole) {
        return parent.get_accRole(varID, pvarRole);
    }
    HRESULT get_accState(VARIANT varID, VARIANT* pvarState) {
        return parent.get_accState(varID, pvarState);
    }
    HRESULT get_accHelp(VARIANT varID, BSTR* pszHelp) {
        return parent.get_accHelp(varID, pszHelp);
    }
    HRESULT get_accHelpTopic(BSTR* pszHelpFile, VARIANT varChild, LONG* pidTopic) {
        return parent.get_accHelpTopic(pszHelpFile, varChild, pidTopic);
    }
    HRESULT get_accKeyboardShortcut(VARIANT varID, BSTR* pszKeyboardShortcut) {
        return parent.get_accKeyboardShortcut(varID, pszKeyboardShortcut);
    }
    HRESULT get_accFocus(VARIANT* pvarID) { return parent.get_accFocus(pvarID); }
    HRESULT get_accSelection(VARIANT* pvarChildren) { return parent.get_accSelection(pvarChildren); }
    HRESULT get_accDefaultAction(VARIANT varID,BSTR* pszDefaultAction) {
        return parent.get_accDefaultAction(varID, pszDefaultAction);
    }
    HRESULT accSelect(LONG flagsSelect, VARIANT varID) {
        return parent.accSelect(flagsSelect, varID);
    }
    HRESULT accLocation(LONG* pxLeft, LONG* pyTop, LONG* pcxWidth, LONG* pcyHeight, VARIANT varID) {
        return parent.accLocation(pxLeft, pyTop, pcxWidth, pcyHeight, varID);
    }
    HRESULT accNavigate(LONG navDir, VARIANT varStart, VARIANT* pvarEnd) {
        return parent.accNavigate(navDir, varStart, pvarEnd);
    }
    HRESULT accHitTest(LONG xLeft,  LONG yTop, VARIANT* pvarID) {
        return parent.accHitTest(xLeft, yTop, pvarID);
    }
    HRESULT accDoDefaultAction(VARIANT varID) {
        return parent.accDoDefaultAction(varID);
    }
    HRESULT put_accName(VARIANT varID, BSTR* szName) {
        return parent.put_accName(varID, szName);
    }
    HRESULT put_accValue(VARIANT varID, BSTR* szValue) {
        return parent.put_accValue(varID, szValue);
    }
}

class _IEnumVARIANTImpl : IEnumVARIANT {

    Accessible  parent;
    this(Accessible a) { parent = a; }
extern (Windows):
    // interface of IUnknown
    HRESULT QueryInterface(REFCIID riid, void ** ppvObject) { return parent.QueryInterface(riid, ppvObject); }
    ULONG AddRef()  { return parent.AddRef(); }
    ULONG Release() { return parent.Release(); }

    // interface of IEnumVARIANT
    HRESULT Next(ULONG celt, VARIANT *rgvar, ULONG *pceltFetched) { return parent.Next(celt, rgvar, pceltFetched); }
    HRESULT Skip(ULONG celt) { return parent.Skip(celt); }
    HRESULT Reset() { return parent.Reset(); }
    HRESULT Clone(LPENUMVARIANT * ppenum) { return COM.E_NOTIMPL;}
}

