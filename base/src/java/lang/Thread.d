module java.lang.Thread;

static import core.thread;
static import core.time;
import java.lang.util;
import java.lang.Runnable;

class Thread {

    alias core.thread.Thread TThread;
    private TThread thread;
    private Runnable runnable;
    private bool interrupted_ = false;
    private static Thread tls; //in tls

    public static const int MAX_PRIORITY  = 10;
    public static const int MIN_PRIORITY  =  1;
    public static const int NORM_PRIORITY =  5;

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
    public int getPriority() {
        return (thread.priority-TThread.PRIORITY_MIN) * (MAX_PRIORITY-MIN_PRIORITY) / (TThread.PRIORITY_MAX-TThread.PRIORITY_MIN) + MIN_PRIORITY;
    }
    public void setPriority( int newPriority ) {
//         assert( MIN_PRIORITY < MAX_PRIORITY );
        auto scaledPrio = (newPriority-MIN_PRIORITY) * (TThread.PRIORITY_MAX-TThread.PRIORITY_MIN) / (MAX_PRIORITY-MIN_PRIORITY) +TThread.PRIORITY_MIN;
//        getDwtLogger().trace( __FILE__, __LINE__, "Thread.setPriority: scale ({} {} {}) -> ({} {} {})", MIN_PRIORITY, newPriority, MAX_PRIORITY, TThread.PRIORITY_MIN, scaledPrio, TThread.PRIORITY_MAX);
//         thread.priority( scaledPrio );
    }

    private void internalRun(){
        tls = this;
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
        TThread.sleep(core.time.dur!("msecs")(time));
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
        core.thread.thread_joinAll();
    }
}

