module java.lang.Thread;

version(Tango){
    static import tango.core.Thread;
} else { // Phobos
    static import core.thread;
    static import core.time;
}
import java.lang.util;
import java.lang.Runnable;

class Thread {

    version(Tango){
        alias tango.core.Thread.Thread TThread;
    } else { // Phobos
        alias core.thread.Thread TThread;
    }
    private TThread thread;
    private Runnable runnable;
    private bool interrupted_ = false;
    version(Tango){
        private alias tango.core.Thread.ThreadLocal!(Thread) TTLS;
        private static TTLS tls;
    } else { // Phobos
        private static Thread tls; //in tls
    }

    public static const int MAX_PRIORITY  = 10;
    public static const int MIN_PRIORITY  =  1;
    public static const int NORM_PRIORITY =  5;

    version(Tango){
        private static TTLS getTls(){
            if( tls is null ){
                synchronized( Thread.classinfo ){
                    if( tls is null ){
                        tls = new TTLS();
                    }
                }
            }
            return tls;
        }
    }

    public this(){
        thread = new TThread(&internalRun);
    }
    public this( void delegate() dg ){
        thread = new TThread(&internalRun);
        runnable = dgRunnable( dg );
    }
    public this(Runnable runnable){
        thread = new TThread(&internalRun);
        this.runnable = runnable;
    }
    public this(Runnable runnable, String name){
        thread = new TThread(&internalRun);
        this.runnable = runnable;
        thread.name = name;
    }
    public this(String name){
        thread = new TThread(&internalRun);
        thread.name = name;
    }

    public void start(){
        thread.start();
    }

    public static Thread currentThread(){
        version(Tango){
            auto res = getTls().val();
            if( res is null ){
                // no synchronized needed
                res = new Thread();
                res.thread = tango.core.Thread.Thread.getThis();
                getTls().val( res );
            }
            assert( res );
            return res;
        } else { // Phobos
            auto res = tls;
            if( res is null ){
                // no synchronized needed
                res = new Thread();
                res.thread = TThread.getThis();
                tls = res;
            }
            assert( res );
            return res;
        }
    }
    public int getPriority() {
        return (thread.priority-TThread.PRIORITY_MIN) * (MAX_PRIORITY-MIN_PRIORITY) / (TThread.PRIORITY_MAX-TThread.PRIORITY_MIN) + MIN_PRIORITY;
    }
    public void setPriority( int newPriority ) {
//         assert( MIN_PRIORITY < MAX_PRIORITY );
//         assert( tango.core.Thread.Thread.PRIORITY_MIN < tango.core.Thread.Thread.PRIORITY_MAX );
        auto scaledPrio = (newPriority-MIN_PRIORITY) * (TThread.PRIORITY_MAX-TThread.PRIORITY_MIN) / (MAX_PRIORITY-MIN_PRIORITY) +TThread.PRIORITY_MIN;
//        getDwtLogger().trace( __FILE__, __LINE__, "Thread.setPriority: scale ({} {} {}) -> ({} {} {})", MIN_PRIORITY, newPriority, MAX_PRIORITY, TThread.PRIORITY_MIN, scaledPrio, TThread.PRIORITY_MAX);
//         thread.priority( scaledPrio );
    }

    private void internalRun(){
        version(Tango){
            // Store this thread object ref to the TLS
            getTls().val( this );
        } else { // Phobos
            tls = this;
        }
        if( runnable !is null ){
            runnable.run();
        }
        else {
            run();
        }
    }

    public bool isAlive(){
        return thread.isRunning();
    }

    public bool isDaemon() {
        return thread.isDaemon();
    }

    public void join(){
        thread.join();
    }

    public void setDaemon(bool on) {
        thread.isDaemon(on);
    }

    public void setName(String name){
        thread.name = name;
    }
    public String getName(){
        return thread.name;
    }

    void interrupt() {
        interrupted_ = true;
        implMissing(__FILE__,__LINE__);
    }

    static bool interrupted() {
        auto t = currentThread();
        synchronized(t){
            bool res = t.interrupted_;
            t.interrupted_ = false;
            return res;
        }
    }

    public void run(){
        // default impl, do nothing
    }
    public static void sleep( int time ){
        version(Tango){
            TThread.sleep(time/1000.0);
        } else { // Phobos
            TThread.sleep(core.time.dur!("msecs")(time));
        }
    }
    public TThread nativeThread(){
        assert(thread);
        return thread;
    }
    public override String toString(){
        return "Thread " ~ thread.name;
    }
    public static void yield(){
        TThread.yield();
    }
    
    public static void joinAll(){
        version (Tango)
            tango.core.Thread.thread_joinAll();
        else
            core.thread.thread_joinAll();
    }
}

