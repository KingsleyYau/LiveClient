package com.qpidnetwork.livemodule.liveshow.liveroom.talent;

import android.app.Activity;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetTalentInviteStatusCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetTalentListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniLiveShow;
import com.qpidnetwork.livemodule.httprequest.item.TalentInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.TalentInviteItem;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.im.listener.IMSysNoticeMessageContent;
import com.qpidnetwork.livemodule.liveshow.liveroom.BaseCommonLiveRoomActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.talent.interfaces.onRequestConfirmListener;
import com.qpidnetwork.livemodule.utils.DisplayUtil;

import java.lang.ref.WeakReference;
import java.util.Timer;
import java.util.TimerTask;

import static com.qpidnetwork.livemodule.im.IMManager.imReconnecting;
import static com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE.LCC_ERR_NOT_FOUND_ROOM;
import static com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE.LCC_ERR_NO_CREDIT;
import static com.qpidnetwork.livemodule.im.listener.IMClientListener.LCC_ERR_TYPE.LCC_ERR_ROOM_CLOSE;

/**
 * 才艺管理工具
 * Created by Jagger on 2017/9/20.
 */

public class TalentManager implements TalentsPopupWindow.onBtnClickedListener {

    private final String TAG = TalentManager.class.getSimpleName();
    private WeakReference<Activity> mActivity;
    private TalentsPopupWindow mTalentsPopupWindow;
    private TalentConfirmPopubWindow talentConfirmPopubWindow;
    private onRequestConfirmListener mOnRequestConfirmListener;
    private TalentInfoItem[] mDatas;            //数据源
    private boolean getTalentListSuccess = false;
    private String mRoomId;                     //房间ID
    private TalentInfoItem mRequestingTalent ;  //正在请求的才艺，用作判断能否发送其它才艺请求
    private View anchorView;

    private long lastTalentNotResponedReqTime = 0l;
    /**网页端 60秒主播没操作 默认拒绝，但是服务器没有通知给客户端*/
    private final long REQUEST_CAN_NOT_SENT_TIME_DELAY = 1*60*1000l;

    private Timer timer;
    private TimerTask timerTask;

    public TalentManager(Activity activity){
        mActivity = new WeakReference<Activity>(activity);
        mTalentsPopupWindow = new TalentsPopupWindow(mActivity.get());
        mTalentsPopupWindow.setOnBtnClickedListener(this);
    }

    public void release(){
        Log.d(TAG,"release");
        stopOverTimeTimer();
        anchorView = null;
        mOnRequestConfirmListener = null;
        if(null != mTalentsPopupWindow){
            mTalentsPopupWindow.setOnBtnClickedListener(null);
        }
        mTalentsPopupWindow = null;
        if(null != talentConfirmPopubWindow){
            talentConfirmPopubWindow.setOnConfirmListener(null);
        }
        talentConfirmPopubWindow = null;
        if(null != mActivity){
            mActivity.clear();
        }
        mActivity= null;
    }

