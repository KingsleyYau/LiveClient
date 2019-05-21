package com.qpidnetwork.livemodule.liveshow.liveroom.talent;

import android.content.Context;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v7.app.AppCompatActivity;
import android.text.TextUtils;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetTalentInviteStatusCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetTalentListCallback;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.TalentInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.TalentInviteItem;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;

import static com.qpidnetwork.livemodule.im.IMManager.imReconnecting;

/**
 * 才艺管理工具
 * Created by Jagger on 2017/9/20.
 */

public class TalentManager implements TalentDialogFragment.onDialogEventListener {

    private final String TAG = "Jagger";// TalentManager.class.getSimpleName();
    private static TalentManager gTalentManager;
    private FragmentManager mFragmentManager;
    private Context mContext;
//    private TalentsPopupWindow mTalentsPopupWindow;
//    private TalentConfirmDialog talentConfirmDialog;
//    private onRequestConfirmListener mOnRequestConfirmListener;
    private String mRoomId;                     //房间ID
    private String mAnchorAvatarURL;            //主播头像
    private String mAnchorNickName;            //主播头像
//    private TalentInfoItem mRequestingTalent ;  //正在请求的才艺，用作判断能否发送其它才艺请求
    private String mTempTalentInviteId = "";        //正在请求的才艺的邀请ID
//    private Consumer<HttpRespObject> mObserverTalentListResult; //
    private List<onTalentEventListener> mOnTalentEventListenerList = new ArrayList<>();
    private HttpRespObject httpRespObjectTalentList;
    private Disposable mDisposable;
    private View anchorView;

//    private long lastTalentNotResponedReqTime = 0l;
    /**网页端 60秒主播没操作 默认拒绝，但是服务器没有通知给客户端*/
//    private final long REQUEST_CAN_NOT_SENT_TIME_DELAY = 1*60*1000l;

//    private Timer timer;
//    private TimerTask timerTask;

    /**
     * 才艺相关事件监听
     */
    public interface onTalentEventListener {
        /**
         * 才艺数据返回(已转交主线程)
         * @param httpRespObject
         */
        void onGetTalentList(HttpRespObject httpRespObject);

        void onConfirm(TalentInfoItem talent);
    }

    /**
     * 注册 才艺相关事件监听
     * @param listener
     */
    public void registerOnTalentEventListener(onTalentEventListener listener){
        mOnTalentEventListenerList.add(listener);
    }

    /**
     * 反注册 才艺相关事件监听
     * @param listener
     */
    public void unregisterOnTalentEventListener(onTalentEventListener listener){
        if(mOnTalentEventListenerList.contains(listener)){
            mOnTalentEventListenerList.remove(listener);
        }
    }

    public static TalentManager newInstance(AppCompatActivity activity , IMRoomInItem room){
        if(gTalentManager == null){
            gTalentManager = new TalentManager(activity , room);
        }
        return gTalentManager;
    }

    public static TalentManager getInstance() {
        return gTalentManager;
    }

    private TalentManager(Context context , IMRoomInItem room){
        mContext = context;
        mRoomId = room.roomId;
        mAnchorAvatarURL = room.photoUrl;
        mAnchorNickName = room.nickName;
//        mTalentsPopupWindow = new TalentsPopupWindow(mActivity , roomId);
//        mTalentsPopupWindow.setOnBtnClickedListener(this);
        getTalentList();
    }

