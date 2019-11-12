package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetHangoutInvitStatusCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.OnSendInvitationHangoutCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniOther;
import com.qpidnetwork.livemodule.httprequest.item.HangoutInviteStatus;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.livemodule.httprequest.item.LSRequestEnum;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.im.IMHangoutEventListener;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.IMOtherEventListener;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMDealInviteItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutCountDownItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutInviteItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRecommendItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMLoveLeveItem;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvEnterRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvKnockRequestItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvLeaveRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.StringUtil;
import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * Hangout 邀请流程抽取
 */
public class HangoutInvitationManager implements IMHangoutEventListener, IMOtherEventListener {

    private static final String TAG = HangoutInvitationManager.class.getName();

    private final int EVENT_SEND_INVITATION_CALLBACK = 1;
    private final int EVENT_ANSWER_INVITATION_CALLBACK = 2;
    private final int EVENT_INVITE_TIMEOUT = 3;
    private final int EVENET_NETWORK_ERROR_RECONNECTED = 4;
    private final int EVENT_CHECK_INVITE_STATUS = 5;
    private final int EVENT_CANCEL_INVITATION_CALLBACK = 6;

    private final int INVITE_TIMEOUT_INTERVAL = 3 * 60 * 1000;
    private final int ARCH_NAME_MAX_LENGHT = 8;

    private IMManager mIMManager;
    private IMUserBaseInfoItem mAnchorInfo;
    private InvitationItem mInvitationItem;
    private Context mContext;
    private Handler mHandler;

    private OnHangoutInvitationEventListener mOnHangoutInvitationEventListener;     //时间监听器

