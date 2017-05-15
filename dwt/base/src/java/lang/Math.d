module java.lang.Math;

version(Tango){
    static import tango.math.Math;
    alias tango.math.Math MathLib;
} else {
    static import std.math;
    alias std.math MathLib;
}

class Math {

    public static immutable double PI = MathLib.PI;

    static double abs(double a){ return a > 0 ? a : -a; }
    static float  abs(float  a){ return a > 0 ? a : -a; }
    static int    abs(int    a){ return a > 0 ? a : -a; }
    static long   abs(long   a){ return a > 0 ? a : -a; }

    static typeof(T1.init < T2.init ? T1.init : T2.init) min(T1, T2)(T1 a, T2 b){ return a < b ? a : b; }
    static typeof(T1.init > T2.init ? T1.init : T2.init) max(T1, T2)(T1 a, T2 b){ return a > b ? a : b; }


    static double sin(double a)  { return MathLib.sin(a); }
    static double cos(double a)  { return MathLib.cos(a); }

    static long   round(double a) { return cast(long)MathLib.round(a); }
    static int    round(float a)  { return cast(int)MathLib.round(a); }
    static int    round(int a)  { return a; }
    static double rint(double a) {
        version(Tango) return MathLib.rndint(a);
        else           return MathLib.rint(a);
    }
    static double ceil(double a) { return MathLib.ceil(a); }
    static double floor(double a) { return MathLib.floor(a); }
    static double sqrt(double a) { return MathLib.sqrt(a); }
    static double atan2(double a, double b) { return MathLib.atan2(a,b); }
    static double pow(double a, double b) { return MathLib.pow(a, b); }
}


