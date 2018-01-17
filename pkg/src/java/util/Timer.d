module java.util.Timer;

import java.lang.all;
import java.util.TimerTask;
import java.lang.Thread;

version(Tango){
    import tango.core.sync.Mutex;
    import tango.core.sync.Condition;
    import tango.text.convert.Format;
} else { // Phobos
}


class Timer {
    private static final class TaskQueue {
        version(Tango){
            private Mutex mutex;
            private Condition cond;
        } else { // Phobos
        }


        private static const int DEFAULT_SIZE = 32;
        private bool nullOnEmpty;
        private TimerTask[] heap;
        private int elements;
        public this() {
            version(Tango){
                mutex = new Mutex();
                cond = new Condition( mutex );
                heap = new TimerTask[DEFAULT_SIZE];
                elements = 0;
                nullOnEmpty = false;
            } else { // Phobos
                implMissingInPhobos();
            }
        }

        private void add(TimerTask task) {
            elements++;
            if (elements is heap.length) {
                TimerTask[] new_heap = new TimerTask[heap.length * 2];
                System.arraycopy(heap, 0, new_heap, 0, cast(int)heap.length);
                heap = new_heap;
            }
            heap[elements] = task;
        }

        private void remove() {
            // clear the entry first
            heap[elements] = null;
            elements--;
            if (elements + DEFAULT_SIZE / 2 <= (heap.length / 4)) {
                TimerTask[] new_heap = new TimerTask[heap.length / 2];
                System.arraycopy(heap, 0, new_heap, 0, elements + 1);
                heap = new_heap;
            }
        }

        public void enqueue(TimerTask task) {
            version(Tango){
                synchronized( mutex ){
                    if (heap is null) {
                        throw new IllegalStateException("cannot enqueue when stop() has been called on queue");
                    }

                    heap[0] = task;
                    add(task);
                    int child = elements;
                    int parent = child / 2;
                    while (heap[parent].scheduled > task.scheduled) {
                        heap[child] = heap[parent];
                        child = parent;
                        parent = child / 2;
                    }
                    heap[child] = task;
                    heap[0] = null;
                    cond.notify();
                }
            } else { // Phobos
                implMissingInPhobos();
            }
        }

        private TimerTask top() {
            if (elements is 0) {
                return null;
            }
            else {
                return heap[1];
            }
        }

        public TimerTask serve() {
            version(Tango){
                synchronized( mutex ){
                    TimerTask task = null;
                    while (task is null) {
                        task = top();

                        if ((heap is null) || (task is null && nullOnEmpty)) {
                            return null;
                        }

                        if (task !is null) {
                            // The time to wait until the task should be served
                            long time = task.scheduled - System.currentTimeMillis();
                            if (time > 0) {
                                // This task should not yet be served
                                // So wait until this task is ready
                                // or something else happens to the queue
                                task = null;  // set to null to make sure we call top()
                                try {
                                    cond.wait(time);
                                }
                                catch (InterruptedException _) {
                                }
                            }
                        }
                        else {
                            // wait until a task is added
                            // or something else happens to the queue
                            try {
                                cond.wait();
                            }
                            catch (InterruptedException _) {
                            }
                        }
                    }

                    TimerTask lastTask = heap[elements];
                    remove();

                    int parent = 1;
                    int child = 2;
                    heap[1] = lastTask;
                    while (child <= elements) {
                        if (child < elements) {
                            if (heap[child].scheduled > heap[child + 1].scheduled) {
                                child++;
                            }
                        }

                        if (lastTask.scheduled <= heap[child].scheduled)
                            break;

                        heap[parent] = heap[child];
                        parent = child;
                        child = parent * 2;
                    }

                    heap[parent] = lastTask;
                    return task;
                }
            } else { // Phobos
                implMissingInPhobos();
                return null;
            }
        }

        public void setNullOnEmpty(bool nullOnEmpty) {
            version(Tango){
                synchronized( mutex ){
                    this.nullOnEmpty = nullOnEmpty;
                    cond.notify();
                }
            } else { // Phobos
                implMissingInPhobos();
            }
        }

        public void stop() {
            version(Tango){
                synchronized( mutex ){
                    this.heap = null;
                    this.elements = 0;
                    cond.notify();
                }
            } else { // Phobos
                implMissingInPhobos();
            }
        }

    }

    private static final class Scheduler : Runnable {
        private TaskQueue queue;

        public this(TaskQueue queue) {
            this.queue = queue;
        }

        public void run() {
            TimerTask task;
            while ((task = queue.serve()) !is null) {
                if (task.scheduled >= 0) {
                    task.lastExecutionTime = task.scheduled;
                    if (task.period < 0) {
                        task.scheduled = -1;
                    }
                    try {
                        task.run();
                    }
                    //                     catch (ThreadDeath death) {
                    //                         // If an exception escapes, the Timer becomes invalid.
                    //                         queue.stop();
                    //                         throw death;
                    //                     }
                    catch (Exception t) {
                        queue.stop();
                    }
                }
                if (task.scheduled >= 0) {
                    if (task.fixed) {
                        task.scheduled += task.period;
                    }
                    else {
                        task.scheduled = task.period + System.currentTimeMillis();
                    }

                    try {
                        queue.enqueue(task);
                    }
                    catch (IllegalStateException ise) {
                        // Ignore. Apparently the Timer queue has been stopped.
                    }
                }
            }
        }
    }

