module java.lang.util;

public import java.lang.wrappers;
public import java.lang.String;
public import java.lang.interfaces;

version(Tango){
    static import tango.text.convert.Format;
    static import tango.core.Exception;
    static import tango.util.log.Log;
    static import tango.util.log.Config;
    static import tango.stdc.stdlib;

    alias tango.stdc.stdlib.exit exit;
} else { // Phobos
    static import core.exception;
    static import core.stdc.stdlib;
    static import std.stdio;
    static import std.ascii;
    static import std.array;
    static import std.conv;
    static import std.format;
    static import std.typetuple;
    static import std.traits;
    static import std.exception;
    static import std.string;
    static import std.utf;
    alias exit = core.stdc.stdlib.exit;
}

version(Tango){
    interface IDwtLogger {
        void trace( String file, ulong line, String fmt, ... );
        void info( String file, ulong line, String fmt, ... );
        void warn( String file, ulong line, String fmt, ... );
        void error( String file, ulong line, String fmt, ... );
        void fatal( String file, ulong line, String fmt, ... );
    }

    class DwtLogger : IDwtLogger {
        tango.util.log.Log.Logger logger;
        private this( char[] name ){
            logger = tango.util.log.Log.Log.lookup( name );
        }
        private char[] format( String file, ulong line, String fmt, TypeInfo[] types, void* argptr ){
            auto msg = Format.convert( types, argptr, fmt );
            auto text = Format( "{} {}: {}", file, line, msg );
            return text;
        }
        void trace( String file, ulong line, String fmt, ... ){
            if( logger.trace ){
                logger.trace( format( file, line, fmt, _arguments, _argptr ));
            }
        }
        void info( String file, ulong line, String fmt, ... ){
            if( logger.info ){
                logger.info( format( file, line, fmt, _arguments, _argptr ));
            }
        }
        void warn( String file, ulong line, String fmt, ... ){
            if( logger.warn ){
                logger.warn( format( file, line, fmt, _arguments, _argptr ));
            }
        }
        void error( String file, ulong line, String fmt, ... ){
            if( logger.error ){
                logger.error( format( file, line, fmt, _arguments, _argptr ));
            }
        }
        void fatal( String file, ulong line, String fmt, ... ){
            if( logger.fatal ){
                logger.fatal( format( file, line, fmt, _arguments, _argptr ));
            }
        }
    }
} else { // Phobos
    class IDwtLogger {
        private this( String name ) {
        }
        void trace(T...)( String file, ulong line, String fmt, T args ){
            std.stdio.writefln( "TRC %s %s: %s", file, line, Format(fmt, args) );
        }
        void info(T...)( String file, ulong line, String fmt, T args ){
            std.stdio.writefln( "INF %s %s: %s", file, line, Format(fmt, args) );
        }
        void warn(T...)( String file, ulong line, String fmt, T args ){
            std.stdio.writefln( "WRN %s %s: %s", file, line, Format(fmt, args));
        }
        void error(T...)( String file, ulong line, String fmt, T args ){
            std.stdio.writefln( "ERR %s %s: %s", file, line, Format(fmt, args) );
        }
        void fatal(T...)( String file, ulong line, String fmt, T args ){
            std.stdio.writefln( "FAT %s %s: %s", file, line, Format(fmt, args) );
        }
    }

    alias DwtLogger = IDwtLogger;
}

private IDwtLogger dwtLoggerInstance;

IDwtLogger getDwtLogger(){
    if( dwtLoggerInstance is null ){
        synchronized{
            if( dwtLoggerInstance is null ){
                dwtLoggerInstance = new DwtLogger( "dwt" );
            }
        }
    }
    return dwtLoggerInstance;
}

void implMissing( String file, uint line ){
    getDwtLogger().fatal( file, line, "implementation missing in file {} line {}", file, line );
    getDwtLogger().fatal( file, line, "Please create a bug report at http://www.dsource.org/projects/dwt" );
    throw new core.exception.AssertError("Implementation missing", file, line);
}

