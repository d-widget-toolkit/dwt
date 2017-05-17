module org.eclipse.swt.internal.mozilla.gfxIImageFrame;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

const char[] GFXIIMAGEFRAME_IID_STR = "f6d00ee7-defc-4101-b2dc-e72cf4c37c3c";

const nsIID GFXIIMAGEFRAME_IID= 
  {0xf6d00ee7, 0xdefc, 0x4101, 
    [ 0xb2, 0xdc, 0xe7, 0x2c, 0xf4, 0xc3, 0x7c, 0x3c ]};

interface gfxIImageFrame : nsISupports {


  static const char[] IID_STR = GFXIIMAGEFRAME_IID_STR;
  static const nsIID IID = GFXIIMAGEFRAME_IID;

extern(System):

  nsresult Init(PRInt32 aX, PRInt32 aY, PRInt32 aWidth, PRInt32 aHeight, gfx_format aFormat, gfx_depth aDepth);
  nsresult GetMutable(PRBool *aMutable);
  nsresult SetMutable(PRBool aMutable);
  nsresult GetX(PRInt32 *aX);
  nsresult GetY(PRInt32 *aY);
  nsresult GetWidth(PRInt32 *aWidth);
  nsresult GetHeight(PRInt32 *aHeight);
  nsresult GetRect(nsIntRect * rect);
  nsresult GetFormat(gfx_format *aFormat);
  nsresult GetNeedsBackground(PRBool *aNeedsBackground);
  nsresult GetImageBytesPerRow(PRUint32 *aImageBytesPerRow);
  nsresult GetImageDataLength(PRUint32 *aImageDataLength);
  nsresult GetImageData(PRUint8 **bits, PRUint32 *length);
  nsresult SetImageData(PRUint8 *data, PRUint32 length, PRInt32 offset);
  nsresult LockImageData();
  nsresult UnlockImageData();
  nsresult GetAlphaBytesPerRow(PRUint32 *aAlphaBytesPerRow);
  nsresult GetAlphaDataLength(PRUint32 *aAlphaDataLength);
  nsresult GetAlphaData(PRUint8 **bits, PRUint32 *length);
  nsresult SetAlphaData(PRUint8 *data, PRUint32 length, PRInt32 offset);
  nsresult LockAlphaData();
  nsresult UnlockAlphaData();
  nsresult DrawTo(gfxIImageFrame aDst, PRInt32 aDX, PRInt32 aDY, PRInt32 aDWidth, PRInt32 aDHeight);
  nsresult GetTimeout(PRInt32 *aTimeout);
  nsresult SetTimeout(PRInt32 aTimeout);
  nsresult GetFrameDisposalMethod(PRInt32 *aFrameDisposalMethod);
  nsresult SetFrameDisposalMethod(PRInt32 aFrameDisposalMethod);
  nsresult GetBackgroundColor(gfx_color *aBackgroundColor);
  nsresult SetBackgroundColor(gfx_color aBackgroundColor);

}

