module java.util.Random;

import java.lang.all;
version(Tango){
    static import tango.math.random.Kiss;
} else { // Phobos
    static import std.random;
}

class Random {
    version(Tango){
        tango.math.random.Kiss.Kiss kiss;
    } else { // Phobos
        std.random.MinstdRand gen;
    }

    public this(int seed ){
        version(Tango){
            kiss.seed(seed);
        } else { // Phobos
            gen.seed( seed );
        }
    }
    public bool  nextBoolean(){
        version(Tango){
            return kiss.toInt(2) is 0;
        } else { // Phobos
            gen.popFront();
            return (gen.front() & 1 ) is 0;
        }
    }
}