    private static int nr;
    private TaskQueue queue;
    private Scheduler scheduler;
    private Thread thread;
    private bool canceled;

    public this() {
        this(false);
    }

    public this(bool daemon) {
        this(daemon, Thread.NORM_PRIORITY);
    }

    private this(bool daemon, int priority) {
        this(daemon, priority, Format( "Timer-{}", ++nr));
    }

    private this(bool daemon, int priority, String name) {
        canceled = false;
        queue = new TaskQueue();
        scheduler = new Scheduler(queue);
        thread = new Thread(scheduler, name);
        thread.setDaemon(daemon);
        thread.setPriority(priority);
        thread.start();
    }

    public void cancel() {
        canceled = true;
        queue.stop();
    }

    private void schedule(TimerTask task, long time, long period, bool fixed) {
        if (time < 0)
            throw new IllegalArgumentException("negative time");

        if (task.scheduled is 0 && task.lastExecutionTime is -1) {
            task.scheduled = time;
            task.period = period;
            task.fixed = fixed;
        }
        else {
            throw new IllegalStateException("task was already scheduled or canceled");
        }

        if (!this.canceled && this.thread !is null) {
            queue.enqueue(task);
        }
        else {
            throw new IllegalStateException("timer was canceled or scheduler thread has died");
        }
    }

    private static void positiveDelay(long delay) {
        if (delay < 0) {
            throw new IllegalArgumentException("delay is negative");
        }
    }

    private static void positivePeriod(long period) {
        if (period < 0) {
            throw new IllegalArgumentException("period is negative");
        }
    }

    //     public void schedule(TimerTask task, Date date) {
    //         long time = date.getTime();
    //         schedule(task, time, -1, false);
    //     }

    //     public void schedule(TimerTask task, Date date, long period) {
    //         positivePeriod(period);
    //         long time = date.getTime();
    //         schedule(task, time, period, false);
    //     }

    public void schedule(TimerTask task, long delay) {
        positiveDelay(delay);
        long time = System.currentTimeMillis() + delay;
        schedule(task, time, -1, false);
    }

    public void schedule(TimerTask task, long delay, long period)  {
        positiveDelay(delay);
        positivePeriod(period);
        long time = System.currentTimeMillis() + delay;
        schedule(task, time, period, false);
    }

    //     public void scheduleAtFixedRate(TimerTask task, Date date, long period)  {
    //         positivePeriod(period);
    //         long time = date.getTime();
    //         schedule(task, time, period, true);
    //     }

    public void scheduleAtFixedRate(TimerTask task, long delay, long period)  {
        positiveDelay(delay);
        positivePeriod(period);
        long time = System.currentTimeMillis() + delay;
        schedule(task, time, period, true);
    }

    protected void finalize() {
        queue.setNullOnEmpty(true);
    }


    ///////////////////////////////////////////////////
    /+    alias CircularList!( TimerTask ) ListType;

    private Thread thread;
    private ListType schedules;
    private Mutex mutex;
    private Condition cond;
    private bool isCanceled = false;

    this(){
        this(false);
    }
    this(bool isDaemon){
        mutex = new Mutex();
        cond = new Condition( mutex );

        schedules = new ListType();
        thread = new Thread( &run );
        thread.setDaemon( isDaemon );
        thread.start();
    }
    private void run(){

        while( !isCanceled ){
            TimerTask timerTask = null;
            synchronized(mutex){
                bool isReady = false;
                do{
                    if( isCanceled ){
                        return;
                    }

                    if( schedules.size() is 0 ){
                        cond.wait();
                    }
                    else{
                        timerTask = schedules.head();
                        TimeSpan toWait = timerTask.executionTime - Clock.now();
                        if( toWait.interval() > 0 ){
                            cond.wait( toWait.interval() );
                        }
                        else{
                            schedules.removeHead();
                            isReady = true;
                        }
                    }
                }while( !isReady );
            }
            if( timerTask ){
                timerTask.run();
                if( timerTask.period.millis > 0 ){
                    timerTask.executionTime += timerTask.period;
                    synchronized(mutex){
                        int index = 0;
                        foreach( tt; schedules ){
                            if( tt.executionTime > timerTask.executionTime ){
                                break;
                            }
                            index++;
                        }
                        schedules.addAt( index, timerTask );
                    }
                }
            }
        }
    }
    void   cancel(){
        synchronized(mutex){
            isCanceled = true;
            cond.notifyAll();
        }
    }
    void   schedule(TimerTask task, long delay){
        scheduleAtFixedRate( task, delay, 0 );
    }
    void   scheduleAtFixedRate(TimerTask task, long delay, long period){
        assert( task );
        version(TANGOSVN){
            task.executionTime = Clock.now + TimeSpan.fromMillis(delay);
        } else {
            task.executionTime = Clock.now + TimeSpan.millis(delay);
        }
        task.timer = this;
        synchronized(mutex){
            int index = 0;
            if( schedules.size() > 0 )
                foreach( tt; schedules ){
                    if( tt.executionTime > task.executionTime ){
                        break;
                    }
                    index++;
                }
            schedules.addAt( index, task );
            cond.notifyAll();
        }
    }

    //     void   schedule(TimerTask task, Date time){}
    //     void   schedule(TimerTask task, Date firstTime, long period){}
    //     void   schedule(TimerTask task, long delay, long period){}
    //     void   scheduleAtFixedRate(TimerTask task, Date firstTime, long period){}
    +/
}