    /**
     * 请求才艺列表数据
     */
    public void getTalentsData(String roomId){
        Log.d(TAG,"getTalentsData-roomId:"+roomId);
        getTalentListSuccess = false;
        mRoomId = roomId;
        LiveRequestOperator.getInstance().GetTalentList(mRoomId, new OnGetTalentListCallback() {
            @Override
            public void onGetTalentList(final boolean isSuccess, int errCode, String errMsg, final TalentInfoItem[] talentList) {
                Log.d(TAG,"getTalentsData-onGetTalentList-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
                mDatas = talentList;
                getTalentListSuccess = isSuccess;
                if(null != mActivity && null != mActivity.get()){
                    mActivity.get().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            mTalentsPopupWindow.setData(mDatas);
                            mTalentsPopupWindow.refreshDataStatusView(false,!getTalentListSuccess,
                                    !(null != mDatas && mDatas.length > 0 && getTalentListSuccess));
                        }
                    });
                }
            }
        });
    }

    /**
     * 点击发送才艺要求确认事件回调
     * @param l
     */
    public void setOnClickedRequestConfirmListener(onRequestConfirmListener l){
        mOnRequestConfirmListener = l;
    }

    /**
     * 显示才艺列表
     * @param anchorView
     */
    public void showTalentsList(View anchorView){
        Log.d(TAG,"showTalentsList");
        this.anchorView = anchorView;
        mTalentsPopupWindow.setData(mDatas);
        mTalentsPopupWindow.refreshDataStatusView(false,!getTalentListSuccess,!(null != mDatas && mDatas.length > 0 && getTalentListSuccess));
        mTalentsPopupWindow.showAtLocation(anchorView, Gravity.BOTTOM,0,DisplayUtil.getNavigationBarHeight(mActivity.get()));
    }

    private void startOverTimeTimer(){
        Log.d(TAG,"startOverTimeTimer");
        stopOverTimeTimer();
        if(null == timer){
            timer = new Timer();
            timerTask = new TimerTask() {
                @Override
                public void run() {
                    Log.d(TAG,"startOverTimeTimer-超时，获取才艺邀请主播处理状态");
                    getTalentStatus();
                    stopOverTimeTimer();
                }
            };
        }
        timer.schedule(timerTask,REQUEST_CAN_NOT_SENT_TIME_DELAY);
    }

    private void stopOverTimeTimer(){
        Log.d(TAG,"stopOverTimeTimer");
        if(null != timer){
            timerTask.cancel();
            timerTask = null;
            timer.cancel();
            timer = null;
        }
    }

    /**
     * 才艺发送结果回调,会弹出相应提示
     */
    public void onTanlentSent(final boolean result , final String errMsg, final IMClientListener.LCC_ERR_TYPE errType){
        Log.d(TAG,"onTanlentSent-result:"+result+" errMsg:"+errMsg);
        if(null != mActivity && null != mActivity.get()){
            mActivity.get().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    String msg = null;
                    if(result){
                        lastTalentNotResponedReqTime = System.currentTimeMillis();
                        startOverTimeTimer();
                        msg = mActivity.get().getString(R.string.live_talent_request_success , mRequestingTalent.talentName);
                        if(mActivity.get() instanceof BaseCommonLiveRoomActivity){
                            IMMessageItem msgItem = new IMMessageItem(((BaseCommonLiveRoomActivity) mActivity.get()).mIMRoomInItem.roomId,
                                    ((BaseCommonLiveRoomActivity) mActivity.get()).mIMManager.mMsgIdIndex.getAndIncrement(),
                                    "",
                                    IMMessageItem.MessageType.SysNotice,
                                    new IMSysNoticeMessageContent(msg,"", IMSysNoticeMessageContent.SysNoticeType.Normal));
                            ((BaseCommonLiveRoomActivity) mActivity.get()).sendMessageUpdateEvent(msgItem);
                        }else{
                            Toast.makeText(mActivity.get() , msg ,Toast.LENGTH_LONG).show();
                        }
                    }else{
                        Log.d(TAG,"onTanlentSent-imReconnecting:"+imReconnecting);
                        mRequestingTalent = null;
                        lastTalentNotResponedReqTime = 0l;
                        if(LCC_ERR_NO_CREDIT == errType){
                            if(mActivity.get() instanceof BaseCommonLiveRoomActivity){
                                ((BaseCommonLiveRoomActivity) mActivity.get()).
                                showCreditNoEnoughDialog(R.string.live_common_noenough_money_tips);
                            }else{
                                Toast.makeText(mActivity.get() , msg ,Toast.LENGTH_LONG).show();
                            }
                        }else{
                            if(LCC_ERR_ROOM_CLOSE == errType || LCC_ERR_NOT_FOUND_ROOM == errType){
                                msg = mActivity.get().getString(R.string.live_talent_request_failed_room_closing);
                            }else{
                                msg = mActivity.get().getString(R.string.live_talent_request_failed);
                            }

                            if(mActivity.get() instanceof BaseFragmentActivity){
                                ((BaseFragmentActivity) mActivity.get()).
                                        showToast(msg);
                            }else{
                                Toast.makeText(mActivity.get() , msg ,Toast.LENGTH_LONG).show();
                            }
                        }
                    }
                    Log.d(TAG,"onTanlentSent-msg:"+msg);
                }
            });
        }
    }

    /**
     * 才艺请求被主播处理回调,会弹出相应提示
     */
    public void onTanlentProcessed(final String talentId , final String talentName ,
                                   final IMClientListener.TalentInviteStatus status){
        Log.d(TAG,"onTanlentProcessed-talentId:"+talentId+" talentName:"+talentName +" status:"+status);
        mRequestingTalent = null;
        stopOverTimeTimer();
        lastTalentNotResponedReqTime = 0;
        if(null != mActivity && null != mActivity.get()){
            mActivity.get().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    String msg = null;
                    if(mActivity.get() instanceof BaseCommonLiveRoomActivity){
                        IMRoomInItem currIMRoomInItem = ((BaseCommonLiveRoomActivity) mActivity.get()).mIMRoomInItem;
                        String nickName = currIMRoomInItem.nickName;
                        if(status == IMClientListener.TalentInviteStatus.Accepted){
                            msg = mActivity.get().getString(R.string.live_talent_accepted , nickName ,talentName);
                        }else if(status == IMClientListener.TalentInviteStatus.Rejested){
                            msg = mActivity.get().getString(R.string.live_talent_declined , nickName ,talentName);
                        }
                        if(!TextUtils.isEmpty(msg)){
                            IMMessageItem msgItem = new IMMessageItem(currIMRoomInItem.roomId,
                                    ((BaseCommonLiveRoomActivity) mActivity.get()).mIMManager.mMsgIdIndex.getAndIncrement(),
                                    "",
                                    IMMessageItem.MessageType.SysNotice,
                                    new IMSysNoticeMessageContent(msg,"", IMSysNoticeMessageContent.SysNoticeType.Normal));
                            ((BaseCommonLiveRoomActivity) mActivity.get()).sendMessageUpdateEvent(msgItem);
                        }
                    }
                    Log.d(TAG,"onTanlentProcessed-msg:"+msg);
                }
            });
        }
    }

    /**
     * 获取才艺点状态
     */
    public void getTalentStatus(){
        long timeDelay = System.currentTimeMillis() - lastTalentNotResponedReqTime;
        Log.d(TAG,"getTalentStatus-lastTalentNotResponedReqTime:"+lastTalentNotResponedReqTime+" timeDelay:"+timeDelay);
        //如果是发送过请求，才去获取
        if(mRequestingTalent != null && timeDelay>=REQUEST_CAN_NOT_SENT_TIME_DELAY){
            LiveRequestOperator.getInstance().GetTalentInviteStatus(mRoomId, mRequestingTalent.talentId,
                    new OnGetTalentInviteStatusCallback() {
                @Override
                public void onGetTalentInviteStatus(boolean isSuccess, int errCode,
                                                    String errMsg, TalentInviteItem inviteItem) {
                    Log.d(TAG,"getTalentStatus-onGetTalentInviteStatus isSuccess:"+isSuccess
                            +" errCode:"+errCode+" errMsg:"+errMsg+" inviteItem:"+inviteItem);
                    //如果已被主播处理了
                    if(isSuccess && inviteItem.inviteStatus != TalentInviteItem.TalentInviteStatus.NoReplied){
                        mRequestingTalent = null;
                        if(mActivity.get() instanceof BaseCommonLiveRoomActivity) {
                            String msg = null;
                            IMRoomInItem currIMRoomInItem = ((BaseCommonLiveRoomActivity) mActivity.get()).mIMRoomInItem;
                            String nickName = currIMRoomInItem.nickName;
                            if(inviteItem.inviteStatus == TalentInviteItem.TalentInviteStatus.Accept){
                                msg = mActivity.get().getString(R.string.live_talent_accepted , nickName ,inviteItem.name);
                            }else if(inviteItem.inviteStatus == TalentInviteItem.TalentInviteStatus.Denied){
                                msg = mActivity.get().getString(R.string.live_talent_declined , nickName ,inviteItem.name);
                            }
                            if(!TextUtils.isEmpty(msg)){
                                IMMessageItem msgItem = new IMMessageItem(currIMRoomInItem.roomId,
                                        ((BaseCommonLiveRoomActivity) mActivity.get()).mIMManager.mMsgIdIndex.getAndIncrement(),
                                        "",
                                        IMMessageItem.MessageType.SysNotice,
                                        new IMSysNoticeMessageContent(msg,"", IMSysNoticeMessageContent.SysNoticeType.Normal));
                                ((BaseCommonLiveRoomActivity) mActivity.get()).sendMessageUpdateEvent(msgItem);
                            }
                        }
                    }
                }
            });
        }
    }

    /**
     * 重新获取数据
     */
    private void reGetTalentsData(){
        Log.d(TAG,"reGetTalentsData");
        if(mTalentsPopupWindow != null){
            mTalentsPopupWindow.refreshDataStatusView(true,false,false);
        }
        getTalentsData(mRoomId);
    }

    @Override
    public void onRequestClicked(TalentInfoItem talent) {
        if(mActivity.get() instanceof BaseCommonLiveRoomActivity){
            double currCredits = ((BaseCommonLiveRoomActivity)mActivity.get()).mLiveRoomCreditRebateManager.getCredit();
            if(currCredits<talent.talentCredit){
                ((BaseCommonLiveRoomActivity) mActivity.get()).
                showCreditNoEnoughDialog(R.string.live_common_noenough_money_tips);
                return;
            }
        }
        long timeDelay = System.currentTimeMillis() - lastTalentNotResponedReqTime;
        Log.d(TAG,"onRequestClicked-talent.talentId:"+talent.talentId+" timeDelay:"+ timeDelay
                +" lastTalentNotResponedReqTime:"+lastTalentNotResponedReqTime);
        if(timeDelay>=REQUEST_CAN_NOT_SENT_TIME_DELAY){
            //弹出确认对话框
            showTalentConfirmDialog(talent);
        }else{
            if(null != mActivity && null != mActivity.get()){
                if(mActivity.get() instanceof BaseCommonLiveRoomActivity){
                    ((BaseCommonLiveRoomActivity)mActivity.get()).showThreeSecondTips(
                            mActivity.get().getResources().getString(R.string.live_talent_request_wait),Gravity.CENTER);
                }else{
                    Toast.makeText(mActivity.get(),
                            mActivity.get().getResources().getString(R.string.live_talent_request_wait) ,
                            Toast.LENGTH_LONG).show();
                }
            }
        }

    }

    @Override
    public void onReloadClicked() {
        reGetTalentsData();
    }

    private void showTalentConfirmDialog(final TalentInfoItem talent){
        Log.d(TAG,"showTalentConfirmDialog-talent:"+talent);
        if(null == talentConfirmPopubWindow){
            talentConfirmPopubWindow = new TalentConfirmPopubWindow(mActivity.get());
            talentConfirmPopubWindow.setOnConfirmListener(new TalentConfirmPopubWindow.OnConfirmRequestTalentListener() {
                @Override
                public void onTalentConfirmRequest(boolean isConfirm, TalentInfoItem talentInfoItem) {
                    Log.d(TAG,"showTalentConfirmDialog-onTalentConfirmRequest talentInfoItem:"+talentInfoItem);
                    if(isConfirm){
                        if(mOnRequestConfirmListener != null){
                            mOnRequestConfirmListener.onConfirm(talentInfoItem);
                        }
                        //记下才艺
                        mRequestingTalent = talentInfoItem;
                        if(null != mTalentsPopupWindow){
                            mTalentsPopupWindow.dismiss();
                        }
                    }

                }
            });
        }
        talentConfirmPopubWindow.setTalentInfoItem(talent);
        if(null != anchorView){
            talentConfirmPopubWindow.showAtLocation(anchorView,Gravity.CENTER,0,0);
        }
    }
}
