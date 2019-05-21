package com.qpidnetwork.livemodule.liveshow.liveroom.gift;


import android.text.TextUtils;

import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.HashMap;
import java.util.Map;

/**
 * Description:礼物+背包发送器,用户管理两者不同的本地发送校验逻辑
 * <p>
 * Created by Harry on 2017/8/16.
 */

public class HangOutGiftSender {
    //-------------------------------单例模式，初始化-------------------
    private HangOutGiftSender() {
    }

    private static HangOutGiftSender instance = null;

    //是否IM断线重连过
    private boolean mHasIMReconnected = false;

    public static HangOutGiftSender getInstance() {
        if (null == instance) {
            instance = new HangOutGiftSender();
        }
        return instance;
    }

    //------------------------------私有变量定义-------------------
    private final String TAG = HangOutGiftSender.class.getSimpleName();
    /**
     * 连击ID
     */
    private int mMultiClickId = 0;
    /**
     * 连击礼物，已发送的总量
     */
//    private int lastSentGiftTotalNum = 0;
    // 2019/4/15 Hardy 根据对应的主播 id 来存放已发送的总量，避免选择多个主播发送时，并且
    // 由于为单例，导致已发送总量的累加导致连击时的数目不对
    private Map<String, Integer> lastSentGiftTotalNum = new HashMap<>();

    /**
     * 当前房间号
     */
    public String currRoomId = null;

    /**
     * 通知IM断线重连成功
     */
    public void notifyIMReconnect() {
        mHasIMReconnected = true;
    }
    //------------------------------私有方法定义-------------------

    /**
     * 发送HangOut直播间礼物
     *
     * @param giftItem
     * @param isRepeat
     * @param toUid
     * @param toUsername
     * @param sendNum
     * @param isPackage
     * @param isPrivate
     * @param listener
     */
    public void sendHangOutGift(GiftItem giftItem, boolean isRepeat, String toUid, String toUsername, int sendNum,
                                boolean isPackage, boolean isPrivate, HangOutGiftSendResultListener listener) {
        Log.d(TAG, "sendHangOutGift-id:" + giftItem.id + " name:" + giftItem.name + " isRepeat:" + isRepeat
                + " toUid:" + toUid + " toUsername:" + toUsername + " sendNum:" + sendNum + " isPrivate:" + isPrivate + " isPackage:" + isPackage);
        //每次判断剩余数量是否充足
        if (IMManager.getInstance().isIMLogined()) {
            Log.d(TAG, "sendHangOutGift-未处于断网重连过程，真发送");
            sendHangOutGift(giftItem, isRepeat, toUid, toUsername, sendNum, isPackage, isPrivate);
        }
        if (null != listener) {
            listener.onHangOutGiftReqSent(giftItem, ErrorCode.SUCCESS, "", isRepeat, sendNum);
        }
    }

    /**
     * 队列发送礼物请求
     *
     * @param giftItem
     * @param isRepeat
     * @param sendNum
     * @param isPackage
     */
    private void sendHangOutGift(GiftItem giftItem, boolean isRepeat, String toUid, String toUsername,
                                 int sendNum, boolean isPackage, boolean isPrivate) {
        Log.d(TAG, "sendHangOutGift-giftItem.id:" + giftItem + " isRepeat:" + isRepeat + " toUid:" + toUid + " toUsername:" + toUsername
                + " sendNum:" + sendNum + " isPackage:" + isPackage + " isPrivate:" + isPrivate);
        int multi_click_start = 0;
        int multi_click_end = 0;

        // 2019/4/15 Hardy
        if (TextUtils.isEmpty(toUid)) {
            toUid = "";
        }

        //是否出现断线重连成功的情况
        if (mHasIMReconnected || !isRepeat) {
            //每次重新开始发送，重新生成
            Log.d(TAG, "sendHangOutGift-断网重连成功或者首次，重新生成连送ID");
            mMultiClickId = (int) (System.currentTimeMillis() / 1000);
            multi_click_start = 1;

            // old
//            lastSentGiftTotalNum = sendNum;
//            multi_click_end = lastSentGiftTotalNum;

            // 2019/4/15 Hardy
            lastSentGiftTotalNum.put(toUid, sendNum);
            multi_click_end = sendNum;

            mHasIMReconnected = false;
        } else {
            Log.d(TAG, "sendHangOutGift-非断网，且连送，沿用旧的连送ID");

            // old
//            multi_click_start = lastSentGiftTotalNum + 1;
//            lastSentGiftTotalNum += sendNum;
//            multi_click_end = lastSentGiftTotalNum;

            // 2019/4/15 Hardy
            multi_click_start = lastSentGiftTotalNum.get(toUid) + 1;
            int num = lastSentGiftTotalNum.get(toUid) + sendNum;
            lastSentGiftTotalNum.put(toUid, num);
            multi_click_end = num;
        }
        Log.d(TAG, "sendHangOutGift-队列发送请求-multi_click_start:" + multi_click_start
                + " multi_click_end:" + multi_click_end);
        HangOutGiftSendReq req = new HangOutGiftSendReq(giftItem, currRoomId, toUid, toUsername, sendNum,
                giftItem.canMultiClick, multi_click_start,
                multi_click_end, mMultiClickId, isPackage, isPrivate);
        HangOutGiftSendReqManager.getInstance().putHangOutGiftSendReq(req);
    }

    //-----------------------listener--------------------------------
    public interface HangOutGiftSendResultListener {

        /**
         * 背包礼物发送请求插入队列回调
         *
         * @param giftItem
         * @param errorCode
         * @param message
         * @param isRepeat
         */
        void onHangOutGiftReqSent(GiftItem giftItem, ErrorCode errorCode,
                                  String message, boolean isRepeat, int sendNum);
    }

    /**
     * 礼物发送请求插入队列错误码
     */
    public enum ErrorCode {
        /**
         * 成功
         */
        SUCCESS,
        /**
         * 失败-信用点数量不够
         */
        FAILED_CREDITS_NOTENOUGHT,
        /**
         * 失败-断线重连中
         */
        FAILED_RECONNECTING,
        /**
         * 失败-背包数量不够
         */
        FAILED_NUMBS_NOTENOUGHT,
        /**
         * 其他发送失败的情况
         */
        FAILED_OTHER
    }
}