    /**
     *
     */
    public void destory(){
        Log.d(TAG,"release");
//        stopOverTimeTimer();
        anchorView = null;
//        mOnRequestConfirmListener = null;
//        if(null != mTalentsPopupWindow){
//            mTalentsPopupWindow.setOnBtnClickedListener(null);
//        }
//        mTalentsPopupWindow = null;
//        if(null != talentConfirmDialog){
//            talentConfirmDialog.setOnConfirmListener(null);
//        }
//        talentConfirmDialog = null;
//        if(null != mActivity){
//            mActivity.clear();
//        }
        if(mDisposable != null && !mDisposable.isDisposed()){
            mDisposable.dispose();
        }
        mOnTalentEventListenerList.clear();
        mContext = null;
        mFragmentManager = null;
//        mRequestingTalent = null;
        mTempTalentInviteId = null;
        httpRespObjectTalentList = null;
        gTalentManager = null;
    }

//    /**
//     * 请求才艺列表数据
//     * (需求要保存到内存中)
//     */
//    public void getTalentList(String roomId){
//        Log.d(TAG,"getTalentList-roomId:"+roomId);
//        getTalentListSuccess = false;
//        mRoomId = roomId;
//        LiveRequestOperator.getInstance().GetTalentList(mRoomId, new OnGetTalentListCallback() {
//            @Override
//            public void onGetTalentList(final boolean isSuccess, int errCode, String errMsg, final TalentInfoItem[] talentList) {
//                Log.d(TAG,"getTalentList-onGetTalentList-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
//                mDatas = talentList;
//                getTalentListSuccess = isSuccess;
//                if(null != mActivity && null != mActivity){
//                    mActivity.runOnUiThread(new Runnable() {
//                        @Override
//                        public void run() {
//                            mTalentsPopupWindow.setData(mDatas);
////                            mTalentsPopupWindow.refreshDataStatusView(false,!getTalentListSuccess, !(null != mDatas && mDatas.length > 0 && getTalentListSuccess));
//                            //edit by Jagger 2018-5-21 ，修复 getTalentListSuccess = false时，空页和无数据页重复的问题
//                            mTalentsPopupWindow.refreshDataStatusView(false,!getTalentListSuccess,null != mDatas && mDatas.length < 1 && getTalentListSuccess);
//                        }
//                    });
//                }
//            }
//        });
//    }

    /**
     * 设置处理结果观察者(已转交主线程)
     */
//    public void setGetTalentListObserver(Consumer<HttpRespObject> observerResult) {
//        // TODO Auto-generated method stub
//        mObserverTalentListResult = observerResult;
//    }

