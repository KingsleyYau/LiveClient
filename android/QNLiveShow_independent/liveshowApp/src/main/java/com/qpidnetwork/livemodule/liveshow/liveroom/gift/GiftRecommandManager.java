package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.BaseCommonLiveRoomActivity;
import com.qpidnetwork.livemodule.utils.Log;

import java.lang.ref.WeakReference;
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

    private WeakReference<BaseCommonLiveRoomActivity> mContext;
    private Timer mRandomRecommandTimer;
    private OnGiftRecommandListener mRecommandListener;
    private NormalGiftManager mNormalGiftManager;

    public GiftRecommandManager(BaseCommonLiveRoomActivity context){
        Log.d(TAG,"GiftRecommandManager");
        this.mContext = new WeakReference<BaseCommonLiveRoomActivity>(context);
        mRandomRecommandTimer = new Timer();
        mNormalGiftManager = NormalGiftManager.getInstance();
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
        if(mRandomRecommandTimer != null){
            mRandomRecommandTimer.schedule(new TimerTask() {
                @Override
                public void run() {
                    if(null != mContext && null != mContext.get() && null != mContext.get().mIMRoomInItem){
                        IMRoomInItem currIMRoomInItem =mContext.get().mIMRoomInItem;
                        List<GiftItem> giftList = NormalGiftManager.getInstance().getLocalSendabelRecomGiftList(
                                currIMRoomInItem.roomId,currIMRoomInItem.manLevel,currIMRoomInItem.loveLevel);
                        if(null != giftList && giftList.size()>0){
                            int position = new Random().nextInt(giftList.size()-1);
                            GiftItem recomGiftItem = giftList.get(position);
                            Log.d(TAG,"startRecommand-recomGiftItem.id:"+recomGiftItem.id+" recomGiftItem.name:"+recomGiftItem.name);
                            if(mRecommandListener != null){
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
        if(mRandomRecommandTimer != null){
            mRandomRecommandTimer.cancel();
        }
    }

    public interface OnGiftRecommandListener{
        public void onGiftRecommand(GiftItem giftItem);
    }
}