    @SuppressLint("HandlerLeak")
    private HangoutInvitationManager(Context context){
        mIMManager = IMManager.getInstance();
        registerIMListener();
        this.mContext = context;
        mHandler = new Handler(){
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                Log.i(TAG, "handleMessage msg.what: " + msg.what);
                switch (msg.what){
                    case EVENT_SEND_INVITATION_CALLBACK:{
                        HttpRespObject respObject = (HttpRespObject)msg.obj;
                        if(respObject.isSuccess){
                            //发送邀请成功
                            InvitationItem item = (InvitationItem)respObject.data;
                            if(item != null && !TextUtils.isEmpty(item.roomId)){
                                //邀请流程结束（主播敲门中，服务器处理自动应邀）
                                onHangoutInvitationFinish(true, HangoutInvationErrorType.Unknown, "", item.roomId);
                            }else{
                                //邀请发送成功，等待主播回复
                                mInvitationItem = item;
                                //通知邀请开始
                                onInvitaionStartNotify();
                                //设置邀请超时定时器
                                mHandler.sendEmptyMessageDelayed(EVENT_INVITE_TIMEOUT, INVITE_TIMEOUT_INTERVAL);
                            }

                            if(msg.arg1 == 1 && item != null && mAnchorInfo != null) {
                                //冒泡提交统计
                                LoginItem loginItem = LoginManager.getInstance().getLoginItem();
                                //冒泡进入，统计事件
                                String manId = "";
                                if(loginItem != null){
                                    manId = loginItem.userId;
                                }
                                RequestJniOther.UpQnInviteId(manId, mAnchorInfo.userId, item.inviteId, item.roomId, LSRequestEnum.LSBubblingInviteType.Hangout, new OnRequestCallback() {
                                    @Override
                                    public void onRequest(boolean isSuccess, int errCode, String errMsg) {

                                    }
                                });
                            }
                        }else{
                            //发送邀请失败
                            onHttpError(respObject.errCode, respObject.errMsg);
                        }
                    }break;
                    case EVENT_ANSWER_INVITATION_CALLBACK:{
                        //主播应邀处理
                        if(isInviting()) {
                            IMDealInviteItem item = (IMDealInviteItem) msg.obj;
                            onRecvDealInvitation(item);
                        }
                    }break;

                    case EVENT_INVITE_TIMEOUT:{
                        //邀请等候超时
                        if(isInviting()) {
                            String message = String.format(mContext.getResources().getString(R.string.hangout_transition_reject_or_timeout), StringUtil.truncateName(mAnchorInfo.nickName, ARCH_NAME_MAX_LENGHT));
                            onHangoutInvitationFinish(false, HangoutInvationErrorType.InviteDeny, message, "");
                        }
                    }break;
                    case EVENET_NETWORK_ERROR_RECONNECTED:{
                        //网络异常，断线重连成功，检查等待中的邀请状态
                        if(isInviting()){
                            checkInviteStatus(mInvitationItem.inviteId);
                        }
                    }break;
                    case EVENT_CHECK_INVITE_STATUS:{
                        //邀请中断线，同步邀请状态返回
                        HttpRespObject respObject = (HttpRespObject)msg.obj;
                        if(respObject.isSuccess){
                            //检测状态返回成功
                            InvitationItem item = (InvitationItem)respObject.data;
                            if(item != null && mInvitationItem != null && mInvitationItem.inviteId.equals(item.inviteId)) {
                                onCheckInviteStatus(item);
                            }
                        }
                    }break;
                    case EVENT_CANCEL_INVITATION_CALLBACK: {
                        HttpRespObject respObject = (HttpRespObject) msg.obj;
                        String invitationId = (String) respObject.data;
                        if ( !TextUtils.isEmpty(invitationId) && mInvitationItem != null && mInvitationItem.inviteId.equals(invitationId)) {
                            onCancelInvitation(respObject);
                        }
                    }break;
                }
            }
        };
    }

    public static HangoutInvitationManager createInvitationClient(Context context){
        HangoutInvitationManager manager = new HangoutInvitationManager(context);
        return manager;
    }

    /***
     * 启动处理一个邀请中的邀请任务
     * @param anchorInfo
     * @return
     */
    public void startInvitationByInvitationStatus(IMUserBaseInfoItem anchorInfo, String invitationId){
        mAnchorInfo = anchorInfo;
        mInvitationItem = new InvitationItem("", invitationId, 0, HangoutInviteStatus.Penging);
    }

    /**
     * 发起多人互动邀请
     * @param anchorInfo 多人互动主播信息
     * @param roomId   当前所在直播间ID
     * @param recommandId   推荐ID
     * @param createOnly
     * @param isBubble  是否冒泡发起
     */
    public void startInvitationSession(final IMUserBaseInfoItem anchorInfo, String roomId, String recommandId, boolean createOnly, final boolean isBubble){
        if(anchorInfo != null) {
            mAnchorInfo = anchorInfo;
            Log.i(TAG, "startInvitationSession userId: " + anchorInfo.userId + "  nickname: " + anchorInfo.nickName + "  photoUrl: " + anchorInfo.photoUrl + " roomId: " + roomId + "  recommandId: " + recommandId + " createOnly: " + createOnly);
            if(checkPhoneSystem()) {
                clearLocalData();
                Log.i(TAG, "SendInvitationHangout userId: " + anchorInfo.userId);
                LiveRequestOperator.getInstance().SendInvitationHangout(roomId, anchorInfo.userId, recommandId, createOnly, new OnSendInvitationHangoutCallback() {
                    @Override
                    public void onSendInvitationHangout(boolean isSuccess, int errCode, String errMsg, String roomId, String inviteId, int expire) {
                        Message msg = Message.obtain();
                        msg.what = EVENT_SEND_INVITATION_CALLBACK;
                        msg.arg1 = isBubble?1:0;
                        msg.obj = new HttpRespObject(isSuccess, errCode, errMsg, new InvitationItem(roomId, inviteId, expire, HangoutInviteStatus.Unknown));
                        mHandler.sendMessage(msg);
                    }
                });
            }
        }
    }

    /**
     * 停掉邀请逻辑
     */
    public void stopInvite(){
        if(mAnchorInfo != null) {
            Log.i(TAG, "stopInvite userId: " + mAnchorInfo.userId);
        }
        if(mInvitationItem != null){
            if(!TextUtils.isEmpty(mInvitationItem.inviteId)) {
                cancelHangoutInvitation(mInvitationItem.inviteId);
            }
        }
    }

    /**
     * 释放资源
     */
    public void release(){
        if(mAnchorInfo != null){
            Log.i(TAG, "release userId: " + mAnchorInfo.userId);
        }
        //重置回调，防止release由于http请求导致继续回调
        mOnHangoutInvitationEventListener = null;
        unregisterIMListener();
        clearLocalData();
    }

    public void setClientEventListener(OnHangoutInvitationEventListener listener){
        mOnHangoutInvitationEventListener = listener;
    }

    private void registerIMListener(){
        if(mIMManager != null){
            mIMManager.registerIMHangoutEventListener(this);
            mIMManager.registerIMOtherEventListener(this);
        }
    }

    /**
     * 取消事件监听
     */
    private void unregisterIMListener(){
        if(mIMManager != null){
            mIMManager.unregisterIMHangoutEventListener(this);
            mIMManager.unregisterIMOtherEventListener(this);
        }
    }

    /**
     * 是否邀请等待返回中
     * @return
     */
    private boolean isInviting(){
        return mInvitationItem != null;
    }

    /**
     * 清除本地所有数据状态
     */
    private void clearLocalData(){
        stopInvite();
        mInvitationItem = null;
        if(mHandler != null) {
            mHandler.removeCallbacksAndMessages(null);
        }
    }

    /**
     * 检测邀请状态
     * @param inviteId
     */
    private void checkInviteStatus(final String inviteId){
        Log.i(TAG, "checkInviteStatus userId: " + mAnchorInfo.userId + " inviteId: " + inviteId);
        mIMManager.checkInviteStatus(inviteId, mAnchorInfo, new OnGetHangoutInvitStatusCallback() {
            @Override
            public void onGetHangoutInvitStatus(boolean isSuccess, int errCode, String errMsg, int status, String roomId, int expire) {
                Message msg = Message.obtain();
                msg.what = EVENT_CHECK_INVITE_STATUS;
                msg.obj = new HttpRespObject(isSuccess, errCode, errMsg, new InvitationItem(roomId, inviteId, expire, IntToEnumUtils.intToHangoutInviteStatus(status)));
                mHandler.sendMessage(msg);
            }
        });
    }

    /**
     * 检测系统是否满足dpi不小于720且系统高于5.0
     * @return
     */
    private boolean checkPhoneSystem(){
        boolean isValid = false;
        if(!DisplayUtil.checkWhetherDpiHigh720(mContext)){
            String message = mContext.getResources().getString(R.string.hangout_system_low_dpi);
            onHangoutInvitationFinish(false, HangoutInvationErrorType.NormalError, message, "");
        }else if(!(android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP)){
            String message = mContext.getResources().getString(R.string.hangout_system_low_lollipop);
            onHangoutInvitationFinish(false, HangoutInvationErrorType.NormalError, message, "");
        }else{
            isValid = true;
        }
        return isValid;
    }


    /**
     * 统一处理http error
     * @param errCode
     * @param errMsg
     */
    private void onHttpError(int errCode, String errMsg){
        HangoutInvationErrorType hangoutInvationErrorType = HangoutInvationErrorType.NormalError;
        String message = errMsg;
        HttpLccErrType httpLccErrType = IntToEnumUtils.intToHttpErrorType(errCode);
        Log.i(TAG, "onHttpError httpLccErrType: " + httpLccErrType.name() + " errMsg: " + errMsg);
        switch (httpLccErrType){
            case HTTP_LCC_ERR_CONNECTFAIL:{
                //断网，可重新尝试
                hangoutInvationErrorType = HangoutInvationErrorType.ConnectFail;
            }break;
            case HTTP_LCC_ERR_NO_CREDIT:{
                //信用点不足
                message = String.format(mContext.getResources().getString(R.string.hangout_transition_add_credit), mAnchorInfo.nickName);
                hangoutInvationErrorType = HangoutInvationErrorType.NoCredit;
            }break;
            default:{
                hangoutInvationErrorType = HangoutInvationErrorType.NormalError;
            }break;
        }
        onHangoutInvitationFinish(false, hangoutInvationErrorType, message, "");
    }

    /**
     * 收到主播回复处理
     */
    private void onRecvDealInvitation(IMDealInviteItem item){
        HangoutInvationErrorType hangoutInvationErrorType = HangoutInvationErrorType.Unknown;
        Log.i(TAG, "onRecvDealInvitation IMAnchorReplyInviteType: " + item.type.name());
        boolean isSuccess = false;
        String message = "";
        switch (item.type){
            case Agree:{
                isSuccess = true;
            }break;
            case Reject:
            case OutTime:{
                message = String.format(mContext.getResources().getString(R.string.hangout_transition_reject_or_timeout), StringUtil.truncateName(mAnchorInfo.nickName, ARCH_NAME_MAX_LENGHT));
                hangoutInvationErrorType = HangoutInvationErrorType.InviteDeny;
            }break;
            case NoCredit:{
                message = String.format(mContext.getResources().getString(R.string.hangout_transition_add_credit), mAnchorInfo.nickName);
                hangoutInvationErrorType = HangoutInvationErrorType.NoCredit;
            }break;
            case Busy:{
                message = mContext.getResources().getString(R.string.hangout_anchor_busy);
                hangoutInvationErrorType = HangoutInvationErrorType.NormalError;
            }break;
        }
        onHangoutInvitationFinish(isSuccess, hangoutInvationErrorType, message, item.roomId);
    }

    /**
     * 检测邀请状态返回处理
     * @param item
     */
    private void onCheckInviteStatus(InvitationItem item){
        Log.i(TAG, "onCheckInviteStatus inviteStatus: " + item.inviteStatus.name());
        if(item.inviteStatus != HangoutInviteStatus.Penging) {
            //邀请已结束
            boolean isSuccess = false;
            String message = "";
            HangoutInvationErrorType hangoutInvationErrorType = HangoutInvationErrorType.Unknown;
            switch (item.inviteStatus) {
                case Busy: {
                    message = mContext.getResources().getString(R.string.hangout_anchor_busy);
                    hangoutInvationErrorType = HangoutInvationErrorType.NormalError;
                }
                break;
                case OutTime:
                case Reject:{
                    message = String.format(mContext.getResources().getString(R.string.hangout_transition_reject_or_timeout), StringUtil.truncateName(mAnchorInfo.nickName, ARCH_NAME_MAX_LENGHT));
                    hangoutInvationErrorType = HangoutInvationErrorType.InviteDeny;
                }break;
                case Cancle: {
                    message = String.format(mContext.getResources().getString(R.string.hangout_transition_reject_or_timeout), StringUtil.truncateName(mAnchorInfo.nickName, ARCH_NAME_MAX_LENGHT));
                    hangoutInvationErrorType = HangoutInvationErrorType.NormalError;
                }
                break;
                case NoCredit: {
                    message = String.format(mContext.getResources().getString(R.string.hangout_transition_add_credit), mAnchorInfo.nickName);
                    hangoutInvationErrorType = HangoutInvationErrorType.NoCredit;
                }
                break;
                case Accept: {
                    isSuccess = true;
                }
                break;
            }
            onHangoutInvitationFinish(isSuccess, hangoutInvationErrorType, message, item.roomId);
        }
    }

    /**
     * 取消邀请结果
     * @param httpRespObject
     */
    private void onCancelInvitation(HttpRespObject httpRespObject){
        Log.i(TAG, "onCheckInviteStatus inviteStatus: " + httpRespObject.isSuccess + ",errMsg:" + httpRespObject.errMsg);
        if(mOnHangoutInvitationEventListener != null){
            mOnHangoutInvitationEventListener.onHangoutCancel(httpRespObject.isSuccess, httpRespObject.errCode, httpRespObject.errMsg, mAnchorInfo);
        }
    }

    /**
     * 通知发送邀请成功
     */
    private void onInvitaionStartNotify(){
        Log.i(TAG, "onInvitaionStartNotify listener: " + mOnHangoutInvitationEventListener);
        if(mOnHangoutInvitationEventListener != null){
            mOnHangoutInvitationEventListener.onHangoutInvitationStart(mAnchorInfo);
        }
    }

    /**
     * 通知邀请发送结束
     * @param isSuccess
     * @param errorType
     * @param errMsg
     * @param roomId
     */
    private void onHangoutInvitationFinish(boolean isSuccess, HangoutInvationErrorType errorType, String errMsg, String roomId){
        Log.i(TAG, "onHangoutInvitationFinish isSuccess: " + isSuccess + " errorType: " + errorType.name() + " errMsg: " + errMsg + " roomId: " + roomId);
        if(!isSuccess) {
            clearLocalData();
        }else{
            mInvitationItem = null;
            if(mHandler != null){
                mHandler.removeCallbacksAndMessages(null);
            }
        }
        if(mOnHangoutInvitationEventListener != null){
            mOnHangoutInvitationEventListener.onHangoutInvitationFinish(isSuccess, errorType, errMsg, mAnchorInfo, roomId);
        }
    }

    /**
     *  取消hangout邀请
     */
    private void cancelHangoutInvitation(final String invitationId){
        Log.i(TAG, "cancelHangoutInvitation invitationId: " + invitationId);
        LiveRequestOperator.getInstance().CancelHangoutInvit(invitationId, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                HttpRespObject httpRespObject = new HttpRespObject(isSuccess, errCode, errMsg, invitationId);
                Message msg = Message.obtain();
                msg.what = EVENT_CANCEL_INVITATION_CALLBACK;
                msg.obj = httpRespObject;
                mHandler.sendMessage(msg);
            }
        });
    }

    /***********************************************   IM事件监听    ************************************************/
    @Override
    public void OnRecvRecommendHangoutNotice(IMHangoutRecommendItem item) {

    }

    @Override
    public void OnRecvDealInvitationHangoutNotice(IMDealInviteItem item) {
        Log.i(TAG, "OnRecvDealInvitationHangoutNotice anchorid: " + item.anchorId);
        if( item != null && !TextUtils.isEmpty(item.anchorId) && mAnchorInfo != null && item.anchorId.equals(mAnchorInfo.userId)) {
            Message msg = Message.obtain();
            msg.what = EVENT_ANSWER_INVITATION_CALLBACK;
            msg.obj = item;
            mHandler.sendMessage(msg);
        }
    }

    @Override
    public void OnEnterHangoutRoom(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMHangoutRoomItem item) {

    }

    @Override
    public void OnLeaveHangoutRoom(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvEnterHangoutRoomNotice(IMRecvEnterRoomItem item) {

    }

    @Override
    public void OnRecvLeaveHangoutRoomNotice(IMRecvLeaveRoomItem item) {

    }

    @Override
    public void OnSendHangoutGift(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem, double credit) {

    }

    @Override
    public void OnRecvHangoutGiftNotice(IMMessageItem item) {

    }

    @Override
    public void OnRecvKnockRequestNotice(IMRecvKnockRequestItem item) {

    }

    @Override
    public void OnRecvLackCreditHangoutNotice(IMRecvLeaveRoomItem item) {

    }

    @Override
    public void OnControlManPushHangout(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String[] manPushUrl) {

    }

    @Override
    public void OnSendHangoutRoomMsg(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem) {

    }

    @Override
    public void OnRecvHangoutRoomMsg(IMMessageItem item) {

    }

    @Override
    public void OnRecvAnchorCountDownEnterHangoutRoomNotice(IMHangoutCountDownItem item) {

    }

    @Override
    public void OnRecvHandoutInviteNotice(IMHangoutInviteItem item) {

    }

    @Override
    public void OnRecvHangoutCreditRunningOutNotice(String roomId, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        Log.i(TAG, "OnLogin errType: " + errType.name());
        if(errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS){
            //断线重连成功
            Message msg = Message.obtain();
            msg.what = EVENET_NETWORK_ERROR_RECONNECTED;
            mHandler.sendMessage(msg);
        }
    }

    @Override
    public void OnLogout(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnKickOff(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvLackOfCreditNotice(String roomId, String message, double credit, IMClientListener.LCC_ERR_TYPE err) {

    }

    @Override
    public void OnRecvCreditNotice(String roomId, double credit) {

    }

    @Override
    public void OnRecvAnchoeInviteNotify(String logId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {

    }

    @Override
    public void OnRecvScheduledInviteNotify(String inviteId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {

    }

    @Override
    public void OnRecvSendBookingReplyNotice(String inviteId, IMClientListener.BookInviteReplyType replyType) {

    }

    @Override
    public void OnRecvBookingNotice(String roomId, String userId, String nickName, String photoUrl, int leftSeconds) {

    }

    @Override
    public void OnRecvLevelUpNotice(int level) {

    }

    @Override
    public void OnRecvLoveLevelUpNotice(IMLoveLeveItem lovelevelItem) {

    }

    @Override
    public void OnRecvBackpackUpdateNotice(IMPackageUpdateItem item) {

    }

    private class InvitationItem{
        public String roomId;
        public String inviteId;
        public int expire;
        public HangoutInviteStatus inviteStatus;

        public InvitationItem(String roomId, String inviteId, int expire, HangoutInviteStatus status){
            this.roomId = roomId;
            this.inviteId = inviteId;
            this.expire = expire;
            this.inviteStatus = status;
        }
    }

    public interface OnHangoutInvitationEventListener{
        void onHangoutInvitationStart(IMUserBaseInfoItem userBaseInfoItem);
        void onHangoutInvitationFinish(boolean isSuccess, HangoutInvationErrorType errorType, String errMsg, IMUserBaseInfoItem userBaseInfoItem, String roomId);
        void onHangoutCancel(boolean isSuccess, int httpErrCode, String errMsg, IMUserBaseInfoItem userBaseInfoItem);
    }

    public enum HangoutInvationErrorType{
        Unknown,
        NormalError,
        ConnectFail,
        NoCredit,
        InviteDeny
    }
}
