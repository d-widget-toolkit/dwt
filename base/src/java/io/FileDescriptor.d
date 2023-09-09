module java.io.FileDescriptor;

version(Posix) {
    import core.stdc.errno : errno;
    import core.stdc.string : strerror;
    import core.sys.posix.unistd : fsync;
} else version(Windows) {
    import core.sys.windows.core;
}

import std.string : fromStringz;

import java.io.SyncFailedException;

/**
 * Instances of the file descriptor class serve as an opaque handle to the
 * underlying machine-specific structure representing an open file, an open
 * socket, or another source or sink of bytes.
 *
 * The main practical use for a file descriptor is to create a
 * `FileInputStream` or `FileOutputStream` to contain it.
 *
 * Applications should not create their own file descriptors.
 *
 * See_Also: FileInputStream, FileOutputStream
 */
public final class FileDescriptor
{
    private int fFD;
    private void* fHandle;

    /// UNIX file descriptor
    package int getFD()
    {
        return fFD;
    }

    /// Windows file HANDLE
    package void* getHandle()
    {
        return fHandle;
    }

    /**
     * A handle to the standard input stream.
     *
     * Usually, this file descriptor is not used directly, but rather via the
     * output stream known as `System.in`.
     */
    public static const FileDescriptor in_;

    /**
     * A handle to the standard output stream.
     *
     * Usually, this file descriptor is not used directly, but rather via the
     * output stream known as `System.out`.
     */
    public static const FileDescriptor out_;

    /**
     * A handle to the standard error stream.
     *
     * Usually, this file descriptor is not used directly, but rather via the
     * output stream known as `System.err`.
     */
    public static const FileDescriptor err;

    static this()
    {
        in_ = new FileDescriptor(0);
        out_ = new FileDescriptor(1);
        err = new FileDescriptor(2);
    }

    /**
     * Construct an (invalid) FileDescriptor object.
     */
    public this()
    {
        fFD = -1;
        fHandle = null;
    }

    private this(int fd)
    {
        fFD = fd;
        version (Posix) {
            fHandle = null;
        } else version(Windows) {
            if (fd == 0) {
                fHandle = GetStdHandle(STD_INPUT_HANDLE);
            } else if (fd == 1) {
                fHandle = GetStdHandle(STD_OUTPUT_HANDLE);
            } else if (fd == 2) {
                fHandle = GetStdHandle(STD_ERROR_HANDLE);
            }
        }
    }

    /**
     * Tests if this file descriptor object is valid.
     *
     * Returns: `true` if the file descriptor object represents a valid, open
     * file, socket, or other active I/O connection; `false` otherwise.
     */
    public bool valid() const
    {
        version (Posix) {
            return fFD >= 0;
        } else version (Windows) {
            return (fFD >= 0) && (fHandle !is null);
        }
    }

    /**
     * Force all system buffers to syncrhonize with the underlying device.
     *
     * This method returns after all modified data and attributes of this
     * FileDescriptor have been written to the relevant device(s).  In
     * particular, if this FileDescriptor refers to a physical storage medium,
     * such as a file in a file system, sync will not return until all
     * in-memory modified copies of buffers associated with this FileDescriptor
     * have been written to the physical medium.  sync is meant to be used by
     * code that requires physical storage (such as a file) to be in a known
     * state.  For example, a class that provided a simple transaction facility
     * might use sync to ensure that all changes to a file caused by a given
     * transaction were recorded on a storage medium.  sync only affects
     * buffers downstream of this FileDescriptor.  If any in-memory buffering
     * is being done by the application (for example, by a BufferedOutputStream
     * object), those buffers must be flushed into the FileDescriptor (for
     * example, by invoking OutputStream.flush) before that data will be
     * affected by sync.
     *
     * Throws: SyncFailedException when the buffer cannot be flushed, or
     * because the system cannot guarantee that all buffers have been
     * synchronized with physical media.
     */
    public void sync() const
    {
        version(Posix) {
            int res = fsync(fFD);
            if (res != 0) {
                throw new SyncFailedException(getLastError());
            }
        } else version(Windows) {
            const res = FlushFileBuffers(cast(void*)fHandle);
            if (res == 0) {
                throw new SyncFailedException(getLastError());
            }
        }
    }


    version(Posix) {
        private string getLastError() const
        {
            return fromStringz(strerror(errno)).dup;
        }
    } else version(Windows) {
        private string getLastError() const
        {
            import java.lang.String : String_valueOf, fromString16z;

            LPWSTR buffer;
            DWORD errorCode = GetLastError();

            FormatMessage(
                FORMAT_MESSAGE_ALLOCATE_BUFFER |
                FORMAT_MESSAGE_FROM_SYSTEM |
                FORMAT_MESSAGE_IGNORE_INSERTS,
                null,
                errorCode,
                MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                cast(LPWSTR)&buffer,
                0,
                null);

            wstring result = fromString16z(buffer);
            LocalFree(buffer);

            return String_valueOf(result);
        }
    }
}