void implMissingInTango(T = void)( String file, uint line ) {
    version(Tango) {} else static assert(0, "For Tango implMissings only");
    getDwtLogger().fatal( file, line, "implementation missing in Tango version" );
    implMissing( file, line );
}

void implMissingInPhobos( String file = __FILE__, uint line = __LINE__ )() {
    version(Tango) static assert(0, "For Phobos implMissings only");
    getDwtLogger().fatal( file, line, "implementation missing in Phobos version" );
    implMissing( file, line );
}

version(Tango){
    alias implMissing implMissingSafe;
} else { // Phobos
    mixin(`@safe nothrow
    void implMissingSafe( String file, uint line ) {
        // impossible processing
    }`);
}

version(Tango){
    public alias tango.text.convert.Format.Format Format;
} else { // Phobos

    unittest
    {
        alias Formatter = Format;

        // basic layout tests
        assert( Formatter( "abc" ) == "abc" );
        assert( Formatter( "{0}", 1 ) == "1" );
        assert( Formatter( "{0}", -1 ) == "-1" );

        assert( Formatter( "{}", 1 ) == "1" );
        assert( Formatter( "{} {}", 1, 2) == "1 2" );
        assert( Formatter( "{} {0} {}", 1, 3) == "1 1 3" );
        // assert( Formatter( "{} {0} {} {}", 1, 3) == "1 1 3 {invalid index}" );
        // assert( Formatter( "{} {0} {} {:x}", 1, 3) == "1 1 3 {invalid index}" );
        assert( Formatter( "{0} {0} {1}", 1, 3) == "1 1 3" );
        assert( Formatter( "{0} {0} {1} {0}", 1, 3) == "1 1 3 1" );

        assert( Formatter( "{0}", true ) == "true" , Formatter( "{0}", true ));
        assert( Formatter( "{0}", false ) == "false" );

        assert( Formatter( "{0}", cast(byte)-128 ) == "-128" );
        assert( Formatter( "{0}", cast(byte)127 ) == "127" );
        assert( Formatter( "{0}", cast(ubyte)255 ) == "255" );

        assert( Formatter( "{0}", cast(short)-32768  ) == "-32768" );
        assert( Formatter( "{0}", cast(short)32767 ) == "32767" );
        assert( Formatter( "{0}", cast(ushort)65535 ) == "65535" );
        // assert( Formatter( "{0:x4}", cast(ushort)0xafe ) == "0afe" );
        // assert( Formatter( "{0:X4}", cast(ushort)0xafe ) == "0AFE" );

        assert( Formatter( "{0}", -2147483648 ) == "-2147483648" );
        assert( Formatter( "{0}", 2147483647 ) == "2147483647" );
        assert( Formatter( "{0}", 4294967295 ) == "4294967295" );

        // large integers
        assert( Formatter( "{0}", -9223372036854775807L) == "-9223372036854775807" );
        assert( Formatter( "{0}", 0x8000_0000_0000_0000L) == "9223372036854775808" );
        assert( Formatter( "{0}", 9223372036854775807L ) == "9223372036854775807" );
        assert( Formatter( "{0:X}", 0xFFFF_FFFF_FFFF_FFFF) == "FFFFFFFFFFFFFFFF" );
        assert( Formatter( "{0:x}", 0xFFFF_FFFF_FFFF_FFFF) == "ffffffffffffffff" );
        assert( Formatter( "{0:x}", 0xFFFF_1234_FFFF_FFFF) == "ffff1234ffffffff" );
        // assert( Formatter( "{0:x19}", 0x1234_FFFF_FFFF) == "00000001234ffffffff" );
        assert( Formatter( "{0}", 18446744073709551615UL ) == "18446744073709551615" );
        assert( Formatter( "{0}", 18446744073709551615UL ) == "18446744073709551615" );

        // fragments before and after
        assert( Formatter( "d{0}d", "s" ) == "dsd" );
        assert( Formatter( "d{0}d", "1234567890" ) == "d1234567890d" );

        // brace escaping
        assert( Formatter( "d{0}d", "<string>" ) == "d<string>d");
        assert( Formatter( "d{{0}d", "<string>" ) == "d{0}d");
        assert( Formatter( "d{{{0}d", "<string>" ) == "d{<string>d");
        assert( Formatter( "d{0}}d", "<string>" ) == "d<string>}d");

        // hex conversions, where width indicates leading zeroes
        assert( Formatter( "{0:x}", 0xafe0000 ) == "afe0000" );
        // assert( Formatter( "{0:x7}", 0xafe0000 ) == "afe0000" );
        // assert( Formatter( "{0:x8}", 0xafe0000 ) == "0afe0000" );
        // assert( Formatter( "{0:X8}", 0xafe0000 ) == "0AFE0000" );
        // assert( Formatter( "{0:X9}", 0xafe0000 ) == "00AFE0000" );
        // assert( Formatter( "{0:X13}", 0xafe0000 ) == "000000AFE0000" );
        // assert( Formatter( "{0:x13}", 0xafe0000 ) == "000000afe0000" );

        // decimal width
        // assert( Formatter( "{0:d6}", 123 ) == "000123" );
        // assert( Formatter( "{0,7:d6}", 123 ) == " 000123" );
        // assert( Formatter( "{0,-7:d6}", 123 ) == "000123 " );

        // width & sign combinations
        // assert( Formatter( "{0:d7}", -123 ) == "-0000123" );
        // assert( Formatter( "{0,7:d6}", 123 ) == " 000123" );
        // assert( Formatter( "{0,7:d7}", -123 ) == "-0000123" );
        // assert( Formatter( "{0,8:d7}", -123 ) == "-0000123" );
        // assert( Formatter( "{0,5:d7}", -123 ) == "-0000123" );

        // Negative numbers in various bases
        assert( Formatter( "{:b}", cast(byte) -1 ) == "11111111" );
        assert( Formatter( "{:b}", cast(short) -1 ) == "1111111111111111" );
        assert( Formatter( "{:b}", cast(int) -1 )
                == "11111111111111111111111111111111" );
        assert( Formatter( "{:b}", cast(long) -1 )
                == "1111111111111111111111111111111111111111111111111111111111111111" );

        assert( Formatter( "{:o}", cast(byte) -1 ) == "377" );
        assert( Formatter( "{:o}", cast(short) -1 ) == "177777" );
        assert( Formatter( "{:o}", cast(int) -1 ) == "37777777777" );
        assert( Formatter( "{:o}", cast(long) -1 ) == "1777777777777777777777" );

        assert( Formatter( "{:d}", cast(byte) -1 ) == "-1" );
        assert( Formatter( "{:d}", cast(short) -1 ) == "-1" );
        assert( Formatter( "{:d}", cast(int) -1 ) == "-1" );
        assert( Formatter( "{:d}", cast(long) -1 ) == "-1" );

        assert( Formatter( "{:x}", cast(byte) -1 ) == "ff" );
        assert( Formatter( "{:x}", cast(short) -1 ) == "ffff" );
        assert( Formatter( "{:x}", cast(int) -1 ) == "ffffffff" );
        assert( Formatter( "{:x}", cast(long) -1 ) == "ffffffffffffffff" );

        // argument index
        assert( Formatter( "a{0}b{1}c{2}", "x", "y", "z" ) == "axbycz" );
        assert( Formatter( "a{2}b{1}c{0}", "x", "y", "z" ) == "azbycx" );
        assert( Formatter( "a{1}b{1}c{1}", "x", "y", "z" ) == "aybycy" );

        // alignment does not restrict the length
        // assert( Formatter( "{0,5}", "hellohello" ) == "hellohello" );

        // alignment fills with spaces
        // assert( Formatter( "->{0,-10}<-", "hello" ) == "->hello     <-" );
        // assert( Formatter( "->{0,10}<-", "hello" ) == "->     hello<-" );
        // assert( Formatter( "->{0,-10}<-", 12345 ) == "->12345     <-" );
        // assert( Formatter( "->{0,10}<-", 12345 ) == "->     12345<-" );

        // chop at maximum specified length; insert ellipses when chopped
        // assert( Formatter( "->{.5}<-", "hello" ) == "->hello<-" );
        // assert( Formatter( "->{.4}<-", "hello" ) == "->hell...<-" );
        // assert( Formatter( "->{.-3}<-", "hello" ) == "->...llo<-" );

        // width specifier indicates number of decimal places
        assert( Formatter( "{0:f}", 1.23f ) == "1.230000" );
        // assert( Formatter( "{0:f4}", 1.23456789L ) == "1.2346" );
        // assert( Formatter( "{0:e4}", 0.0001) == "1.0000e-04");

        assert( Formatter( "{0:f}", 1.23f*1i ) == "1.230000i");
        // assert( Formatter( "{0:f4}", 1.23456789L*1i ) == "1.2346*1i" );
        // assert( Formatter( "{0:e4}", 0.0001*1i) == "1.0000e-04*1i");

        assert( Formatter( "{0:f}", 1.23f+1i ) == "1.230000+1.000000i" );
        // assert( Formatter( "{0:f4}", 1.23456789L+1i ) == "1.2346+1.0000*1i" );
        // assert( Formatter( "{0:e4}", 0.0001+1i) == "1.0000e-04+1.0000e+00*1i");
        assert( Formatter( "{0:f}", 1.23f-1i ) == "1.230000-1.000000i" );
        // assert( Formatter( "{0:f4}", 1.23456789L-1i ) == "1.2346-1.0000*1i" );
        // assert( Formatter( "{0:e4}", 0.0001-1i) == "1.0000e-04-1.0000e+00*1i");

        // 'f.' & 'e.' format truncates zeroes from floating decimals
        // assert( Formatter( "{:f4.}", 1.230 ) == "1.23" );
        // assert( Formatter( "{:f6.}", 1.230 ) == "1.23" );
        // assert( Formatter( "{:f1.}", 1.230 ) == "1.2" );
        // assert( Formatter( "{:f.}", 1.233 ) == "1.23" );
        // assert( Formatter( "{:f.}", 1.237 ) == "1.24" );
        // assert( Formatter( "{:f.}", 1.000 ) == "1" );
        // assert( Formatter( "{:f2.}", 200.001 ) == "200");

        // array output
        int[] a = [ 51, 52, 53, 54, 55 ];
        assert( Formatter( "{}", a ) == "[51, 52, 53, 54, 55]" );
        assert( Formatter( "{:x}", a ) == "[33, 34, 35, 36, 37]" );
        // assert( Formatter( "{,-4}", a ) == "[51  , 52  , 53  , 54  , 55  ]" );
        // assert( Formatter( "{,4}", a ) == "[  51,   52,   53,   54,   55]" );
        int[][] b = [ [ 51, 52 ], [ 53, 54, 55 ] ];
        assert( Formatter( "{}", b ) == "[[51, 52], [53, 54, 55]]" );

        char[1024] static_buffer;
        static_buffer[0..10] = "1234567890";

        assert (Formatter( "{}", static_buffer[0..10]) == "1234567890");

        version(X86)
        {
            ushort[3] c = [ cast(ushort)51, 52, 53 ];
            assert( Formatter( "{}", c ) == "[51, 52, 53]" );
        }

        /*// integer AA
        ushort[long] d;
        d[234] = 2;
        d[345] = 3;

        assert( Formatter( "{}", d ) == "{234 => 2, 345 => 3}" ||
                Formatter( "{}", d ) == "{345 => 3, 234 => 2}");

        // bool/string AA
        bool[char[]] e;
        e[ "key".dup ] = true;
        e[ "value".dup ] = false;
        assert( Formatter( "{}", e ) == "{key => true, value => false}" ||
                Formatter( "{}", e ) == "{value => false, key => true}");

        // string/double AA
        char[][ double ] f;
        f[ 1.0 ] = "one".dup;
        f[ 3.14 ] = "PI".dup;
        assert( Formatter( "{}", f ) == "{1.00 => one, 3.14 => PI}" ||
                Formatter( "{}", f ) == "{3.14 => PI, 1.00 => one}");*/
    }

    class Format {

        /// assitive enum for `Format`.
        private enum ArgType {
            basic,
            array,
            assocArray
        }

        template UnTypedef(T) {
            alias UnTypedef = std.traits.Unqual!(T);
        }

        static String opCall(A...)(in String fmt, A _args) {
            auto app = std.array.appender!(String)();
            std.typetuple.staticMap!(UnTypedef, A) args;

            ArgType[_args.length] argTypes;
            foreach(i, a; _args) {
                args[i] = a;

                if (std.traits.isSomeString!(typeof(a))) {
                    // while strings are a range, we don't want to
                    // format them differently
                    argTypes[i] = ArgType.basic;
                } else if (std.traits.isArray!(typeof(a))) {
                    // output should be [elem, elem, elem]
                    argTypes[i] = ArgType.array;
                } else if (std.traits.isAssociativeArray!(typeof(a))) {
                    // output should be {key => value, key2 => value2}
                    // (not implemented yet)
                    argTypes[i] = ArgType.assocArray;
                } else {
                    // no special formatting by default
                    argTypes[i] = ArgType.basic;
                }
            }

            /// Marks the start of the format
            size_t mark;
            /// Flag for checking if currently in a format specification
            bool inFormat = false;
            /// Should the current iteration be skipped (i.e. `i += 1; continue`)
            bool skip = false;
            /// Current "continuous" argument position
            int argIndex = 0;
            /// Should `argIndex` be incremented.
            bool increment = false;

            foreach (i, ref c; fmt) {
                if (skip) {
                    skip = false;
                    continue;
                }

                if (c == '%') {
                    app.put("%%");
                } else if (c == '{') {
                    if (i + 1 < fmt.length && fmt[i + 1] == '{') {
                        // escape e.g. d{{0}d => d{0}d
                        app.put('{');
                        skip = true;
                        continue;
                    } else {
                        mark = i;
                        inFormat = true;
                    }
                } else if (inFormat == false) {
                    app.put(c);
                } else {
                    if (c != '}') continue;

                    inFormat = false;
                    string f = fmt[mark + 1 .. i];
                    if (f.length) {
                        if (std.ascii.isDigit(f[0])) {
                            immutable n = std.conv.parse!(int)(f);
                            increment = false;
                            app.put("%" ~ std.conv.to!(string)(n + 1) ~ "$");
                        } else {
                            increment = true;
                            app.put(argTypes[argIndex] == ArgType.basic ? "%" : "[%(%");
                            // insert the "coninuous" positional argument
                            app.put(std.conv.to!(string)(argIndex + 1));
                        }
                        if (f.length) {
                            //NOTE: to support widths, this will need to be changed.
                            std.exception.enforce(f[0] == ':' && f.length > 1);
                            if (f.length == 2 && "bodxXeEfFgG".indexOf(f[1]) != -1) {
                                // e.g. {:x}
                                app.put(f[1]);
                                if (argTypes[argIndex] == ArgType.array) {
                                    app.put(", %)]");
                                }
                            } else {
                                implMissingInPhobos();
                            }
                        } else {
                            // fallback format char
                            app.put('s');
                            if (argTypes[argIndex] == ArgType.array) {
                                app.put(", %)]");
                            }
                        }
                    } else {
                        // no format length (i.e. {})
                        increment = true;
                        app.put("%" ~ std.conv.to!(string)(argIndex + 1) ~ "$s");
                    }
                    if (increment) {
                        argIndex += 1;
                    }
                }
            }

            auto writer = std.array.appender!(String)();
            std.format.formattedWrite(writer, app.data, args);
            auto res = writer.data();
            return std.exception.assumeUnique(res);
        }
    }
}

