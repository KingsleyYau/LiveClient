package com.qpidnetwork.anchor.liveshow.liveroom.gift;

import android.support.annotation.NonNull;

import com.qpidnetwork.anchor.im.IMHangOutRoomEventListener;
import com.qpidnetwork.anchor.im.IMManager;
import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMDealInviteItem;
import com.qpidnetwork.anchor.im.listener.IMHangoutRecommendItem;
import com.qpidnetwork.anchor.im.listener.IMHangoutRoomItem;
import com.qpidnetwork.anchor.im.listener.IMKnockRequestItem;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;
import com.qpidnetwork.anchor.im.listener.IMOtherInviteItem;
import com.qpidnetwork.anchor.im.listener.IMRecvEnterRoomItem;
import com.qpidnetwork.anchor.im.listener.IMRecvHangoutGiftItem;
import com.qpidnetwork.anchor.im.listener.IMRecvLeaveRoomItem;
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

public class HangOutGiftSendReqManager implements IMHangOutRoomEventListener {

    private final static String TAG = HangOutGiftSendReqManager.class.getSimpleName();
    private static HangOutGiftSendReqManager instance = null;
    private ExecutorService giftSendReqExecService = null;
    private LinkedBlockingQueue<HangOutGiftSendReq> giftSendReqLBQueue;
    private boolean continueGiftReqSentTask = false;
    private boolean watingForExecNextReqTask = true;
    private final long sleepTime = 300l;//xxx毫秒间隔发送

    private HangOutGiftSendReqManager(){
        IMManager.getInstance().registerIMHangOutRoomEventListener(this);
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

    public static HangOutGiftSendReqManager getInstance(){
        if(null == instance){
            instance = new HangOutGiftSendReqManager();
        }

        return instance;
    }

    /**
     * 添加GiftSendReq到无界阻塞队列，队列无法容纳则等待
     * @param req
     */
    public void putHangOutGiftSendReq(HangOutGiftSendReq req){
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
    private HangOutGiftSendReq takeHangOutGiftSendReq(){
        HangOutGiftSendReq req = null;
        try {
            req = giftSendReqLBQueue.take();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        Log.d(TAG,"takeHangOutGiftSendReq-req:"+req);
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
        giftSendReqExecService.execute(new HangOutGiftSendReqExecThread());
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
        IMManager.getInstance().unregisterIMHangOutRoomEventListener(this);
        instance = null;
    }

    @Override
    public void OnSendHangoutGift(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        Log.d(TAG,"OnSendHangoutGift-success:"+success+" errType:"+errType+" errMsg:"+errMsg);

        if(errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS){
            Log.d(TAG,"OnSendHangoutGift-一次送礼请求发送成功，执行下一个送礼请求");
        }else {
            Log.d(TAG, "OnSendHangoutGift-一次送礼请求发送失败，清空送礼请求队列");
            clearGiftSendReqQueue();
        }
        watingForExecNextReqTask = false;
    }

    private class HangOutGiftSendReqExecThread implements Runnable{
        @Override
        public void run() {
            while(continueGiftReqSentTask){
                Log.d(TAG,"HangOutGiftSendReqExecThread::run-continueGiftReqSentTask:"+continueGiftReqSentTask);
                if(watingForExecNextReqTask){
                    try {
                        Log.d(TAG,"HangOutGiftSendReqExecThread::run-上个发送的礼物还未接受到发送结果，等待"+sleepTime+"毫秒");
                        Thread.sleep(sleepTime);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }else{
                    HangOutGiftSendReq req = takeHangOutGiftSendReq();
                    Log.d(TAG,"HangOutGiftSendReqExecThread::run-req:"+req);
                    if(null != req && req.giftItem!=null){
                        Log.d(TAG,"HangOutGiftSendReqExecThread::run-取队列中的礼物发送请求，发送中...");
                        IMManager.getInstance().sendHangOutGift(req.mRoomId, req.giftItem, req.isPackage
                                ,req.toUid,req.toUsername,req.count,req.isMultiClick
                                , req.multiStart,req.multiEnd
                                , req.multiClickId,req.isPrivate);
                        watingForExecNextReqTask = true;
                    }
                }

            }
        }
    }


    @Override
    public void OnRecvAnchorGiftNotice(IMRecvHangoutGiftItem item) {

    }

    @Override
    public void OnRecvHangoutInteractiveVideoNotice(String roomId, String userId, String nickname, String avatarImg, IMClientListener.IMVideoInteractiveOperateType operateType, String[] pushUrls) {

    }

    @Override
    public void OnSendHangoutMsg(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvHangoutMsg(IMMessageItem imMessageItem) {

    }

    @Override
    public void OnRecvAnchorCountDownEnterRoomNotice(String roomId, String anchorId, int leftSecond) {

    }

    @Override
    public void OnEnterHangoutRoom(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMHangoutRoomItem hangoutRoomItem, int expire) {

    }

    @Override
    public void OnLeaveHangoutRoom(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvAnchorRecommendHangoutNotice(IMHangoutRecommendItem item) {

    }

    @Override
    public void OnRecvAnchorDealKnockRequestNotice(IMKnockRequestItem item) {

    }

    @Override
    public void OnRecvAnchorOtherInviteNotice(IMOtherInviteItem item) {

    }

    @Override
    public void OnRecvAnchorDealInviteNotice(IMDealInviteItem item) {

    }

    @Override
    public void OnRecvAnchorEnterRoomNotice(IMRecvEnterRoomItem item) {

    }

    @Override
    public void OnRecvAnchorLeaveRoomNotice(IMRecvLeaveRoomItem item) {

    }

    @Override
    public void OnRecvAnchorChangeVideoUrl(String roomId, boolean isAnchor, String userId, String[] playUrl) {

    }
}
