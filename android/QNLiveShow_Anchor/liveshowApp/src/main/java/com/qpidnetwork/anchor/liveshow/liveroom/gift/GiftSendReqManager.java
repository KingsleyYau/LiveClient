package com.qpidnetwork.anchor.liveshow.liveroom.gift;

import android.support.annotation.NonNull;

import com.qpidnetwork.anchor.im.IMLiveRoomEventListener;
import com.qpidnetwork.anchor.im.IMManager;
import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;
import com.qpidnetwork.anchor.utils.Log;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadFactory;

/**
 * Description:普通礼物，发送请求队列管理器
 * <p>
 * Created by Harry on 2017/8/11.
 */

public class GiftSendReqManager implements IMLiveRoomEventListener {

    private final static String TAG = GiftSendReqManager.class.getSimpleName();
    private ExecutorService giftSendReqExecService = null;
    private LinkedBlockingQueue<GiftSendReq> giftSendReqLBQueue;
    private boolean continueGiftReqSentTask = false;
    private boolean watingForExecNextReqTask = true;
    private final long sleepTime = 300l;//xxx毫秒间隔发送

    public GiftSendReqManager(){
        IMManager.getInstance().registerIMLiveRoomEventListener(this);
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

    /**
     * 添加GiftSendReq到无界阻塞队列，队列无法容纳则等待
     * @param req
     */
    public void putGiftSendReq(GiftSendReq req){
        Log.d(TAG,"putHangOutGiftSendReq-req:"+req);
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
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        Log.d(TAG,"takeGiftSendReq-req:"+req);
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
        continueGiftReqSentTask = true;
        watingForExecNextReqTask = false;
        Log.d(TAG,"executeNextReqTask-continueGiftReqSentTask:"+continueGiftReqSentTask
                +" watingForExecNextReqTask:"+watingForExecNextReqTask);
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
        continueGiftReqSentTask = false;
        giftSendReqExecService.shutdownNow();
        giftSendReqExecService = null;
        IMManager.getInstance().unregisterIMLiveRoomEventListener(this);
    }

    private class GiftSendReqExecThread implements Runnable{
        @Override
        public void run() {
            while(continueGiftReqSentTask){
                Log.d(TAG,"GiftSendReqExecThread::run-continueGiftReqSentTask:"+continueGiftReqSentTask);
                if(watingForExecNextReqTask){
                    try {
                        Log.d(TAG,"GiftSendReqExecThread::run-上个发送的礼物还未接受到发送结果，等待"+sleepTime+"毫秒");
                        Thread.sleep(sleepTime);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }else{
                    GiftSendReq req = takeGiftSendReq();
                    Log.d(TAG,"GiftSendReqExecThread::run-req:"+req);
                    if(null != req && req.giftItem!=null){
                        Log.d(TAG,"GiftSendReqExecThread::run-取队列中的礼物发送请求，发送中...");
                        IMManager.getInstance().sendGift(req.mRoomId, req.giftItem, req.isPackage
                                ,req.count,req.isMultiClick
                                , req.multiStart,req.multiEnd
                                , req.multiClickId);
                        watingForExecNextReqTask = true;
                    }
                }

            }
        }
    }

    @Override
    public void OnSendGift(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg,
                           IMMessageItem msgItem) {
        Log.d(TAG,"OnSendGift-success:"+success+" errType:"+errType+" errMsg:"+errMsg
                +" msgItem:"+msgItem);

        if(errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS){
            Log.d(TAG,"OnSendGift-一次送礼请求发送成功，执行下一个送礼请求");
        }else {
            Log.d(TAG, "OnSendGift-一次送礼请求发送失败，清空送礼请求队列");
            clearGiftSendReqQueue();
        }
        watingForExecNextReqTask = false;
    }

    //---------------------------------------------------------------------
    @Override
    public void OnRecvRoomCloseNotice(String roomId, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {}

    @Override
    public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl,
                                      String riderId, String riderName, String riderUrl, int fansNum, boolean isHasTicket) {}

    @Override
    public void OnRecvLeaveRoomNotice(String roomId, String userId, String nickName, String photoUrl,
                                      int fansNum) {}

    @Override
    public void OnRecvLeavingPublicRoomNotice(String roomId, int leftSeconds,
                                              IMClientListener.LCC_ERR_TYPE err, String errMsg) {}

    @Override
    public void OnRecvAnchorLeaveRoomNotice(String roomId, String anchorId) {

    }

    @Override
    public void OnRecvRoomKickoffNotice(String roomId, IMClientListener.LCC_ERR_TYPE err, String errMsg) {}

    @Override
    public void OnSendRoomMsg(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg,
                              IMMessageItem msgItem) {}

    @Override
    public void OnRecvRoomMsg(IMMessageItem msgItem) {}

    @Override
    public void OnRecvSendSystemNotice(IMMessageItem msgItem) {}

    @Override
    public void OnRecvRoomGiftNotice(IMMessageItem msgItem) {}


    @Override
    public void OnRecvRoomToastNotice(IMMessageItem msgItem) {}

    @Override
    public void OnRecvTalentRequestNotice(String talentInvitationId, String name, String userId, String nickName) {

    }

    @Override
    public void OnRecvInteractiveVideoNotice(String roomId, String userId,
                                             String nickname, String avatarImg,
                                             IMClientListener.IMVideoInteractiveOperateType operateType,
                                             String[] pushUrls) {

    }

}
