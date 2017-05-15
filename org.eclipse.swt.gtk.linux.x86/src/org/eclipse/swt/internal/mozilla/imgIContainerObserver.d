module org.eclipse.swt.internal.mozilla.imgIContainerObserver;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.imgIContainer;
import org.eclipse.swt.internal.mozilla.gfxIImageFrame;

const char[] IMGICONTAINEROBSERVER_IID_STR = "53102f15-0f53-4939-957e-aea353ad2700";

const nsIID IMGICONTAINEROBSERVER_IID= 
  {0x53102f15, 0x0f53, 0x4939, 
    [ 0x95, 0x7e, 0xae, 0xa3, 0x53, 0xad, 0x27, 0x00 ]};

interface imgIContainerObserver : nsISupports {

  static const char[] IID_STR = IMGICONTAINEROBSERVER_IID_STR;
  static const nsIID IID = IMGICONTAINEROBSERVER_IID;

extern(System):
  nsresult FrameChanged(imgIContainer aContainer, gfxIImageFrame aFrame, nsIntRect * aDirtyRect);

}

