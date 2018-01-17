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
 *     Shawn Liu
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module org.eclipse.swt.internal.ole.win32.COM;


public import org.eclipse.swt.internal.ole.win32.COMTYPES;
private import org.eclipse.swt.internal.ole.win32.OAIDL;
private import org.eclipse.swt.internal.ole.win32.OBJIDL;
private import org.eclipse.swt.internal.ole.win32.OLEIDL;
private import org.eclipse.swt.internal.ole.win32.DOCOBJ;
private import org.eclipse.swt.internal.ole.win32.EXDISP;
private import org.eclipse.swt.internal.ole.win32.MSHTMHST;
private import org.eclipse.swt.internal.ole.win32.extras;
private import org.eclipse.swt.internal.ole.win32.ifs;
private import org.eclipse.swt.internal.ole.win32.COMAPI;
import java.lang.all;

private alias org.eclipse.swt.internal.ole.win32.COMAPI COMAPI;


public import org.eclipse.swt.internal.win32.OS;

template IIDFromStringT(String g) {
   static if (g.length == 38)
     const GUID IIDFromStringT = IIDFromStringT!(g[1..$-1]);
   else static if (g.length == 36)
     const GUID IIDFromStringT = GUID (
        mixin("0x" ~ g[0..8]),
        mixin("0x" ~ g[9..13]),
        mixin("0x" ~ g[14..18]),
        [
            mixin("0x" ~ g[19..21]),
            mixin("0x" ~ g[21..23]),
            mixin("0x" ~ g[24..26]),
            mixin("0x" ~ g[26..28]),
            mixin("0x" ~ g[28..30]),
            mixin("0x" ~ g[30..32]),
            mixin("0x" ~ g[32..34]),
            mixin("0x" ~ g[34..36]) ] );
   else
     static assert(false, "Incorrect format for GUID. "~g);
}


public class COM : OS {

	//private import std.c.windows.com;

	// all the GUID
	// GUIDs for Home Page Browser

