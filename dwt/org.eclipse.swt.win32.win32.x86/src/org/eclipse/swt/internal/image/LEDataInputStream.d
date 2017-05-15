/*******************************************************************************
 * Copyright (c) 2000, 2007 IBM Corporation and others.
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
module org.eclipse.swt.internal.image.LEDataInputStream;


import java.io.InputStream;
import java.lang.all;

final class LEDataInputStream : InputStream{

    alias InputStream.read read;

    InputStream host;

    int position;

    /**
     * The byte array containing the bytes to read.
     */
    protected byte[] buf;

    /**
     * The current position within the byte array <code>buf</code>. A value
     * equal to buf.length indicates no bytes available.  A value of
     * 0 indicates the buffer is full.
     */
    protected int pos;


    public this(InputStream input) {
        this(input, 512);
    }

    public this(InputStream input, int bufferSize) {
        host = input;
        if (bufferSize > 0) {
            buf = new byte[bufferSize];
            pos = bufferSize;
        }
        else throw new IllegalArgumentException("bufferSize must be greater zero" );
    }

    override
    public void close() {
        buf = null;
        if (host !is null) {
            host.close();
            host = null;
        }
    }

    /**
     * Answer how many bytes were read.
     */
    public int getPosition() {
        return position;
    }

    /**
     * Answers how many bytes are available for reading without blocking
     */
    public override ptrdiff_t available() {
        if (buf is null) throw new IOException("buf is null");
        return (buf.length - pos) + host.available();
    }

    /**
     * Answer the next byte of the input stream.
     */
    public override int read() {
        if (buf is null) throw new IOException("buf is null");
        if (pos < buf.length) {
            position++;
            return (buf[pos++] & 0xFF);
        }
        int c = host.read();
        if (c !is -1 ) position++;
        return c;
    }

    /**
     * Don't imitate the JDK behaviour of reading a random number
     * of bytes when you can actually read them all.
     */
    public override ptrdiff_t read(byte[] b, ptrdiff_t off, ptrdiff_t len) {
        ptrdiff_t read = 0, count;
        while (read !is len && (count = readData(b, off, len - read)) !is -1) {
            off += count;
            read += count;
        }
        position += read;
        if (read is 0 && read !is len) return -1;
        return read;
    }

    public override long skip(long n) {
        if (buf.length < position + n) {
            n = buf.length - position;
        }
        pos += n;
        position += n;
        host.skip(n);
        return n;
    }

    /**
     * Reads at most <code>length</code> bytes from this LEDataInputStream and
     * stores them in byte array <code>buffer</code> starting at <code>offset</code>.
     * <p>
     * Answer the number of bytes actually read or -1 if no bytes were read and
     * end of stream was encountered.  This implementation reads bytes from
     * the pushback buffer first, then the target stream if more bytes are required
     * to satisfy <code>count</code>.
     * </p>
     * @param buffer the byte array in which to store the read bytes.
     * @param offset the offset in <code>buffer</code> to store the read bytes.
     * @param length the maximum number of bytes to store in <code>buffer</code>.
     *
     * @return int the number of bytes actually read or -1 if end of stream.
     *
     * @exception java.io.IOException if an IOException occurs.
     */
    private ptrdiff_t readData(byte[] buffer, ptrdiff_t offset, ptrdiff_t len) {
        if (buf is null) throw new IOException("buf is null");
        if (offset < 0 || offset > buffer.length ||
            len < 0 || (len > buffer.length - offset)) {
            throw new ArrayIndexOutOfBoundsException(__FILE__,__LINE__);
            }

        ptrdiff_t cacheCopied = 0;
        ptrdiff_t newOffset = offset;

        // Are there pushback bytes available?
        ptrdiff_t available = buf.length - pos;
        if (available > 0) {
            cacheCopied = (available >= len) ? len : available;
            System.arraycopy(buf, pos, buffer, newOffset, cacheCopied);
            newOffset += cacheCopied;
            pos += cacheCopied;
        }

        // Have we copied enough?
        if (cacheCopied is len) return len;

        ptrdiff_t inCopied = host.read( buffer, newOffset, len - cacheCopied );
        if( inCopied is -1 ) inCopied = -1;
        if (inCopied > 0 ) return inCopied + cacheCopied;
        if (cacheCopied is 0) return inCopied;
        return cacheCopied;
    }

    /**
     * Answer an integer comprised of the next
     * four bytes of the input stream.
     */
    public int readInt() {
        byte[4] buf = void;
        read(buf);
        return ((buf[3] & 0xFF) << 24) | 
            ((buf[2] & 0xFF) << 16) | 
            ((buf[1] & 0xFF) << 8) | 
            (buf[0] & 0xFF);
    }

    /**
     * Answer a short comprised of the next
     * two bytes of the input stream.
     */
    public short readShort() {
        byte[2] buf = void;
        read(buf);
        return cast(short)(((buf[1] & 0xFF) << 8) | (buf[0] & 0xFF));
    }

    /**
     * Push back the entire content of the given buffer <code>b</code>.
     * <p>
     * The bytes are pushed so that they would be read back b[0], b[1], etc.
     * If the push back buffer cannot handle the bytes copied from <code>b</code>,
     * an IOException will be thrown and no byte will be pushed back.
     * </p>
     *
     * @param b the byte array containing bytes to push back into the stream
     *
     * @exception   java.io.IOException if the pushback buffer is too small
     */
    public void unread(byte[] b) {
        auto l = b.length;
        if (l > pos) throw new IOException("cannot unread");
        position -= l;
        pos -= l;
        System.arraycopy(b, 0, buf, pos, l);
    }
}
