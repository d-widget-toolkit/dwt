/******************************************************************************

  module:

  Based on D version created by John Chapman for the Juno Project
    see: www.dsource.org/projects/juno

  Changes and Additions for DWT:
    John Reimer <terminal.node@gmail.com>

******************************************************************************/

module org.eclipse.swt.internal.gdip.native;

import org.eclipse.swt.internal.win32.WINTYPES;
import java.lang.all;

extern(Windows):

/******************************************************************************


******************************************************************************/

enum DebugEventLevel {
  Fatal,
  Warning
}

alias void  function(DebugEventLevel level, char* message) DebugEventProc;

alias int   function(out ULONG_PTR token) NotificationHookProc;
alias void  function(in  ULONG_PTR token) NotificationUnhookProc;


/******************************************************************************


******************************************************************************/


struct GdiplusStartupInput {
  uint GdiplusVersion;
  DebugEventProc DebugEventCallback;
  int SuppressBackgroundThread;
  int SuppressExternalCodecs;
}

struct GdiplusStartupOutput {
  NotificationHookProc NotificationHook;
  NotificationUnhookProc NotificationUnhook;
}

struct GpBitmapData {
  int Width;
  int Height;
  int Stride;
  int PixelFormat;
  void* Scan0;
  size_t Reserved;
}

struct GpColorMatrix {
  float[5][5] m;
}

struct GpPropertyItem {
  int id;
  int length;
  short type;
  void* value;
}

struct GpColorPalette {
  int Flags;
  int Count;
  int[1] Entries;
}

public struct GpRectF {
    public float X = 0;
    public float Y = 0;
    public float Width = 0;
    public float Height = 0;
}

public struct GpRect {
    public int X;
    public int Y;
    public int Width;
    public int Height;
}
public struct GpPoint {
    public int X;
    public int Y;
}
public struct GpPointF {
    public float X = 0;
    public float Y = 0;
}

alias int function(void*) GpDrawImageAbort;
alias GpDrawImageAbort GpGetThumbnailImageAbort;

/******************************************************************************


******************************************************************************/

enum Status {
  OK,
  GenericError,
  InvalidParameter,
  OutOfMemory,
  ObjectBusy,
  InsufficientBuffer,
  NotImplemented,
  Win32Error,
  WrongState,
  Aborted,
  FileNotFound,
  ValueOverflow,
  AccessDenied,
  UnknownImageFormat,
  FontFamilyNotFound,
  FontStyleNotFound,
  NotTrueTypeFont,
  UnsupportedGdiplusVersion,
  GdiplusNotInitialized,
  PropertyNotFound,
  PropertyNotSupported
}

/**************************************************************************

	Opaque types managed by Gdi+

**************************************************************************/
alias GpImage  GpBitmap;

// alias   uint   ARGB;
alias Handle GpFontFamily;
alias Handle GpImage;
alias Handle GpBrush;
alias Handle GpFont;
alias Handle GpFontCollection;
alias Handle GpGraphics;
alias Handle GpGraphicsPath;
alias Handle GpImageAttributes;
alias Handle GpHatchBrush;
alias Handle GpLinearGradientBrush;
alias Handle GpMatrix;
alias Handle GpPen;
alias Handle GpRegion;
alias Handle GpSolidBrush;
alias Handle GpStringFormat;
alias Handle GpTextureBrush;
alias Handle GpPath;

alias void* Handle;

alias int BrushType;
alias int CombineMode;
alias int FlushIntention;
alias int MatrixOrder;
alias int GraphicsUnit;
alias int QualityMode;
alias int SmoothingMode;
alias int InterpolationMode;
alias int CompositingMode;
alias int CompositingQuality;
alias int PixelOffsetMode;
alias int PixelFormat;
alias int RotateFlipType;
alias int CoordinateSpace;
alias int WarpMode;
alias int WrapMode;
alias int FillMode;
alias int LineJoin;
alias int LineCap;
alias int DashCap;
alias int DashStyle;
alias int PenAlignment;
alias int ColorMatrixFlag;
alias int ColorAdjustType;
alias int ColorChannelFlag;
alias int ImageLockMode;
alias int ImageCodecFlags;
alias int EncoderParameterValueType;
alias int GenericFontFamilies;
alias int FontStyle;
alias int HatchStyle;
alias int StringFormatFlags;
alias int StringAlignment;
alias int StringTrimming;
alias int TextRenderingHint;
alias int PenType;
alias int LinearGradientMode;
alias int KnownColor;
alias int Unit;

alias uint GraphicsState;

/******************************************************************************

	Flat GDI+ Exports (C Interface)

******************************************************************************/

extern (Windows):

