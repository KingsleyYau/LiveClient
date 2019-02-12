package com.qpidnetwork.qnbridgemodule.util;

import java.util.concurrent.RejectedExecutionHandler;
import java.util.concurrent.SynchronousQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

/**
 * 2018/11/22 Hardy
 */
public class ThreadPoolExecutorUtil {

    private static final SynchronousQueue<Runnable> synrun = new SynchronousQueue<Runnable>();
    /**
     * @date 2016-11-18
     * Hardy
     * @see android.os.AsyncTask
     */
    private static final int CPU_COUNT = Runtime.getRuntime().availableProcessors();
    // We want at least 2 threads and at most 4 threads in the core pool,
    // preferring to have 1 less than the CPU count to avoid saturating
    // the CPU with background work
    private static final int CORE_POOL_SIZE = Math.max(2, Math.min(CPU_COUNT - 1, 4));
    private static final int MAXIMUM_POOL_SIZE = CPU_COUNT * 2 + 1;
    private static final int KEEP_ALIVE_SECONDS = 30;

    private static final ThreadPoolExecutor executorService = new ThreadPoolExecutor(
            CORE_POOL_SIZE, MAXIMUM_POOL_SIZE, KEEP_ALIVE_SECONDS, TimeUnit.SECONDS, synrun,
            new DiscardOldestPolicys());
    //======================================================================

    // origin...
    //	private static final ThreadPoolExecutor executorService = new ThreadPoolExecutor(
    //			5, Integer.MAX_VALUE, 30L, TimeUnit.SECONDS, synrun,
    //			new DiscardOldestPolicys());

    public static void doTask(Runnable run) {
//        Log.i("info", "CPU_COUNT: " + CPU_COUNT + "======> " + "CORE_POOL_SIZE: " + CORE_POOL_SIZE + "========> " + "MAXIMUM_POOL_SIZE: " + MAXIMUM_POOL_SIZE);
        executorService.execute(run);
    }

    public static ThreadPoolExecutor getThreadPoolExecutor() {
        return executorService;
    }

    public static class DiscardOldestPolicys implements
            RejectedExecutionHandler {

        public DiscardOldestPolicys() {
        }

        public void rejectedExecution(Runnable r, ThreadPoolExecutor e) {
            try {
                if (!e.isShutdown()) {
                    e.getQueue().poll();
                    e.execute(r);
                }
            } catch (Exception e1) {
                e1.printStackTrace();
            } catch (StackOverflowError stackOverflowError){
                stackOverflowError.printStackTrace();
            }
        }
    }
}
