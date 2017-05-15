module org.eclipse.swt.internal.mozilla.Common; 

version(Windows) {
    const NS_WIN32 = 1;
}
version(linux) {
    const NS_UNIX = 1;
}

alias uint nsresult;
alias uint nsrefcnt;

const nsnull = 0;

/******************************************************************************

    prtypes

******************************************************************************/

extern (System):

alias ubyte PRUint8;
alias byte  PRInt8;

const PR_INT8_MAX = 127;
const PR_UINT8_MAX = 255U;

alias ushort PRUint16;
alias short PRInt16;

const PR_INT16_MAX = 32767;
const PR_UINT16_MAX = 65535U;

alias uint PRUint32;
alias int PRInt32;

alias long PRInt64;
alias ulong PRUint64;

alias int PRIntn;
alias uint PRUintn;

alias double PRFloat64;
alias size_t PRSize;

alias PRInt32 PROffset32;
alias PRInt64 PROffset64;

alias ptrdiff_t PRPtrdiff;
alias uint      PRUptrdiff;

alias PRIntn PRBool;

const PR_TRUE = 1;
const PR_FALSE = 0;

alias PRUint8 PRPackedBool;

enum
{
    PR_FAILURE = -1,
    PR_SUCCESS,
}

alias int PRStatus;

alias wchar PRUnichar;

alias int PRWord;
alias uint PRUword;

/******************************************************************************

    nscommon

******************************************************************************/

alias void* nsIWidget;
alias void* nsILayoutHistoryState;
alias void* nsIDeviceContext;
alias void* nsPresContext;
alias void* nsEvent;
alias void* nsEventStatus;
alias void* nsIPresShell;
alias void* JSContext;

alias void* PRThread;
alias void* PLEvent;
alias void* PLEventQueue;
alias void* PLHandleEventProc;
alias void* PLDestroyEventProc;

/******************************************************************************

    gfxtypes

******************************************************************************/

alias PRUint32 gfx_color;
alias PRUint16 gfx_depth;
alias PRInt32  gfx_format;

alias void* nsIntRect;
alias void* nsRect;