version( STATIC_GDIPLUS ){
Status GdiplusStartup(ULONG_PTR* token, GdiplusStartupInput* input, GdiplusStartupOutput* output);
void   GdiplusShutdown(in uint token);
Status GdipCreateFromHDC(Handle hdc, out Handle graphics);
Status GdipCreateFromHDC2(Handle hdc, Handle hDevice, out Handle graphics);
Status GdipCreateFromHWND(Handle hwnd, out Handle graphics);
Status GdipGetImageGraphicsContext(Handle image, out Handle graphics);
Status GdipDeleteGraphics(Handle graphics);
Status GdipGetDC(Handle graphics, out Handle hdc);
Status GdipReleaseDC(Handle graphics, Handle hdc);
Status GdipSetClipGraphics(Handle graphics, in Handle srcgraphics, in CombineMode combineMode);
Status GdipSetClipRectI(Handle graphics, in int x, in int y, in int width, in int height, in CombineMode combineMode);
Status GdipSetClipRect(Handle graphics, in float x, in float y, in float width, in float height, in CombineMode combineMode);
Status GdipSetClipPath(Handle graphics, in Handle path, in CombineMode combineMode);
Status GdipSetClipRegion(Handle graphics, in Handle region, in CombineMode combineMode);
Status GdipSetClipHrgn(Handle graphics, in HRGN hRgn, in CombineMode combineMode);

Status GdipGetClip(Handle graphics, out Handle region);
Status GdipResetClip(Handle graphics);
Status GdipSaveGraphics(Handle graphics, out uint state);
Status GdipRestoreGraphics(Handle graphics, in int state);
Status GdipFlush(Handle graphics, in FlushIntention intention);
Status GdipScaleWorldTransform(Handle graphics, in float sx, in float sy, in MatrixOrder order);
Status GdipRotateWorldTransform(Handle graphics, in float angle, in MatrixOrder order);
Status GdipTranslateWorldTransform(Handle graphics, in float dx, in float dy, in MatrixOrder order);
Status GdipMultiplyWorldTransform(Handle graphics, Handle matrix, in MatrixOrder order);
Status GdipResetWorldTransform(Handle graphics);
Status GdipBeginContainer(Handle graphics, ref GpRectF dstrect, ref GpRectF srcrect, in GraphicsUnit unit, out int state);
Status GdipBeginContainerI(Handle graphics, ref GpRect dstrect, ref GpRect srcrect, in GraphicsUnit unit, out int state);
Status GdipBeginContainer2(Handle graphics, out int state);
Status GdipEndContainer(Handle graphics, in int state);
Status GdipGetDpiX(Handle graphics, out float dpi);
Status GdipGetDpiY(Handle graphics, out float dpi);
Status GdipGetPageUnit(Handle graphics, out GraphicsUnit unit);
Status GdipSetPageUnit(Handle graphics, in GraphicsUnit unit);
Status GdipGetPageScale(Handle graphics, out float scale);
Status GdipSetPageScale(Handle graphics, in float scale);
Status GdipGetWorldTransform(Handle graphics, Handle matrix); // out not necessary?
Status GdipSetWorldTransform(Handle graphics, in Handle matrix);
Status GdipGetCompositingMode(Handle graphics, out CompositingMode compositingMode);
Status GdipSetCompositingMode(Handle graphics, in CompositingMode compositingMode);
Status GdipGetCompositingQuality(Handle graphics, out CompositingQuality compositingQuality);
Status GdipSetCompositingQuality(Handle graphics, in CompositingQuality compositingQuality);
Status GdipGetInterpolationMode(Handle graphics, out InterpolationMode interpolationMode);
Status GdipSetInterpolationMode(Handle graphics, in InterpolationMode interpolationMode);
Status GdipGetSmoothingMode(Handle graphics, out SmoothingMode smoothingMode);
Status GdipSetSmoothingMode(Handle graphics, in SmoothingMode smoothingMode);
Status GdipGetPixelOffsetMode(Handle graphics, out PixelOffsetMode pixelOffsetMode);
Status GdipSetPixelOffsetMode(Handle graphics, in PixelOffsetMode pixelOffsetMode);
Status GdipGetTextContrast(Handle graphics, out uint textContrast);
Status GdipSetTextContrast(Handle graphics, in uint textContrast);
Status GdipGraphicsClear(Handle graphics, in int color);
Status GdipDrawLine(Handle graphics, Handle pen, in float x1, in float y1, in float x2, in float y2);
Status GdipDrawLines(Handle graphics, Handle pen, GpPointF* points, in int count);
Status GdipDrawLineI(Handle graphics, Handle pen, in int x1, in int y1, in int x2, in int y2);
Status GdipDrawLinesI(Handle graphics, Handle pen, GpPoint* points, in int count);
Status GdipDrawArc(Handle graphics, Handle pen, in float x, in float y, in float width, in float height, in float startAngle, in float sweepAngle);
Status GdipDrawArcI(Handle graphics, Handle pen, in int x, in int y, in int width, in int height, in float startAngle, in float sweepAngle);
Status GdipDrawBezier(Handle graphics, Handle pen, in float x1, in float y1, in float x2, in float y2, in float x3, in float y3, in float x4, in float y4);
Status GdipDrawBeziers(Handle graphics, Handle pen, GpPointF* points, in int count);
Status GdipDrawBezierI(Handle graphics, Handle pen, in int x1, in int y1, in int x2, in int y2, in int x3, in int y3, in int x4, in int y4);
Status GdipDrawBeziersI(Handle graphics, Handle pen, GpPoint* points, in int count);
Status GdipDrawRectangle(Handle graphics, Handle pen, in float x, in float y, in float width, in float height);
Status GdipDrawRectangles(Handle graphics, Handle pen, GpRectF* rects, in int count);
Status GdipDrawRectangleI(Handle graphics, Handle pen, in int x, in int y, in int width, in int height);
Status GdipDrawRectanglesI(Handle graphics, Handle pen, GpRect* rects, in int count);
Status GdipDrawEllipse(Handle graphics, Handle pen, in float x, in float y, in float width, in float height);
Status GdipDrawEllipseI(Handle graphics, Handle pen, in int x, in int y, in int width, in int height);
Status GdipDrawPie(Handle graphics, Handle pen, in float x, in float y, in float width, in float height, in float startAngle, in float sweepAngle);
Status GdipDrawPieI(Handle graphics, Handle pen, in int x, in int y, in int width, in int height, in float startAngle, in float sweepAngle);
Status GdipDrawPolygon(Handle graphics, Handle pen, GpPointF* points, in int count);
Status GdipDrawPolygonI(Handle graphics, Handle pen, GpPoint* points, in int count);
Status GdipDrawCurve(Handle graphics, Handle pen, GpPointF* points, in int count);
Status GdipDrawCurve2(Handle graphics, Handle pen, GpPointF* points, in int count, in float tension);
Status GdipDrawCurve3(Handle graphics, Handle pen, GpPointF* points, in int count, in int offset, in int numberOfSegments, in float tension);
Status GdipDrawCurveI(Handle graphics, Handle pen, GpPoint* points, in int count);
Status GdipDrawCurve2I(Handle graphics, Handle pen, GpPoint* points, in int count, in float tension);
Status GdipDrawCurve3I(Handle graphics, Handle pen, GpPoint* points, in int count, in int offset, in int numberOfSegments, in float tension);
Status GdipDrawClosedCurve(Handle graphics, Handle pen, GpPointF* points, in int count);
Status GdipDrawClosedCurve2(Handle graphics, Handle pen, GpPointF* points, in int count, in float tension);
Status GdipDrawClosedCurveI(Handle graphics, Handle pen, GpPoint* points, in int count);
Status GdipDrawClosedCurve2I(Handle graphics, Handle pen, GpPoint* points, in int count, in float tension);
Status GdipFillRectangleI(Handle graphics, Handle brush, in int x, in int y, in int width, in int height);
Status GdipFillRectangle(Handle graphics, Handle brush, in float x, in float y, in float width, in float height);
Status GdipFillRectanglesI(Handle graphics, Handle brush, GpRect* rects, in int count);
Status GdipFillRectangles(Handle graphics, Handle brush, GpRectF* rects, in int count);
Status GdipFillPolygon(Handle graphics, Handle brush, GpPointF* rects, in int count, in FillMode fillMode);
Status GdipFillPolygonI(Handle graphics, Handle brush, GpPoint* rects, in int count, in FillMode fillMode);
Status GdipFillEllipse(Handle graphics, Handle brush, in float x, in float y, in float width, in float height);
Status GdipFillEllipseI(Handle graphics, Handle brush, in int x, in int y, in int width, in int height);
Status GdipFillPie(Handle graphics, Handle brush, in float x, in float y, in float width, in float height, in float startAngle, in float sweepAngle);
Status GdipFillPieI(Handle graphics, Handle brush, in int x, in int y, in int width, in int height, in float startAngle, in float sweepAngle);
Status GdipFillPath(Handle graphics, Handle brush, Handle path);
Status GdipFillClosedCurve(Handle graphics, Handle brush, GpPointF* points, in int count);
Status GdipFillClosedCurveI(Handle graphics, Handle brush, GpPoint* points, in int count);
Status GdipFillClosedCurve2(Handle graphics, Handle brush, GpPointF* points, in int count, in FillMode fillMode, in float tension);
Status GdipFillClosedCurve2I(Handle graphics, Handle brush, GpPoint* points, in int count, in FillMode fillMode, in float tension);
Status GdipFillRegion(Handle graphics, Handle brush, Handle region);
Status GdipDrawString(Handle graphics, LPCWSTR string, in int length, Handle font, ref GpRectF layoutRect, Handle stringFormat, Handle brush);
Status GdipMeasureString(Handle graphics, LPCWSTR string, in int length, Handle font, ref GpRectF layoutRect, Handle stringFormat, ref GpRectF boundingBox, int* codepointsFitted, int* linesFitted);
Status GdipGetStringFormatMeasurableCharacterRangeCount(Handle format, out int count);
Status GdipCloneStringFormat(Handle format, out Handle newFormat);

Status GdipMeasureCharacterRanges(Handle graphics, LPCWSTR string, in int length, Handle font, ref GpRectF layoutRect, Handle stringFormat, in int regionCount, Handle* regions);
Status GdipDrawImage(Handle graphics, Handle image, in float x, in float y);
Status GdipDrawImageI(Handle graphics, Handle image, in int x, in int y);
Status GdipDrawImageRect(Handle graphics, Handle image, in float x, in float y, in float width, in float height);
Status GdipDrawImageRectI(Handle graphics, Handle image, in int x, in int y, in int width, in int height);
Status GdipDrawImagePointRect(Handle graphics, Handle image, in float x, in float y, in float srcx, in float srcy, in float srcwidth, in float srcheight, in GraphicsUnit srcUnit);
Status GdipDrawImagePointRectI(Handle graphics, Handle image, in int x, in int y, in int srcx, in int srcy, in int srcwidth, in int srcheight, in GraphicsUnit srcUnit);
Status GdipDrawImageRectRect(Handle graphics, Handle image, in float dstx, in float dsty, in float dstwidth, in float dstheight, in float srcx, in float srcy, in float srcwidth, in float srcheight, in GraphicsUnit srcUnit, Handle imageAttributes, GpDrawImageAbort callback, void* callbakcData);
Status GdipDrawImageRectRectI(Handle graphics, Handle image, in int dstx, in int dsty, in int dstwidth, in int dstheight, in int srcx, in int srcy, in int srcwidth, in int srcheight, in GraphicsUnit srcUnit, Handle imageAttributes, GpDrawImageAbort callback, void* callbakcData);
Status GdipDrawImagePoints(Handle graphics, Handle image, GpPointF* dstpoints, in int count);
Status GdipDrawImagePointsI(Handle graphics, Handle image, GpPoint* dstpoints, in int count);
Status GdipDrawImagePointsRect(Handle graphics, Handle image, GpPointF* dstpoints, in int count, in float srcx, in float srcy, in float srcwidth, in float srcheight, in GraphicsUnit srcUnit, Handle imageAttributes, GpDrawImageAbort callback, void* callbakcData);
Status GdipDrawImagePointsRectI(Handle graphics, Handle image, GpPoint* dstpoints, in int count, in int srcx, in int srcy, in int srcwidth, in int srcheight, in GraphicsUnit srcUnit, Handle imageAttributes, GpDrawImageAbort callback, void* callbakcData);
Status GdipIsVisiblePoint(Handle graphics, in float x, in float y, out int result);
Status GdipIsVisiblePointI(Handle graphics, in int x, in int y, out int result);
Status GdipIsVisibleRect(Handle graphics, in float x, in float y, in float width, in float height, out int result);
Status GdipIsVisibleRectI(Handle graphics, in int x, in int y, in int width, in int height, out int result);
Status GdipGetTextRenderingHint(Handle graphics, out TextRenderingHint mode);
Status GdipSetTextRenderingHint(Handle graphics, in TextRenderingHint mode);
Status GdipGetClipBounds(Handle graphics, out GpRectF rect);
Status GdipGetClipBoundsI(Handle graphics, out GpRect rect);
Status GdipGetVisibleClipBounds(Handle graphics, out GpRectF rect);
Status GdipGetVisibleClipBoundsI(Handle graphics, out GpRect rect);
Status GdipIsClipEmpty(Handle graphics, out int result);
Status GdipIsVisibleClipEmpty(Handle graphics, out int result);
Status GdipGetRenderingOrigin(Handle graphics, out int x, out int y);
Status GdipSetRenderingOrigin(Handle graphics, in int x, in int y);
Status GdipGetNearestColor(Handle graphics, ref int argb);
Status GdipComment(Handle graphics, in uint sizeData, ubyte* data);
Status GdipTransformPoints(Handle graphics, in CoordinateSpace destSpace, in CoordinateSpace srcSpace, GpPointF* points, in int count);
Status GdipTransformPointsI(Handle graphics, in CoordinateSpace destSpace, in CoordinateSpace srcSpace, GpPoint* points, in int count);

Status GdipCreateMatrix(out Handle matrix);
Status GdipCreateMatrix2(in float m11, in float m12, in float m21, in float m22, in float dx, in float dy, out Handle matrix);
Status GdipCreateMatrix3(ref GpRectF rect, GpPointF* dstplg, out Handle matrix);
Status GdipCreateMatrix3I(ref GpRect rect, GpPoint* dstplg, out Handle matrix);
Status GdipDeleteMatrix(Handle matrix);
Status GdipCloneMatrix(Handle matrix, out Handle cloneMatrix);
Status GdipGetMatrixElements(Handle matrix, float* matrixOut);
Status GdipSetMatrixElements(Handle matrix, in float m11, in float m12, in float m21, in float m22, in float xy, in float dy);
Status GdipInvertMatrix(Handle matrix);
Status GdipMultiplyMatrix(Handle matrix, Handle matrix2, in MatrixOrder order);
Status GdipScaleMatrix(Handle matrix, in float scaleX, in float scaleY, in MatrixOrder order);
Status GdipShearMatrix(Handle matrix, in float shearX, in float shearY, in MatrixOrder order);
Status GdipRotateMatrix(Handle matrix, in float angle, in MatrixOrder order);
Status GdipTranslateMatrix(Handle matrix, in float offsetX, in float offsetY, in MatrixOrder order);
Status GdipIsMatrixIdentity(Handle matrix, out int result);
Status GdipIsMatrixInvertible(Handle matrix, out int result);
Status GdipTransformMatrixPoints(Handle matrix, GpPointF *pts, in int count);

Status GdipGetBrushType(Handle brush, out BrushType type );
Status GdipCloneBrush(Handle brush, out Handle cloneBrush);
Status GdipDeleteBrush(Handle brush);

Status GdipCreateSolidFill(in int color, out Handle brush);
Status GdipGetSolidFillColor(Handle brush, out int color);
Status GdipSetSolidFillColor(Handle brush, in int color);

Status GdipCreateTexture(Handle image, in WrapMode wrapMode, out Handle texture);
Status GdipCreateTexture2(Handle image, in WrapMode wrapMode, in float x, in float y, in float width, in float height, out Handle texture);
Status GdipCreateTexture2I(Handle image, in WrapMode wrapMode, in int x, in int y, in int width, in int height, out Handle texture);
Status GdipGetTextureImage(Handle brush, out Handle image);
Status GdipGetTextureTransform(Handle brush, out Handle matrix);
Status GdipSetTextureTransform(Handle brush, in Handle matrix);
Status GdipGetTextureWrapMode(Handle brush, out WrapMode wrapmode);
Status GdipSetTextureWrapMode(Handle brush, in WrapMode wrapmode);

Status GdipCreateHatchBrush(in HatchStyle hatchstyle, in int forecol, in int backcol, out Handle brush);
Status GdipGetHatchStyle(Handle brush, out HatchStyle hatchstyle);
Status GdipGetHatchForegroundColor(Handle brush, out int forecol);
Status GdipGetHatchBackgroundColor(Handle brush, out int backcol);

Status GdipCreateLineBrushI(ref GpPoint point1, ref GpPoint point2, in int color1, in int color2, in WrapMode wrapMode, out Handle lineGradient);
Status GdipCreateLineBrush(ref GpPointF point1, ref GpPointF point2, in int color1, in int color2, in WrapMode wrapMode, out Handle lineGradient);
Status GdipCreateLineBrushFromRectI(ref GpRect rect, in int color1, in int color2, in LinearGradientMode mode, in WrapMode wrapMode, out Handle lineGradient);
Status GdipCreateLineBrushFromRect(ref GpRectF rect, in int color1, in int color2, in LinearGradientMode mode, in WrapMode wrapMode, out Handle lineGradient);
Status GdipCreateLineBrushFromRectWithAngleI(ref GpRect rect, in int color1, in int color2, in float angle, in int isAngleScalable, in WrapMode wrapMode, out Handle lineGradient);
Status GdipCreateLineBrushFromRectWithAngle(ref GpRectF rect, in int color1, in int color2, in float angle, in int isAngleScalable, in WrapMode wrapMode, out Handle lineGradient);
Status GdipGetLineBlendCount(Handle brush, out int count);
Status GdipGetLineBlend(Handle brush, float* blend, float* positions, in int count);
Status GdipSetLineBlend(Handle brush, in float* blend, in float* positions, in int count);
Status GdipGetLinePresetBlendCount(Handle brush, out int count);
Status GdipGetLinePresetBlend(Handle brush, uint* blend, float* positions, in int count);
Status GdipSetLinePresetBlend(Handle brush, in uint* blend, in float* positions, in int count);
Status GdipGetLineWrapMode(Handle brush, out WrapMode wrapmode);
Status GdipSetLineWrapMode(Handle brush, in WrapMode wrapmode);
Status GdipGetLineRect(Handle brush, out GpRectF rect);
Status GdipGetLineColors(Handle brush, int* colors);
Status GdipSetLineColors(Handle brush, in int color1, in int color2);
Status GdipGetLineGammaCorrection(Handle brush, out int useGammaCorrection);
Status GdipSetLineGammaCorrection(Handle brush, in int useGammaCorrection);
Status GdipSetLineSigmaBlend(Handle brush, in float focus, in float scale);
Status GdipSetLineLinearBlend(Handle brush, in float focus, in float scale);
Status GdipGetLineTransform(Handle brush, out Handle matrix);
Status GdipSetLineTransform(Handle brush, Handle matrix);
Status GdipResetLineTransform(Handle brush);
Status GdipMultiplyLineTransform(Handle brush, Handle matrix, in MatrixOrder order);
Status GdipTranslateLineTransform(Handle brush, in float dx, in float dy, in MatrixOrder order);
Status GdipScaleLineTransform(Handle brush, in float sx, in float sy, in MatrixOrder order);
Status GdipRotateLineTransform(Handle brush, in float angle, in MatrixOrder order);

Status GdipCreatePen1(in int argb, in float width, in GraphicsUnit unit, out Handle pen);
Status GdipCreatePen2(Handle brush, in float width, in GraphicsUnit unit, out Handle pen);
Status GdipDeletePen(Handle pen);
Status GdipClonePen(Handle pen, out Handle clonepen);
Status GdipSetPenLineCap197819(Handle pen, in LineCap startCap, in LineCap endCap, in DashCap dashCap);
Status GdipGetPenStartCap(Handle pen, out LineCap startCap);
Status GdipSetPenStartCap(Handle pen, in LineCap startCap);
Status GdipGetPenEndCap(Handle pen, out LineCap endCap);
Status GdipSetPenEndCap(Handle pen, in LineCap endCap);
Status GdipGetPenDashCap197819(Handle pen, out DashCap endCap);
Status GdipSetPenDashCap197819(Handle pen, in DashCap endCap);
Status GdipGetPenLineJoin(Handle pen, out LineJoin lineJoin);
Status GdipSetPenLineJoin(Handle pen, in LineJoin lineJoin);
Status GdipGetPenMiterLimit(Handle pen, out float miterLimit);
Status GdipSetPenMiterLimit(Handle pen, in float miterLimit);
Status GdipGetPenMode(Handle pen, out PenAlignment penMode);
Status GdipSetPenMode(Handle pen, in PenAlignment penMode);
Status GdipGetPenTransform(Handle pen, out Handle matrix);
Status GdipSetPenTransform(Handle pen, Handle matrix);
Status GdipResetPenTransform(Handle pen);
Status GdipMultiplyPenTransform(Handle pen, Handle matrix, in MatrixOrder order);
Status GdipTranslatePenTransform(Handle pen, in float dx, in float dy, in MatrixOrder order);
Status GdipScalePenTransform(Handle pen, in float sx, in float sy, in MatrixOrder order);
Status GdipRotatePenTransform(Handle pen, in float angle, in MatrixOrder order);
Status GdipGetPenColor(Handle pen, out int argb);
Status GdipSetPenColor(Handle pen, in int argb);
Status GdipGetPenWidth(Handle pen, out float width);
Status GdipSetPenWidth(Handle pen, in float width);
Status GdipGetPenFillType(Handle pen, out PenType type);
Status GdipGetPenBrushFill(Handle pen, out Handle brush);
Status GdipSetPenBrushFill(Handle pen, Handle brush);
Status GdipGetPenDashStyle(Handle pen, out DashStyle dashstyle);
Status GdipSetPenDashStyle(Handle pen, in DashStyle dashstyle);
Status GdipGetPenDashOffset(Handle pen, out float offset);
Status GdipSetPenDashOffset(Handle pen, in float offset);
Status GdipGetPenDashCount(Handle pen, out int count);
Status GdipGetPenDashArray(Handle pen, float* dash, in int count);
Status GdipSetPenDashArray(Handle pen, in float* dash, in int count);
Status GdipGetPenCompoundCount(Handle pen, out int count);
Status GdipGetPenCompoundArray(Handle pen, float* dash, in int count);
Status GdipSetPenCompoundArray(Handle pen, in float* dash, in int count);

Status GdipCreateRegion(out Handle region);
Status GdipCreateRegionRect(ref GpRectF rect, out Handle region);
Status GdipCreateRegionRectI(ref GpRect rect, out Handle region);
Status GdipCreateRegionPath(Handle path, out Handle region);
Status GdipCreateRegionHrgn(Handle hRgn, out Handle region);
Status GdipDeleteRegion(Handle region);
Status GdipSetInfinite(Handle region);
Status GdipSetEmpty(Handle region);
Status GdipCombineRegionRect(Handle region, ref GpRectF rect, in CombineMode combineMode);
Status GdipCombineRegionRectI(Handle region, ref GpRect rect, in CombineMode combineMode);
Status GdipCombineRegionPath(Handle region, Handle path, in CombineMode combineMode);
Status GdipCombineRegionRegion(Handle region, Handle region, in CombineMode combineMode);
Status GdipTranslateRegion(Handle region, in float dx, in float dy);
Status GdipTranslateRegionI(Handle region, in int dx, in int dy);
Status GdipTransformRegion(Handle region, Handle matrix);
Status GdipGetRegionBounds(Handle region, Handle graphics, out GpRectF rect);
Status GdipGetRegionHRgn(Handle region, Handle graphics, out Handle hRgn);
Status GdipIsEmptyRegion(Handle region, Handle graphics, out int result);
Status GdipIsInfiniteRegion(Handle region, Handle graphics, out int result);
Status GdipIsEqualRegion(Handle region1, Handle region2, Handle graphics, out int result);
Status GdipIsVisibleRegionPoint(Handle region, in float x, in float y, Handle graphics, out int result);
Status GdipIsVisibleRegionRect(Handle region, in float x, in float y, in float width, in float height, Handle graphics, out int result);
Status GdipIsVisibleRegionPointI(Handle region, in int x, in int y, Handle graphics, out int result);
Status GdipIsVisibleRegionRectI(Handle region, in int x, in int y, in int width, in int height, Handle graphics, out int result);
Status GdipGetRegionScansCount(Handle region, out int count, Handle matrix);
Status GdipGetRegionScans(Handle region, GpRectF* rects, out int count, Handle matrix);

Status GdipDisposeImage(Handle image);
Status GdipImageForceValidation(Handle image);
Status GdipLoadImageFromFileICM(LPCWSTR filename, out Handle image);
Status GdipLoadImageFromFile(LPCWSTR filename, out Handle image);
// Status GdipLoadImageFromStreamICM(IStream stream, out Handle image);
// Status GdipLoadImageFromStream(IStream stream, out Handle image);
// Status GdipGetImageRawFormat(Handle image, out GUID format);
Status GdipGetImageEncodersSize(out int numEncoders, out int size);
// Status GdipGetImageEncoders(in int numEncoders, in int size, GpImageCodecInfo* encoders);
// Status GdipSaveImageToFile(Handle image, LPCWSTR filename, ref GUID clsidEncoder, GpEncoderParameters* encoderParams);
// Status GdipSaveImageToStream(Handle image, IStream stream, ref GUID clsidEncoder, GpEncoderParameters* encoderParams);
// Status GdipSaveAdd(Handle image, GpEncoderParameters* encoderParams);
// Status GdipSaveAddImage(Handle image, Handle newImage, GpEncoderParameters* encoderParams);
Status GdipCloneImage(Handle image, out Handle cloneImage);
Status GdipGetImageType(Handle image, out int type);
Status GdipGetImageFlags(Handle image, out uint flags);
Status GdipGetImageWidth(Handle image, out uint width);
Status GdipGetImageHeight(Handle image, out uint height);
Status GdipGetImageHorizontalResolution(Handle image, out float resolution);
Status GdipGetImageVerticalResolution(Handle image, out float resolution);
Status GdipGetPropertyCount(Handle image, out int numOfProperty);
Status GdipGetPropertyIdList(Handle image, in int numOfProperty, int* list);
Status GdipGetImagePixelFormat(Handle image, out PixelFormat format);
Status GdipGetImageDimension(Handle image, out float width, out float height);
Status GdipGetImageThumbnail(Handle image, in int thumbWidth, in int thumbHeight, out Handle thumbImage, GpGetThumbnailImageAbort callback, void* callbackData);
// Status GdipImageGetFrameCount(Handle image, ref GUID dimensionID, out int count);
// Status GdipImageSelectActiveFrame(Handle image, ref GUID dimensionID, in int frameCount);
Status GdipImageGetFrameDimensionsCount(Handle image, out int count);
// Status GdipImageGetFrameDimensionsList(Handle image, GUID* dimensionIDs, in int count);
Status GdipImageRotateFlip(Handle image, in RotateFlipType rotateFlipType);
Status GdipGetPropertyItemSize(Handle image, in int propId, out uint propSize);
Status GdipGetPropertyItem(Handle image, in int propId, in uint propSize, GpPropertyItem* buffer);
Status GdipSetPropertyItem(Handle image, ref GpPropertyItem buffer);
Status GdipRemovePropertyItem(Handle image, in int propId);
Status GdipGetPropertySize(Handle image, out uint totalBufferSize, ref int numProperties);
Status GdipGetAllPropertyItems(Handle image, in uint totalBufferSize, in int numProperties, GpPropertyItem* allItems);
Status GdipGetImageBounds(Handle image, out GpRectF srcRect, out GraphicsUnit srcUnit);
// Status GdipGetEncoderParameterListSize(Handle image, ref GUID clsidEncoder, out uint size);
// Status GdipGetEncoderParameterList(Handle image, ref GUID clsidEncoder, in uint size, GpEncoderParameters* buffer);
Status GdipGetImagePaletteSize(Handle image, out int size);
Status GdipGetImagePalette(Handle image, GpColorPalette* palette, in int size);
Status GdipSetImagePalette(Handle image, in GpColorPalette* palette);

Status GdipCreateBitmapFromScan0(in int width, in int height, in int stride, in PixelFormat format, ubyte* scan0, out Handle bitmap);
Status GdipCreateBitmapFromHBITMAP(Handle hbitmap, Handle hpalette, out Handle bitmap);
Status GdipCreateBitmapFromHICON(Handle hicon, out Handle bitmap);
Status GdipCreateBitmapFromFileICM(LPCWSTR fileName, out Handle bitmap);
Status GdipCreateBitmapFromFile(LPCWSTR fileName, out Handle bitmap);
// Status GdipCreateBitmapFromStreamICM(IStream stream, out Handle bitmap);
// Status GdipCreateBitmapFromStream(IStream stream, out Handle bitmap);
Status GdipCreateBitmapFromGraphics(in int width, in int height, Handle graphics, out Handle bitmap);
Status GdipCloneBitmapArea(in float x, in float y, in float width, in float height, in PixelFormat format, Handle srcbitmap, out Handle dstbitmap);
Status GdipCloneBitmapAreaI(in int x, in int y, in int width, in int height, in PixelFormat format, Handle srcbitmap, out Handle dstbitmap);
Status GdipBitmapGetPixel(Handle bitmap, in int x, in int y, out int color);
Status GdipBitmapSetPixel(Handle bitmap, in int x, in int y, in int color);
Status GdipBitmapLockBits(Handle bitmap, GpRect* rect, in ImageLockMode flags, in PixelFormat format, GpBitmapData* lockedBitmapData);
Status GdipBitmapUnlockBits(Handle bitmap, GpBitmapData* lockedBitmapData);
Status GdipBitmapSetResolution(Handle bitmap, in float xdpi, in float ydpi);
Status GdipCreateHICONFromBitmap(Handle bitmap, out Handle hbmReturn);
Status GdipCreateHBITMAPFromBitmap(Handle bitmap, out Handle hbmReturn, in int background);

Status GdipCreateImageAttributes(out Handle imageattr);
Status GdipDisposeImageAttributes(Handle imageattr);
Status GdipSetImageAttributesColorMatrix(Handle imageattr, in ColorAdjustType type, in int enableFlag, in GpColorMatrix* colorMatrix, in GpColorMatrix* grayMatrix, in ColorMatrixFlag flags);
Status GdipSetImageAttributesThreshold(Handle imageattr, in ColorAdjustType type, in int enableFlag, in float threshold);
Status GdipSetImageAttributesGamma(Handle imageattr, in ColorAdjustType type, in int enableFlag, in float gamma);
Status GdipSetImageAttributesNoOp(Handle imageattr, in ColorAdjustType type, in int enableFlag);
Status GdipSetImageAttributesColorKeys(Handle imageattr, in ColorAdjustType type, in int enableFlag, in int colorLow, in int colorHigh);
Status GdipSetImageAttributesOutputChannel(Handle imageattr, in ColorAdjustType type, in int enableFlag, in ColorChannelFlag flags);
Status GdipSetImageAttributesOutputChannelColorProfile(Handle imageattr, in ColorAdjustType type, in int enableFlag, LPCWSTR colorProfileFilename);
Status GdipSetImageAttributesWrapMode(Handle imageattr, in WrapMode wrap, in int argb, in int clamp);

Status GdipNewInstalledFontCollection(out Handle fontCollection);
Status GdipNewPrivateFontCollection(out Handle fontCollection);
Status GdipDeletePrivateFontCollection(Handle fontCollection);
Status GdipPrivateAddFontFile(Handle fontCollection, LPCWSTR filename);
Status GdipPrivateAddMemoryFont(Handle fontCollection, void* memory, in int length);
Status GdipGetFontCollectionFamilyCount(Handle fontCollection, out int numFound);
Status GdipGetFontCollectionFamilyList(Handle fontCollection, in int numSought, Handle* gpfamilies, out int numFound);

Status GdipCreateFontFamilyFromName(LPCWSTR name, Handle fontCollection, out Handle FontFamily);
Status GdipDeleteFontFamily(Handle FontFamily);
Status GdipCloneFontFamily(Handle FontFamily, out Handle clonedFontFamily);
Status GdipGetFamilyName(Handle family, LPCWSTR name, in int language);
Status GdipGetGenericFontFamilyMonospace(out Handle nativeFamily);
Status GdipGetGenericFontFamilySerif(out Handle nativeFamily);
Status GdipGetGenericFontFamilySansSerif(out Handle nativeFamily);
Status GdipGetEmHeight(Handle family, in FontStyle style, out short EmHeight);
Status GdipGetCellAscent(Handle family, in FontStyle style, out short CellAscent);
Status GdipGetCellDescent(Handle family, in FontStyle style, out short CellDescent);
Status GdipGetLineSpacing(Handle family, in FontStyle style, out short LineSpacing);
Status GdipIsStyleAvailable(Handle family, in FontStyle style, out int IsStyleAvailable);

Status GdipCreateFont(Handle fontFamily, in float emSize, in int style, in int unit, out Handle font);
Status GdipCreateFontFromDC(Handle hdc, out Handle font);
Status GdipDeleteFont(Handle font);
Status GdipCloneFont(Handle font, out Handle cloneFont);
Status GdipGetFontSize(Handle font, out float size);
Status GdipGetFontHeight(Handle font, Handle graphics, out float height);
Status GdipGetFontHeightGivenDPI(Handle font, in float dpi, out float height);
Status GdipGetFontStyle(Handle font, out FontStyle style);
Status GdipGetFontUnit(Handle font, out GraphicsUnit unit);
Status GdipGetFamily(Handle font, out Handle family);
Status GdipCreateFontFromLogfontW(Handle hdc, ref LOGFONTW logfont, out Handle font);
Status GdipCreateFontFromLogfontA(Handle hdc, ref LOGFONTA logfont, out Handle font);

Status GdipGetLogFontW(Handle font, Handle graphics, out LOGFONTW logfontW);
alias GdipGetLogFontW GdipGetLogFont;

Status GdipCreateStringFormat(in StringFormatFlags formatAttributes, in int language, out Handle format);
Status GdipDeleteStringFormat(Handle format);
Status GdipGetStringFormatFlags(Handle format, out StringFormatFlags flags);
Status GdipSetStringFormatFlags(Handle format, in StringFormatFlags flags);
Status GdipGetStringFormatAlign(Handle format, out StringAlignment alignment);
Status GdipSetStringFormatAlign(Handle format, in StringAlignment alignment);
Status GdipGetStringFormatLineAlign(Handle format, out StringAlignment alignment);
Status GdipSetStringFormatLineAlign(Handle format, in StringAlignment alignment);
Status GdipGetStringFormatTrimming(Handle format, out StringTrimming trimming);
Status GdipSetStringFormatTrimming(Handle format, in StringTrimming trimming);

Status GdipCreatePath(in FillMode brushMode, out Handle path);
Status GdipCreatePath2(GpPointF*, ubyte*, int, FillMode, out Handle);
Status GdipCreatePath2I(GpPoint*, ubyte*, int, FillMode, out Handle);
Status GdipDeletePath(Handle path);
Status GdipClonePath(Handle path, out Handle clonepath);
Status GdipResetPath(Handle path);
Status GdipGetPathFillMode(Handle path, out FillMode fillmode);
Status GdipSetPathFillMode(Handle path, in FillMode fillmode);
Status GdipStartPathFigure(Handle path);
Status GdipClosePathFigure(Handle path);
Status GdipClosePathFigures(Handle path);
Status GdipSetPathMarker(Handle path);
Status GdipClearPathMarkers(Handle path);
Status GdipReversePath(Handle path);
Status GdipGetPathLastPoint(Handle path, out GpPointF lastPoint);
Status GdipAddPathLine(Handle path, in float x1, in float y1, in float x2, in float y2);
Status GdipAddPathLineI(Handle path, in int x1, in int y1, in int x2, in int y2);
Status GdipAddPathLine2(Handle path, GpPointF* points, in int count);
Status GdipAddPathLine2I(Handle path, GpPoint* points, in int count);
Status GdipAddPathArc(Handle path, in float x, in float y, in float width, in float height, in float startAngle, in float sweepAngle);
Status GdipAddPathArcI(Handle path, in int x, in int y, in int width, in int height, in float startAngle, in float sweepAngle);
Status GdipAddPathBezier(Handle path, in float x1, in float y1, in float x2, in float y2, in float x3, in float y3, in float x4, in float y4);
Status GdipAddPathBezierI(Handle path, in int x1, in int y1, in int x2, in int y2, in int x3, in int y3, in int x4, in int y4);
Status GdipAddPathBeziers(Handle path, GpPointF* points, in int count);
Status GdipAddPathBeziersI(Handle path, GpPoint* points, in int count);
Status GdipAddPathCurve(Handle path, GpPointF* points, in int count);
Status GdipAddPathCurveI(Handle path, GpPoint* points, in int count);
Status GdipAddPathCurve2(Handle path, GpPointF* points, in int count, in float tension);
Status GdipAddPathCurve2I(Handle path, GpPoint* points, in int count, in float tension);
Status GdipAddPathCurve3(Handle path, GpPointF* points, in int count, in int offset, in int numberOfSegments, in float tension);
Status GdipAddPathCurve3I(Handle path, GpPoint* points, in int count, in int offset, in int numberOfSegments, in float tension);
Status GdipAddPathClosedCurve(Handle path, GpPointF* points, in int count);
Status GdipAddPathClosedCurveI(Handle path, GpPoint* points, in int count);
Status GdipAddPathClosedCurve2(Handle path, GpPointF* points, in int count, in float tension);
Status GdipAddPathClosedCurve2I(Handle path, GpPoint* points, in int count, in float tension);
Status GdipAddPathRectangle(Handle path, in float x, in float y, in float width, in float height);
Status GdipAddPathRectangleI(Handle path, in int x, in int y, in int width, in int height);
Status GdipAddPathRectangles(Handle path, GpRectF* rects, in int count);
Status GdipAddPathRectanglesI(Handle path, GpRect* rects, in int count);
Status GdipAddPathEllipse(Handle path, in float x, in float y, in float width, in float height);
Status GdipAddPathEllipseI(Handle path, in int x, in int y, in int width, in int height);
Status GdipAddPathPie(Handle path, in float x, in float y, in float width, in float height, in float startAngle, in float sweepAngle);
Status GdipAddPathPieI(Handle path, in int x, in int y, in int width, in int height, in float startAngle, in float sweepAngle);
Status GdipAddPathPolygon(Handle path, GpPointF* points, in int count);
Status GdipAddPathPolygonI(Handle path, GpPoint* points, in int count);
Status GdipAddPathPath(Handle path, Handle addingPath, in int connect);
Status GdipAddPathString(Handle path, LPCWSTR string, in int length, Handle family, in FontStyle style, in float emSize, ref GpRectF layoutRect, Handle format);
Status GdipAddPathStringI(Handle path, LPCWSTR string, in int length, Handle family, in FontStyle style, in float emSize, ref GpRect layoutRect, Handle format);
Status GdipTransformPath(Handle path, Handle matrix);
Status GdipGetPathWorldBounds(Handle path, out GpRectF bounds, Handle matrix, Handle pen);
Status GdipFlattenPath(Handle path, Handle matrix, in float flatness);
Status GdipWidenPath(Handle path, Handle pen, Handle matrix, in float flatness);
Status GdipWindingModeOutline(Handle path, Handle matrix, in float flatness);
Status GdipWarpPath(Handle path, Handle matrix, GpPointF* points, in int count, in float srcx, in float srcy, in float srcwidth, in float srcwidth, in WarpMode warpMode, in float flatness);
Status GdipGetPointCount(Handle path, out int count);
Status GdipGetPathTypes(Handle path, byte* types, in int count);
Status GdipGetPathPoints(Handle path, GpPointF* points, in int count);
Status GdipIsVisiblePathPoint(Handle path, in float x, in float y, Handle graphics, out int result);
Status GdipIsVisiblePathPointI(Handle path, in int x, in int y, Handle graphics, out int result);
Status GdipIsOutlineVisiblePathPoint(Handle path, in float x, in float y, Handle pen, Handle graphics, out int result);
Status GdipIsOutlineVisiblePathPointI(Handle path, in int x, in int y, Handle pen, Handle graphics, out int result);
Status GdipDrawPath(Handle graphics, Handle pen, Handle path);


Status GdipCreatePathIter(out Handle iterator, Handle path);
Status GdipDeletePathIter(Handle iterator);
Status GdipPathIterNextSubpath(Handle iterator, out int resultCount, out int startIndex, out int endIndex, out int isClosed);
Status GdipPathIterNextSubpathPath(Handle iterator, out int resultCount, Handle path, out int isClosed);
Status GdipPathIterNextPathType(Handle iterator, out int resultCount, out ubyte pathType, out int startIndex, out int endIndex);
Status GdipPathIterNextMarker(Handle iterator, out int resultCount, out int startIndex, out int endIndex);
Status GdipPathIterNextMarkerPath(Handle iterator, out int resultCount, Handle path);
Status GdipPathIterGetCount(Handle iterator, out int count);
Status GdipPathIterGetSubpathCount(Handle iterator, out int count);
Status GdipPathIterHasCurve(Handle iterator, out int hasCurve);
Status GdipPathIterRewind(Handle iterator);
Status GdipPathIterEnumerate(Handle iterator, out int resultCount, GpPointF* points, ubyte* types, in int count);
Status GdipPathIterCopyData(Handle iterator, out int resultCount, GpPointF* points, ubyte* types, in int startIndex, in int endIndex);

Status GdipCreatePathGradient(GpPointF* points, in int count, in WrapMode wrapMode, out Handle polyGradient);
Status GdipCreatePathGradientI(GpPoint* points, in int count, in WrapMode wrapMode, out Handle polyGradient);
Status GdipCreatePathGradientFromPath(Handle path, out Handle polyGradient);
Status GdipGetPathGradientCenterColor(Handle brush, out int colors);
Status GdipSetPathGradientCenterColor(Handle brush, in int colors);
Status GdipGetPathGradientSurroundColorCount(Handle brush, out int count);
Status GdipGetPathGradientSurroundColorsWithCount(Handle brush, int* color, ref int count);
Status GdipSetPathGradientSurroundColorsWithCount(Handle brush, in int* color, ref int count);
Status GdipGetPathGradientCenterPoint(Handle brush, ref GpPointF point);
Status GdipSetPathGradientCenterPoint(Handle brush, ref GpPointF point);
Status GdipGetPathGradientRect(Handle brush, ref GpRectF rect);
Status GdipGetPathGradientBlendCount(Handle brush, out int count);
Status GdipGetPathGradientBlend(Handle brush, float* blend, float* positions, in int count);
Status GdipSetPathGradientBlend(Handle brush, in float* blend, in float* positions, in int count);
Status GdipGetPathGradientPresetBlendCount(Handle brush, out int count);
Status GdipGetPathGradientPresetBlend(Handle brush, int* blend, float* positions, in int count);
Status GdipSetPathGradientPresetBlend(Handle brush, in int* blend, in float* positions, in int count);
Status GdipSetPathGradientSigmaBlend(Handle brush, in float focus, in float scale);
Status GdipSetPathGradientLinearBlend(Handle brush, in float focus, in float scale);
Status GdipGetPathGradientTransform(Handle brush, out Handle matrix);
Status GdipSetPathGradientTransform(Handle brush, Handle matrix);
Status GdipResetPathGradientTransform(Handle brush);
Status GdipMultiplyPathGradientTransform(Handle brush, Handle matrix, in MatrixOrder order);
Status GdipRotatePathGradientTransform(Handle brush, in float angle, in MatrixOrder order);
Status GdipTranslatePathGradientTransform(Handle brush, in float dx, in float dy, in MatrixOrder order);
Status GdipScalePathGradientTransform(Handle brush, in float sx, in float sy, in MatrixOrder order);
Status GdipGetPathGradientFocusScales(Handle brush, out float xScale, out float yScale);
Status GdipSetPathGradientFocusScales(Handle brush, in float xScale, in float yScale);
Status GdipGetPathGradientWrapMode(Handle brush, out WrapMode wrapMode);
Status GdipSetPathGradientWrapMode(Handle brush, in WrapMode wrapMode);

//added

Status GdipResetTextureTransform(Handle brush);
Status GdipScaleTextureTransform(Handle brush, in float sx, in float sy, in MatrixOrder order);
Status GdipTranslateTextureTransform(Handle brush, in float dx, in float dy, in MatrixOrder order);
Status GdipStringFormatGetGenericDefault(out Handle format);
Status GdipStringFormatGetGenericTypographic(out Handle format);
Status GdipSetStringFormatHotkeyPrefix(Handle format, in int hotkeyPrefix);
Status GdipSetStringFormatTabStops(Handle format, in float firstTabOffset, in int count, in float* tabStops);

void loadLib_Gdip(){
    // do nothing in this version
}

}
else{ // version(!STATIC_GDIPLUS)
import java.nonstandard.SharedLib;
Status function(ULONG_PTR* token, GdiplusStartupInput* input, GdiplusStartupOutput* output) GdiplusStartup;
void   function(in ULONG_PTR token) GdiplusShutdown;
Status function(Handle hdc, out Handle graphics) GdipCreateFromHDC;
Status function(Handle hdc, Handle hDevice, out Handle graphics) GdipCreateFromHDC2;
Status function(Handle hwnd, out Handle graphics) GdipCreateFromHWND;
Status function(Handle image, out Handle graphics) GdipGetImageGraphicsContext;
Status function(Handle graphics) GdipDeleteGraphics;
Status function(Handle graphics, out Handle hdc) GdipGetDC;
Status function(Handle graphics, Handle hdc) GdipReleaseDC;
Status function(Handle graphics, Handle srcgraphics, in CombineMode combineMode) GdipSetClipGraphics;
Status function(Handle graphics, in int x, in int y, in int width, in int height, in CombineMode combineMode) GdipSetClipRectI;
Status function(Handle graphics, in float x, in float y, in float width, in float height, in CombineMode combineMode) GdipSetClipRect;
Status function(Handle graphics, Handle path, in CombineMode combineMode) GdipSetClipPath;
Status function(Handle graphics, Handle region, in CombineMode combineMode) GdipSetClipRegion;
Status function(Handle graphics, HRGN hRgn, in CombineMode combineMode) GdipSetClipHrgn;
Status function(Handle graphics, out Handle region) GdipGetClip;
Status function(Handle graphics) GdipResetClip;
Status function(Handle graphics, out uint state) GdipSaveGraphics;
Status function(Handle graphics, in int state) GdipRestoreGraphics;
Status function(Handle graphics, in FlushIntention intention) GdipFlush;
Status function(Handle graphics, in float sx, in float sy, in MatrixOrder order) GdipScaleWorldTransform;
Status function(Handle graphics, in float angle, in MatrixOrder order) GdipRotateWorldTransform;
Status function(Handle graphics, in float dx, in float dy, in MatrixOrder order) GdipTranslateWorldTransform;
Status function(Handle graphics, Handle matrix, in MatrixOrder order) GdipMultiplyWorldTransform;
Status function(Handle graphics) GdipResetWorldTransform;
Status function(Handle graphics, ref GpRectF dstrect, ref GpRectF srcrect, in GraphicsUnit unit, out int state) GdipBeginContainer;
Status function(Handle graphics, ref GpRect dstrect, ref GpRect srcrect, in GraphicsUnit unit, out int state) GdipBeginContainerI;
Status function(Handle graphics, out int state) GdipBeginContainer2;
Status function(Handle graphics, in int state) GdipEndContainer;
Status function(Handle graphics, out float dpi) GdipGetDpiX;
Status function(Handle graphics, out float dpi) GdipGetDpiY;
Status function(Handle graphics, out GraphicsUnit unit) GdipGetPageUnit;
Status function(Handle graphics, in GraphicsUnit unit) GdipSetPageUnit;
Status function(Handle graphics, out float scale) GdipGetPageScale;
Status function(Handle graphics, in float scale) GdipSetPageScale;
Status function(Handle graphics, Handle matrix) GdipGetWorldTransform;
Status function(Handle graphics, Handle matrix) GdipSetWorldTransform;
Status function(Handle graphics, out CompositingMode compositingMode) GdipGetCompositingMode;
Status function(Handle graphics, in CompositingMode compositingMode) GdipSetCompositingMode;
Status function(Handle graphics, out CompositingQuality compositingQuality) GdipGetCompositingQuality;
Status function(Handle graphics, in CompositingQuality compositingQuality) GdipSetCompositingQuality;
Status function(Handle graphics, out InterpolationMode interpolationMode) GdipGetInterpolationMode;
Status function(Handle graphics, in InterpolationMode interpolationMode) GdipSetInterpolationMode;
Status function(Handle graphics, out SmoothingMode smoothingMode) GdipGetSmoothingMode;
Status function(Handle graphics, in SmoothingMode smoothingMode) GdipSetSmoothingMode;
Status function(Handle graphics, out PixelOffsetMode pixelOffsetMode) GdipGetPixelOffsetMode;
Status function(Handle graphics, in PixelOffsetMode pixelOffsetMode) GdipSetPixelOffsetMode;
Status function(Handle graphics, out uint textContrast) GdipGetTextContrast;
Status function(Handle graphics, in uint textContrast) GdipSetTextContrast;
Status function(Handle graphics, in int color) GdipGraphicsClear;
Status function(Handle graphics, Handle pen, in float x1, in float y1, in float x2, in float y2) GdipDrawLine;
Status function(Handle graphics, Handle pen, GpPointF* points, in int count) GdipDrawLines;
Status function(Handle graphics, Handle pen, in int x1, in int y1, in int x2, in int y2) GdipDrawLineI;
Status function(Handle graphics, Handle pen, GpPoint* points, in int count) GdipDrawLinesI;
Status function(Handle graphics, Handle pen, in float x, in float y, in float width, in float height, in float startAngle, in float sweepAngle) GdipDrawArc;
Status function(Handle graphics, Handle pen, in int x, in int y, in int width, in int height, in float startAngle, in float sweepAngle) GdipDrawArcI;
Status function(Handle graphics, Handle pen, in float x1, in float y1, in float x2, in float y2, in float x3, in float y3, in float x4, in float y4) GdipDrawBezier;
Status function(Handle graphics, Handle pen, GpPointF* points, in int count) GdipDrawBeziers;
Status function(Handle graphics, Handle pen, in int x1, in int y1, in int x2, in int y2, in int x3, in int y3, in int x4, in int y4) GdipDrawBezierI;
Status function(Handle graphics, Handle pen, GpPoint* points, in int count) GdipDrawBeziersI;
Status function(Handle graphics, Handle pen, in float x, in float y, in float width, in float height) GdipDrawRectangle;
Status function(Handle graphics, Handle pen, GpRectF* rects, in int count) GdipDrawRectangles;
Status function(Handle graphics, Handle pen, in int x, in int y, in int width, in int height) GdipDrawRectangleI;
Status function(Handle graphics, Handle pen, GpRect* rects, in int count) GdipDrawRectanglesI;
Status function(Handle graphics, Handle pen, in float x, in float y, in float width, in float height) GdipDrawEllipse;
Status function(Handle graphics, Handle pen, in int x, in int y, in int width, in int height) GdipDrawEllipseI;
Status function(Handle graphics, Handle pen, in float x, in float y, in float width, in float height, in float startAngle, in float sweepAngle) GdipDrawPie;
Status function(Handle graphics, Handle pen, in int x, in int y, in int width, in int height, in float startAngle, in float sweepAngle) GdipDrawPieI;
Status function(Handle graphics, Handle pen, GpPointF* points, in int count) GdipDrawPolygon;
Status function(Handle graphics, Handle pen, GpPoint* points, in int count) GdipDrawPolygonI;
Status function(Handle graphics, Handle pen, GpPointF* points, in int count) GdipDrawCurve;
Status function(Handle graphics, Handle pen, GpPointF* points, in int count, in float tension) GdipDrawCurve2;
Status function(Handle graphics, Handle pen, GpPointF* points, in int count, in int offset, in int numberOfSegments, in float tension) GdipDrawCurve3;
Status function(Handle graphics, Handle pen, GpPoint* points, in int count) GdipDrawCurveI;
Status function(Handle graphics, Handle pen, GpPoint* points, in int count, in float tension) GdipDrawCurve2I;
Status function(Handle graphics, Handle pen, GpPoint* points, in int count, in int offset, in int numberOfSegments, in float tension) GdipDrawCurve3I;
Status function(Handle graphics, Handle pen, GpPointF* points, in int count) GdipDrawClosedCurve;
Status function(Handle graphics, Handle pen, GpPointF* points, in int count, in float tension) GdipDrawClosedCurve2;
Status function(Handle graphics, Handle pen, GpPoint* points, in int count) GdipDrawClosedCurveI;
Status function(Handle graphics, Handle pen, GpPoint* points, in int count, in float tension) GdipDrawClosedCurve2I;
Status function(Handle graphics, Handle brush, in int x, in int y, in int width, in int height) GdipFillRectangleI;
Status function(Handle graphics, Handle brush, in float x, in float y, in float width, in float height) GdipFillRectangle;
Status function(Handle graphics, Handle brush, GpRect* rects, in int count) GdipFillRectanglesI;
Status function(Handle graphics, Handle brush, GpRectF* rects, in int count) GdipFillRectangles;
Status function(Handle graphics, Handle brush, GpPointF* rects, in int count, in FillMode fillMode) GdipFillPolygon;
Status function(Handle graphics, Handle brush, GpPoint* rects, in int count, in FillMode fillMode) GdipFillPolygonI;
Status function(Handle graphics, Handle brush, in float x, in float y, in float width, in float height) GdipFillEllipse;
Status function(Handle graphics, Handle brush, in int x, in int y, in int width, in int height) GdipFillEllipseI;
Status function(Handle graphics, Handle brush, in float x, in float y, in float width, in float height, in float startAngle, in float sweepAngle) GdipFillPie;
Status function(Handle graphics, Handle brush, in int x, in int y, in int width, in int height, in float startAngle, in float sweepAngle) GdipFillPieI;
Status function(Handle graphics, Handle brush, Handle path) GdipFillPath;
Status function(Handle graphics, Handle brush, GpPointF* points, in int count) GdipFillClosedCurve;
Status function(Handle graphics, Handle brush, GpPoint* points, in int count) GdipFillClosedCurveI;
Status function(Handle graphics, Handle brush, GpPointF* points, in int count, in FillMode fillMode, in float tension) GdipFillClosedCurve2;
Status function(Handle graphics, Handle brush, GpPoint* points, in int count, in FillMode fillMode, in float tension) GdipFillClosedCurve2I;
Status function(Handle graphics, Handle brush, Handle region) GdipFillRegion;
Status function(Handle graphics, LPCWSTR string, in int length, Handle font, ref GpRectF layoutRect, Handle stringFormat, Handle brush) GdipDrawString;
Status function(Handle graphics, LPCWSTR string, in int length, Handle font, ref GpRectF layoutRect, Handle stringFormat, ref GpRectF boundingBox, int* codepointsFitted, int* linesFitted) GdipMeasureString;
Status function(Handle format, out int count) GdipGetStringFormatMeasurableCharacterRangeCount;
Status function(Handle format, out Handle newFormat) GdipCloneStringFormat;
Status function(Handle graphics, LPCWSTR string, in int length, Handle font, ref GpRectF layoutRect, Handle stringFormat, in int regionCount, Handle* regions) GdipMeasureCharacterRanges;
Status function(Handle graphics, Handle image, in float x, in float y) GdipDrawImage;
Status function(Handle graphics, Handle image, in int x, in int y) GdipDrawImageI;
Status function(Handle graphics, Handle image, in float x, in float y, in float width, in float height) GdipDrawImageRect;
Status function(Handle graphics, Handle image, in int x, in int y, in int width, in int height) GdipDrawImageRectI;
Status function(Handle graphics, Handle image, in float x, in float y, in float srcx, in float srcy, in float srcwidth, in float srcheight, in GraphicsUnit srcUnit) GdipDrawImagePointRect;
Status function(Handle graphics, Handle image, in int x, in int y, in int srcx, in int srcy, in int srcwidth, in int srcheight, in GraphicsUnit srcUnit) GdipDrawImagePointRectI;
Status function(Handle graphics, Handle image, in float dstx, in float dsty, in float dstwidth, in float dstheight, in float srcx, in float srcy, in float srcwidth, in float srcheight, in GraphicsUnit srcUnit, Handle imageAttributes, GpDrawImageAbort callback, void* callbakcData) GdipDrawImageRectRect;
Status function(Handle graphics, Handle image, in int dstx, in int dsty, in int dstwidth, in int dstheight, in int srcx, in int srcy, in int srcwidth, in int srcheight, in GraphicsUnit srcUnit, Handle imageAttributes, GpDrawImageAbort callback, void* callbakcData) GdipDrawImageRectRectI;
Status function(Handle graphics, Handle image, GpPointF* dstpoints, in int count) GdipDrawImagePoints;
Status function(Handle graphics, Handle image, GpPoint* dstpoints, in int count) GdipDrawImagePointsI;
Status function(Handle graphics, Handle image, GpPointF* dstpoints, in int count, in float srcx, in float srcy, in float srcwidth, in float srcheight, in GraphicsUnit srcUnit, Handle imageAttributes, GpDrawImageAbort callback, void* callbakcData) GdipDrawImagePointsRect;
Status function(Handle graphics, Handle image, GpPoint* dstpoints, in int count, in int srcx, in int srcy, in int srcwidth, in int srcheight, in GraphicsUnit srcUnit, Handle imageAttributes, GpDrawImageAbort callback, void* callbakcData) GdipDrawImagePointsRectI;
Status function(Handle graphics, in float x, in float y, out int result) GdipIsVisiblePoint;
Status function(Handle graphics, in int x, in int y, out int result) GdipIsVisiblePointI;
Status function(Handle graphics, in float x, in float y, in float width, in float height, out int result) GdipIsVisibleRect;
Status function(Handle graphics, in int x, in int y, in int width, in int height, out int result) GdipIsVisibleRectI;
Status function(Handle graphics, out TextRenderingHint mode) GdipGetTextRenderingHint;
Status function(Handle graphics, in TextRenderingHint mode) GdipSetTextRenderingHint;
Status function(Handle graphics, out GpRectF rect) GdipGetClipBounds;
Status function(Handle graphics, out GpRect rect) GdipGetClipBoundsI;
Status function(Handle graphics, out GpRectF rect) GdipGetVisibleClipBounds;
Status function(Handle graphics, out GpRect rect) GdipGetVisibleClipBoundsI;
Status function(Handle graphics, out int result) GdipIsClipEmpty;
Status function(Handle graphics, out int result) GdipIsVisibleClipEmpty;
Status function(Handle graphics, out int x, out int y) GdipGetRenderingOrigin;
Status function(Handle graphics, in int x, in int y) GdipSetRenderingOrigin;
Status function(Handle graphics, ref int argb) GdipGetNearestColor;
Status function(Handle graphics, in uint sizeData, ubyte* data) GdipComment;
Status function(Handle graphics, in CoordinateSpace destSpace, in CoordinateSpace srcSpace, GpPointF* points, in int count) GdipTransformPoints;
Status function(Handle graphics, in CoordinateSpace destSpace, in CoordinateSpace srcSpace, GpPoint* points, in int count) GdipTransformPointsI;
Status function(out Handle matrix) GdipCreateMatrix;
Status function(in float m11, in float m12, in float m21, in float m22, in float dx, in float dy, out Handle matrix) GdipCreateMatrix2;
Status function(ref GpRectF rect, GpPointF* dstplg, out Handle matrix) GdipCreateMatrix3;
Status function(ref GpRect rect, GpPoint* dstplg, out Handle matrix) GdipCreateMatrix3I;
Status function(Handle matrix) GdipDeleteMatrix;
Status function(Handle matrix, out Handle cloneMatrix) GdipCloneMatrix;
Status function(Handle matrix, float* matrixOut) GdipGetMatrixElements;
Status function(Handle matrix, in float m11, in float m12, in float m21, in float m22, in float xy, in float dy) GdipSetMatrixElements;
Status function(Handle matrix) GdipInvertMatrix;
Status function(Handle matrix, Handle matrix2, in MatrixOrder order) GdipMultiplyMatrix;
Status function(Handle matrix, in float scaleX, in float scaleY, in MatrixOrder order) GdipScaleMatrix;
Status function(Handle matrix, in float shearX, in float shearY, in MatrixOrder order) GdipShearMatrix;
Status function(Handle matrix, in float angle, in MatrixOrder order) GdipRotateMatrix;
Status function(Handle matrix, in float offsetX, in float offsetY, in MatrixOrder order) GdipTranslateMatrix;
Status function(Handle matrix, out int result) GdipIsMatrixIdentity;
Status function(Handle matrix, out int result) GdipIsMatrixInvertible;
Status function(Handle matrix, GpPointF *pts, in int count) GdipTransformMatrixPoints;
Status function(Handle brush, out BrushType type ) GdipGetBrushType;
Status function(Handle brush, out Handle cloneBrush) GdipCloneBrush;
Status function(Handle brush) GdipDeleteBrush;
Status function(in int color, out Handle brush) GdipCreateSolidFill;
Status function(Handle brush, out int color) GdipGetSolidFillColor;
Status function(Handle brush, in int color) GdipSetSolidFillColor;
Status function(Handle image, in WrapMode wrapMode, out Handle texture) GdipCreateTexture;
Status function(Handle image, in WrapMode wrapMode, in float x, in float y, in float width, in float height, out Handle texture) GdipCreateTexture2;
Status function(Handle image, in WrapMode wrapMode, in int x, in int y, in int width, in int height, out Handle texture) GdipCreateTexture2I;
Status function(Handle brush, out Handle image) GdipGetTextureImage;
Status function(Handle brush, out Handle matrix) GdipGetTextureTransform;
Status function(Handle brush, Handle matrix) GdipSetTextureTransform;
Status function(Handle brush, out WrapMode wrapmode) GdipGetTextureWrapMode;
Status function(Handle brush, in WrapMode wrapmode) GdipSetTextureWrapMode;
Status function(in HatchStyle hatchstyle, in int forecol, in int backcol, out Handle brush) GdipCreateHatchBrush;
Status function(Handle brush, out HatchStyle hatchstyle) GdipGetHatchStyle;
Status function(Handle brush, out int forecol) GdipGetHatchForegroundColor;
Status function(Handle brush, out int backcol) GdipGetHatchBackgroundColor;
Status function(ref GpPoint point1, ref GpPoint point2, in int color1, in int color2, in WrapMode wrapMode, out Handle lineGradient) GdipCreateLineBrushI;
Status function(ref GpPointF point1, ref GpPointF point2, in int color1, in int color2, in WrapMode wrapMode, out Handle lineGradient) GdipCreateLineBrush;
Status function(ref GpRect rect, in int color1, in int color2, in LinearGradientMode mode, in WrapMode wrapMode, out Handle lineGradient) GdipCreateLineBrushFromRectI;
Status function(ref GpRectF rect, in int color1, in int color2, in LinearGradientMode mode, in WrapMode wrapMode, out Handle lineGradient) GdipCreateLineBrushFromRect;
Status function(ref GpRect rect, in int color1, in int color2, in float angle, in int isAngleScalable, in WrapMode wrapMode, out Handle lineGradient) GdipCreateLineBrushFromRectWithAngleI;
Status function(ref GpRectF rect, in int color1, in int color2, in float angle, in int isAngleScalable, in WrapMode wrapMode, out Handle lineGradient) GdipCreateLineBrushFromRectWithAngle;
Status function(Handle brush, out int count) GdipGetLineBlendCount;
Status function(Handle brush, float* blend, float* positions, in int count) GdipGetLineBlend;
Status function(Handle brush, in float* blend, in float* positions, in int count) GdipSetLineBlend;
Status function(Handle brush, out int count) GdipGetLinePresetBlendCount;
Status function(Handle brush, uint* blend, float* positions, in int count) GdipGetLinePresetBlend;
Status function(Handle brush, in uint* blend, in float* positions, in int count) GdipSetLinePresetBlend;
Status function(Handle brush, out WrapMode wrapmode) GdipGetLineWrapMode;
Status function(Handle brush, in WrapMode wrapmode) GdipSetLineWrapMode;
Status function(Handle brush, out GpRectF rect) GdipGetLineRect;
Status function(Handle brush, int* colors) GdipGetLineColors;
Status function(Handle brush, in int color1, in int color2) GdipSetLineColors;
Status function(Handle brush, out int useGammaCorrection) GdipGetLineGammaCorrection;
Status function(Handle brush, in int useGammaCorrection) GdipSetLineGammaCorrection;
Status function(Handle brush, in float focus, in float scale) GdipSetLineSigmaBlend;
Status function(Handle brush, in float focus, in float scale) GdipSetLineLinearBlend;
Status function(Handle brush, out Handle matrix) GdipGetLineTransform;
Status function(Handle brush, Handle matrix) GdipSetLineTransform;
Status function(Handle brush) GdipResetLineTransform;
Status function(Handle brush, Handle matrix, in MatrixOrder order) GdipMultiplyLineTransform;
Status function(Handle brush, in float dx, in float dy, in MatrixOrder order) GdipTranslateLineTransform;
Status function(Handle brush, in float sx, in float sy, in MatrixOrder order) GdipScaleLineTransform;
Status function(Handle brush, in float angle, in MatrixOrder order) GdipRotateLineTransform;
Status function(in int argb, in float width, in GraphicsUnit unit, out Handle pen) GdipCreatePen1;
Status function(Handle brush, in float width, in GraphicsUnit unit, out Handle pen) GdipCreatePen2;
Status function(Handle pen) GdipDeletePen;
Status function(Handle pen, out Handle clonepen) GdipClonePen;
Status function(Handle pen, in LineCap startCap, in LineCap endCap, in DashCap dashCap) GdipSetPenLineCap197819;
Status function(Handle pen, out LineCap startCap) GdipGetPenStartCap;
Status function(Handle pen, in LineCap startCap) GdipSetPenStartCap;
Status function(Handle pen, out LineCap endCap) GdipGetPenEndCap;
Status function(Handle pen, in LineCap endCap) GdipSetPenEndCap;
Status function(Handle pen, out DashCap endCap) GdipGetPenDashCap197819;
Status function(Handle pen, in DashCap endCap) GdipSetPenDashCap197819;
Status function(Handle pen, out LineJoin lineJoin) GdipGetPenLineJoin;
Status function(Handle pen, in LineJoin lineJoin) GdipSetPenLineJoin;
Status function(Handle pen, out float miterLimit) GdipGetPenMiterLimit;
Status function(Handle pen, in float miterLimit) GdipSetPenMiterLimit;
Status function(Handle pen, out PenAlignment penMode) GdipGetPenMode;
Status function(Handle pen, in PenAlignment penMode) GdipSetPenMode;
Status function(Handle pen, out Handle matrix) GdipGetPenTransform;
Status function(Handle pen, Handle matrix) GdipSetPenTransform;
Status function(Handle pen) GdipResetPenTransform;
Status function(Handle pen, Handle matrix, in MatrixOrder order) GdipMultiplyPenTransform;
Status function(Handle pen, in float dx, in float dy, in MatrixOrder order) GdipTranslatePenTransform;
Status function(Handle pen, in float sx, in float sy, in MatrixOrder order) GdipScalePenTransform;
Status function(Handle pen, in float angle, in MatrixOrder order) GdipRotatePenTransform;
Status function(Handle pen, out int argb) GdipGetPenColor;
Status function(Handle pen, in int argb) GdipSetPenColor;
Status function(Handle pen, out float width) GdipGetPenWidth;
Status function(Handle pen, in float width) GdipSetPenWidth;
Status function(Handle pen, out PenType type) GdipGetPenFillType;
Status function(Handle pen, out Handle brush) GdipGetPenBrushFill;
Status function(Handle pen, Handle brush) GdipSetPenBrushFill;
Status function(Handle pen, out DashStyle dashstyle) GdipGetPenDashStyle;
Status function(Handle pen, in DashStyle dashstyle) GdipSetPenDashStyle;
Status function(Handle pen, out float offset) GdipGetPenDashOffset;
Status function(Handle pen, in float offset) GdipSetPenDashOffset;
Status function(Handle pen, out int count) GdipGetPenDashCount;
Status function(Handle pen, float* dash, in int count) GdipGetPenDashArray;
Status function(Handle pen, in float* dash, in int count) GdipSetPenDashArray;
Status function(Handle pen, out int count) GdipGetPenCompoundCount;
Status function(Handle pen, float* dash, in int count) GdipGetPenCompoundArray;
Status function(Handle pen, in float* dash, in int count) GdipSetPenCompoundArray;
Status function(out Handle region) GdipCreateRegion;
Status function(ref GpRectF rect, out Handle region) GdipCreateRegionRect;
Status function(ref GpRect rect, out Handle region) GdipCreateRegionRectI;
Status function(Handle path, out Handle region) GdipCreateRegionPath;
Status function(Handle hRgn, out Handle region) GdipCreateRegionHrgn;
Status function(Handle region) GdipDeleteRegion;
Status function(Handle region) GdipSetInfinite;
Status function(Handle region) GdipSetEmpty;
Status function(Handle region, ref GpRectF rect, in CombineMode combineMode) GdipCombineRegionRect;
Status function(Handle region, ref GpRect rect, in CombineMode combineMode) GdipCombineRegionRectI;
Status function(Handle region, Handle path, in CombineMode combineMode) GdipCombineRegionPath;
Status function(Handle region, Handle region, in CombineMode combineMode) GdipCombineRegionRegion;
Status function(Handle region, in float dx, in float dy) GdipTranslateRegion;
Status function(Handle region, in int dx, in int dy) GdipTranslateRegionI;
Status function(Handle region, Handle matrix) GdipTransformRegion;
Status function(Handle region, Handle graphics, out GpRectF rect) GdipGetRegionBounds;
Status function(Handle region, Handle graphics, out Handle hRgn) GdipGetRegionHRgn;
Status function(Handle region, Handle graphics, out int result) GdipIsEmptyRegion;
Status function(Handle region, Handle graphics, out int result) GdipIsInfiniteRegion;
Status function(Handle region1, Handle region2, Handle graphics, out int result) GdipIsEqualRegion;
Status function(Handle region, in float x, in float y, Handle graphics, out int result) GdipIsVisibleRegionPoint;
Status function(Handle region, in float x, in float y, in float width, in float height, Handle graphics, out int result) GdipIsVisibleRegionRect;
Status function(Handle region, in int x, in int y, Handle graphics, out int result) GdipIsVisibleRegionPointI;
Status function(Handle region, in int x, in int y, in int width, in int height, Handle graphics, out int result) GdipIsVisibleRegionRectI;
Status function(Handle region, out int count, Handle matrix) GdipGetRegionScansCount;
Status function(Handle region, GpRectF* rects, out int count, Handle matrix) GdipGetRegionScans;
Status function(Handle image) GdipDisposeImage;
Status function(Handle image) GdipImageForceValidation;
Status function(LPCWSTR filename, out Handle image) GdipLoadImageFromFileICM;
Status function(LPCWSTR filename, out Handle image) GdipLoadImageFromFile;
Status function(out int numEncoders, out int size) GdipGetImageEncodersSize;
Status function(Handle image, out Handle cloneImage) GdipCloneImage;
Status function(Handle image, out int type) GdipGetImageType;
Status function(Handle image, out uint flags) GdipGetImageFlags;
Status function(Handle image, out uint width) GdipGetImageWidth;
Status function(Handle image, out uint height) GdipGetImageHeight;
Status function(Handle image, out float resolution) GdipGetImageHorizontalResolution;
Status function(Handle image, out float resolution) GdipGetImageVerticalResolution;
Status function(Handle image, out int numOfProperty) GdipGetPropertyCount;
Status function(Handle image, in int numOfProperty, int* list) GdipGetPropertyIdList;
Status function(Handle image, out PixelFormat format) GdipGetImagePixelFormat;
Status function(Handle image, out float width, out float height) GdipGetImageDimension;
Status function(Handle image, in int thumbWidth, in int thumbHeight, out Handle thumbImage, GpGetThumbnailImageAbort callback, void* callbackData) GdipGetImageThumbnail;
Status function(Handle image, out int count) GdipImageGetFrameDimensionsCount;
Status function(Handle image, in RotateFlipType rotateFlipType) GdipImageRotateFlip;
Status function(Handle image, in int propId, out uint propSize) GdipGetPropertyItemSize;
Status function(Handle image, in int propId, in uint propSize, GpPropertyItem* buffer) GdipGetPropertyItem;
Status function(Handle image, ref GpPropertyItem buffer) GdipSetPropertyItem;
Status function(Handle image, in int propId) GdipRemovePropertyItem;
Status function(Handle image, out uint totalBufferSize, ref int numProperties) GdipGetPropertySize;
Status function(Handle image, in uint totalBufferSize, in int numProperties, GpPropertyItem* allItems) GdipGetAllPropertyItems;
Status function(Handle image, out GpRectF srcRect, out GraphicsUnit srcUnit) GdipGetImageBounds;
Status function(Handle image, out int size) GdipGetImagePaletteSize;
Status function(Handle image, GpColorPalette* palette, in int size) GdipGetImagePalette;
Status function(Handle image, in GpColorPalette* palette) GdipSetImagePalette;
Status function(in int width, in int height, in int stride, in PixelFormat format, ubyte* scan0, out Handle bitmap) GdipCreateBitmapFromScan0;
Status function(Handle hbitmap, Handle hpalette, out Handle bitmap) GdipCreateBitmapFromHBITMAP;
Status function(Handle hicon, out Handle bitmap) GdipCreateBitmapFromHICON;
Status function(LPCWSTR fileName, out Handle bitmap) GdipCreateBitmapFromFileICM;
Status function(LPCWSTR fileName, out Handle bitmap) GdipCreateBitmapFromFile;
Status function(in int width, in int height, Handle graphics, out Handle bitmap) GdipCreateBitmapFromGraphics;
Status function(in float x, in float y, in float width, in float height, in PixelFormat format, Handle srcbitmap, out Handle dstbitmap) GdipCloneBitmapArea;
Status function(in int x, in int y, in int width, in int height, in PixelFormat format, Handle srcbitmap, out Handle dstbitmap) GdipCloneBitmapAreaI;
Status function(Handle bitmap, in int x, in int y, out int color) GdipBitmapGetPixel;
Status function(Handle bitmap, in int x, in int y, in int color) GdipBitmapSetPixel;
Status function(Handle bitmap, GpRect* rect, in ImageLockMode flags, in PixelFormat format, GpBitmapData* lockedBitmapData) GdipBitmapLockBits;
Status function(Handle bitmap, GpBitmapData* lockedBitmapData) GdipBitmapUnlockBits;
Status function(Handle bitmap, in float xdpi, in float ydpi) GdipBitmapSetResolution;
Status function(Handle bitmap, out Handle hbmReturn) GdipCreateHICONFromBitmap;
Status function(Handle bitmap, out Handle hbmReturn, in int background) GdipCreateHBITMAPFromBitmap;
Status function(out Handle imageattr) GdipCreateImageAttributes;
Status function(Handle imageattr) GdipDisposeImageAttributes;
Status function(Handle imageattr, in ColorAdjustType type, in int enableFlag, in GpColorMatrix* colorMatrix, in GpColorMatrix* grayMatrix, in ColorMatrixFlag flags) GdipSetImageAttributesColorMatrix;
Status function(Handle imageattr, in ColorAdjustType type, in int enableFlag, in float threshold) GdipSetImageAttributesThreshold;
Status function(Handle imageattr, in ColorAdjustType type, in int enableFlag, in float gamma) GdipSetImageAttributesGamma;
Status function(Handle imageattr, in ColorAdjustType type, in int enableFlag) GdipSetImageAttributesNoOp;
Status function(Handle imageattr, in ColorAdjustType type, in int enableFlag, in int colorLow, in int colorHigh) GdipSetImageAttributesColorKeys;
Status function(Handle imageattr, in ColorAdjustType type, in int enableFlag, in ColorChannelFlag flags) GdipSetImageAttributesOutputChannel;
Status function(Handle imageattr, in ColorAdjustType type, in int enableFlag, LPCWSTR colorProfileFilename) GdipSetImageAttributesOutputChannelColorProfile;
Status function(Handle imageattr, in WrapMode wrap, in int argb, in int clamp) GdipSetImageAttributesWrapMode;
Status function(out Handle fontCollection) GdipNewInstalledFontCollection;
Status function(out Handle fontCollection) GdipNewPrivateFontCollection;
Status function(Handle fontCollection) GdipDeletePrivateFontCollection;
Status function(Handle fontCollection, LPCWSTR filename) GdipPrivateAddFontFile;
Status function(Handle fontCollection, void* memory, in int length) GdipPrivateAddMemoryFont;
Status function(Handle fontCollection, out int numFound) GdipGetFontCollectionFamilyCount;
Status function(Handle fontCollection, in int numSought, Handle* gpfamilies, out int numFound) GdipGetFontCollectionFamilyList;
Status function(LPCWSTR name, Handle fontCollection, out Handle FontFamily) GdipCreateFontFamilyFromName;
Status function(Handle FontFamily) GdipDeleteFontFamily;
Status function(Handle FontFamily, out Handle clonedFontFamily) GdipCloneFontFamily;
Status function(Handle family, LPCWSTR name, in int language) GdipGetFamilyName;
Status function(out Handle nativeFamily) GdipGetGenericFontFamilyMonospace;
Status function(out Handle nativeFamily) GdipGetGenericFontFamilySerif;
Status function(out Handle nativeFamily) GdipGetGenericFontFamilySansSerif;
Status function(Handle family, in FontStyle style, out short EmHeight) GdipGetEmHeight;
Status function(Handle family, in FontStyle style, out short CellAscent) GdipGetCellAscent;
Status function(Handle family, in FontStyle style, out short CellDescent) GdipGetCellDescent;
Status function(Handle family, in FontStyle style, out short LineSpacing) GdipGetLineSpacing;
Status function(Handle family, in FontStyle style, out int IsStyleAvailable) GdipIsStyleAvailable;
Status function(Handle fontFamily, in float emSize, in int style, in int unit, out Handle font) GdipCreateFont;
Status function(Handle hdc, out Handle font) GdipCreateFontFromDC;
Status function(Handle font) GdipDeleteFont;
Status function(Handle font, out Handle cloneFont) GdipCloneFont;
Status function(Handle font, out float size) GdipGetFontSize;
Status function(Handle font, Handle graphics, out float height) GdipGetFontHeight;
Status function(Handle font, in float dpi, out float height) GdipGetFontHeightGivenDPI;
Status function(Handle font, out FontStyle style) GdipGetFontStyle;
Status function(Handle font, out GraphicsUnit unit) GdipGetFontUnit;
Status function(Handle font, out Handle family) GdipGetFamily;
Status function(Handle hdc, ref LOGFONTW logfont, out Handle font) GdipCreateFontFromLogfontW;
Status function(Handle hdc, ref LOGFONTA logfont, out Handle font ) GdipCreateFontFromLogfontA;
Status function(Handle font, Handle graphics, out LOGFONTW logfontW) GdipGetLogFontW;
Status function(in StringFormatFlags formatAttributes, in int language, out Handle format) GdipCreateStringFormat;
Status function(Handle format) GdipDeleteStringFormat;
Status function(Handle format, out StringFormatFlags flags) GdipGetStringFormatFlags;
Status function(Handle format, in StringFormatFlags flags) GdipSetStringFormatFlags;
Status function(Handle format, out StringAlignment alignment) GdipGetStringFormatAlign;
Status function(Handle format, in StringAlignment alignment) GdipSetStringFormatAlign;
Status function(Handle format, out StringAlignment alignment) GdipGetStringFormatLineAlign;
Status function(Handle format, in StringAlignment alignment) GdipSetStringFormatLineAlign;
Status function(Handle format, out StringTrimming trimming) GdipGetStringFormatTrimming;
Status function(Handle format, in StringTrimming trimming) GdipSetStringFormatTrimming;
Status function(in FillMode brushMode, out Handle path) GdipCreatePath;
Status function(GpPointF*, ubyte*, int, FillMode, out Handle) GdipCreatePath2;
Status function(GpPoint*, ubyte*, int, FillMode, out Handle) GdipCreatePath2I;
Status function(Handle path) GdipDeletePath;
Status function(Handle path, out Handle clonepath) GdipClonePath;
Status function(Handle path) GdipResetPath;
Status function(Handle path, out FillMode fillmode) GdipGetPathFillMode;
Status function(Handle path, in FillMode fillmode) GdipSetPathFillMode;
Status function(Handle path) GdipStartPathFigure;
Status function(Handle path) GdipClosePathFigure;
Status function(Handle path) GdipClosePathFigures;
Status function(Handle path) GdipSetPathMarker;
Status function(Handle path) GdipClearPathMarkers;
Status function(Handle path) GdipReversePath;
Status function(Handle path, out GpPointF lastPoint) GdipGetPathLastPoint;
Status function(Handle path, in float x1, in float y1, in float x2, in float y2) GdipAddPathLine;
Status function(Handle path, in int x1, in int y1, in int x2, in int y2) GdipAddPathLineI;
Status function(Handle path, GpPointF* points, in int count) GdipAddPathLine2;
Status function(Handle path, GpPoint* points, in int count) GdipAddPathLine2I;
Status function(Handle path, in float x, in float y, in float width, in float height, in float startAngle, in float sweepAngle) GdipAddPathArc;
Status function(Handle path, in int x, in int y, in int width, in int height, in float startAngle, in float sweepAngle) GdipAddPathArcI;
Status function(Handle path, in float x1, in float y1, in float x2, in float y2, in float x3, in float y3, in float x4, in float y4) GdipAddPathBezier;
Status function(Handle path, in int x1, in int y1, in int x2, in int y2, in int x3, in int y3, in int x4, in int y4) GdipAddPathBezierI;
Status function(Handle path, GpPointF* points, in int count) GdipAddPathBeziers;
Status function(Handle path, GpPoint* points, in int count) GdipAddPathBeziersI;
Status function(Handle path, GpPointF* points, in int count) GdipAddPathCurve;
Status function(Handle path, GpPoint* points, in int count) GdipAddPathCurveI;
Status function(Handle path, GpPointF* points, in int count, in float tension) GdipAddPathCurve2;
Status function(Handle path, GpPoint* points, in int count, in float tension) GdipAddPathCurve2I;
Status function(Handle path, GpPointF* points, in int count, in int offset, in int numberOfSegments, in float tension) GdipAddPathCurve3;
Status function(Handle path, GpPoint* points, in int count, in int offset, in int numberOfSegments, in float tension) GdipAddPathCurve3I;
Status function(Handle path, GpPointF* points, in int count) GdipAddPathClosedCurve;
Status function(Handle path, GpPoint* points, in int count) GdipAddPathClosedCurveI;
Status function(Handle path, GpPointF* points, in int count, in float tension) GdipAddPathClosedCurve2;
Status function(Handle path, GpPoint* points, in int count, in float tension) GdipAddPathClosedCurve2I;
Status function(Handle path, in float x, in float y, in float width, in float height) GdipAddPathRectangle;
Status function(Handle path, in int x, in int y, in int width, in int height) GdipAddPathRectangleI;
Status function(Handle path, GpRectF* rects, in int count) GdipAddPathRectangles;
Status function(Handle path, GpRect* rects, in int count) GdipAddPathRectanglesI;
Status function(Handle path, in float x, in float y, in float width, in float height) GdipAddPathEllipse;
Status function(Handle path, in int x, in int y, in int width, in int height) GdipAddPathEllipseI;
Status function(Handle path, in float x, in float y, in float width, in float height, in float startAngle, in float sweepAngle) GdipAddPathPie;
Status function(Handle path, in int x, in int y, in int width, in int height, in float startAngle, in float sweepAngle) GdipAddPathPieI;
Status function(Handle path, GpPointF* points, in int count) GdipAddPathPolygon;
Status function(Handle path, GpPoint* points, in int count) GdipAddPathPolygonI;
Status function(Handle path, Handle addingPath, in int connect) GdipAddPathPath;
Status function(Handle path, LPCWSTR string, in int length, Handle family, in FontStyle style, in float emSize, ref GpRectF layoutRect, Handle format) GdipAddPathString;
Status function(Handle path, LPCWSTR string, in int length, Handle family, in FontStyle style, in float emSize, ref GpRect layoutRect, Handle format) GdipAddPathStringI;
Status function(Handle path, Handle matrix) GdipTransformPath;
Status function(Handle path, out GpRectF bounds, Handle matrix, Handle pen) GdipGetPathWorldBounds;
Status function(Handle path, Handle matrix, in float flatness) GdipFlattenPath;
Status function(Handle path, Handle pen, Handle matrix, in float flatness) GdipWidenPath;
Status function(Handle path, Handle matrix, in float flatness) GdipWindingModeOutline;
Status function(Handle path, Handle matrix, GpPointF* points, in int count, in float srcx, in float srcy, in float srcwidth, in float srcwidth, in WarpMode warpMode, in float flatness) GdipWarpPath;
Status function(Handle path, out int count) GdipGetPointCount;
Status function(Handle path, byte* types, in int count) GdipGetPathTypes;
Status function(Handle path, GpPointF* points, in int count) GdipGetPathPoints;
Status function(Handle path, in float x, in float y, Handle graphics, out int result) GdipIsVisiblePathPoint;
Status function(Handle path, in int x, in int y, Handle graphics, out int result) GdipIsVisiblePathPointI;
Status function(Handle path, in float x, in float y, Handle pen, Handle graphics, out int result) GdipIsOutlineVisiblePathPoint;
Status function(Handle path, in int x, in int y, Handle pen, Handle graphics, out int result) GdipIsOutlineVisiblePathPointI;
Status function(Handle graphics, Handle pen, Handle path) GdipDrawPath;
Status function(out Handle iterator, Handle path) GdipCreatePathIter;
Status function(Handle iterator) GdipDeletePathIter;
Status function(Handle iterator, out int resultCount, out int startIndex, out int endIndex, out int isClosed) GdipPathIterNextSubpath;
Status function(Handle iterator, out int resultCount, Handle path, out int isClosed) GdipPathIterNextSubpathPath;
Status function(Handle iterator, out int resultCount, out ubyte pathType, out int startIndex, out int endIndex) GdipPathIterNextPathType;
Status function(Handle iterator, out int resultCount, out int startIndex, out int endIndex) GdipPathIterNextMarker;
Status function(Handle iterator, out int resultCount, Handle path) GdipPathIterNextMarkerPath;
Status function(Handle iterator, out int count) GdipPathIterGetCount;
Status function(Handle iterator, out int count) GdipPathIterGetSubpathCount;
Status function(Handle iterator, out int hasCurve) GdipPathIterHasCurve;
Status function(Handle iterator) GdipPathIterRewind;
Status function(Handle iterator, out int resultCount, GpPointF* points, ubyte* types, in int count) GdipPathIterEnumerate;
Status function(Handle iterator, out int resultCount, GpPointF* points, ubyte* types, in int startIndex, in int endIndex) GdipPathIterCopyData;
Status function(GpPointF* points, in int count, in WrapMode wrapMode, out Handle polyGradient) GdipCreatePathGradient;
Status function(GpPoint* points, in int count, in WrapMode wrapMode, out Handle polyGradient) GdipCreatePathGradientI;
Status function(Handle path, out Handle polyGradient) GdipCreatePathGradientFromPath;
Status function(Handle brush, out int colors) GdipGetPathGradientCenterColor;
Status function(Handle brush, in int colors) GdipSetPathGradientCenterColor;
Status function(Handle brush, out int count) GdipGetPathGradientSurroundColorCount;
Status function(Handle brush, int* color, ref int count) GdipGetPathGradientSurroundColorsWithCount;
Status function(Handle brush, in int* color, ref int count) GdipSetPathGradientSurroundColorsWithCount;
Status function(Handle brush, ref GpPointF point) GdipGetPathGradientCenterPoint;
Status function(Handle brush, ref GpPointF point) GdipSetPathGradientCenterPoint;
Status function(Handle brush, ref GpRectF rect) GdipGetPathGradientRect;
Status function(Handle brush, out int count) GdipGetPathGradientBlendCount;
Status function(Handle brush, float* blend, float* positions, in int count) GdipGetPathGradientBlend;
Status function(Handle brush, in float* blend, in float* positions, in int count) GdipSetPathGradientBlend;
Status function(Handle brush, out int count) GdipGetPathGradientPresetBlendCount;
Status function(Handle brush, int* blend, float* positions, in int count) GdipGetPathGradientPresetBlend;
Status function(Handle brush, in int* blend, in float* positions, in int count) GdipSetPathGradientPresetBlend;
Status function(Handle brush, in float focus, in float scale) GdipSetPathGradientSigmaBlend;
Status function(Handle brush, in float focus, in float scale) GdipSetPathGradientLinearBlend;
Status function(Handle brush, out Handle matrix) GdipGetPathGradientTransform;
Status function(Handle brush, Handle matrix) GdipSetPathGradientTransform;
Status function(Handle brush) GdipResetPathGradientTransform;
Status function(Handle brush, Handle matrix, in MatrixOrder order) GdipMultiplyPathGradientTransform;
Status function(Handle brush, in float angle, in MatrixOrder order) GdipRotatePathGradientTransform;
Status function(Handle brush, in float dx, in float dy, in MatrixOrder order) GdipTranslatePathGradientTransform;
Status function(Handle brush, in float sx, in float sy, in MatrixOrder order) GdipScalePathGradientTransform;
Status function(Handle brush, out float xScale, out float yScale) GdipGetPathGradientFocusScales;
Status function(Handle brush, in float xScale, in float yScale) GdipSetPathGradientFocusScales;
Status function(Handle brush, out WrapMode wrapMode) GdipGetPathGradientWrapMode;
Status function(Handle brush, in WrapMode wrapMode) GdipSetPathGradientWrapMode;
Status function(Handle brush ) GdipResetTextureTransform;
Status function(Handle brush, in float sx, in float sy, in MatrixOrder order ) GdipScaleTextureTransform;
Status function(Handle brush, in float dx, in float dy, in MatrixOrder order) GdipTranslateTextureTransform;
Status function(out Handle format) GdipStringFormatGetGenericDefault;
Status function(out Handle format) GdipStringFormatGetGenericTypographic;
Status function(Handle format, in int hotkeyPrefix) GdipSetStringFormatHotkeyPrefix;
Status function(Handle format, in float firstTabOffset, in int count, in float* tabStops) GdipSetStringFormatTabStops;

mixin(gshared!(`Symbol[] symbols;`));
mixin(sharedStaticThis!(`{
    symbols = [
        Symbol( "GdiplusStartup", cast(void**)& GdiplusStartup ),
        Symbol( "GdiplusShutdown", cast(void**)& GdiplusShutdown ),
        Symbol( "GdipCreateFromHDC", cast(void**)& GdipCreateFromHDC ),
        Symbol( "GdipCreateFromHDC2", cast(void**)& GdipCreateFromHDC2 ),
        Symbol( "GdipCreateFromHWND", cast(void**)& GdipCreateFromHWND ),
        Symbol( "GdipGetImageGraphicsContext", cast(void**)& GdipGetImageGraphicsContext ),
        Symbol( "GdipDeleteGraphics", cast(void**)& GdipDeleteGraphics ),
        Symbol( "GdipGetDC", cast(void**)& GdipGetDC ),
        Symbol( "GdipReleaseDC", cast(void**)& GdipReleaseDC ),
        Symbol( "GdipSetClipGraphics", cast(void**)& GdipSetClipGraphics ),
        Symbol( "GdipSetClipRectI", cast(void**)& GdipSetClipRectI ),
        Symbol( "GdipSetClipRect", cast(void**)& GdipSetClipRect ),
        Symbol( "GdipSetClipPath", cast(void**)& GdipSetClipPath ),
        Symbol( "GdipSetClipRegion", cast(void**)& GdipSetClipRegion ),
        Symbol( "GdipSetClipHrgn", cast(void**)& GdipSetClipHrgn ),
        Symbol( "GdipGetClip", cast(void**)& GdipGetClip ),
        Symbol( "GdipResetClip", cast(void**)& GdipResetClip ),
        Symbol( "GdipSaveGraphics", cast(void**)& GdipSaveGraphics ),
        Symbol( "GdipRestoreGraphics", cast(void**)& GdipRestoreGraphics ),
        Symbol( "GdipFlush", cast(void**)& GdipFlush ),
        Symbol( "GdipScaleWorldTransform", cast(void**)& GdipScaleWorldTransform ),
        Symbol( "GdipRotateWorldTransform", cast(void**)& GdipRotateWorldTransform ),
        Symbol( "GdipTranslateWorldTransform", cast(void**)& GdipTranslateWorldTransform ),
        Symbol( "GdipMultiplyWorldTransform", cast(void**)& GdipMultiplyWorldTransform ),
        Symbol( "GdipResetWorldTransform", cast(void**)& GdipResetWorldTransform ),
        Symbol( "GdipBeginContainer", cast(void**)& GdipBeginContainer ),
        Symbol( "GdipBeginContainerI", cast(void**)& GdipBeginContainerI ),
        Symbol( "GdipBeginContainer2", cast(void**)& GdipBeginContainer2 ),
        Symbol( "GdipEndContainer", cast(void**)& GdipEndContainer ),
        Symbol( "GdipGetDpiX", cast(void**)& GdipGetDpiX ),
        Symbol( "GdipGetDpiY", cast(void**)& GdipGetDpiY ),
        Symbol( "GdipGetPageUnit", cast(void**)& GdipGetPageUnit ),
        Symbol( "GdipSetPageUnit", cast(void**)& GdipSetPageUnit ),
        Symbol( "GdipGetPageScale", cast(void**)& GdipGetPageScale ),
        Symbol( "GdipSetPageScale", cast(void**)& GdipSetPageScale ),
        Symbol( "GdipGetWorldTransform", cast(void**)& GdipGetWorldTransform ),
        Symbol( "GdipSetWorldTransform", cast(void**)& GdipSetWorldTransform ),
        Symbol( "GdipGetCompositingMode", cast(void**)& GdipGetCompositingMode ),
        Symbol( "GdipSetCompositingMode", cast(void**)& GdipSetCompositingMode ),
        Symbol( "GdipGetCompositingQuality", cast(void**)& GdipGetCompositingQuality ),
        Symbol( "GdipSetCompositingQuality", cast(void**)& GdipSetCompositingQuality ),
        Symbol( "GdipGetInterpolationMode", cast(void**)& GdipGetInterpolationMode ),
        Symbol( "GdipSetInterpolationMode", cast(void**)& GdipSetInterpolationMode ),
        Symbol( "GdipGetSmoothingMode", cast(void**)& GdipGetSmoothingMode ),
        Symbol( "GdipSetSmoothingMode", cast(void**)& GdipSetSmoothingMode ),
        Symbol( "GdipGetPixelOffsetMode", cast(void**)& GdipGetPixelOffsetMode ),
        Symbol( "GdipSetPixelOffsetMode", cast(void**)& GdipSetPixelOffsetMode ),
        Symbol( "GdipGetTextContrast", cast(void**)& GdipGetTextContrast ),
        Symbol( "GdipSetTextContrast", cast(void**)& GdipSetTextContrast ),
        Symbol( "GdipGraphicsClear", cast(void**)& GdipGraphicsClear ),
        Symbol( "GdipDrawLine", cast(void**)& GdipDrawLine ),
        Symbol( "GdipDrawLines", cast(void**)& GdipDrawLines ),
        Symbol( "GdipDrawLineI", cast(void**)& GdipDrawLineI ),
        Symbol( "GdipDrawLinesI", cast(void**)& GdipDrawLinesI ),
        Symbol( "GdipDrawArc", cast(void**)& GdipDrawArc ),
        Symbol( "GdipDrawArcI", cast(void**)& GdipDrawArcI ),
        Symbol( "GdipDrawBezier", cast(void**)& GdipDrawBezier ),
        Symbol( "GdipDrawBeziers", cast(void**)& GdipDrawBeziers ),
        Symbol( "GdipDrawBezierI", cast(void**)& GdipDrawBezierI ),
        Symbol( "GdipDrawBeziersI", cast(void**)& GdipDrawBeziersI ),
        Symbol( "GdipDrawRectangle", cast(void**)& GdipDrawRectangle ),
        Symbol( "GdipDrawRectangles", cast(void**)& GdipDrawRectangles ),
        Symbol( "GdipDrawRectangleI", cast(void**)& GdipDrawRectangleI ),
        Symbol( "GdipDrawRectanglesI", cast(void**)& GdipDrawRectanglesI ),
        Symbol( "GdipDrawEllipse", cast(void**)& GdipDrawEllipse ),
        Symbol( "GdipDrawEllipseI", cast(void**)& GdipDrawEllipseI ),
        Symbol( "GdipDrawPie", cast(void**)& GdipDrawPie ),
        Symbol( "GdipDrawPieI", cast(void**)& GdipDrawPieI ),
        Symbol( "GdipDrawPolygon", cast(void**)& GdipDrawPolygon ),
        Symbol( "GdipDrawPolygonI", cast(void**)& GdipDrawPolygonI ),
        Symbol( "GdipDrawCurve", cast(void**)& GdipDrawCurve ),
        Symbol( "GdipDrawCurve2", cast(void**)& GdipDrawCurve2 ),
        Symbol( "GdipDrawCurve3", cast(void**)& GdipDrawCurve3 ),
        Symbol( "GdipDrawCurveI", cast(void**)& GdipDrawCurveI ),
        Symbol( "GdipDrawCurve2I", cast(void**)& GdipDrawCurve2I ),
        Symbol( "GdipDrawCurve3I", cast(void**)& GdipDrawCurve3I ),
        Symbol( "GdipDrawClosedCurve", cast(void**)& GdipDrawClosedCurve ),
        Symbol( "GdipDrawClosedCurve2", cast(void**)& GdipDrawClosedCurve2 ),
        Symbol( "GdipDrawClosedCurveI", cast(void**)& GdipDrawClosedCurveI ),
        Symbol( "GdipDrawClosedCurve2I", cast(void**)& GdipDrawClosedCurve2I ),
        Symbol( "GdipFillRectangleI", cast(void**)& GdipFillRectangleI ),
        Symbol( "GdipFillRectangle", cast(void**)& GdipFillRectangle ),
        Symbol( "GdipFillRectanglesI", cast(void**)& GdipFillRectanglesI ),
        Symbol( "GdipFillRectangles", cast(void**)& GdipFillRectangles ),
        Symbol( "GdipFillPolygon", cast(void**)& GdipFillPolygon ),
        Symbol( "GdipFillPolygonI", cast(void**)& GdipFillPolygonI ),
        Symbol( "GdipFillEllipse", cast(void**)& GdipFillEllipse ),
        Symbol( "GdipFillEllipseI", cast(void**)& GdipFillEllipseI ),
        Symbol( "GdipFillPie", cast(void**)& GdipFillPie ),
        Symbol( "GdipFillPieI", cast(void**)& GdipFillPieI ),
        Symbol( "GdipFillPath", cast(void**)& GdipFillPath ),
        Symbol( "GdipFillClosedCurve", cast(void**)& GdipFillClosedCurve ),
        Symbol( "GdipFillClosedCurveI", cast(void**)& GdipFillClosedCurveI ),
        Symbol( "GdipFillClosedCurve2", cast(void**)& GdipFillClosedCurve2 ),
        Symbol( "GdipFillClosedCurve2I", cast(void**)& GdipFillClosedCurve2I ),
        Symbol( "GdipFillRegion", cast(void**)& GdipFillRegion ),
        Symbol( "GdipDrawString", cast(void**)& GdipDrawString ),
        Symbol( "GdipMeasureString", cast(void**)& GdipMeasureString ),
        Symbol( "GdipGetStringFormatMeasurableCharacterRangeCount", cast(void**)& GdipGetStringFormatMeasurableCharacterRangeCount ),
        Symbol( "GdipCloneStringFormat", cast(void**)& GdipCloneStringFormat ),
        Symbol( "GdipMeasureCharacterRanges", cast(void**)& GdipMeasureCharacterRanges ),
        Symbol( "GdipDrawImage", cast(void**)& GdipDrawImage ),
        Symbol( "GdipDrawImageI", cast(void**)& GdipDrawImageI ),
        Symbol( "GdipDrawImageRect", cast(void**)& GdipDrawImageRect ),
        Symbol( "GdipDrawImageRectI", cast(void**)& GdipDrawImageRectI ),
        Symbol( "GdipDrawImagePointRect", cast(void**)& GdipDrawImagePointRect ),
        Symbol( "GdipDrawImagePointRectI", cast(void**)& GdipDrawImagePointRectI ),
        Symbol( "GdipDrawImageRectRect", cast(void**)& GdipDrawImageRectRect ),
        Symbol( "GdipDrawImageRectRectI", cast(void**)& GdipDrawImageRectRectI ),
        Symbol( "GdipDrawImagePoints", cast(void**)& GdipDrawImagePoints ),
        Symbol( "GdipDrawImagePointsI", cast(void**)& GdipDrawImagePointsI ),
        Symbol( "GdipDrawImagePointsRect", cast(void**)& GdipDrawImagePointsRect ),
        Symbol( "GdipDrawImagePointsRectI", cast(void**)& GdipDrawImagePointsRectI ),
        Symbol( "GdipIsVisiblePoint", cast(void**)& GdipIsVisiblePoint ),
        Symbol( "GdipIsVisiblePointI", cast(void**)& GdipIsVisiblePointI ),
        Symbol( "GdipIsVisibleRect", cast(void**)& GdipIsVisibleRect ),
        Symbol( "GdipIsVisibleRectI", cast(void**)& GdipIsVisibleRectI ),
        Symbol( "GdipGetTextRenderingHint", cast(void**)& GdipGetTextRenderingHint ),
        Symbol( "GdipSetTextRenderingHint", cast(void**)& GdipSetTextRenderingHint ),
        Symbol( "GdipGetClipBounds", cast(void**)& GdipGetClipBounds ),
        Symbol( "GdipGetClipBoundsI", cast(void**)& GdipGetClipBoundsI ),
        Symbol( "GdipGetVisibleClipBounds", cast(void**)& GdipGetVisibleClipBounds ),
        Symbol( "GdipGetVisibleClipBoundsI", cast(void**)& GdipGetVisibleClipBoundsI ),
        Symbol( "GdipIsClipEmpty", cast(void**)& GdipIsClipEmpty ),
        Symbol( "GdipIsVisibleClipEmpty", cast(void**)& GdipIsVisibleClipEmpty ),
        Symbol( "GdipGetRenderingOrigin", cast(void**)& GdipGetRenderingOrigin ),
        Symbol( "GdipSetRenderingOrigin", cast(void**)& GdipSetRenderingOrigin ),
        Symbol( "GdipGetNearestColor", cast(void**)& GdipGetNearestColor ),
        Symbol( "GdipComment", cast(void**)& GdipComment ),
        Symbol( "GdipTransformPoints", cast(void**)& GdipTransformPoints ),
        Symbol( "GdipTransformPointsI", cast(void**)& GdipTransformPointsI ),
        Symbol( "GdipCreateMatrix", cast(void**)& GdipCreateMatrix ),
        Symbol( "GdipCreateMatrix2", cast(void**)& GdipCreateMatrix2 ),
        Symbol( "GdipCreateMatrix3", cast(void**)& GdipCreateMatrix3 ),
        Symbol( "GdipCreateMatrix3I", cast(void**)& GdipCreateMatrix3I ),
        Symbol( "GdipDeleteMatrix", cast(void**)& GdipDeleteMatrix ),
        Symbol( "GdipCloneMatrix", cast(void**)& GdipCloneMatrix ),
        Symbol( "GdipGetMatrixElements", cast(void**)& GdipGetMatrixElements ),
        Symbol( "GdipSetMatrixElements", cast(void**)& GdipSetMatrixElements ),
        Symbol( "GdipInvertMatrix", cast(void**)& GdipInvertMatrix ),
        Symbol( "GdipMultiplyMatrix", cast(void**)& GdipMultiplyMatrix ),
        Symbol( "GdipScaleMatrix", cast(void**)& GdipScaleMatrix ),
        Symbol( "GdipShearMatrix", cast(void**)& GdipShearMatrix ),
        Symbol( "GdipRotateMatrix", cast(void**)& GdipRotateMatrix ),
        Symbol( "GdipTranslateMatrix", cast(void**)& GdipTranslateMatrix ),
        Symbol( "GdipIsMatrixIdentity", cast(void**)& GdipIsMatrixIdentity ),
        Symbol( "GdipIsMatrixInvertible", cast(void**)& GdipIsMatrixInvertible ),
        Symbol( "GdipTransformMatrixPoints", cast(void**)& GdipTransformMatrixPoints ),
        Symbol( "GdipGetBrushType", cast(void**)& GdipGetBrushType ),
        Symbol( "GdipCloneBrush", cast(void**)& GdipCloneBrush ),
        Symbol( "GdipDeleteBrush", cast(void**)& GdipDeleteBrush ),
        Symbol( "GdipCreateSolidFill", cast(void**)& GdipCreateSolidFill ),
        Symbol( "GdipGetSolidFillColor", cast(void**)& GdipGetSolidFillColor ),
        Symbol( "GdipSetSolidFillColor", cast(void**)& GdipSetSolidFillColor ),
        Symbol( "GdipCreateTexture", cast(void**)& GdipCreateTexture ),
        Symbol( "GdipCreateTexture2", cast(void**)& GdipCreateTexture2 ),
        Symbol( "GdipCreateTexture2I", cast(void**)& GdipCreateTexture2I ),
        Symbol( "GdipGetTextureImage", cast(void**)& GdipGetTextureImage ),
        Symbol( "GdipGetTextureTransform", cast(void**)& GdipGetTextureTransform ),
        Symbol( "GdipSetTextureTransform", cast(void**)& GdipSetTextureTransform ),
        Symbol( "GdipGetTextureWrapMode", cast(void**)& GdipGetTextureWrapMode ),
        Symbol( "GdipSetTextureWrapMode", cast(void**)& GdipSetTextureWrapMode ),
        Symbol( "GdipCreateHatchBrush", cast(void**)& GdipCreateHatchBrush ),
        Symbol( "GdipGetHatchStyle", cast(void**)& GdipGetHatchStyle ),
        Symbol( "GdipGetHatchForegroundColor", cast(void**)& GdipGetHatchForegroundColor ),
        Symbol( "GdipGetHatchBackgroundColor", cast(void**)& GdipGetHatchBackgroundColor ),
        Symbol( "GdipCreateLineBrushI", cast(void**)& GdipCreateLineBrushI ),
        Symbol( "GdipCreateLineBrush", cast(void**)& GdipCreateLineBrush ),
        Symbol( "GdipCreateLineBrushFromRectI", cast(void**)& GdipCreateLineBrushFromRectI ),
        Symbol( "GdipCreateLineBrushFromRect", cast(void**)& GdipCreateLineBrushFromRect ),
        Symbol( "GdipCreateLineBrushFromRectWithAngleI", cast(void**)& GdipCreateLineBrushFromRectWithAngleI ),
        Symbol( "GdipCreateLineBrushFromRectWithAngle", cast(void**)& GdipCreateLineBrushFromRectWithAngle ),
        Symbol( "GdipGetLineBlendCount", cast(void**)& GdipGetLineBlendCount ),
        Symbol( "GdipGetLineBlend", cast(void**)& GdipGetLineBlend ),
        Symbol( "GdipSetLineBlend", cast(void**)& GdipSetLineBlend ),
        Symbol( "GdipGetLinePresetBlendCount", cast(void**)& GdipGetLinePresetBlendCount ),
        Symbol( "GdipGetLinePresetBlend", cast(void**)& GdipGetLinePresetBlend ),
        Symbol( "GdipSetLinePresetBlend", cast(void**)& GdipSetLinePresetBlend ),
        Symbol( "GdipGetLineWrapMode", cast(void**)& GdipGetLineWrapMode ),
        Symbol( "GdipSetLineWrapMode", cast(void**)& GdipSetLineWrapMode ),
        Symbol( "GdipGetLineRect", cast(void**)& GdipGetLineRect ),
        Symbol( "GdipGetLineColors", cast(void**)& GdipGetLineColors ),
        Symbol( "GdipSetLineColors", cast(void**)& GdipSetLineColors ),
        Symbol( "GdipGetLineGammaCorrection", cast(void**)& GdipGetLineGammaCorrection ),
        Symbol( "GdipSetLineGammaCorrection", cast(void**)& GdipSetLineGammaCorrection ),
        Symbol( "GdipSetLineSigmaBlend", cast(void**)& GdipSetLineSigmaBlend ),
        Symbol( "GdipSetLineLinearBlend", cast(void**)& GdipSetLineLinearBlend ),
        Symbol( "GdipGetLineTransform", cast(void**)& GdipGetLineTransform ),
        Symbol( "GdipSetLineTransform", cast(void**)& GdipSetLineTransform ),
        Symbol( "GdipResetLineTransform", cast(void**)& GdipResetLineTransform ),
        Symbol( "GdipMultiplyLineTransform", cast(void**)& GdipMultiplyLineTransform ),
        Symbol( "GdipTranslateLineTransform", cast(void**)& GdipTranslateLineTransform ),
        Symbol( "GdipScaleLineTransform", cast(void**)& GdipScaleLineTransform ),
        Symbol( "GdipRotateLineTransform", cast(void**)& GdipRotateLineTransform ),
        Symbol( "GdipCreatePen1", cast(void**)& GdipCreatePen1 ),
        Symbol( "GdipCreatePen2", cast(void**)& GdipCreatePen2 ),
        Symbol( "GdipDeletePen", cast(void**)& GdipDeletePen ),
        Symbol( "GdipClonePen", cast(void**)& GdipClonePen ),
        Symbol( "GdipSetPenLineCap197819", cast(void**)& GdipSetPenLineCap197819 ),
        Symbol( "GdipGetPenStartCap", cast(void**)& GdipGetPenStartCap ),
        Symbol( "GdipSetPenStartCap", cast(void**)& GdipSetPenStartCap ),
        Symbol( "GdipGetPenEndCap", cast(void**)& GdipGetPenEndCap ),
        Symbol( "GdipSetPenEndCap", cast(void**)& GdipSetPenEndCap ),
        Symbol( "GdipGetPenDashCap197819", cast(void**)& GdipGetPenDashCap197819 ),
        Symbol( "GdipSetPenDashCap197819", cast(void**)& GdipSetPenDashCap197819 ),
        Symbol( "GdipGetPenLineJoin", cast(void**)& GdipGetPenLineJoin ),
        Symbol( "GdipSetPenLineJoin", cast(void**)& GdipSetPenLineJoin ),
        Symbol( "GdipGetPenMiterLimit", cast(void**)& GdipGetPenMiterLimit ),
        Symbol( "GdipSetPenMiterLimit", cast(void**)& GdipSetPenMiterLimit ),
        Symbol( "GdipGetPenMode", cast(void**)& GdipGetPenMode ),
        Symbol( "GdipSetPenMode", cast(void**)& GdipSetPenMode ),
        Symbol( "GdipGetPenTransform", cast(void**)& GdipGetPenTransform ),
        Symbol( "GdipSetPenTransform", cast(void**)& GdipSetPenTransform ),
        Symbol( "GdipResetPenTransform", cast(void**)& GdipResetPenTransform ),
        Symbol( "GdipMultiplyPenTransform", cast(void**)& GdipMultiplyPenTransform ),
        Symbol( "GdipTranslatePenTransform", cast(void**)& GdipTranslatePenTransform ),
        Symbol( "GdipScalePenTransform", cast(void**)& GdipScalePenTransform ),
        Symbol( "GdipRotatePenTransform", cast(void**)& GdipRotatePenTransform ),
        Symbol( "GdipGetPenColor", cast(void**)& GdipGetPenColor ),
        Symbol( "GdipSetPenColor", cast(void**)& GdipSetPenColor ),
        Symbol( "GdipGetPenWidth", cast(void**)& GdipGetPenWidth ),
        Symbol( "GdipSetPenWidth", cast(void**)& GdipSetPenWidth ),
        Symbol( "GdipGetPenFillType", cast(void**)& GdipGetPenFillType ),
        Symbol( "GdipGetPenBrushFill", cast(void**)& GdipGetPenBrushFill ),
        Symbol( "GdipSetPenBrushFill", cast(void**)& GdipSetPenBrushFill ),
        Symbol( "GdipGetPenDashStyle", cast(void**)& GdipGetPenDashStyle ),
        Symbol( "GdipSetPenDashStyle", cast(void**)& GdipSetPenDashStyle ),
        Symbol( "GdipGetPenDashOffset", cast(void**)& GdipGetPenDashOffset ),
        Symbol( "GdipSetPenDashOffset", cast(void**)& GdipSetPenDashOffset ),
        Symbol( "GdipGetPenDashCount", cast(void**)& GdipGetPenDashCount ),
        Symbol( "GdipGetPenDashArray", cast(void**)& GdipGetPenDashArray ),
        Symbol( "GdipSetPenDashArray", cast(void**)& GdipSetPenDashArray ),
        Symbol( "GdipGetPenCompoundCount", cast(void**)& GdipGetPenCompoundCount ),
        Symbol( "GdipGetPenCompoundArray", cast(void**)& GdipGetPenCompoundArray ),
        Symbol( "GdipSetPenCompoundArray", cast(void**)& GdipSetPenCompoundArray ),
        Symbol( "GdipCreateRegion", cast(void**)& GdipCreateRegion ),
        Symbol( "GdipCreateRegionRect", cast(void**)& GdipCreateRegionRect ),
        Symbol( "GdipCreateRegionRectI", cast(void**)& GdipCreateRegionRectI ),
        Symbol( "GdipCreateRegionPath", cast(void**)& GdipCreateRegionPath ),
        Symbol( "GdipCreateRegionHrgn", cast(void**)& GdipCreateRegionHrgn ),
        Symbol( "GdipDeleteRegion", cast(void**)& GdipDeleteRegion ),
        Symbol( "GdipSetInfinite", cast(void**)& GdipSetInfinite ),
        Symbol( "GdipSetEmpty", cast(void**)& GdipSetEmpty ),
        Symbol( "GdipCombineRegionRect", cast(void**)& GdipCombineRegionRect ),
        Symbol( "GdipCombineRegionRectI", cast(void**)& GdipCombineRegionRectI ),
        Symbol( "GdipCombineRegionPath", cast(void**)& GdipCombineRegionPath ),
        Symbol( "GdipCombineRegionRegion", cast(void**)& GdipCombineRegionRegion ),
        Symbol( "GdipTranslateRegion", cast(void**)& GdipTranslateRegion ),
        Symbol( "GdipTranslateRegionI", cast(void**)& GdipTranslateRegionI ),
        Symbol( "GdipTransformRegion", cast(void**)& GdipTransformRegion ),
        Symbol( "GdipGetRegionBounds", cast(void**)& GdipGetRegionBounds ),
        Symbol( "GdipGetRegionHRgn", cast(void**)& GdipGetRegionHRgn ),
        Symbol( "GdipIsEmptyRegion", cast(void**)& GdipIsEmptyRegion ),
        Symbol( "GdipIsInfiniteRegion", cast(void**)& GdipIsInfiniteRegion ),
        Symbol( "GdipIsEqualRegion", cast(void**)& GdipIsEqualRegion ),
        Symbol( "GdipIsVisibleRegionPoint", cast(void**)& GdipIsVisibleRegionPoint ),
        Symbol( "GdipIsVisibleRegionRect", cast(void**)& GdipIsVisibleRegionRect ),
        Symbol( "GdipIsVisibleRegionPointI", cast(void**)& GdipIsVisibleRegionPointI ),
        Symbol( "GdipIsVisibleRegionRectI", cast(void**)& GdipIsVisibleRegionRectI ),
        Symbol( "GdipGetRegionScansCount", cast(void**)& GdipGetRegionScansCount ),
        Symbol( "GdipGetRegionScans", cast(void**)& GdipGetRegionScans ),
        Symbol( "GdipDisposeImage", cast(void**)& GdipDisposeImage ),
        Symbol( "GdipImageForceValidation", cast(void**)& GdipImageForceValidation ),
        Symbol( "GdipLoadImageFromFileICM", cast(void**)& GdipLoadImageFromFileICM ),
        Symbol( "GdipLoadImageFromFile", cast(void**)& GdipLoadImageFromFile ),
        Symbol( "GdipGetImageEncodersSize", cast(void**)& GdipGetImageEncodersSize ),
        Symbol( "GdipCloneImage", cast(void**)& GdipCloneImage ),
        Symbol( "GdipGetImageType", cast(void**)& GdipGetImageType ),
        Symbol( "GdipGetImageFlags", cast(void**)& GdipGetImageFlags ),
        Symbol( "GdipGetImageWidth", cast(void**)& GdipGetImageWidth ),
        Symbol( "GdipGetImageHeight", cast(void**)& GdipGetImageHeight ),
        Symbol( "GdipGetImageHorizontalResolution", cast(void**)& GdipGetImageHorizontalResolution ),
        Symbol( "GdipGetImageVerticalResolution", cast(void**)& GdipGetImageVerticalResolution ),
        Symbol( "GdipGetPropertyCount", cast(void**)& GdipGetPropertyCount ),
        Symbol( "GdipGetPropertyIdList", cast(void**)& GdipGetPropertyIdList ),
        Symbol( "GdipGetImagePixelFormat", cast(void**)& GdipGetImagePixelFormat ),
        Symbol( "GdipGetImageDimension", cast(void**)& GdipGetImageDimension ),
        Symbol( "GdipGetImageThumbnail", cast(void**)& GdipGetImageThumbnail ),
        Symbol( "GdipImageGetFrameDimensionsCount", cast(void**)& GdipImageGetFrameDimensionsCount ),
        Symbol( "GdipImageRotateFlip", cast(void**)& GdipImageRotateFlip ),
        Symbol( "GdipGetPropertyItemSize", cast(void**)& GdipGetPropertyItemSize ),
        Symbol( "GdipGetPropertyItem", cast(void**)& GdipGetPropertyItem ),
        Symbol( "GdipSetPropertyItem", cast(void**)& GdipSetPropertyItem ),
        Symbol( "GdipRemovePropertyItem", cast(void**)& GdipRemovePropertyItem ),
        Symbol( "GdipGetPropertySize", cast(void**)& GdipGetPropertySize ),
        Symbol( "GdipGetAllPropertyItems", cast(void**)& GdipGetAllPropertyItems ),
        Symbol( "GdipGetImageBounds", cast(void**)& GdipGetImageBounds ),
        Symbol( "GdipGetImagePaletteSize", cast(void**)& GdipGetImagePaletteSize ),
        Symbol( "GdipGetImagePalette", cast(void**)& GdipGetImagePalette ),
        Symbol( "GdipSetImagePalette", cast(void**)& GdipSetImagePalette ),
        Symbol( "GdipCreateBitmapFromScan0", cast(void**)& GdipCreateBitmapFromScan0 ),
        Symbol( "GdipCreateBitmapFromHBITMAP", cast(void**)& GdipCreateBitmapFromHBITMAP ),
        Symbol( "GdipCreateBitmapFromHICON", cast(void**)& GdipCreateBitmapFromHICON ),
        Symbol( "GdipCreateBitmapFromFileICM", cast(void**)& GdipCreateBitmapFromFileICM ),
        Symbol( "GdipCreateBitmapFromFile", cast(void**)& GdipCreateBitmapFromFile ),
        Symbol( "GdipCreateBitmapFromGraphics", cast(void**)& GdipCreateBitmapFromGraphics ),
        Symbol( "GdipCloneBitmapArea", cast(void**)& GdipCloneBitmapArea ),
        Symbol( "GdipCloneBitmapAreaI", cast(void**)& GdipCloneBitmapAreaI ),
        Symbol( "GdipBitmapGetPixel", cast(void**)& GdipBitmapGetPixel ),
        Symbol( "GdipBitmapSetPixel", cast(void**)& GdipBitmapSetPixel ),
        Symbol( "GdipBitmapLockBits", cast(void**)& GdipBitmapLockBits ),
        Symbol( "GdipBitmapUnlockBits", cast(void**)& GdipBitmapUnlockBits ),
        Symbol( "GdipBitmapSetResolution", cast(void**)& GdipBitmapSetResolution ),
        Symbol( "GdipCreateHICONFromBitmap", cast(void**)& GdipCreateHICONFromBitmap ),
        Symbol( "GdipCreateHBITMAPFromBitmap", cast(void**)& GdipCreateHBITMAPFromBitmap ),
        Symbol( "GdipCreateImageAttributes", cast(void**)& GdipCreateImageAttributes ),
        Symbol( "GdipDisposeImageAttributes", cast(void**)& GdipDisposeImageAttributes ),
        Symbol( "GdipSetImageAttributesColorMatrix", cast(void**)& GdipSetImageAttributesColorMatrix ),
        Symbol( "GdipSetImageAttributesThreshold", cast(void**)& GdipSetImageAttributesThreshold ),
        Symbol( "GdipSetImageAttributesGamma", cast(void**)& GdipSetImageAttributesGamma ),
        Symbol( "GdipSetImageAttributesNoOp", cast(void**)& GdipSetImageAttributesNoOp ),
        Symbol( "GdipSetImageAttributesColorKeys", cast(void**)& GdipSetImageAttributesColorKeys ),
        Symbol( "GdipSetImageAttributesOutputChannel", cast(void**)& GdipSetImageAttributesOutputChannel ),
        Symbol( "GdipSetImageAttributesOutputChannelColorProfile", cast(void**)& GdipSetImageAttributesOutputChannelColorProfile ),
        Symbol( "GdipSetImageAttributesWrapMode", cast(void**)& GdipSetImageAttributesWrapMode ),
        Symbol( "GdipNewInstalledFontCollection", cast(void**)& GdipNewInstalledFontCollection ),
        Symbol( "GdipNewPrivateFontCollection", cast(void**)& GdipNewPrivateFontCollection ),
        Symbol( "GdipDeletePrivateFontCollection", cast(void**)& GdipDeletePrivateFontCollection ),
        Symbol( "GdipPrivateAddFontFile", cast(void**)& GdipPrivateAddFontFile ),
        Symbol( "GdipPrivateAddMemoryFont", cast(void**)& GdipPrivateAddMemoryFont ),
        Symbol( "GdipGetFontCollectionFamilyCount", cast(void**)& GdipGetFontCollectionFamilyCount ),
        Symbol( "GdipGetFontCollectionFamilyList", cast(void**)& GdipGetFontCollectionFamilyList ),
        Symbol( "GdipCreateFontFamilyFromName", cast(void**)& GdipCreateFontFamilyFromName ),
        Symbol( "GdipDeleteFontFamily", cast(void**)& GdipDeleteFontFamily ),
        Symbol( "GdipCloneFontFamily", cast(void**)& GdipCloneFontFamily ),
        Symbol( "GdipGetFamilyName", cast(void**)& GdipGetFamilyName ),
        Symbol( "GdipGetGenericFontFamilyMonospace", cast(void**)& GdipGetGenericFontFamilyMonospace ),
        Symbol( "GdipGetGenericFontFamilySerif", cast(void**)& GdipGetGenericFontFamilySerif ),
        Symbol( "GdipGetGenericFontFamilySansSerif", cast(void**)& GdipGetGenericFontFamilySansSerif ),
        Symbol( "GdipGetEmHeight", cast(void**)& GdipGetEmHeight ),
        Symbol( "GdipGetCellAscent", cast(void**)& GdipGetCellAscent ),
        Symbol( "GdipGetCellDescent", cast(void**)& GdipGetCellDescent ),
        Symbol( "GdipGetLineSpacing", cast(void**)& GdipGetLineSpacing ),
        Symbol( "GdipIsStyleAvailable", cast(void**)& GdipIsStyleAvailable ),
        Symbol( "GdipCreateFont", cast(void**)& GdipCreateFont ),
        Symbol( "GdipCreateFontFromDC", cast(void**)& GdipCreateFontFromDC ),
        Symbol( "GdipDeleteFont", cast(void**)& GdipDeleteFont ),
        Symbol( "GdipCloneFont", cast(void**)& GdipCloneFont ),
        Symbol( "GdipGetFontSize", cast(void**)& GdipGetFontSize ),
        Symbol( "GdipGetFontHeight", cast(void**)& GdipGetFontHeight ),
        Symbol( "GdipGetFontHeightGivenDPI", cast(void**)& GdipGetFontHeightGivenDPI ),
        Symbol( "GdipGetFontStyle", cast(void**)& GdipGetFontStyle ),
        Symbol( "GdipGetFontUnit", cast(void**)& GdipGetFontUnit ),
        Symbol( "GdipGetFamily", cast(void**)& GdipGetFamily ),
        Symbol( "GdipCreateFontFromLogfontW", cast(void**)& GdipCreateFontFromLogfontW ),
        Symbol( "GdipCreateFontFromLogfontA", cast(void**)& GdipCreateFontFromLogfontA ),
        Symbol( "GdipGetLogFontW", cast(void**)& GdipGetLogFontW ),
        Symbol( "GdipCreateStringFormat", cast(void**)& GdipCreateStringFormat ),
        Symbol( "GdipDeleteStringFormat", cast(void**)& GdipDeleteStringFormat ),
        Symbol( "GdipGetStringFormatFlags", cast(void**)& GdipGetStringFormatFlags ),
        Symbol( "GdipSetStringFormatFlags", cast(void**)& GdipSetStringFormatFlags ),
        Symbol( "GdipGetStringFormatAlign", cast(void**)& GdipGetStringFormatAlign ),
        Symbol( "GdipSetStringFormatAlign", cast(void**)& GdipSetStringFormatAlign ),
        Symbol( "GdipGetStringFormatLineAlign", cast(void**)& GdipGetStringFormatLineAlign ),
        Symbol( "GdipSetStringFormatLineAlign", cast(void**)& GdipSetStringFormatLineAlign ),
        Symbol( "GdipGetStringFormatTrimming", cast(void**)& GdipGetStringFormatTrimming ),
        Symbol( "GdipSetStringFormatTrimming", cast(void**)& GdipSetStringFormatTrimming ),
        Symbol( "GdipCreatePath", cast(void**)& GdipCreatePath ),
        Symbol( "GdipCreatePath2", cast(void**)& GdipCreatePath2 ),
        Symbol( "GdipCreatePath2I", cast(void**)& GdipCreatePath2I ),
        Symbol( "GdipDeletePath", cast(void**)& GdipDeletePath ),
        Symbol( "GdipClonePath", cast(void**)& GdipClonePath ),
        Symbol( "GdipResetPath", cast(void**)& GdipResetPath ),
        Symbol( "GdipGetPathFillMode", cast(void**)& GdipGetPathFillMode ),
        Symbol( "GdipSetPathFillMode", cast(void**)& GdipSetPathFillMode ),
        Symbol( "GdipStartPathFigure", cast(void**)& GdipStartPathFigure ),
        Symbol( "GdipClosePathFigure", cast(void**)& GdipClosePathFigure ),
        Symbol( "GdipClosePathFigures", cast(void**)& GdipClosePathFigures ),
        Symbol( "GdipSetPathMarker", cast(void**)& GdipSetPathMarker ),
        Symbol( "GdipClearPathMarkers", cast(void**)& GdipClearPathMarkers ),
        Symbol( "GdipReversePath", cast(void**)& GdipReversePath ),
        Symbol( "GdipGetPathLastPoint", cast(void**)& GdipGetPathLastPoint ),
        Symbol( "GdipAddPathLine", cast(void**)& GdipAddPathLine ),
        Symbol( "GdipAddPathLineI", cast(void**)& GdipAddPathLineI ),
        Symbol( "GdipAddPathLine2", cast(void**)& GdipAddPathLine2 ),
        Symbol( "GdipAddPathLine2I", cast(void**)& GdipAddPathLine2I ),
        Symbol( "GdipAddPathArc", cast(void**)& GdipAddPathArc ),
        Symbol( "GdipAddPathArcI", cast(void**)& GdipAddPathArcI ),
        Symbol( "GdipAddPathBezier", cast(void**)& GdipAddPathBezier ),
        Symbol( "GdipAddPathBezierI", cast(void**)& GdipAddPathBezierI ),
        Symbol( "GdipAddPathBeziers", cast(void**)& GdipAddPathBeziers ),
        Symbol( "GdipAddPathBeziersI", cast(void**)& GdipAddPathBeziersI ),
        Symbol( "GdipAddPathCurve", cast(void**)& GdipAddPathCurve ),
        Symbol( "GdipAddPathCurveI", cast(void**)& GdipAddPathCurveI ),
        Symbol( "GdipAddPathCurve2", cast(void**)& GdipAddPathCurve2 ),
        Symbol( "GdipAddPathCurve2I", cast(void**)& GdipAddPathCurve2I ),
        Symbol( "GdipAddPathCurve3", cast(void**)& GdipAddPathCurve3 ),
        Symbol( "GdipAddPathCurve3I", cast(void**)& GdipAddPathCurve3I ),
        Symbol( "GdipAddPathClosedCurve", cast(void**)& GdipAddPathClosedCurve ),
        Symbol( "GdipAddPathClosedCurveI", cast(void**)& GdipAddPathClosedCurveI ),
        Symbol( "GdipAddPathClosedCurve2", cast(void**)& GdipAddPathClosedCurve2 ),
        Symbol( "GdipAddPathClosedCurve2I", cast(void**)& GdipAddPathClosedCurve2I ),
        Symbol( "GdipAddPathRectangle", cast(void**)& GdipAddPathRectangle ),
        Symbol( "GdipAddPathRectangleI", cast(void**)& GdipAddPathRectangleI ),
        Symbol( "GdipAddPathRectangles", cast(void**)& GdipAddPathRectangles ),
        Symbol( "GdipAddPathRectanglesI", cast(void**)& GdipAddPathRectanglesI ),
        Symbol( "GdipAddPathEllipse", cast(void**)& GdipAddPathEllipse ),
        Symbol( "GdipAddPathEllipseI", cast(void**)& GdipAddPathEllipseI ),
        Symbol( "GdipAddPathPie", cast(void**)& GdipAddPathPie ),
        Symbol( "GdipAddPathPieI", cast(void**)& GdipAddPathPieI ),
        Symbol( "GdipAddPathPolygon", cast(void**)& GdipAddPathPolygon ),
        Symbol( "GdipAddPathPolygonI", cast(void**)& GdipAddPathPolygonI ),
        Symbol( "GdipAddPathPath", cast(void**)& GdipAddPathPath ),
        Symbol( "GdipAddPathString", cast(void**)& GdipAddPathString ),
        Symbol( "GdipAddPathStringI", cast(void**)& GdipAddPathStringI ),
        Symbol( "GdipTransformPath", cast(void**)& GdipTransformPath ),
        Symbol( "GdipGetPathWorldBounds", cast(void**)& GdipGetPathWorldBounds ),
        Symbol( "GdipFlattenPath", cast(void**)& GdipFlattenPath ),
        Symbol( "GdipWidenPath", cast(void**)& GdipWidenPath ),
        Symbol( "GdipWindingModeOutline", cast(void**)& GdipWindingModeOutline ),
        Symbol( "GdipWarpPath", cast(void**)& GdipWarpPath ),
        Symbol( "GdipGetPointCount", cast(void**)& GdipGetPointCount ),
        Symbol( "GdipGetPathTypes", cast(void**)& GdipGetPathTypes ),
        Symbol( "GdipGetPathPoints", cast(void**)& GdipGetPathPoints ),
        Symbol( "GdipIsVisiblePathPoint", cast(void**)& GdipIsVisiblePathPoint ),
        Symbol( "GdipIsVisiblePathPointI", cast(void**)& GdipIsVisiblePathPointI ),
        Symbol( "GdipIsOutlineVisiblePathPoint", cast(void**)& GdipIsOutlineVisiblePathPoint ),
        Symbol( "GdipIsOutlineVisiblePathPointI", cast(void**)& GdipIsOutlineVisiblePathPointI ),
        Symbol( "GdipDrawPath", cast(void**)& GdipDrawPath ),
        Symbol( "GdipCreatePathIter", cast(void**)& GdipCreatePathIter ),
        Symbol( "GdipDeletePathIter", cast(void**)& GdipDeletePathIter ),
        Symbol( "GdipPathIterNextSubpath", cast(void**)& GdipPathIterNextSubpath ),
        Symbol( "GdipPathIterNextSubpathPath", cast(void**)& GdipPathIterNextSubpathPath ),
        Symbol( "GdipPathIterNextPathType", cast(void**)& GdipPathIterNextPathType ),
        Symbol( "GdipPathIterNextMarker", cast(void**)& GdipPathIterNextMarker ),
        Symbol( "GdipPathIterNextMarkerPath", cast(void**)& GdipPathIterNextMarkerPath ),
        Symbol( "GdipPathIterGetCount", cast(void**)& GdipPathIterGetCount ),
        Symbol( "GdipPathIterGetSubpathCount", cast(void**)& GdipPathIterGetSubpathCount ),
        Symbol( "GdipPathIterHasCurve", cast(void**)& GdipPathIterHasCurve ),
        Symbol( "GdipPathIterRewind", cast(void**)& GdipPathIterRewind ),
        Symbol( "GdipPathIterEnumerate", cast(void**)& GdipPathIterEnumerate ),
        Symbol( "GdipPathIterCopyData", cast(void**)& GdipPathIterCopyData ),
        Symbol( "GdipCreatePathGradient", cast(void**)& GdipCreatePathGradient ),
        Symbol( "GdipCreatePathGradientI", cast(void**)& GdipCreatePathGradientI ),
        Symbol( "GdipCreatePathGradientFromPath", cast(void**)& GdipCreatePathGradientFromPath ),
        Symbol( "GdipGetPathGradientCenterColor", cast(void**)& GdipGetPathGradientCenterColor ),
        Symbol( "GdipSetPathGradientCenterColor", cast(void**)& GdipSetPathGradientCenterColor ),
        Symbol( "GdipGetPathGradientSurroundColorCount", cast(void**)& GdipGetPathGradientSurroundColorCount ),
        Symbol( "GdipGetPathGradientSurroundColorsWithCount", cast(void**)& GdipGetPathGradientSurroundColorsWithCount ),
        Symbol( "GdipSetPathGradientSurroundColorsWithCount", cast(void**)& GdipSetPathGradientSurroundColorsWithCount ),
        Symbol( "GdipGetPathGradientCenterPoint", cast(void**)& GdipGetPathGradientCenterPoint ),
        Symbol( "GdipSetPathGradientCenterPoint", cast(void**)& GdipSetPathGradientCenterPoint ),
        Symbol( "GdipGetPathGradientRect", cast(void**)& GdipGetPathGradientRect ),
        Symbol( "GdipGetPathGradientBlendCount", cast(void**)& GdipGetPathGradientBlendCount ),
        Symbol( "GdipGetPathGradientBlend", cast(void**)& GdipGetPathGradientBlend ),
        Symbol( "GdipSetPathGradientBlend", cast(void**)& GdipSetPathGradientBlend ),
        Symbol( "GdipGetPathGradientPresetBlendCount", cast(void**)& GdipGetPathGradientPresetBlendCount ),
        Symbol( "GdipGetPathGradientPresetBlend", cast(void**)& GdipGetPathGradientPresetBlend ),
        Symbol( "GdipSetPathGradientPresetBlend", cast(void**)& GdipSetPathGradientPresetBlend ),
        Symbol( "GdipSetPathGradientSigmaBlend", cast(void**)& GdipSetPathGradientSigmaBlend ),
        Symbol( "GdipSetPathGradientLinearBlend", cast(void**)& GdipSetPathGradientLinearBlend ),
        Symbol( "GdipGetPathGradientTransform", cast(void**)& GdipGetPathGradientTransform ),
        Symbol( "GdipSetPathGradientTransform", cast(void**)& GdipSetPathGradientTransform ),
        Symbol( "GdipResetPathGradientTransform", cast(void**)& GdipResetPathGradientTransform ),
        Symbol( "GdipMultiplyPathGradientTransform", cast(void**)& GdipMultiplyPathGradientTransform ),
        Symbol( "GdipRotatePathGradientTransform", cast(void**)& GdipRotatePathGradientTransform ),
        Symbol( "GdipTranslatePathGradientTransform", cast(void**)& GdipTranslatePathGradientTransform ),
        Symbol( "GdipScalePathGradientTransform", cast(void**)& GdipScalePathGradientTransform ),
        Symbol( "GdipGetPathGradientFocusScales", cast(void**)& GdipGetPathGradientFocusScales ),
        Symbol( "GdipSetPathGradientFocusScales", cast(void**)& GdipSetPathGradientFocusScales ),
        Symbol( "GdipGetPathGradientWrapMode", cast(void**)& GdipGetPathGradientWrapMode ),
        Symbol( "GdipSetPathGradientWrapMode", cast(void**)& GdipSetPathGradientWrapMode ),
        Symbol( "GdipResetTextureTransform", cast(void**)& GdipResetTextureTransform ),
        Symbol( "GdipScaleTextureTransform", cast(void**)& GdipScaleTextureTransform ),
        Symbol( "GdipTranslateTextureTransform", cast(void**)& GdipTranslateTextureTransform ),
        Symbol( "GdipStringFormatGetGenericDefault", cast(void**)& GdipStringFormatGetGenericDefault ),
        Symbol( "GdipStringFormatGetGenericTypographic", cast(void**)& GdipStringFormatGetGenericTypographic ),
        Symbol( "GdipSetStringFormatHotkeyPrefix", cast(void**)& GdipSetStringFormatHotkeyPrefix ),
        Symbol( "GdipSetStringFormatTabStops", cast(void**)& GdipSetStringFormatTabStops )
    ];
}`));


void loadLib_Gdip(){
    SharedLib.loadLibSymbols( symbols, "gdiplus.dll" );
}

}

/******************************************************************************

******************************************************************************/
/+
private uint initToken;
private bool isShutdown;

public int startup() {
  static GdiplusStartupInput input = { 1, null, 0, 0 };
  static GdiplusStartupOutput output;

  return GdiplusStartup(initToken, input, output);
}

public void shutdown() {
  // GC.collect();
  isShutdown = true;

  GdiplusShutdown(initToken);
}
+/
