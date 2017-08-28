package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import android.support.annotation.NonNull;

import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.utils.Log;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadFactory;

/**
 * Description:普通礼物，发送请求队列管理器
 * <p>
 * Created by Harry on 2017/8/11.
 */

public class GiftSendReqManager {
    private final static String TAG = GiftSendReqManager.class.getSimpleName();
    private static GiftSendReqManager instance = null;
    private ExecutorService giftSendReqExecService = null;
    private LinkedBlockingQueue<GiftSendReq> giftSendReqLBQueue;

    private GiftSendReqManager(){
        giftSendReqExecService = Executors.newSingleThreadExecutor(new ThreadFactory() {
            @Override
            public Thread newThread(@NonNull Runnable r) {
                Thread t = new Thread(r);
                t.setName("逐一执行送礼/背包请求的单一线程池");
                return t;
            }
        });
        giftSendReqLBQueue = new LinkedBlockingQueue();
    }

    public static GiftSendReqManager getInstance(){
        if(null == instance){
            instance = new GiftSendReqManager();
        }

        return instance;
    }

    /**
     * 添加GiftSendReq到无界阻塞队列，队列无法容纳则等待
     * @param req
     */
    public void putGiftSendReq(GiftSendReq req){
        Log.d(TAG,"putGiftSendReq-req:"+req);
        try {
            giftSendReqLBQueue.put(req);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    /**
     * 取走无界阻塞队列首位的GiftSendReq，没有则等待
     * @return
     */
    private GiftSendReq takeGiftSendReq(){
        GiftSendReq req = null;
        try {
            req = giftSendReqLBQueue.take();
            Log.d(TAG,"takeGiftSendReq-req:"+req);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        return req;
    }

    /**
     * 清空送礼请求任务队列
     */
    public void clearGiftSendReqQueue(){
        Log.d(TAG,"clearGiftSendReqQueue-giftSendReqLBQueue.size:"+giftSendReqLBQueue.size());
        giftSendReqLBQueue.clear();
    }

    /**
     * 执行下一个送礼请求任务
     */
    public void executeNextReqTask(){
        Log.d(TAG,"executeNextReqTask");
        giftSendReqExecService.execute(new GiftSendReqExecThread());

    }

    /**
     * 立即关停giftSendReqExecService，并尝试中断所有正在被执行的任务
     */
    public void shutDownReqQueueServNow(){
        Log.d(TAG,"shutDownReqQueueServNow");
        //通过调用Thread.interrupt()方法来实现的，但是该方法作用有限，如果线程中没有sleep、wait、condition、定时锁
        //等的应用，interrupt方法是无法中断当前的线程的
        clearGiftSendReqQueue();
        giftSendReqExecService.shutdownNow();
        giftSendReqExecService = null;
        instance = null;
    }

    private class GiftSendReqExecThread implements Runnable{
        @Override
        public void run() {
            GiftSendReq req = takeGiftSendReq();
            if(null != req && req.giftItem!=null){
                Log.d(TAG,"GiftSendReqExecThread::run-req:"+req);
                IMManager.getInstance().sendGift(req.mRoomId, req.giftItem
                        ,req.count,req.isMultiClick
                        , req.multiStart,req.multiEnd
                        , req.multiClickId);
            }
        }
    }
}