    /**
     * 请求才艺列表数据
     * (需求要保存到内存中)
     */
    public void getTalentList(){
        Log.d(TAG,"getTalentList-roomId:"+mRoomId);

        //RxJava
        Observable<HttpRespObject> observerable = Observable.create(new ObservableOnSubscribe<HttpRespObject>() {

            @Override
            public void subscribe(final ObservableEmitter<HttpRespObject> emitter) throws Exception {

                if(httpRespObjectTalentList != null && httpRespObjectTalentList.isSuccess){
                    //正常发射结果
                    emitter.onNext(httpRespObjectTalentList);
                    emitter.onComplete();
                }else{
                    // 调用接口
                    LiveRequestOperator.getInstance().GetTalentList(mRoomId, new OnGetTalentListCallback() {
                        @Override
                        public void onGetTalentList(final boolean isSuccess, int errCode, String errMsg, final TalentInfoItem[] talentList) {
                            Log.d(TAG,"getTalentList-onGetTalentList-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);

                            //处理特殊错误码
                            if(!isSuccess && errCode == HttpLccErrType.HTTP_LCC_ERR_CONNECTFAIL.ordinal() && mContext != null){
                                errMsg = mContext.getString(R.string.live_talent_list_error_tips);
                            }

                            HttpRespObject httpRespObject = new HttpRespObject(isSuccess , errCode , errMsg , talentList);
                            //保存到内存中
                            httpRespObjectTalentList = httpRespObject;

                            //正常发射结果
                            emitter.onNext(httpRespObjectTalentList);
                            emitter.onComplete();
                        }
                    });
                }
            }
        });

        mDisposable = observerable
            .observeOn(AndroidSchedulers.mainThread())	//转由主线程处理结果
            .subscribe(new Consumer<HttpRespObject>() {
                @Override
                public void accept(HttpRespObject httpRespObject) throws Exception {
                    if(mOnTalentEventListenerList != null && mOnTalentEventListenerList.size() > 0){
                        for (onTalentEventListener listener: mOnTalentEventListenerList) {
                            listener.onGetTalentList(httpRespObject);
                        }
                    }
                }
            });
    }

    /**
     * 点击发送才艺要求确认事件回调
     * @param l
     */
//    public void setOnClickedRequestConfirmListener(onRequestConfirmListener l){
//        mOnRequestConfirmListener = l;
//    }

    /**
     * 显示才艺列表
     * @param anchorView
     */
    public void showTalentsList(FragmentActivity fragmentActivity, View anchorView){
        Log.d(TAG,"showTalentsList");
        this.anchorView = anchorView;
//        mTalentsPopupWindow.setData(mDatas);
////        mTalentsPopupWindow.refreshDataStatusView(false,!getTalentListSuccess,!(null != mDatas && mDatas.length > 0 && getTalentListSuccess));
//        //edit by Jagger 2018-5-21 ，修复 getTalentListSuccess = false时，空页和无数据页重复的问题
//        mTalentsPopupWindow.refreshDataStatusView(false,!getTalentListSuccess,null != mDatas && mDatas.length < 1 && getTalentListSuccess);
//        mTalentsPopupWindow.showAtLocation(anchorView, Gravity.BOTTOM,0,DisplayUtil.getNavigationBarHeight(mActivity));

        mFragmentManager = fragmentActivity.getSupportFragmentManager();
        TalentDialogFragment.showDialog(mFragmentManager , mRoomId , mAnchorAvatarURL, mAnchorNickName);
        TalentDialogFragment.setOnDialogEventListener(this);
    }

//    private void startOverTimeTimer(){
//        Log.d(TAG,"startOverTimeTimer");
//        stopOverTimeTimer();
//        if(null == timer){
//            timer = new Timer();
//            timerTask = new TimerTask() {
//                @Override
//                public void run() {
//                    Log.d(TAG,"startOverTimeTimer-超时，获取才艺邀请主播处理状态");
//                    getTalentStatus();
//                    stopOverTimeTimer();
//                }
//            };
//        }
//        timer.schedule(timerTask,REQUEST_CAN_NOT_SENT_TIME_DELAY);
//    }

//    private void stopOverTimeTimer(){
//        Log.d(TAG,"stopOverTimeTimer");
//        if(null != timer){
//            timerTask.cancel();
//            timerTask = null;
//            timer.cancel();
//            timer = null;
//        }
//    }

    /**
     * 才艺发送结果回调,会弹出相应提示
     */
    public void onTalentSent(final boolean result , final String errMsg, final IMClientListener.LCC_ERR_TYPE errType , final String talentInviteId , final String talentId){
        Log.d(TAG,"onTalentSent-result:"+result+" errMsg:"+errMsg);
//        if(null != mActivity && null != mActivity){
//            mActivity.runOnUiThread(new Runnable() {
//                @Override
//                public void run() {
//                    String msg = null;
                    if(result){
                        //本地记下邀请ID
//                        lastTalentNotResponedReqTime = System.currentTimeMillis();
//                        startOverTimeTimer();
                        mTempTalentInviteId = talentInviteId;

//                        //聊天控件插入成功提示
//                        String talentName = "";
//                        TalentInfoItem item = getTalentInfoItemById(talentId);
//                        if(item != null){
//                            talentName = item.talentName;
//                        }
//                        msg = mActivity.getString(R.string.live_talent_request_success , talentName);
//                        if(mActivity instanceof BaseCommonLiveRoomActivity){
//                            IMMessageItem msgItem = new IMMessageItem(((BaseCommonLiveRoomActivity) mActivity).mIMRoomInItem.roomId,
//                                    ((BaseCommonLiveRoomActivity) mActivity).mIMManager.mMsgIdIndex.getAndIncrement(),
//                                    "",
//                                    IMMessageItem.MessageType.SysNotice,
//                                    new IMSysNoticeMessageContent(msg,"", IMSysNoticeMessageContent.SysNoticeType.Normal));
//                            ((BaseCommonLiveRoomActivity) mActivity).sendMessageUpdateEvent(msgItem);
//                        }else{
//                        ToastUtil.showToast(mActivity, msg);
//                        }
                    }else{
                        //返回失败提示
                        Log.d(TAG,"onTalentSent-imReconnecting:"+imReconnecting);
////                        mRequestingTalent = null;
////                        mTempTalentInviteId = "";
//                        if(LCC_ERR_NO_CREDIT == errType){
//                            //信用点不足
//                            if(mActivity instanceof BaseCommonLiveRoomActivity){
//                                ((BaseCommonLiveRoomActivity) mActivity).
//                                        showCreditNoEnoughDialog(R.string.live_common_noenough_money_tips);
//                            }else{
//                        ToastUtil.showToast(mActivity, errMsg);
//                            }
//                        }else{
//                            //房间错误
////                            if(LCC_ERR_ROOM_CLOSE == errType || LCC_ERR_NOT_FOUND_ROOM == errType){
////                                msg = mActivity.getString(R.string.live_talent_request_failed_room_closing);
////                            }else{
////                                msg = mActivity.getString(R.string.live_talent_request_failed);
////                            }
//
//                            //其它错误使用服务器返回信息
//                            if(mActivity instanceof BaseFragmentActivity){
//                                ((BaseFragmentActivity) mActivity).
//                                        showToast(errMsg);
//                            }else{
//                        ToastUtil.showToast(mActivity, errMsg);
//                            }
//                        }
                    }
//                }
//            });
//        }
    }

    /**
     * 才艺请求被主播处理回调,会弹出相应提示
     */
    public boolean onTalentProcessed(final String talentId , final String talentName ,
                                  final double credit,
                                  final IMClientListener.TalentInviteStatus status,
                                  final String giftId, final String giftName, final int giftNum ,
                                  final String talentInviteId){
        Log.d(TAG,"onTalentProcessed-talentId:"+talentId+" talentName:"+talentName +" status:"+status);
//        if(null != mActivity ){
            TalentInviteItem inviteItem = new TalentInviteItem(
                    talentInviteId,
                    talentId,
                    talentName,
                    credit,
                    status.ordinal(),
                    giftId,
                    giftName,
                    giftNum
                    );
            return doShowTalentMsg(inviteItem);
//        }
    }

    /**
     * 获取才艺点状态
     */
    public void getTalentStatus(){
//        long timeDelay = System.currentTimeMillis() - lastTalentNotResponedReqTime;
//        Log.d(TAG,"getTalentStatus-lastTalentNotResponedReqTime:"+lastTalentNotResponedReqTime+" timeDelay:"+timeDelay);
        //如果是发送过请求，才去获取
//        if(mRequestingTalent != null && timeDelay>=REQUEST_CAN_NOT_SENT_TIME_DELAY){
        //本地是否有邀请信息
        if(!TextUtils.isEmpty(mTempTalentInviteId)){
            LiveRequestOperator.getInstance().GetTalentInviteStatus(mRoomId, mTempTalentInviteId,
                    new OnGetTalentInviteStatusCallback() {
                @Override
                public void onGetTalentInviteStatus(boolean isSuccess, int errCode,
                                                    String errMsg, TalentInviteItem inviteItem) {
                    Log.d(TAG,"getTalentStatus-onGetTalentInviteStatus isSuccess:"+isSuccess
                            +" errCode:"+errCode+" errMsg:"+errMsg+" inviteItem:"+inviteItem);
                    //如果已被主播处理了
                    if(isSuccess && inviteItem.inviteStatus != TalentInviteItem.TalentInviteStatus.NoReplied){
                        doShowTalentMsg(inviteItem);
                    }
                }
            });
        }
    }

    /**
     * 界面显示才艺处理结果
     */
    private boolean doShowTalentMsg(TalentInviteItem inviteItem){
//        if(mActivity instanceof BaseCommonLiveRoomActivity && inviteItem.talentInviteId.equals(mTempTalentInviteId)) {
//            String msg = null;
//            IMRoomInItem currIMRoomInItem = ((BaseCommonLiveRoomActivity) mActivity).mIMRoomInItem;
//            String nickName = currIMRoomInItem.nickName;
//            if(inviteItem.inviteStatus == TalentInviteItem.TalentInviteStatus.Accept){
//                msg = mActivity.getString(R.string.live_talent_accepted , nickName ,inviteItem.name);
//
//                //add by Jagger 2018-5-31 需求增加同时播放大礼物
//                IMMessageItem msgGiftItem = new IMMessageItem(currIMRoomInItem.roomId,
//                        ((BaseCommonLiveRoomActivity) mActivity).mIMManager.mMsgIdIndex.getAndIncrement(),
//                        "",
//                        "",
//                        "",
//                        0,
//                        IMMessageItem.MessageType.Gift,
//                        null,
//                        new IMGiftMessageContent(inviteItem.giftId , "" , inviteItem.giftNum , false , -1 , -1, -1 )
//                );
//                ((BaseCommonLiveRoomActivity) mActivity).sendMessageShowGiftEvent(msgGiftItem);
//            }else if(inviteItem.inviteStatus == TalentInviteItem.TalentInviteStatus.Denied){
//                msg = mActivity.getString(R.string.live_talent_declined , nickName ,inviteItem.name);
//            }
//            if(!TextUtils.isEmpty(msg)){
//                IMMessageItem msgItem = new IMMessageItem(currIMRoomInItem.roomId,
//                        ((BaseCommonLiveRoomActivity) mActivity).mIMManager.mMsgIdIndex.getAndIncrement(),
//                        "",
//                        IMMessageItem.MessageType.SysNotice,
//                        new IMSysNoticeMessageContent(msg,"", IMSysNoticeMessageContent.SysNoticeType.Normal));
//                ((BaseCommonLiveRoomActivity) mActivity).sendMessageUpdateEvent(msgItem);
//            }
//        }

        boolean canShow = false;
        if(inviteItem.talentInviteId.equals(mTempTalentInviteId)){
            canShow = true;
        }
        doCleanTempTalent();
        return canShow;
    }

    /**
     * 清空本地才艺邀请信息
     */
    private void doCleanTempTalent(){
//        mRequestingTalent = null;
        mTempTalentInviteId = "";
    }

    @Override
    public void onRequestClicked(TalentInfoItem talent) {
//        if(mActivity instanceof BaseCommonLiveRoomActivity){
//            double currCredits = ((BaseCommonLiveRoomActivity)mActivity).mLiveRoomCreditRebateManager.getCredit();
//            if(currCredits<talent.talentCredit){
//                ((BaseCommonLiveRoomActivity) mActivity).
//                showCreditNoEnoughDialog(R.string.live_common_noenough_money_tips);
//                return;
//            }
//        }
//        long timeDelay = System.currentTimeMillis() - lastTalentNotResponedReqTime;
//        Log.d(TAG,"onRequestClicked-talent.talentId:"+talent.talentId+" timeDelay:"+ timeDelay
//                +" lastTalentNotResponedReqTime:"+lastTalentNotResponedReqTime);
//        if(timeDelay>=REQUEST_CAN_NOT_SENT_TIME_DELAY){
//            //弹出确认对话框
////            showTalentConfirmDialog(talent);

            //通知外部发送请求
            sendConfirm(talent);
//        }else{
//            if(null != mActivity && null != mActivity){
//                if(mActivity instanceof BaseCommonLiveRoomActivity){
//                    ((BaseCommonLiveRoomActivity)mActivity).showThreeSecondTips(
//                            mActivity.getResources().getString(R.string.live_talent_request_wait),Gravity.CENTER);
//                }else{
//        ToastUtil.showToast(mActivity, R.string.live_talent_request_wait);
//                }
//            }
//        }

    }

//    private void showTalentConfirmDialog(final TalentInfoItem talent){
//        Log.d(TAG,"showTalentConfirmDialog-talent:"+talent);
////        if(null == talentConfirmDialog){
//            TalentConfirmDialog talentConfirmDialog = new TalentConfirmDialog(mActivity);
//            talentConfirmDialog.setOnConfirmListener(new TalentConfirmDialog.OnConfirmRequestTalentListener() {
//                @Override
//                public void onTalentConfirmRequest(boolean isConfirm, TalentInfoItem talentInfoItem) {
//                    Log.d(TAG,"showTalentConfirmDialog-onTalentConfirmRequest talentInfoItem:"+talentInfoItem);
//                    if(isConfirm){
////                        if(mOnRequestConfirmListener != null){
////                            mOnRequestConfirmListener.onConfirm(talentInfoItem);
////                        }
//                        if(mOnTalentEventListenerList != null && mOnTalentEventListenerList.size() > 0){
//                            for (onTalentEventListener listener: mOnTalentEventListenerList) {
//                                listener.onConfirm(talentInfoItem);
//                            }
//                        }
//                        //记下才艺
//                        mRequestingTalent = talentInfoItem;
////                        if(null != mTalentsPopupWindow){
////                            mTalentsPopupWindow.dismiss();
////                        }
//                    }
//
//                }
//            });
////        }
//        talentConfirmDialog.setTalentInfoItem(talent);
//        if(null != anchorView){
//            talentConfirmDialog.show();
//        }
//    }

    /**
     * 通知外部发送请求
     * @param talent
     */
    private void sendConfirm(final TalentInfoItem talent){
//        if(mOnRequestConfirmListener != null){
//            mOnRequestConfirmListener.onConfirm(talent);
//        }
        if(mOnTalentEventListenerList != null && mOnTalentEventListenerList.size() > 0){
            for (onTalentEventListener listener: mOnTalentEventListenerList) {
                listener.onConfirm(talent);
            }
        }
//        //记下才艺
//        mRequestingTalent = talent;

        //关闭弹出框
//        FragmentManager fragmentManager = mActivity.getSupportFragmentManager();
        if(mFragmentManager != null){
            TalentDialogFragment.dismissDialog(mFragmentManager);
            mFragmentManager = null;
        }
    }

    /**
     * 找出缓存中ID匹配的才艺
     * @param talentId
     * @return
     */
    public TalentInfoItem getTalentInfoItemById(String talentId){
        TalentInfoItem talentInfoItem = null;
        TalentInfoItem[] talentList = (TalentInfoItem[])httpRespObjectTalentList.data;
        for (TalentInfoItem item: talentList) {
            if(item.talentId.equals(talentId)){
                talentInfoItem = item;
                break;
            }
        }
        return talentInfoItem;
    }
}
