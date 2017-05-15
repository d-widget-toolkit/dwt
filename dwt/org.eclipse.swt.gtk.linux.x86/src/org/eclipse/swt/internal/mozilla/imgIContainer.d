module org.eclipse.swt.internal.mozilla.imgIContainer;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.gfxIImageFrame;
import org.eclipse.swt.internal.mozilla.imgIContainerObserver;

const char[] IMGICONTAINER_IID_STR = "1a6290e6-8285-4e10-963d-d001f8d327b8";

const nsIID IMGICONTAINER_IID= 
  {0x1a6290e6, 0x8285, 0x4e10, 
    [ 0x96, 0x3d, 0xd0, 0x01, 0xf8, 0xd3, 0x27, 0xb8 ]};


interface imgIContainer : nsISupports {

  static const char[] IID_STR = IMGICONTAINER_IID_STR;
  static const nsIID IID = IMGICONTAINER_IID;

extern(System):
  nsresult Init(PRInt32 aWidth, PRInt32 aHeight, imgIContainerObserver aObserver);
  nsresult GetPreferredAlphaChannelFormat(gfx_format *aPreferredAlphaChannelFormat);
  nsresult GetWidth(PRInt32 *aWidth);
  nsresult GetHeight(PRInt32 *aHeight);
  nsresult GetCurrentFrame(gfxIImageFrame  *aCurrentFrame);
  nsresult GetNumFrames(PRUint32 *aNumFrames);

  enum { kNormalAnimMode = 0 };
  enum { kDontAnimMode = 1 };
  enum { kLoopOnceAnimMode = 2 };

  nsresult GetAnimationMode(PRUint16 *aAnimationMode);
  nsresult SetAnimationMode(PRUint16 aAnimationMode);
  nsresult GetFrameAt(PRUint32 index, gfxIImageFrame *_retval);
  nsresult AppendFrame(gfxIImageFrame item);
  nsresult RemoveFrame(gfxIImageFrame item);
  nsresult EndFrameDecode(PRUint32 framenumber, PRUint32 timeout);
  nsresult DecodingComplete();
  nsresult Clear();
  nsresult StartAnimation();
  nsresult StopAnimation();
  nsresult ResetAnimation();
  nsresult GetLoopCount(PRInt32 *aLoopCount);
  nsresult SetLoopCount(PRInt32 aLoopCount);

}

