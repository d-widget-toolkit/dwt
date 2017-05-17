module org.eclipse.swt.internal.opengl.win32.native;

private import org.eclipse.swt.internal.win32.WINTYPES;

extern (Windows):

int     ChoosePixelFormat( HDC, PIXELFORMATDESCRIPTOR* );
int     DescribePixelFormat( HDC, int, UINT, PIXELFORMATDESCRIPTOR* );
int     GetPixelFormat( HDC );
BOOL    SetPixelFormat( HDC, int, PIXELFORMATDESCRIPTOR* );
BOOL    SwapBuffers( HDC );

BOOL    wglCopyContext(HGLRC, HGLRC, UINT);
HGLRC   wglCreateContext(HDC);
HGLRC   wglCreateLayerContext(HDC, int);
BOOL    wglDeleteContext(HGLRC);
BOOL    wglDescribeLayerPlane(HDC, int, int, UINT, LPLAYERPLANEDESCRIPTOR);
HGLRC   wglGetCurrentContext();
HDC     wglGetCurrentDC();
int     wglGetLayerPaletteEntries(HDC, int, int, int, COLORREF*);
FARPROC wglGetProcAddress(LPCSTR);
BOOL    wglMakeCurrent(HDC, HGLRC);
BOOL    wglRealizeLayerPalette(HDC, int, BOOL);
int     wglSetLayerPaletteEntries(HDC, int, int, int, COLORREF*);
BOOL    wglShareLists(HGLRC, HGLRC);
BOOL    wglSwapLayerBuffers(HDC, UINT);