    /** GUID Constants */
    public static const GUID IIDJavaBeansBridge = IIDFromStringT!("{8AD9C840-044E-11D1-B3E9-00805F499D93}"); //$NON-NLS-1$
    public static const GUID IIDShockwaveActiveXControl = IIDFromStringT!("{166B1BCA-3F9C-11CF-8075-444553540000}"); //$NON-NLS-1$
    public static const GUID IIDIEditorSiteTime = IIDFromStringT!("{6BD2AEFE-7876-45e6-A6E7-3BFCDF6540AA}"); //$NON-NLS-1$
    public static const GUID IIDIEditorSiteProperty = IIDFromStringT!("{D381A1F4-2326-4f3c-AFB9-B7537DB9E238}"); //$NON-NLS-1$
    public static const GUID IIDIEditorBaseProperty = IIDFromStringT!("{61E55B0B-2647-47c4-8C89-E736EF15D636}"); //$NON-NLS-1$
    public static const GUID IIDIEditorSite = IIDFromStringT!("{CDD88AB9-B01D-426E-B0F0-30973E9A074B}"); //$NON-NLS-1$
    public static const GUID IIDIEditorService = IIDFromStringT!("{BEE283FE-7B42-4FF3-8232-0F07D43ABCF1}"); //$NON-NLS-1$
    public static const GUID IIDIEditorManager = IIDFromStringT!("{EFDE08C4-BE87-4B1A-BF84-15FC30207180}"); //$NON-NLS-1$
    public static const GUID IIDIAccessible = IIDFromStringT!("{618736E0-3C3D-11CF-810C-00AA00389B71}"); //$NON-NLS-1$
    //public static const GUID IIDIAccessibleHandler = IIDFromStringT!("{03022430-ABC4-11D0-BDE2-00AA001A1953}"); //$NON-NLS-1$
    //public static const GUID IIDIAccessor = IIDFromStringT!("{0C733A8C-2A1C-11CE-ADE5-00AA0044773D}"); //$NON-NLS-1$
    public static const GUID IIDIAdviseSink = IIDFromStringT!("{0000010F-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIAdviseSink2 = IIDFromStringT!("{00000125-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIBindCtx = IIDFromStringT!("{0000000E-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIClassFactory = IIDFromStringT!("{00000001-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIClassFactory2 = IIDFromStringT!("{B196B28F-BAB4-101A-B69C-00AA00341D07}"); //$NON-NLS-1$
    public static const GUID IIDIConnectionPoint = IIDFromStringT!("{B196B286-BAB4-101A-B69C-00AA00341D07}"); //$NON-NLS-1$
    public static const GUID IIDIConnectionPointContainer = IIDFromStringT!("{B196B284-BAB4-101A-B69C-00AA00341D07}"); //$NON-NLS-1$
    //public static const GUID IIDICreateErrorInfo = IIDFromStringT!("{22F03340-547D-101B-8E65-08002B2BD119}"); //$NON-NLS-1$
    //public static const GUID IIDICreateTypeInfo = IIDFromStringT!("{00020405-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDICreateTypeLib = IIDFromStringT!("{00020406-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIDataAdviseHolder = IIDFromStringT!("{00000110-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIDataObject = IIDFromStringT!("{0000010E-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIDispatch = IIDFromStringT!("{00020400-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIDocHostUIHandler = IIDFromStringT!("{BD3F23C0-D43E-11CF-893B-00AA00BDCE1A}"); //$NON-NLS-1$
    public static const GUID IIDIDocHostShowUI = IIDFromStringT!("{C4D244B0-D43E-11CF-893B-00AA00BDCE1A}"); //$NON-NLS-1$
    public static const GUID IIDIDropSource = IIDFromStringT!("{00000121-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIDropTarget = IIDFromStringT!("{00000122-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIEnumConnectionPoints = IIDFromStringT!("{B196B285-BAB4-101A-B69C-00AA00341D07}"); //$NON-NLS-1$
    //public static const GUID IIDIEnumConnections = IIDFromStringT!("{B196B287-BAB4-101A-B69C-00AA00341D07}"); //$NON-NLS-1$
    public static const GUID IIDIEnumFORMATETC = IIDFromStringT!("{00000103-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIEnumMoniker = IIDFromStringT!("{00000102-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIEnumOLEVERB = IIDFromStringT!("{00000104-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIEnumSTATDATA = IIDFromStringT!("{00000105-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIEnumSTATSTG = IIDFromStringT!("{0000000D-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIEnumString = IIDFromStringT!("{00000101-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIEnumUnknown = IIDFromStringT!("{00000100-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIEnumVARIANT = IIDFromStringT!("{00020404-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIErrorInfo = IIDFromStringT!("{1CF2B120-547D-101B-8E65-08002B2BD119}"); //$NON-NLS-1$
    //public static const GUID IIDIErrorLog = IIDFromStringT!("{3127CA40-446E-11CE-8135-00AA004BB851}"); //$NON-NLS-1$
    //public static const GUID IIDIExternalConnection = IIDFromStringT!("{00000019-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIFont = IIDFromStringT!("{BEF6E002-A874-101A-8BBA-00AA00300CAB}"); //$NON-NLS-1$
    //public static const GUID IIDIFontDisp = IIDFromStringT!("{BEF6E003-A874-101A-8BBA-00AA00300CAB}"); //$NON-NLS-1$
    public static const /*GUID*/ String IIDIHTMLDocumentEvents2 = /*IIDFromStringT!(*/"{3050F613-98B5-11CF-BB82-00AA00BDCE0B}"/*)*/;
    public static const GUID IIDIInternetSecurityManager = IIDFromStringT!("{79eac9ee-baf9-11ce-8c82-00aa004ba90b}"); //$NON-NLS-1$
    //public static const GUID IIDILockBytes = IIDFromStringT!("{0000000A-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIMalloc = IIDFromStringT!("{00000002-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIMallocSpy = IIDFromStringT!("{0000001D-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIMarshal = IIDFromStringT!("{00000003-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIMessageFilter = IIDFromStringT!("{00000016-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIMoniker = IIDFromStringT!("{0000000F-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIOleAdviseHolder = IIDFromStringT!("{00000111-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIOleCache = IIDFromStringT!("{0000011E-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIOleCache2 = IIDFromStringT!("{00000128-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIOleCacheControl = IIDFromStringT!("{00000129-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIOleClientSite = IIDFromStringT!("{00000118-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIOleCommandTarget = IIDFromStringT!("{B722BCCB-4E68-101B-A2BC-00AA00404770}"); //$NON-NLS-1$
    public static const GUID IIDIOleContainer = IIDFromStringT!("{0000011B-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIOleControl = IIDFromStringT!("{B196B288-BAB4-101A-B69C-00AA00341D07}"); //$NON-NLS-1$
    public static const GUID IIDIOleControlSite = IIDFromStringT!("{B196B289-BAB4-101A-B69C-00AA00341D07}"); //$NON-NLS-1$
    public static const GUID IIDIOleDocument = IIDFromStringT!("{B722BCC5-4E68-101B-A2BC-00AA00404770}"); //$NON-NLS-1$
    public static const GUID IIDIOleDocumentSite = IIDFromStringT!("{B722BCC7-4E68-101B-A2BC-00AA00404770}"); //$NON-NLS-1$
    public static const GUID IIDIOleInPlaceActiveObject = IIDFromStringT!("{00000117-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIOleInPlaceFrame = IIDFromStringT!("{00000116-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIOleInPlaceObject = IIDFromStringT!("{00000113-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIOleInPlaceSite = IIDFromStringT!("{00000119-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIOleInPlaceUIWindow = IIDFromStringT!("{00000115-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIOleItemContainer = IIDFromStringT!("{0000011C-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIOleLink = IIDFromStringT!("{0000011D-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIOleObject = IIDFromStringT!("{00000112-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIOleWindow = IIDFromStringT!("{00000114-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIParseDisplayName = IIDFromStringT!("{0000011A-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIPerPropertyBrowsing = IIDFromStringT!("{376BD3AA-3845-101B-84ED-08002B2EC713}"); //$NON-NLS-1$
    public static const GUID IIDIPersist = IIDFromStringT!("{0000010C-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIPersistFile = IIDFromStringT!("{0000010B-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIPersistMemory = IIDFromStringT!("{BD1AE5E0-A6AE-11CE-BD37-504200C10000}"); //$NON-NLS-1$
    //public static const GUID IIDIPersistPropertyBag = IIDFromStringT!("{37D84F60-42CB-11CE-8135-00AA004BB851}"); //$NON-NLS-1$
    public static const GUID IIDIPersistStorage = IIDFromStringT!("{0000010A-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIPersistStream = IIDFromStringT!("{00000109-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIPersistStreamInit = IIDFromStringT!("{7FD52380-4E07-101B-AE2D-08002B2EC713}"); //$NON-NLS-1$
    //public static const GUID IIDIPicture = IIDFromStringT!("{7BF80980-BF32-101A-8BBB-00AA00300CAB}"); //$NON-NLS-1$
    //public static const GUID IIDIPictureDisp = IIDFromStringT!("{7BF80981-BF32-101A-8BBB-00AA00300CAB}"); //$NON-NLS-1$
    //public static const GUID IIDIPropertyBag = IIDFromStringT!("{55272A00-42CB-11CE-8135-00AA004BB851}"); //$NON-NLS-1$
    public static const GUID IIDIPropertyNotifySink = IIDFromStringT!("{9BFBBC02-EFF1-101A-84ED-00AA00341D07}"); //$NON-NLS-1$
    //public static const GUID IIDIPropertyPage = IIDFromStringT!("{B196B28D-BAB4-101A-B69C-00AA00341D07}"); //$NON-NLS-1$
    //public static const GUID IIDIPropertyPage2 = IIDFromStringT!("{01E44665-24AC-101B-84ED-08002B2EC713}"); //$NON-NLS-1$
    //public static const GUID IIDIPropertyPageSite = IIDFromStringT!("{B196B28C-BAB4-101A-B69C-00AA00341D07}"); //$NON-NLS-1$
    public static const GUID IIDIProvideClassInfo = IIDFromStringT!("{B196B283-BAB4-101A-B69C-00AA00341D07}"); //$NON-NLS-1$
    public static const GUID IIDIProvideClassInfo2 = IIDFromStringT!("{A6BC3AC0-DBAA-11CE-9DE3-00AA004BB851}"); //$NON-NLS-1$
    //public static const GUID IIDIPSFactoryBuffer = IIDFromStringT!("{D5F569D0-593B-101A-B569-08002B2DBF7A}"); //$NON-NLS-1$
    //public static const GUID IIDIRootStorage = IIDFromStringT!("{00000012-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIROTData = IIDFromStringT!("{F29F6BC0-5021-11CE-AA15-00006901293F}"); //$NON-NLS-1$
    //public static const GUID IIDIRpcChannelBuffer = IIDFromStringT!("{D5F56B60-593B-101A-B569-08002B2DBF7A}"); //$NON-NLS-1$
    //public static const GUID IIDIRpcProxyBuffer = IIDFromStringT!("{D5F56A34-593B-101A-B569-08002B2DBF7A}"); //$NON-NLS-1$
    //public static const GUID IIDIRpcStubBuffer = IIDFromStringT!("{D5F56AFC-593B-101A-B569-08002B2DBF7A}"); //$NON-NLS-1$
    //public static const GUID IIDIRunnableObject = IIDFromStringT!("{00000126-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIRunningObjectTable = IIDFromStringT!("{00000010-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDISimpleFrameSite = IIDFromStringT!("{742B0E01-14E6-101B-914E-00AA00300CAB}"); //$NON-NLS-1$
    public static const GUID IIDIServiceProvider = IIDFromStringT!("{6d5140c1-7436-11ce-8034-00aa006009fa}"); //$NON-NLS-1$
    public static const GUID IIDISpecifyPropertyPages = IIDFromStringT!("{B196B28B-BAB4-101A-B69C-00AA00341D07}"); //$NON-NLS-1$
    //public static const GUID IIDIStdMarshalInfo = IIDFromStringT!("{00000018-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIStorage = IIDFromStringT!("{0000000B-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIStream = IIDFromStringT!("{0000000C-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDISupportErrorInfo = IIDFromStringT!("{DF0B3D60-548F-101B-8E65-08002B2BD119}"); //$NON-NLS-1$
    //public static const GUID IIDITypeComp = IIDFromStringT!("{00020403-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDITypeLib = IIDFromStringT!("{00020402-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIUnknown = IIDFromStringT!("{00000000-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    //public static const GUID IIDIViewObject = IIDFromStringT!("{0000010D-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID IIDIViewObject2 = IIDFromStringT!("{00000127-0000-0000-C000-000000000046}"); //$NON-NLS-1$
    public static const GUID CGID_DocHostCommandHandler = IIDFromStringT!("{f38bc242-b950-11d1-8918-00c04fc2c836}"); //$NON-NLS-1$
    public static const GUID CGID_Explorer = IIDFromStringT!("{000214D0-0000-0000-C000-000000000046}"); //$NON-NLS-1$



	/* Constants */
    //public static const int ADVF_DATAONSTOP = 64;
    //public static const int ADVF_NODATA = 1;
    //public static const int ADVF_ONLYONCE = 2;
    //public static const int ADVF_PRIMEFIRST = 4;
    //public static const int ADVFCACHE_FORCEBUILTIN = 16;
    //public static const int ADVFCACHE_NOHANDLER = 8;
    //public static const int ADVFCACHE_ONSAVE = 32;
    public static const int CF_TEXT = 1;
    public static const int CF_BITMAP = 2;
    public static const int CF_METAFILEPICT = 3;
    public static const int CF_SYLK = 4;
    public static const int CF_DIF = 5;
    public static const int CF_TIFF = 6;
    public static const int CF_OEMTEXT = 7;
    public static const int CF_DIB = 8;
    public static const int CF_PALETTE = 9;
    public static const int CF_PENDATA = 10;
    public static const int CF_RIFF = 11;
    public static const int CF_WAVE = 12;
    public static const int CF_UNICODETEXT = 13;
    public static const int CF_ENHMETAFILE = 14;
    public static const int CF_HDROP = 15;
    public static const int CF_LOCALE = 16;
    public static const int CF_MAX = 17;
    public static const int CLSCTX_INPROC_HANDLER = 2;
    public static const int CLSCTX_INPROC_SERVER = 1;
    public static const int CLSCTX_LOCAL_SERVER = 4;
    public static const int CLSCTX_REMOTE_SERVER = 16;
    public static const int CO_E_CLASSSTRING = -2147221005;
    //public static const int COINIT_APARTMENTTHREADED = 2;
    //public static const int COINIT_DISABLE_OLE1DDE = 4;
    //public static const int COINIT_MULTITHREADED = 0;
    //public static const int COINIT_SPEED_OVER_MEMORY = 8;
    public static const int DATADIR_GET = 1;
    public static const int DATADIR_SET = 2;
    public static const int DISP_E_EXCEPTION = 0x80020009;
    public static const int DISP_E_MEMBERNOTFOUND = -2147352573;
    public static const int DISP_E_UNKNOWNINTERFACE = 0x80020001;
    //public static const int DISPID_AMBIENT_APPEARANCE = -716;
    //public static const int DISPID_AMBIENT_AUTOCLIP = -715;
    public static const int DISPID_AMBIENT_BACKCOLOR = -701;
    //public static const int DISPID_AMBIENT_CHARSET = -727;
    //public static const int DISPID_AMBIENT_CODEPAGE = -725;
    //public static const int DISPID_AMBIENT_DISPLAYASDEFAULT = -713;
    //public static const int DISPID_AMBIENT_DISPLAYNAME = -702;
    public static const int DISPID_AMBIENT_FONT = -703;
    public static const int DISPID_AMBIENT_FORECOLOR = -704;
    public static const int DISPID_AMBIENT_LOCALEID = -705;
    public static const int DISPID_AMBIENT_MESSAGEREFLECT = -706;
    public static const int DISPID_AMBIENT_OFFLINEIFNOTCONNECTED = -5501;
    //public static const int DISPID_AMBIENT_PALETTE = -726;
    //public static const int DISPID_AMBIENT_RIGHTTOLEFT = -732;
    //public static const int DISPID_AMBIENT_SCALEUNITS = -707;
    public static const int DISPID_AMBIENT_SHOWGRABHANDLES = -711;
    public static const int DISPID_AMBIENT_SHOWHATCHING = -712;
    public static const int DISPID_AMBIENT_SILENT = -5502;
    public static const int DISPID_AMBIENT_SUPPORTSMNEMONICS = -714;
    //public static const int DISPID_AMBIENT_TEXTALIGN = -708;
    //public static const int DISPID_AMBIENT_TOPTOBOTTOM = -733;
    //public static const int DISPID_AMBIENT_TRANSFERPRIORITY = -728;
    public static const int DISPID_AMBIENT_UIDEAD = -710;
    public static const int DISPID_AMBIENT_USERMODE = -709;
    public static const int DISPID_BACKCOLOR = -501;
    public static const int DISPID_FONT = -512;
    public static const int DISPID_FONT_BOLD = 3;
    public static const int DISPID_FONT_CHARSET = 8;
    public static const int DISPID_FONT_ITALIC = 4;
    public static const int DISPID_FONT_NAME = 0;
    public static const int DISPID_FONT_SIZE = 2;
    public static const int DISPID_FONT_STRIKE = 6;
    public static const int DISPID_FONT_UNDER = 5;
    public static const int DISPID_FONT_WEIGHT = 7;
    public static const int DISPID_FORECOLOR = -513;
    public static const int DISPID_HTMLDOCUMENTEVENTS_ONDBLCLICK = 0xFFFFFDA7;
    public static const int DISPID_HTMLDOCUMENTEVENTS_ONDRAGEND = 0x80010015;
    public static const int DISPID_HTMLDOCUMENTEVENTS_ONDRAGSTART = 0x8001000B;
    public static const int DISPID_HTMLDOCUMENTEVENTS_ONKEYDOWN = 0xFFFFFDA6;
    public static const int DISPID_HTMLDOCUMENTEVENTS_ONKEYPRESS = 0xFFFFFDA5;
    public static const int DISPID_HTMLDOCUMENTEVENTS_ONKEYUP = 0xFFFFFDA4;
    public static const int DISPID_HTMLDOCUMENTEVENTS_ONMOUSEOUT = 0x80010009;
    public static const int DISPID_HTMLDOCUMENTEVENTS_ONMOUSEOVER = 0x80010008;
    public static const int DISPID_HTMLDOCUMENTEVENTS_ONMOUSEMOVE = 0xFFFFFDA2;
    public static const int DISPID_HTMLDOCUMENTEVENTS_ONMOUSEDOWN = 0xFFFFFDA3;
    public static const int DISPID_HTMLDOCUMENTEVENTS_ONMOUSEUP = 0xFFFFFDA1;
    public static const int DISPID_HTMLDOCUMENTEVENTS_ONSTOP = 0x00000402;
    public static const int DISPID_HTMLDOCUMENTEVENTS_ONMOUSEWHEEL = 1033;

    //public static const int DISPID_READYSTATE = -525;
    //public static const int DISPID_READYSTATECHANGE = -609;
    public static const int DRAGDROP_S_DROP = 0x00040100;
    public static const int DRAGDROP_S_CANCEL = 0x00040101;
    public static const int DRAGDROP_S_USEDEFAULTCURSORS = 0x00040102;
    public static const int DROPEFFECT_NONE = 0;
    public static const int DROPEFFECT_COPY = 1;
    public static const int DROPEFFECT_MOVE = 2;
    public static const int DROPEFFECT_LINK = 4;
    public static const int DROPEFFECT_SCROLL = 0x80000000;
    public static const int DSH_ALLOWDROPDESCRIPTIONTEXT = 0x1;
    public static const int DV_E_FORMATETC = -2147221404;
    public static const int DV_E_STGMEDIUM = -2147221402;
    public static const int DV_E_TYMED = -2147221399;
    public static const int DVASPECT_CONTENT = 1;
    //public static const int DVASPECT_DOCPRINT = 8;
    //public static const int DVASPECT_ICON = 4;
    //public static const int DVASPECT_THUMBNAIL = 2;
    public static const int E_FAIL = -2147467259;
    public static const int E_INVALIDARG = -2147024809;
    public static const int E_NOINTERFACE = -2147467262;
    public static const int E_NOTIMPL = -2147467263;
    public static const int E_NOTSUPPORTED = 0x80040100;
    //public static const int E_NOTLICENSED = -2147221230;
    public static const int E_OUTOFMEMORY = -2147024882;
    //public static const int E_POINTER = -2147467261;
    public static const int GMEM_FIXED = 0;
    //public static const int GMEM_MOVABLE = 2;
    //public static const int GMEM_NODISCARD = 32;
    public static const int GMEM_ZEROINIT = 64;
    public static const int GUIDKIND_DEFAULT_SOURCE_DISP_IID = 1;
    public static const int IMPLTYPEFLAG_FDEFAULT = 1;
    //public static const int IMPLTYPEFLAG_FDEFAULTVTABLE = 2048;
    public static const int IMPLTYPEFLAG_FRESTRICTED = 4;
    public static const int IMPLTYPEFLAG_FSOURCE = 2;
    public static const int LOCALE_SYSTEM_DEFAULT = 1024;
    public static const int LOCALE_USER_DEFAULT = 2048;
    //public static const int MEMCTX_TASK = 1;
    //public static const int OLEACTIVATEAUTO = 3;
    //public static const int OLEACTIVATEDOUBLECLICK = 2;
    //public static const int OLEACTIVATEGETFOCUS = 1;
    //public static const int OLEACTIVATEMANUAL = 0;
    //public static const int OLEAUTOMATIC = 0;
    //public static const int OLECHANGED = 0;
    public static const int OLECLOSE_NOSAVE = 1;
    //public static const int OLECLOSE_PROMPTSAVE = 2;
    public static const int OLECLOSE_SAVEIFDIRTY = 0;
    //public static const int OLECLOSED = 2;
    //public static const int OLECONTF_EMBEDDINGS = 1;
    //public static const int OLECONTF_LINKS = 2;
    //public static const int OLECONTF_ONLYIFRUNNING = 16;
    //public static const int OLECONTF_ONLYUSER = 8;
    //public static const int OLECONTF_OTHERS = 4;
    //public static const int OLEDEACTIVATEMANUAL = 1;
    //public static const int OLEDEACTIVATEONLOSEFOCUS = 0;
    //public static const int OLEDECBORDER = 1;
    //public static const int OLEDECBORDERANDNIBS = 3;
    //public static const int OLEDECNIBS = 2;
    //public static const int OLEDECNONE = 0;
    //public static const int OLEDISPLAYCONTENT = 0;
    //public static const int OLEDISPLAYICON = 1;
    //public static const int OLEEITHER = 2;
    public static const int OLEEMBEDDED = 1;
    //public static const int OLEFROZEN = 1;
    public static const int OLEIVERB_DISCARDUNDOSTATE = -6;
    //public static const int OLEIVERB_HIDE = -3;
    public static const int OLEIVERB_INPLACEACTIVATE = -5;
    //public static const int OLEIVERB_OPEN = -2;
    public static const int OLEIVERB_PRIMARY = 0;
    //public static const int OLEIVERB_PROPERTIES = -7;
    //public static const int OLEIVERB_SHOW = -1;
    //public static const int OLEIVERB_UIACTIVATE = -4;
    public static const int OLELINKED = 0;
    //public static const int OLEMANUAL = 2;
    //public static const int OLEMISC_ACTIVATEWHENVISIBLE = 256;
    //public static const int OLEMISC_ACTSLIKEBUTTON = 4096;
    //public static const int OLEMISC_ACTSLIKELABEL = 8192;
    //public static const int OLEMISC_ALIGNABLE = 32768;
    //public static const int OLEMISC_ALWAYSRUN = 2048;
    //public static const int OLEMISC_CANLINKBYOLE1 = 32;
    //public static const int OLEMISC_CANTLINKINSIDE = 16;
    //public static const int OLEMISC_IGNOREACTIVATEWHENVISIBLE = 524288;
    //public static const int OLEMISC_IMEMODE = 262144;
    //public static const int OLEMISC_INSERTNOTREPLACE = 4;
    //public static const int OLEMISC_INSIDEOUT = 128;
    //public static const int OLEMISC_INVISIBLEATRUNTIME = 1024;
    //public static const int OLEMISC_ISLINKOBJECT = 64;
    //public static const int OLEMISC_NOUIACTIVATE = 16384;
    //public static const int OLEMISC_ONLYICONIC = 2;
    //public static const int OLEMISC_RECOMPOSEONRESIZE = 1;
    //public static const int OLEMISC_RENDERINGISDEVICEINDEPENDENT = 512;
    //public static const int OLEMISC_SETCLIENTSITEFIRST = 131072;
    //public static const int OLEMISC_SIMPLEFRAME = 65536;
    //public static const int OLEMISC_STATIC = 8;
    //public static const int OLEMISC_SUPPORTSMULTILEVELUNDO = 2097152;
    //public static const int OLEMISC_WANTSTOMENUMERGE = 1048576;
    //public static const int OLENONE = 3;
    //public static const int OLERENAMED = 3;
    //public static const int OLERENDER_ASIS = 3;
    public static const int OLERENDER_DRAW = 1;
    //public static const int OLERENDER_FORMAT = 2;
    //public static const int OLERENDER_NONE = 0;
    //public static const int OLESAVED = 1;
    //public static const int OLESIZEAUTOSIZE = 2;
    //public static const int OLESIZECLIP = 0;
    //public static const int OLESIZESTRETCH = 1;
    //public static const int OLESIZEZOOM = 3;
    //public static const int OLEWHICHMK_CONTAINER = 1;
    //public static const int OLEWHICHMK_OBJFULL = 3;
    //public static const int OLEWHICHMK_OBJREL = 2;
    public static const int S_FALSE = 1;
    public static const int S_OK = 0;
    public static const int STG_E_FILENOTFOUND = 0x80030002;
    public static const int STG_S_CONVERTED = 0x00030200;
    //public static const int STGC_CONSOLIDATE = 8;
    //public static const int STGC_DANGEROUSLYCOMMITMERELYTODISKCACHE = 4;
    public static const int STGC_DEFAULT = 0;
    //public static const int STGC_ONLYIFCURRENT = 2;
    //public static const int STGC_OVERWRITE = 1;
    public static const int STGM_CONVERT = 0x00020000;
    public static const int STGM_CREATE = 0x00001000;
    public static const int STGM_DELETEONRELEASE = 0x04000000;
    public static const int STGM_DIRECT = 0x00000000;
    public static const int STGM_DIRECT_SWMR = 0x00400000;
    public static const int STGM_FAILIFTHERE = 0x00000000;
    public static const int STGM_NOSCRATCH = 0x00100000;
    public static const int STGM_NOSNAPSHOT = 0x00200000;
    public static const int STGM_PRIORITY = 0x00040000;
    public static const int STGM_READ = 0x00000000;
    public static const int STGM_READWRITE = 0x00000002;
    public static const int STGM_SHARE_DENY_NONE = 0x00000040;
    public static const int STGM_SHARE_DENY_READ = 0x00000030;
    public static const int STGM_SHARE_DENY_WRITE = 0x00000020;
    public static const int STGM_SHARE_EXCLUSIVE = 0x00000010;
    public static const int STGM_SIMPLE = 0x08000000;
    public static const int STGM_TRANSACTED = 0x00010000;
    public static const int STGM_WRITE = 0x00000001;
    public static const int STGTY_STORAGE = 1;
    public static const int STGTY_STREAM = 2;
    public static const int STGTY_LOCKBYTES = 3;
    public static const int STGTY_PROPERTY = 4;
    //public static const int TYMED_ENHMF = 64;
    //public static const int TYMED_FILE = 2;
    //public static const int TYMED_GDI = 16;
    public static const int TYMED_HGLOBAL = 1;
    //public static const int TYMED_ISTORAGE = 8;
    //public static const int TYMED_ISTREAM = 4;
    //public static const int TYMED_MFPICT = 32;
    //public static const int TYMED_NULL = 0;
    public static const short DISPATCH_METHOD = 0x1;
    public static const short DISPATCH_PROPERTYGET = 0x2;
    public static const short DISPATCH_PROPERTYPUT = 0x4;
    public static const short DISPATCH_PROPERTYPUTREF = 0x8;
    //public static const short DISPID_CONSTRUCTOR = -6;
    //public static const short DISPID_DESTRUCTOR = -7;
    //public static const short DISPID_EVALUATE = -5;
    //public static const short DISPID_NEWENUM = -4;
    public static const short DISPID_PROPERTYPUT = -3;
    //public static const short DISPID_UNKNOWN = -1;
    //public static const short DISPID_VALUE = 0;
    public static const short VT_BOOL = 11;
    public static const short VT_BSTR = 8;
    public static const short VT_BYREF = 16384;
    public static const short VT_CY = 6;
    public static const short VT_DATE = 7;
    public static const short VT_DISPATCH = 9;
    public static const short VT_EMPTY = 0;
    public static const short VT_ERROR = 10;
    public static const short VT_I1 = 16;
    public static const short VT_I2 = 2;
    public static const short VT_I4 = 3;
    public static const short VT_I8 = 20;
    public static const short VT_NULL = 1;
    public static const short VT_R4 = 4;
    public static const short VT_R8 = 5;
    public static const short VT_UI1 = 17;
    public static const short VT_UI2 = 18;
    public static const short VT_UI4 = 19;
    public static const short VT_UNKNOWN = 13;
    public static const short VT_VARIANT = 12;
    public static const short VARIANT_TRUE = -1;
    public static const short VARIANT_FALSE = 0;


// alias org.eclipse.swt.internal.ole.win32.comapi.
// public static GUID* IIDFromString(String lpsz) {
// 	GUID* lpiid = new GUID();
// 	if (COM.IIDFromString(Converter.StrToWCHARz(lpsz), lpiid) == COM.S_OK)
// 		return lpiid;
// 	return null;
// }

alias COMAPI.CLSIDFromProgID CLSIDFromProgID;
alias COMAPI.CLSIDFromString CLSIDFromString;
alias COMAPI.CoCreateInstance CoCreateInstance;
alias COMAPI.CoFreeUnusedLibraries CoFreeUnusedLibraries;
alias COMAPI.CoGetClassObject CoGetClassObject;
alias COMAPI.CoLockObjectExternal CoLockObjectExternal;
alias COMAPI.CoTaskMemAlloc CoTaskMemAlloc;
alias COMAPI.CoTaskMemFree CoTaskMemFree;
alias COMAPI.CreateStdAccessibleObject CreateStdAccessibleObject;
alias COMAPI.CreateStreamOnHGlobal CreateStreamOnHGlobal;
alias COMAPI.DoDragDrop DoDragDrop;
alias COMAPI.GetClassFile GetClassFile;
alias COMAPI.IIDFromString IIDFromString;
alias COMAPI.IsEqualGUID IsEqualGUID;
alias COMAPI.LresultFromObject LresultFromObject;
alias COMAPI.OleCreate OleCreate;
alias COMAPI.OleCreateFromFile OleCreateFromFile;
alias COMAPI.OleCreatePropertyFrame OleCreatePropertyFrame;
alias COMAPI.OleDraw OleDraw;
alias COMAPI.OleFlushClipboard OleFlushClipboard;
alias COMAPI.OleGetClipboard OleGetClipboard;
alias COMAPI.OleIsCurrentClipboard OleIsCurrentClipboard;
alias COMAPI.OleIsRunning OleIsRunning;
alias COMAPI.OleLoad OleLoad;
alias COMAPI.OleRun OleRun;
alias COMAPI.OleSave OleSave;
alias COMAPI.OleSetClipboard OleSetClipboard;
alias COMAPI.OleSetContainedObject OleSetContainedObject;
alias COMAPI.OleSetMenuDescriptor OleSetMenuDescriptor;
alias COMAPI.OleTranslateColor OleTranslateColor;
alias COMAPI.ProgIDFromCLSID ProgIDFromCLSID;
alias COMAPI.RegisterDragDrop RegisterDragDrop;
alias COMAPI.ReleaseStgMedium ReleaseStgMedium;
alias COMAPI.RevokeDragDrop RevokeDragDrop;
alias COMAPI.SHDoDragDrop SHDoDragDrop;
alias COMAPI.StgCreateDocfile StgCreateDocfile;
alias COMAPI.StgIsStorageFile StgIsStorageFile;
alias COMAPI.StgOpenStorage StgOpenStorage;
alias COMAPI.StringFromCLSID StringFromCLSID;
alias COMAPI.SysAllocString SysAllocString;
alias COMAPI.SysFreeString SysFreeString;
alias COMAPI.SysStringByteLen SysStringByteLen;
alias COMAPI.VariantChangeType VariantChangeType;
alias COMAPI.VariantClear VariantClear;
alias COMAPI.VariantCopy VariantCopy;
alias COMAPI.VariantInit VariantInit;
alias COMAPI.WriteClassStg WriteClassStg;

/**
 * <Shawn Liu>
 * VtbCall partially kept, use VtbCall instead of automation can promote performace
 * and VtbCall doesn't need prototype of interface declaration
 */

public static int VtblCall(int fnNumber, void* ppVtbl) {
	Function1 fn = cast(Function1)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl);
}

public static int VtblCall(int fnNumber, void* ppVtbl, int arg0){
	Function2 fn = cast(Function2)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0);
}

public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int arg1){
	Function3 fn = cast(Function3)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, arg1);
}

public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int arg1, int arg2){
	Function4 fn = cast(Function4)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, arg1, arg2);
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int arg1, int arg2, int arg3){
	Function5 fn = cast(Function5)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, arg1, arg2, arg3);
}

public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int arg1, int arg2, int arg3, int arg4){
	Function6 fn = cast(Function6)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, arg1, arg2, arg3, arg4);
}

public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int arg1, int arg2, int arg3, int arg4, int arg5){
	Function7 fn = cast(Function7)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
}

public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int arg1, int arg2, int arg3, int arg4, int arg5, int arg6){
	Function8 fn = cast(Function8)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5, arg6);
}

public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7){
	Function9 fn = cast(Function9)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
}

/*
public static int VtblCall(int fnNumber, void* ppVtbl) {
	Function1 fn = cast(Function1)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl);
}

public static int VtblCall(int fnNumber, void* ppVtbl, int arg0){
	Function2 fn = cast(Function2)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0);
}

public static int VtblCall(int fnNumber, void* ppVtbl, void* arg0){
	Function2 fn = cast(Function2)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)arg0);
}

public static int VtblCall(int fnNumber, void* ppVtbl, wchar* arg0) {
	Function2 fn = cast(Function2)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)arg0);
}
public static int VtblCall(int fnNumber, void* ppVtbl, wchar* arg0, wchar* arg1){
	Function3 fn = cast(Function3)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)arg0, cast(int)arg1);
}
public static int VtblCall(int fnNumber, void* ppVtbl, wchar* arg0, int arg1) {
	Function3 fn = cast(Function3)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)arg0, arg1);
}
public static int VtblCall(int fnNumber, void* ppVtbl, wchar* arg0, int arg1, int arg2, int arg3, int[] arg4) {
	Function6 fn = cast(Function6)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)arg0, arg1, arg2, arg3, cast(int)cast(int*)arg4);
}
public static int VtblCall(int fnNumber, void* ppVtbl, wchar* arg0, int arg1, int arg2, int arg3, int arg4, int[] arg5) {
	Function7 fn = cast(Function7)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)arg0, arg1, arg2, arg3, arg4, cast(int)cast(int*)arg5);
}
public static int VtblCall(int fnNumber, void* ppVtbl, int[] arg0) {
	Function2 fn = cast(Function2)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)cast(int*)arg0);
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int[] arg1) {
	Function3 fn = cast(Function3)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, cast(int)cast(int*)arg1);
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int arg1) {
	Function3 fn = cast(Function3)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, arg1);
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int arg1, int[] arg2) {
	Function4 fn = cast(Function4)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, arg1, cast(int)cast(int*)arg2);
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int arg1, int arg2) {
	Function4 fn = cast(Function4)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, arg1, arg2);
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int arg1, int arg2, int[] arg3) {
	Function5 fn = cast(Function5)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, arg1, arg2, cast(int)cast(int*)arg3);
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int arg1, DVTARGETDEVICE* arg2, SIZE* arg3) {
	Function5 fn = cast(Function5)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, arg1, cast(int)(arg2), cast(int)(arg3));
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int arg1, GUID* arg2, int arg3, int[] arg4) {
	Function6 fn = cast(Function6)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, arg1, cast(int)(arg2), arg3, cast(int)cast(int*)arg4);
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, FORMATETC* arg1, int[] arg2) {
	Function4 fn = cast(Function4)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, cast(int)(arg1), cast(int)cast(int*)arg2);
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, GUID* arg1) {
	Function3 fn = cast(Function3)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, cast(int)(arg1));
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, GUID* arg1, int arg2, int arg3) {
	Function5 fn = cast(Function5)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, cast(int)(arg1), arg2, arg3);
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, GUID* arg1, int arg2, int arg3, DISPPARAMS* arg4, int arg5, EXCEPINFO* arg6, int[] arg7) {
	Function9 fn = cast(Function9)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, cast(int)(arg1), arg2, arg3, cast(int)(arg4), arg5, cast(int)(arg6), cast(int)cast(int*)arg7);
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, STATSTG* arg1, int[] arg2) {
	Function4 fn = cast(Function4)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, cast(int)(arg1), cast(int)cast(int*)arg2);
}
public static int VtblCall(int fnNumber, void* ppVtbl, MSG* arg0) {
	Function2 fn = cast(Function2)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)(arg0));
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, MSG* arg1, int arg2, int arg3, int arg4, RECT* arg5) {
	Function7 fn = cast(Function7)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, cast(int)(arg1), arg2, arg3, arg4, cast(int)(arg5));
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, SIZE* arg1) {
	Function3 fn = cast(Function3)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, cast(int)(arg1));
}

// TODO: the type of BOOL ???
// conflict with  VtblCall(int, int, int, int);
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, bool arg1) {
	Function3 fn = cast(Function3)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, cast(int)arg1);
}
public static int VtblCall(int fnNumber, void* ppVtbl, CAUUID* arg0) {
	Function2 fn = cast(Function2)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)(arg0));
}
public static int VtblCall(int fnNumber, void* ppVtbl, CONTROLINFO* arg0) {
	Function2 fn = cast(Function2)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)(arg0));
}
public static int VtblCall(int fnNumber, void* ppVtbl, FORMATETC* arg0) {
	Function2 fn = cast(Function2)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)(arg0));
}
public static int VtblCall(int fnNumber, void* ppVtbl, FORMATETC* arg0, STGMEDIUM* arg1) {
	Function3 fn = cast(Function3)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)(arg0), cast(int)(arg1));
}
// TODO: BOOL type ???
public static int VtblCall(int fnNumber, void* ppVtbl, FORMATETC* arg0, STGMEDIUM* arg1, int arg2) {
	Function4 fn = cast(Function4)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)(arg0), cast(int)(arg1), arg2);
}
public static int VtblCall(int fnNumber, void* ppVtbl, GUID* arg0) {
	Function2 fn = cast(Function2)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)(arg0));
}

public static int VtblCall(int fnNumber, void* ppVtbl, GUID* arg0, int[] arg1) {
	Function3 fn = cast(Function3)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)(arg0), cast(int)cast(int*)arg1);
}

public static int VtblCall(int fnNumber, void* ppVtbl, GUID* arg0, int arg1, int arg2, int arg3, int[] arg4) {
	Function6 fn = cast(Function6)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)(arg0), arg1, arg2, arg3, cast(int)cast(int*)arg4);
}
public static int VtblCall(int fnNumber, void* ppVtbl, GUID* arg0, int arg1, int arg2, int arg3, int arg4) {
	Function6 fn = cast(Function6)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)(arg0), arg1, arg2, arg3, arg4);
}
public static int VtblCall(int fnNumber, void* ppVtbl, GUID* arg0, int arg1, OLECMD* arg2, OLECMDTEXT* arg3) {
	Function5 fn = cast(Function5)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)(arg0), arg1, cast(int)(arg2), cast(int)(arg3));
}
public static int VtblCall(int fnNumber, void* ppVtbl, LICINFO* arg0) {
	Function2 fn = cast(Function2)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)(arg0));
}
public static int VtblCall(int fnNumber, void* ppVtbl, RECT* arg0, int arg1, int arg2) {
	Function4 fn = cast(Function4)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)(arg0), arg1, arg2);
}
public static int VtblCall(int fnNumber, void* ppVtbl, RECT* arg0, RECT* arg1) {
	Function3 fn = cast(Function3)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)(arg0), cast(int)(arg1));
}
public static int VtblCall(int fnNumber, void* ppVtbl, RECT* arg0) {
	Function2 fn = cast(Function2)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, cast(size_t)(arg0));
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int[] arg1, int[] arg2, int[] arg3, int[] arg4) {
	Function6 fn = cast(Function6)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, cast(int)cast(int*)arg1, cast(int)cast(int*)arg2, cast(int)cast(int*)arg3, cast(int)cast(int*)arg4);
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int[] arg1, int arg2, int[] arg3) {
	Function5 fn = cast(Function5)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, cast(int)cast(int*)arg1, arg2, cast(int)cast(int*)arg3);
}


// Start ACCESSIBILITY
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int arg1, int arg2, int arg3) {
	Function5 fn = cast(Function5)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, arg1, arg2, arg3);
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int arg1, int arg2, int arg3, int arg4) {
	Function6 fn = cast(Function6)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, arg1, arg2, arg3, arg4);
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int arg1, int arg2, int arg3, int arg4, int arg5) {
	Function7 fn = cast(Function7)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5);
}
public static int VtblCall(int fnNumber, void* ppVtbl, int arg0, int arg1, int arg2, int arg3, int arg4, int arg5, int arg6, int arg7) {
	Function9 fn = cast(Function9)(*cast(int **)ppVtbl)[fnNumber];
	return fn(ppVtbl, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
}

*/


public static const int CHILDID_SELF = 0;
public static const int CO_E_OBJNOTCONNECTED = 0x800401FD;

//public static const int ROLE_SYSTEM_TITLEBAR = 0x1;
public static const int ROLE_SYSTEM_MENUBAR = 0x2;
public static const int ROLE_SYSTEM_SCROLLBAR = 0x3;
//public static const int ROLE_SYSTEM_GRIP = 0x4;
//public static const int ROLE_SYSTEM_SOUND = 0x5;
//public static const int ROLE_SYSTEM_CURSOR = 0x6;
//public static const int ROLE_SYSTEM_CARET = 0x7;
//public static const int ROLE_SYSTEM_ALERT = 0x8;
public static const int ROLE_SYSTEM_WINDOW = 0x9;
public static const int ROLE_SYSTEM_CLIENT = 0xa;
public static const int ROLE_SYSTEM_MENUPOPUP = 0xb;
public static const int ROLE_SYSTEM_MENUITEM = 0xc;
public static const int ROLE_SYSTEM_TOOLTIP = 0xd;
//public static const int ROLE_SYSTEM_APPLICATION = 0xe;
//public static const int ROLE_SYSTEM_DOCUMENT = 0xf;
//public static const int ROLE_SYSTEM_PANE = 0x10;
//public static const int ROLE_SYSTEM_CHART = 0x11;
public static const int ROLE_SYSTEM_DIALOG = 0x12;
//public static const int ROLE_SYSTEM_BORDER = 0x13;
//public static const int ROLE_SYSTEM_GROUPING = 0x14;
public static const int ROLE_SYSTEM_SEPARATOR = 0x15;
public static const int ROLE_SYSTEM_TOOLBAR = 0x16;
//public static const int ROLE_SYSTEM_STATUSBAR = 0x17;
public static const int ROLE_SYSTEM_TABLE = 0x18;
public static const int ROLE_SYSTEM_COLUMNHEADER = 0x19;
public static const int ROLE_SYSTEM_ROWHEADER = 0x1a;
//public static const int ROLE_SYSTEM_COLUMN = 0x1b;
//public static const int ROLE_SYSTEM_ROW = 0x1c;
public static const int ROLE_SYSTEM_CELL = 0x1d;
public static const int ROLE_SYSTEM_LINK = 0x1e;
//public static const int ROLE_SYSTEM_HELPBALLOON = 0x1f;
//public static const int ROLE_SYSTEM_CHARACTER = 0x20;
public static const int ROLE_SYSTEM_LIST = 0x21;
public static const int ROLE_SYSTEM_LISTITEM = 0x22;
public static const int ROLE_SYSTEM_OUTLINE = 0x23;
public static const int ROLE_SYSTEM_OUTLINEITEM = 0x24;
public static const int ROLE_SYSTEM_PAGETAB = 0x25;
//public static const int ROLE_SYSTEM_PROPERTYPAGE = 0x26;
//public static const int ROLE_SYSTEM_INDICATOR = 0x27;
//public static const int ROLE_SYSTEM_GRAPHIC = 0x28;
public static const int ROLE_SYSTEM_STATICTEXT = 0x29;
public static const int ROLE_SYSTEM_TEXT = 0x2a;
public static const int ROLE_SYSTEM_PUSHBUTTON = 0x2b;
public static const int ROLE_SYSTEM_CHECKBUTTON = 0x2c;
public static const int ROLE_SYSTEM_RADIOBUTTON = 0x2d;
public static const int ROLE_SYSTEM_COMBOBOX = 0x2e;
//public static const int ROLE_SYSTEM_DROPLIST = 0x2f;
public static const int ROLE_SYSTEM_PROGRESSBAR = 0x30;
//public static const int ROLE_SYSTEM_DIAL = 0x31;
//public static const int ROLE_SYSTEM_HOTKEYFIELD = 0x32;
public static const int ROLE_SYSTEM_SLIDER = 0x33;
//public static const int ROLE_SYSTEM_SPINBUTTON = 0x34;
//public static const int ROLE_SYSTEM_DIAGRAM = 0x35;
//public static const int ROLE_SYSTEM_ANIMATION = 0x36;
//public static const int ROLE_SYSTEM_EQUATION = 0x37;
//public static const int ROLE_SYSTEM_BUTTONDROPDOWN = 0x38;
//public static const int ROLE_SYSTEM_BUTTONMENU = 0x39;
//public static const int ROLE_SYSTEM_BUTTONDROPDOWNGRID = 0x3a;
//public static const int ROLE_SYSTEM_WHITESPACE = 0x3b;
public static const int ROLE_SYSTEM_PAGETABLIST = 0x3c;
//public static const int ROLE_SYSTEM_CLOCK = 0x3d;

public static const int STATE_SYSTEM_NORMAL = 0;
//public static const int STATE_SYSTEM_UNAVAILABLE = 0x1;
public static const int STATE_SYSTEM_SELECTED = 0x2;
public static const int STATE_SYSTEM_FOCUSED = 0x4;
public static const int STATE_SYSTEM_PRESSED = 0x8;
public static const int STATE_SYSTEM_CHECKED = 0x10;
public static const int STATE_SYSTEM_MIXED = 0x20;
//public static const int STATE_SYSTEM_INDETERMINATE = STATE_SYSTEM_MIXED;
public static const int STATE_SYSTEM_READONLY = 0x40;
public static const int STATE_SYSTEM_HOTTRACKED = 0x80;
//public static const int STATE_SYSTEM_DEFAULT = 0x100;
public static const int STATE_SYSTEM_EXPANDED = 0x200;
public static const int STATE_SYSTEM_COLLAPSED = 0x400;
public static const int STATE_SYSTEM_BUSY = 0x800;
//public static const int STATE_SYSTEM_FLOATING = 0x1000;
//public static const int STATE_SYSTEM_MARQUEED = 0x2000;
//public static const int STATE_SYSTEM_ANIMATED = 0x4000;
public static const int STATE_SYSTEM_INVISIBLE = 0x8000;
public static const int STATE_SYSTEM_OFFSCREEN = 0x10000;
public static const int STATE_SYSTEM_SIZEABLE = 0x20000;
//public static const int STATE_SYSTEM_MOVEABLE = 0x40000;
//public static const int STATE_SYSTEM_SELFVOICING = 0x80000;
public static const int STATE_SYSTEM_FOCUSABLE = 0x100000;
public static const int STATE_SYSTEM_SELECTABLE = 0x200000;
public static const int STATE_SYSTEM_LINKED = 0x400000;
//public static const int STATE_SYSTEM_TRAVERSED = 0x800000;
public static const int STATE_SYSTEM_MULTISELECTABLE = 0x1000000;
//public static const int STATE_SYSTEM_EXTSELECTABLE = 0x2000000;
//public static const int STATE_SYSTEM_ALERT_LOW = 0x4000000;
//public static const int STATE_SYSTEM_ALERT_MEDIUM = 0x8000000;
//public static const int STATE_SYSTEM_ALERT_HIGH = 0x10000000;
//public static const int STATE_SYSTEM_PROTECTED = 0x20000000;
//public static const int STATE_SYSTEM_VALID = 0x3fffffff;

/* End ACCESSIBILITY */

}

/**
 * <Shawn> difference between WCHARzToStr(pwstr, -1) :
 * BSTRToStr() internally call WCHARzToStr(pwstr, length) with length set,
 * instead to determine the null ended, this mean BSTRToStr() can get string
 * which has embedded null characters.
 */
// BSTR is aliased to wchar*
// Note : Free the "bstr" memory if freeTheString is true, default false
String BSTRToStr( /*BSTR*/ ref wchar* bstr, bool freeTheString = false){
    if(bstr is null) return null;
    int size = (SysStringByteLen(bstr) + 1)/wchar.sizeof;
    String result = WCHARzToStr(bstr, size);
    if(freeTheString) {
        // free the string and set ptr to null
        SysFreeString(bstr);
        bstr = null;
    }
    return result;
}