version( D_Version2 ) {
    //dmd v2.052 bug: mixin("alias const(Type) Name;"); will be unvisible outside it's module => we should write alias Const!(Type) Name;
    template Immutable(T) {
        mixin("alias immutable(T) Immutable;");
    }
    template Const(T) {
        mixin("alias const(T) Const;");
    }
    template Shared(T) {
        mixin("alias shared(T) Shared;");
    }

    alias Immutable TryImmutable;
    alias Const TryConst;
    alias Shared TryShared;

    //e.g. for passing strings to com.ibm.icu: *.text.* modules assepts String,
    //but internal *.mangoicu.* modules work with char[] even if they don't modify it
    std.traits.Unqual!(T)[] Unqual(T)(T[] t) {
        return cast(std.traits.Unqual!(T)[])t;
    }

    Immutable!(T)[] _idup(T)( T[] str ){ return str.idup; }

    template prefixedIfD2(String prefix, String content) {
        const prefixedIfD2 = prefix ~ " " ~ content;
    }
} else { // D1
    template AliasT(T) { alias T AliasT; }

    alias AliasT TryImmutable;
    alias AliasT TryConst;
    alias AliasT TryShared;

    T Unqual(T)(T t) { return t; }

    String16 _idup( String16 str ){
        return str.dup;
    }
    String _idup( String str ){
        return str.dup;
    }

    template prefixedIfD2(String prefix, String content) {
        const prefixedIfD2 = content;
    }
}

