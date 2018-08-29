package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.utils.Log;

import static com.qpidnetwork.livemodule.im.IMManager.hasIMReconnected;
import static com.qpidnetwork.livemodule.im.IMManager.imReconnecting;

/**
 * Description:礼物+背包发送器,用户管理两者不同的本地发送校验逻辑
 * <p>
 * Created by Harry on 2017/8/16.
 */

public class GiftSender {
    //-------------------------------单例模式，初始化-------------------
    private GiftSender(){}

    private static GiftSender instance = null;

    public static GiftSender getInstance(){
        if(null == instance){
            instance = new GiftSender();
        }
        return instance;
    }

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
     * 连击礼物，选择发送数量
     */
    private int lastSentGiftSelectedNumb = 0;
    /**
     * 当前房间号
     */
    public String currRoomId = null;
    //------------------------------私有方法定义-------------------

    /**
     * 发送商店礼物,校验本地金币数量是否满足发送下一批量礼物的金币要求
     * @param giftItem
     * @param isRepeat
     * @param sendNum
     * @param listener
     */
    public void sendStoreGift(GiftItem giftItem, boolean isRepeat, int sendNum,
                              GiftSendResultListener listener){
        Log.d(TAG,"sendStoreGift-id:"+giftItem.id+" name:"+giftItem.name+" isRepeat:"+isRepeat
                +" sendNum:"+sendNum);
        //判断本地金币数量是否充足
        double reqCoins = giftItem.credit*sendNum;
        //礼物首次发送，需要本地校验下金币数量是否充足
        double localCoins = LiveRoomCreditRebateManager.getInstance().getCredit();
        Log.d(TAG,"sendStoreGift-reqCoins:"+reqCoins+" localCoins:"+localCoins);
        if(!isRepeat && localCoins < reqCoins){
            if(null != listener){
                listener.onGiftReqSent(giftItem,ErrorCode.FAILED_CREDITS_NOTENOUGHT,
                        "本地金币数量不够了！",localCoins,isRepeat,sendNum);
            }
            return;
        }

        if(!imReconnecting){
            Log.d(TAG,"sendStoreGift-未处于断网重连过程，真发送");
            sendGift(giftItem,isRepeat,sendNum,false);
        }
        if(null != listener){
            listener.onGiftReqSent(giftItem,ErrorCode.SUCCESS,"",localCoins,isRepeat,sendNum);
        }
    }

    /**
     * 发送背包礼物,校验本地背包数量是否够发送下一批量的背包礼物的数量要求
     * @param giftItem
     * @param isRepeat
     * @param sendNum
     * @param listener
     */
    public void sendBackpackGift(GiftItem giftItem, boolean isRepeat, int sendNum,int totalNum,
                                 GiftSendResultListener listener){
        Log.d(TAG,"sendBackpackGift-id:"+giftItem.id+" name:"+giftItem.name+" isRepeat:"+isRepeat
            +" sendNum:"+sendNum+" totalNum:"+totalNum);
        //每次判断剩余数量是否充足
        if(totalNum>=sendNum){
            if(!imReconnecting) {
                Log.d(TAG,"sendBackpackGift-未处于断网重连过程，真发送");
                sendGift(giftItem, isRepeat, sendNum,true);
            }
            if(listener != null){
                listener.onPackReqSend(giftItem,ErrorCode.SUCCESS,"",isRepeat,sendNum);
            }
        }else{
            if(null != listener){
                listener.onPackReqSend(giftItem,ErrorCode.FAILED_NUMBS_NOTENOUGHT,
                        "剩余数量不足!",isRepeat,sendNum);
            }
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
        int multi_click_start = 0;
        int multi_click_end = 0;
        //是否出现断线重连成功的情况
        if(hasIMReconnected || !isRepeat){
            //每次重新开始发送，重新生成
            Log.d(TAG,"sendGift-断网重连成功或者首次，重新生成连送ID");
            mMultiClickId = (int)(System.currentTimeMillis()/1000);
            multi_click_start = 1;
            lastSentGiftSelectedNumb = sendNum;
            lastSentGiftTotalNum = lastSentGiftSelectedNumb;
            multi_click_end = lastSentGiftTotalNum;
            hasIMReconnected = false;
        }else{
            Log.d(TAG,"sendGift-非断网，且连送，沿用旧的连送ID");
            multi_click_start = lastSentGiftTotalNum+1;
            lastSentGiftTotalNum+= lastSentGiftSelectedNumb;
            multi_click_end = lastSentGiftTotalNum;
        }
        Log.d(TAG,"sendGift-队列发送请求");
        GiftSendReq req = new GiftSendReq(giftItem,currRoomId,lastSentGiftSelectedNumb,
                giftItem.canMultiClick,multi_click_start,
                multi_click_end,mMultiClickId,isPackage);
        GiftSendReqManager.getInstance().putGiftSendReq(req);
    }

    //-----------------------listener--------------------------------
    public interface GiftSendResultListener{
        /**
         * 礼物发送请求插入队列回调
         * @param normalGiftItem
         * @param errorCode
         * @param message
         * @param localCoins
         * @param isRepeat
         */
        void onGiftReqSent(GiftItem normalGiftItem, ErrorCode errorCode, String message,
                           double localCoins, boolean isRepeat, int sendNum);

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
