package com.qpidnetwork.anchor.liveshow.liveroom.gift;

import com.qpidnetwork.anchor.httprequest.item.GiftItem;
import com.qpidnetwork.anchor.im.IMManager;
import com.qpidnetwork.anchor.utils.Log;

/**
 * Description:礼物+背包发送器,用户管理两者不同的本地发送校验逻辑
 * <p>
 * Created by Harry on 2017/8/16.
 */

public class GiftSender {
    private GiftSendReqManager giftSendReqManager;

    //-------------------------------单例模式，初始化-------------------
    public GiftSender(GiftSendReqManager giftSendReqManager){
        this.giftSendReqManager = giftSendReqManager;
    }

    //是否IM断线重连过
    private boolean mHasIMReconnected = false;

    //------------------------------私有变量定义-------------------
    private final String TAG = GiftSender.class.getSimpleName();
    /**
     * 连击ID
     */
    private int mMultiClickId = 0;
    /**
     * 连击礼物，已发送的总量
     */
    private int lastSentGiftTotalNum = 0;

    /**
     * 当前房间号
     */
    public String currRoomId = null;

    /**
     * 通知IM断线重连成功
     */
    public void notifyIMReconnect(){
        mHasIMReconnected = true;
    }
    //------------------------------私有方法定义-------------------

    /**
     * 发送背包礼物,校验本地背包数量是否够发送下一批量的背包礼物的数量要求
     * @param giftItem
     * @param isRepeat
     * @param sendNum
     * @param listener
     */
    public void sendBackpackGift(GiftItem giftItem, boolean isRepeat, int sendNum,int totalNum,
                                 GiftSender.GiftSendResultListener listener){
        //每次判断剩余数量是否充足
        int currSentNum = totalNum >= sendNum ? sendNum : totalNum;
        Log.d(TAG,"sendBackpackGift-id:"+giftItem.id+" name:"+giftItem.name+" isRepeat:"+isRepeat
                +" sendNum:"+sendNum+" totalNum:"+totalNum+" currSentNum:"+currSentNum);
        if(IMManager.getInstance().isIMLogined()) {
            Log.d(TAG,"sendBackpackGift-未处于断网重连过程，真发送");
            sendGift(giftItem, isRepeat, currSentNum,false);
        }
        if(null != listener){
            listener.onPackReqSend(giftItem, GiftSender.ErrorCode.SUCCESS,"",isRepeat,currSentNum);
        }

    }

    /**
     * 队列发送礼物请求
     * @param giftItem
     * @param isRepeat
     * @param sendNum
     * @param isPackage
     */
    private void sendGift(GiftItem giftItem, boolean isRepeat,int sendNum, boolean isPackage){
        Log.d(TAG,"sendGift-giftItem.id:"+giftItem+" isRepeat:"+isRepeat+" sendNum:"+sendNum+" isPackage:"+isPackage);
        int multi_click_start = 0;
        int multi_click_end = 0;
        //是否出现断线重连成功的情况
        if(mHasIMReconnected || !isRepeat){
            //每次重新开始发送，重新生成
            Log.d(TAG,"sendGift-断网重连成功或者首次，重新生成连送ID");
            mMultiClickId = (int)(System.currentTimeMillis()/1000);
            multi_click_start = 1;
            lastSentGiftTotalNum = sendNum;
            multi_click_end = lastSentGiftTotalNum;
            mHasIMReconnected = false;
        }else{
            Log.d(TAG,"sendGift-非断网，且连送，沿用旧的连送ID");
            multi_click_start = lastSentGiftTotalNum+1;
            lastSentGiftTotalNum+= sendNum;
            multi_click_end = lastSentGiftTotalNum;
        }
        Log.d(TAG,"sendGift-队列发送请求-multi_click_start:"+multi_click_start
                +" multi_click_end:"+multi_click_end);
        GiftSendReq req = new GiftSendReq(giftItem,currRoomId,sendNum,
                giftItem.canMultiClick,multi_click_start,
                multi_click_end,mMultiClickId,isPackage);
        giftSendReqManager.putGiftSendReq(req);
    }

    //-----------------------listener--------------------------------
    public interface GiftSendResultListener{

        /**
         * 背包礼物发送请求插入队列回调
         * @param giftItem
         * @param errorCode
         * @param message
         * @param isRepeat
         */
        void onPackReqSend(GiftItem giftItem, ErrorCode errorCode,
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