template sharedStaticThis(String content) {
    const sharedStaticThis = prefixedIfD2!("extern(D) shared", "static this()" ~ content);
}

template sharedStatic_This(String content) {
    const sharedStatic_This = prefixedIfD2!("shared", "private static void static_this()" ~ content);
}

template gshared(String content) {
    const gshared = prefixedIfD2!("__gshared:", content);
}

template constFuncs(String content) {
    const constFuncs = prefixedIfD2!("const:", content);
}

private struct GCStats {
    size_t poolsize;        // total size of pool
    size_t usedsize;        // bytes allocated
    size_t freeblocks;      // number of blocks marked FREE
    size_t freelistsize;    // total of memory on free lists
    size_t pageblocks;      // number of blocks marked PAGE
}
private extern(C) GCStats gc_stats();

size_t RuntimeTotalMemory(){
    GCStats s = gc_stats();
    return s.poolsize;
}


template arraycast(T) {
    T[] arraycast(U) (U[] u) {
        static if (
            (is (T == interface ) && is (U == interface )) ||
            (is (T == class ) && is (U == class ))) {
            return(cast(T[])u);
        }
        else {
            int l = u.length;
            T[] res;
            res.length = l;
            for (int i = 0; i < l; i++) {
                res[i] = cast(T)u[i];
            }
            return(res);
        }
    }
}


