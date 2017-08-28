package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.utils.Log;

import static com.qpidnetwork.livemodule.utils.TestDataUtil.localCoins;

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
    /**
     * 是否连击过程中出现断线重连的情况
     */
    public boolean imReconnecting = false;
    /**
     * 是否连击过程中出现断线而后重连成功的情况
     */
    public boolean hasIMReconnected = false;

    //------------------------------私有方法定义-------------------

    /**
     * 发送商店礼物,校验本地金币数量是否满足发送下一批量礼物的金币要求
     * @param gift
     * @param isRepeat
     * @param sendNum
     * @param listener
     */
    public void sendStoreGift(Gift gift, boolean isRepeat, int sendNum,
                              GiftSendResultListener listener){
        Log.d(TAG,"sendStoreGift-isRepeat:"+isRepeat
                +" giftId:"+gift.giftItem.id+" sendNum:"+sendNum);

        //判断本地金币数量是否充足
        double reqCoins = gift.giftItem.credit*sendNum;
        Log.d(TAG,"sendStoreGift-reqCoins:"+reqCoins+" localCoins:"+localCoins);
        //礼物首次发送，需要本地校验下金币数量是否充足
        if(!isRepeat && localCoins < reqCoins){
            if(null != listener){
                listener.onGiftReqSent(gift,ErrorCode.FAILED_COINS_NOTENOUGHT,
                        "本地金币数量不够了！",localCoins,isRepeat);
            }
            return;
        }

        if(!imReconnecting){
            Log.d(TAG,"sendStoreGift-未处于断网重连过程，真发送");
            sendGift(gift.giftItem,isRepeat,sendNum);
            if(!isRepeat){
                localCoins-=reqCoins;
                localCoins = (double)(Math.round(localCoins*100)/100.0);
            }
        }
        if(null != listener){
            listener.onGiftReqSent(gift,ErrorCode.SUCCESS,"",localCoins,isRepeat);
        }
    }

    /**
     * 发送背包礼物,校验本地背包数量是否够发送下一批量的背包礼物的数量要求
     * @param pack
     * @param isRepeat
     * @param sendNum
     * @param listener
     */
    public void sendBackpackGift(Pack pack, boolean isRepeat, int sendNum,
                                 GiftSendResultListener listener){
        //每次判断剩余数量是否充足
        if(pack.num>=sendNum){
            if(!imReconnecting) {
                Log.d(TAG,"sendBackpackGift-未处于断网重连过程，真发送");
                sendGift(pack.giftItem, isRepeat, sendNum);
                pack.num -= sendNum;
            }
            listener.onPackReqSend(pack,ErrorCode.SUCCESS,"",isRepeat);
        }else{
            if(null != listener){
                listener.onPackReqSend(pack,ErrorCode.FAILED_NUMBS_NOTENOUGHT,
                        "剩余数量不足!",isRepeat);
            }
        }
    }

    private void sendGift(GiftItem giftItem, boolean isRepeat,int sendNum){
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
        //大礼物不排队，直接发送
        if(giftItem.giftType == GiftItem.GiftType.Advanced){
            Log.d(TAG,"sendGift-大礼物不排队，直接发送");
            IMManager.getInstance().sendGift(currRoomId, giftItem,
                    lastSentGiftSelectedNumb, giftItem.canMultiClick,
                    multi_click_start, multi_click_end, mMultiClickId);
        }else{
            //普通礼物,队列发送请求
            Log.d(TAG,"sendGift-普通礼物,队列发送请求");
            GiftSendReq req = new GiftSendReq(giftItem,currRoomId,lastSentGiftSelectedNumb,
                    giftItem.canMultiClick,multi_click_start,
                    multi_click_end,mMultiClickId);
            GiftSendReqManager.getInstance().putGiftSendReq(req);
        }
    }

    //-----------------------listener--------------------------------
    public interface GiftSendResultListener{
        /**
         * 礼物发送请求插入队列回调
         * @param gift
         * @param errorCode
         * @param message
         * @param localCoins
         * @param isRepeat
         */
        void onGiftReqSent(Gift gift, ErrorCode errorCode, String message,
                           double localCoins, boolean isRepeat);

        /**
         * 背包礼物发送请求插入队列回调
         * @param pack
         * @param errorCode
         * @param message
         * @param isRepeat
         */
        void onPackReqSend(Pack pack, ErrorCode errorCode,
                           String message, boolean isRepeat);
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
         * 失败-金币数量不够
         */
        FAILED_COINS_NOTENOUGHT,
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
