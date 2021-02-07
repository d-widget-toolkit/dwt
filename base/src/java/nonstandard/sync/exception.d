/**
 * Define base class for synchronization exceptions.
 *
 * Copyright: Copyright Sean Kelly 2005 - 2009.
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Authors:   Sean Kelly
 * Source:    $(DRUNTIMESRC core/sync/_exception.d)
 */

/*          Copyright Sean Kelly 2005 - 2009.
 * Distributed under the Boost Software License, Version 1.0.
 *    (See accompanying file LICENSE or copy at
 *          http://www.boost.org/LICENSE_1_0.txt)
 */
deprecated("Use core.sync.exception (SyncException is now SyncError)")
module java.nonstandard.sync.exception;

public import core.sync.exception;

deprecated("Use core.sync.exception.SyncError instead")
public alias SyncException = SyncError;
