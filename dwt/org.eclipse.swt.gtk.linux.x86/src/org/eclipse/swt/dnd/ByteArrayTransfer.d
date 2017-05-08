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
module org.eclipse.swt.dnd.ByteArrayTransfer;

import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.dnd.Transfer;
import org.eclipse.swt.dnd.TransferData;
import org.eclipse.swt.dnd.DND;
import java.lang.all;

/**
 * The class <code>ByteArrayTransfer</code> provides a platform specific
 * mechanism for converting a java <code>byte[]</code> to a platform
 * specific representation of the byte array and vice versa.
 *
 * <p><code>ByteArrayTransfer</code> is never used directly but is sub-classed
 * by transfer agents that convert between data in a java format such as a
 * <code>String</code> and a platform specific byte array.
 *
 * <p>If the data you are converting <b>does not</b> map to a
 * <code>byte[]</code>, you should sub-class <code>Transfer</code> directly
 * and do your own mapping to a platform data type.</p>
 *
 * <p>The following snippet shows a subclass of ByteArrayTransfer that transfers
 * data defined by the class <code>MyType</code>.</p>
 *
 * <pre><code>
 * public class MyType {
 *  public String fileName;
 *  public long fileLength;
 *  public long lastModified;
 * }
 * </code></pre>
 *
 * <pre><code>
 * public class MyTypeTransfer extends ByteArrayTransfer {
 *
 *  private static final String MYTYPENAME = "my_type_name";
 *  private static final int MYTYPEID = registerType(MYTYPENAME);
 *  private static MyTypeTransfer _instance = new MyTypeTransfer();
 *
 * private MyTypeTransfer() {}
 *
 * public static MyTypeTransfer getInstance () {
 *  return _instance;
 * }
 * public void javaToNative (Object object, TransferData transferData) {
 *  if (object is null || !(object instanceof MyType[])) return;
 *
 *  if (isSupportedType(transferData)) {
 *      MyType[] myTypes = (MyType[]) object;
 *      try {
 *          // write data to a byte array and then ask super to convert to pMedium
 *          ByteArrayOutputStream out = new ByteArrayOutputStream();
 *          DataOutputStream writeOut = new DataOutputStream(out);
 *          for (int i = 0, length = myTypes.length; i &lt; length;  i++){
 *              byte[] buffer = myTypes[i].fileName.getBytes();
 *              writeOut.writeInt(buffer.length);
 *              writeOut.write(buffer);
 *              writeOut.writeLong(myTypes[i].fileLength);
 *              writeOut.writeLong(myTypes[i].lastModified);
 *          }
 *          byte[] buffer = out.toByteArray();
 *          writeOut.close();
 *
 *          super.javaToNative(buffer, transferData);
 *
 *      } catch (IOException e) {
 *      }
 *  }
 * }
 * public Object nativeToJava(TransferData transferData){
 *
 *  if (isSupportedType(transferData)) {
 *
 *      byte[] buffer = (byte[])super.nativeToJava(transferData);
 *      if (buffer is null) return null;
 *
 *      MyType[] myData = new MyType[0];
 *      try {
 *          ByteArrayInputStream in = new ByteArrayInputStream(buffer);
 *          DataInputStream readIn = new DataInputStream(in);
 *          while(readIn.available() > 20) {
 *              MyType datum = new MyType();
 *              int size = readIn.readInt();
 *              byte[] name = new byte[size];
 *              readIn.read(name);
 *              datum.fileName = new String(name);
 *              datum.fileLength = readIn.readLong();
 *              datum.lastModified = readIn.readLong();
 *              MyType[] newMyData = new MyType[myData.length + 1];
 *              System.arraycopy(myData, 0, newMyData, 0, myData.length);
 *              newMyData[myData.length] = datum;
 *              myData = newMyData;
 *          }
 *          readIn.close();
 *      } catch (IOException ex) {
 *          return null;
 *      }
 *      return myData;
 *  }
 *
 *  return null;
 * }
 * protected String[] getTypeNames(){
 *  return new String[]{MYTYPENAME};
 * }
 * protected int[] getTypeIds(){
 *  return new int[] {MYTYPEID};
 * }
 * }
 * </code></pre>
 *
 * @see Transfer
 */
public abstract class ByteArrayTransfer : Transfer {

public override TransferData[] getSupportedTypes() {
    int[] types = getTypeIds();
    TransferData[] data = new TransferData[types.length];
    for (int i = 0; i < types.length; i++) {
        data[i] = new TransferData();
        data[i].type = cast(void*)types[i];
    }
    return data;
}

public override bool isSupportedType(TransferData transferData){
    if (transferData is null) return false;
    int[] types = getTypeIds();
    for (int i = 0; i < types.length; i++) {
        if (transferData.type is cast(void*)types[i]) return true;
    }
    return false;
}

/**
 * This implementation of <code>javaToNative</code> converts a java
 * <code>byte[]</code> to a platform specific representation.
 * 
 * @param object a java <code>byte[]</code> containing the data to be converted
 * @param transferData an empty <code>TransferData</code> object that will
 *      be filled in on return with the platform specific format of the data
 * 
 * @see Transfer#nativeToJava
 */
protected override void javaToNative (Object object, TransferData transferData) {
    transferData.result = 0;
    if (!checkByteArray(object) || !isSupportedType(transferData)) {
        DND.error(DND.ERROR_INVALID_DATA);
    }
    byte[] buffer = (cast(ArrayWrapperByte)object).array;
    if (buffer.length is 0) return;
    byte* pValue = cast(byte*)OS.g_malloc(buffer.length);
    if (pValue is null) return;
    pValue[ 0 .. buffer.length ] = buffer;
    transferData.length = cast(int)/*64bit*/buffer.length;
    transferData.format = 8;
    transferData.pValue = cast(char*)pValue;
    transferData.result = 1;
}

/**
 * This implementation of <code>nativeToJava</code> converts a platform specific
 * representation of a byte array to a java <code>byte[]</code>.
 *
 * @param transferData the platform specific representation of the data to be converted
 * @return a java <code>byte[]</code> containing the converted data if the conversion was
 *      successful; otherwise null
 *
 * @see Transfer#javaToNative
 */
protected override Object nativeToJava(TransferData transferData) {
    if ( !isSupportedType(transferData) || transferData.pValue is null) return null;
    int size = transferData.format * transferData.length / 8;
    if (size is 0) return null;
    byte* ptr = cast(byte*)transferData.pValue;
    return new ArrayWrapperByte( ptr[ 0 .. size ].dup );
}

bool checkByteArray(Object object) {
    if( object is null ) return false;
    ArrayWrapperByte arr = cast(ArrayWrapperByte)object;
    if( arr is null ) return false;
    return arr.array.length > 0;
}
}
