package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Context;

import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;

import java.util.List;
import java.util.Random;
import java.util.Timer;
import java.util.TimerTask;

/**
 * Created by Hunter Mun on 2017/9/19.
 */

public class GiftRecommandManager {

    private static final int RECOMMAND_DURATion = 5 * 60 * 1000;    //每5分钟随机推荐一个礼物

    private Context mContext;
    private String mRoomId;
    private Timer mRandomRecommandTimer;
    private OnGiftRecommandListener mRecommandListener;
    private NormalGiftManager mNormalGiftManager;

    public GiftRecommandManager(Context context, String roomId){
        this.mContext = context;
        this.mRoomId = roomId;
        mRandomRecommandTimer = new Timer();
        mNormalGiftManager = NormalGiftManager.getInstance();
    }

    /**
     * 设置推荐监听器
     * @param listener
     */
    public void setRecommandListener(OnGiftRecommandListener listener){
        this.mRecommandListener = listener;
    }

    /**
     * 开启推荐定时器
     */
    public void startRecommand(){
        if(mRandomRecommandTimer != null){
            mRandomRecommandTimer.schedule(new TimerTask() {
                @Override
                public void run() {
                    List<GiftItem> giftList = NormalGiftManager.getInstance().getLocalAllSendabelGiftList(mRoomId);
                    int position = new Random().nextInt(giftList.size()-1);
                    if(mRecommandListener != null){
                        mRecommandListener.onGiftRecommand(giftList.get(position));
                    }
                }
            }, 0, RECOMMAND_DURATion);
        }
    }

    /**
     * 停止推荐
     */
    public void stopRecommand(){
        if(mRandomRecommandTimer != null){
            mRandomRecommandTimer.cancel();
        }
    }

    public interface OnGiftRecommandListener{
        public void onGiftRecommand(GiftItem giftItem);
    }
}
