package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.List;
import java.util.Random;
import java.util.Timer;
import java.util.TimerTask;

/**
 * Created by Hunter Mun on 2017/9/19.
 * 逻辑：
 * 1.仅仅私密直播间存在推荐礼物功能
 * 2.在获取礼物配置和可发送礼物配置后，就
 */

public class GiftRecommandManager {

    private static final int RECOMMAND_DURATION = 5 * 60 * 1000;    //每5分钟随机推荐一个礼物
    private final String TAG = GiftRecommandManager.class.getSimpleName();

    private Timer mRandomRecommandTimer;
    private OnGiftRecommandListener mRecommandListener;
    private RoomSendableGiftManager mRoomSendableGiftManager;

    //标记推荐是否开启,防止重复启动
    private boolean mRecommandStarted = false;

    public GiftRecommandManager(RoomSendableGiftManager roomSendableGiftManager){
        this.mRoomSendableGiftManager = roomSendableGiftManager;
        mRandomRecommandTimer = new Timer();
    }

    /**
     * 设置推荐监听器
     * @param listener
     */
    public void setRecommandListener(OnGiftRecommandListener listener){
        Log.d(TAG,"setRecommandListener");
        this.mRecommandListener = listener;
    }

    /**
     * 开启推荐定时器
     */
    public void startRecommand(){
        Log.d(TAG,"startRecommand");
        //启动推荐逻辑
        if (mRandomRecommandTimer != null && !mRecommandStarted) {
            mRecommandStarted = true;
            mRandomRecommandTimer.schedule(new TimerTask() {
                @Override
                public void run() {
                    if(mRoomSendableGiftManager != null){
                        List<GiftItem> recommandGiftList = mRoomSendableGiftManager.getFilterRecommandGiftList();
                        if(recommandGiftList != null && recommandGiftList.size() > 0){
                            int position;
                            if(recommandGiftList.size() == 1){
                                position = 0;
                            }else{
                                position = new Random().nextInt(recommandGiftList.size() - 1);
                            }

                            GiftItem recomGiftItem = recommandGiftList.get(position);
                            if (mRecommandListener != null) {
                                mRecommandListener.onGiftRecommand(recomGiftItem);
                            }
                        }
                    }
                }
            }, 0, RECOMMAND_DURATION);
        }
    }

    /**
     * 停止推荐
     */
    public void stopRecommand(){
        Log.d(TAG,"stopRecommand");
        mRecommandStarted = false;
        if(mRandomRecommandTimer != null){
            mRandomRecommandTimer.cancel();
        }
    }

    public interface OnGiftRecommandListener{
        public void onGiftRecommand(GiftItem giftItem);
    }
}