bool ArrayEquals(T)( T[] a, T[] b ){
    if( a.length !is b.length ){
        return false;
    }
    for( int i = 0; i < a.length; i++ ){
        static if( is( T==class) || is(T==interface)){
            if( a[i] !is null && b[i] !is null ){
                if( a[i] != b[i] ){
                    return false;
                }
            }
            else if( a[i] is null && b[i] is null ){
            }
            else{
                return false;
            }
        }
        else{
            if( a[i] != b[i] ){
                return false;
            }
        }
    }
    return true;
}

int arrayIndexOf(T)( T[] arr, T v ){
    int res = -1;
    int idx = 0;


    static if (is(T == interface))
    {
        Object[] array = cast(Object[]) arr;
        Object value = cast(Object) v;
    }

    else
    {
        auto array = arr;
        auto value = v;
    }

    foreach( p; array ){
        if( p == value){
            res = idx;
            break;
        }
        idx++;
    }
    return res;
}

T[] arrayIndexRemove(T)(T[] arr, uint n) {
    if (n is 0)
        return arr[1..$];
    if (n > arr.length)
        return arr;
    if (n is arr.length-1)
        return arr[0..n-1];
    // else
    return arr[0..n] ~ arr[n+1..$];
}

struct ImportData{
    TryImmutable!(void)[] data;
    String name;

    //empty () is just a hack to force opCall to be included in full in the .di file
    public static ImportData opCall()( TryImmutable!(void)[] data, String name ){
        ImportData res;
        res.data = data;
        res.name = name;
        return res;
    }
}

template getImportData(String name) {
    const ImportData getImportData = ImportData( cast(TryImmutable!(void)[]) import(name), name );
}
