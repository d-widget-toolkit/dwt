module java.io.SyncFailedException;

import java.lang.exceptions : IOException;

/**
 * Signals that a sync operation has failed.
 */
public class SyncFailedException : IOException
{
    /**
     * Constructs a SyncFailedException with a detail message.
     *
     * A detail message is a String that describes this particular exception.
     *
     * Params:
     *   desc = a String describing the exception.
     */
    this(string desc)
    {
        super(msg);
    }
}
