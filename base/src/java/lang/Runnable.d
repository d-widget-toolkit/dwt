/**
 * Authors: Frank Benoit <benoit@tionex.de>
 */
module java.lang.Runnable;

static import std.traits;
static import std.typetuple;

public interface Runnable  {

    public abstract void run();

}

class _DgRunnableT(Dg,T...) : Runnable {

    alias std.traits.ParameterTypeTuple!(Dg) DgArgs;
    static assert( is(DgArgs == std.typetuple.TypeTuple!(T)),
            "Delegate args not correct: "~DgArgs.stringof~" vs "~T.stringof );

    Dg dg;
    T t;

    private this( Dg dg, T t ){
        this.dg = dg;
        static if( T.length > 0 ){
            this.t = t;
        }
    }

    void run( ){
        dg(t);
    }
}

_DgRunnableT!(Dg,T) dgRunnable(Dg,T...)( Dg dg, T args ){
    return new _DgRunnableT!(Dg,T)(dg,args);
}
