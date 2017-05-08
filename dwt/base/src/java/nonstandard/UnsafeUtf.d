/** 
 * Stuff for working with narrow strings.
 * Unsafe because of no type checking.
 * 
 * Authors: Denis Shelomovskij <verylonglogin.reg@gmail.com>
 */
module java.nonstandard.UnsafeUtf;

import java.nonstandard.UtfBase;

private const bool UTFTypeCheck = false;
mixin(UtfBaseText);