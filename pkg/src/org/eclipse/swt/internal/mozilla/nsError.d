module org.eclipse.swt.internal.mozilla.nsError;

import org.eclipse.swt.internal.mozilla.Common;

/**
 * @name Standard Module Offset Code. Each Module should identify a unique number
 *       and then all errors associated with that module become offsets from the
 *       base associated with that module id. There are 16 bits of code bits for
 *       each module.
 */

enum {
    NS_ERROR_MODULE_XPCOM = 1,
    NS_ERROR_MODULE_BASE = 2,
    NS_ERROR_MODULE_GFX = 3,
    NS_ERROR_MODULE_WIDGET = 4,
    NS_ERROR_MODULE_CALENDAR = 5,
    NS_ERROR_MODULE_NETWORK = 6,
    NS_ERROR_MODULE_PLUGINS = 7,
    NS_ERROR_MODULE_LAYOUT = 8,
    NS_ERROR_MODULE_HTMLPARSER = 9,
    NS_ERROR_MODULE_RDF = 10,
    NS_ERROR_MODULE_UCONV = 11,
    NS_ERROR_MODULE_REG = 12,
    NS_ERROR_MODULE_FILES = 13,
    NS_ERROR_MODULE_DOM = 14,
    NS_ERROR_MODULE_IMGLIB = 15,
    NS_ERROR_MODULE_MAILNEWS = 16,
    NS_ERROR_MODULE_EDITOR = 17,
    NS_ERROR_MODULE_XPCONNECT = 18,
    NS_ERROR_MODULE_PROFILE = 19,
    NS_ERROR_MODULE_LDAP = 20,
    NS_ERROR_MODULE_SECURITY = 21,
    NS_ERROR_MODULE_DOM_XPATH = 22,
    NS_ERROR_MODULE_DOM_RANGE = 23,
    NS_ERROR_MODULE_URILOADER = 24,
    NS_ERROR_MODULE_CONTENT = 25,
    NS_ERROR_MODULE_PYXPCOM = 26,
    NS_ERROR_MODULE_XSLT = 27,
    NS_ERROR_MODULE_IPC = 28,
    NS_ERROR_MODULE_SVG = 29,
    NS_ERROR_MODULE_STORAGE = 30,
    NS_ERROR_MODULE_SCHEMA = 31,
    NS_ERROR_MODULE_GENERAL = 51,
    NS_ERROR_SEVERITY_ERROR = 1,
    NS_ERROR_MODULE_BASE_OFFSET = 0x45,
}

const nsresult NS_OK = cast(nsresult)0;
const nsresult NS_ERROR_BASE = cast(nsresult) 0xC1F30000;
const nsresult NS_ERROR_NOT_INITIALIZED = cast(nsresult)(NS_ERROR_BASE + 1);
const nsresult NS_ERROR_ALREADY_INITIALIZED = cast(nsresult)(NS_ERROR_BASE + 2);
const nsresult NS_NOINTERFACE = cast(nsresult)0x80004002L;

alias NS_NOINTERFACE NS_ERROR_NO_INTERFACE;

const nsresult NS_ERROR_INVALID_POINTER = cast(nsresult)0x80004003L;

alias NS_ERROR_INVALID_POINTER NS_ERROR_NULL_POINTER;

const nsresult NS_ERROR_ABORT         = cast(nsresult)0x80004004L;
const nsresult NS_ERROR_FAILURE       = cast(nsresult)0x80004005L;
const nsresult NS_ERROR_UNEXPECTED    = cast(nsresult)0x8000ffffL;
const nsresult NS_ERROR_OUT_OF_MEMORY = cast(nsresult) 0x8007000eL;
const nsresult NS_ERROR_ILLEGAL_VALUE = cast(nsresult) 0x80070057L;

alias NS_ERROR_ILLEGAL_VALUE NS_ERROR_INVALID_ARG;
