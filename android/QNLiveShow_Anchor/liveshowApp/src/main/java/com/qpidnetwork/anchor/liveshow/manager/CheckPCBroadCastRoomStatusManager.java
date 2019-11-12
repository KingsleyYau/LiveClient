package com.qpidnetwork.anchor.liveshow.manager;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.text.TextUtils;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.OnGetCurrentRoomInfoCallback;
import com.qpidnetwork.anchor.httprequest.item.LiveRoomType;
import com.qpidnetwork.anchor.httprequest.item.LoginItem;
import com.qpidnetwork.anchor.httprequest.item.PushRoomInfoItem;
import com.qpidnetwork.anchor.im.IMInviteLaunchEventListener;
import com.qpidnetwork.anchor.im.IMLiveRoomEventListener;
import com.qpidnetwork.anchor.im.IMManager;
import com.qpidnetwork.anchor.im.IMOtherEventListener;
import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMInviteListItem;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;
import com.qpidnetwork.anchor.im.listener.IMRoomInItem;
import com.qpidnetwork.anchor.im.listener.IMSendInviteInfoItem;
import com.qpidnetwork.anchor.liveshow.LiveApplication;
import com.qpidnetwork.anchor.liveshow.authorization.LoginManager;
import com.qpidnetwork.anchor.liveshow.authorization.interfaces.IAuthorizationListener;
import com.qpidnetwork.anchor.liveshow.liveroom.LiveRoomTransitionActivity;
import com.qpidnetwork.anchor.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Hardy on 2019/11/11.
 * 主播端——直播间多终端在线检测管理类
 */
public class CheckPCBroadCastRoomStatusManager implements OnGetCurrentRoomInfoCallback, IAuthorizationListener,
        IMOtherEventListener, IMInviteLaunchEventListener, IMLiveRoomEventListener {

    private static final int RESP_CODE_GET_CUR_ROOM_INFO = 11;
    private static final int RESP_CODE_ROOM_VIEW_HIDE = 12;
    private static final int RESP_CODE_ROOM_VIEW_OPEN = 13;

    private static CheckPCBroadCastRoomStatusManager instance;

    private Context context;
    private Handler mUIHandler;

    private PushRoomInfoItem mCurRoomInfo;
    private List<OnCheckRoomStatusChangeListener> mOnCheckRoomStatusChangeListenerList;

    // 记录是否正在请求查询当前直播间信息接口
    private boolean isGetRoomInfoRequest;

    public static CheckPCBroadCastRoomStatusManager getInstance() {
        if (instance == null) {
            instance = new CheckPCBroadCastRoomStatusManager(LiveApplication.getContext());
        }

        return instance;
    }

    public CheckPCBroadCastRoomStatusManager(Context context) {
        this.context = context.getApplicationContext();

        mOnCheckRoomStatusChangeListenerList = new ArrayList<>();

        mUIHandler = new Handler(Looper.getMainLooper()) {
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);

                HttpRespObject respObject = (HttpRespObject) msg.obj;
                switch (msg.what) {
                    case RESP_CODE_GET_CUR_ROOM_INFO: {
                        if (respObject.isSuccess) {
                            mCurRoomInfo = (PushRoomInfoItem) respObject.data;
                        } else {
                            mCurRoomInfo = null;
                        }

                        handlerGetRoomItemInfo();

                        isGetRoomInfoRequest = false;
                    }
                    break;

                    case RESP_CODE_ROOM_VIEW_HIDE: {
                        handlerListenerHide();
                    }
                    break;

                    case RESP_CODE_ROOM_VIEW_OPEN: {
                        getCurRoomInfo();
                    }
                    break;

                    default:
                        break;
                }
            }
        };
    }

    /**
     * PC 是否开启直播间
     */
    private boolean hasCurRoomInfo() {
        return mCurRoomInfo != null && !TextUtils.isEmpty(mCurRoomInfo.roomId);
    }

    /**
     * 是否为公开直播间
     */
    private boolean isPublicRoom() {
        if (mCurRoomInfo != null && mCurRoomInfo.roomType != null) {
            return mCurRoomInfo.roomType == LiveRoomType.FreePublicRoom ||
                    mCurRoomInfo.roomType == LiveRoomType.PaidPublicRoom;
        }
        return false;
    }

    /**
     * 是否为私密直播间
     */
    private boolean isPrivateRoom() {
        if (mCurRoomInfo != null && mCurRoomInfo.roomType != null) {
            return mCurRoomInfo.roomType == LiveRoomType.AdvancedPrivateRoom ||
                    mCurRoomInfo.roomType == LiveRoomType.NormalPrivateRoom;
        }
        return false;
    }

    /**
     * 清理数据
     */
    private void clearData() {
        mCurRoomInfo = null;

        isGetRoomInfoRequest = false;

        mOnCheckRoomStatusChangeListenerList.clear();
    }

    /**
     * 根据当前直播间信息，处理回调外层
     */
    private void handlerGetRoomItemInfo() {
        if (hasCurRoomInfo()) {
            if (isPublicRoom() || isPrivateRoom()) {
                String desc;

                if (isPublicRoom()) {
                    desc = context.getString(R.string.main_broadcast_item_public_broadcast_desc);
                } else {
                    String nickName = mCurRoomInfo.userInfo != null ? mCurRoomInfo.userInfo.nickName : "";
                    desc = context.getString(R.string.main_broadcast_item_private_broadcast_desc, nickName);
                }

                handlerListenerOpen(desc);
            }
        } else {
            handlerListenerHide();
        }
    }

    private boolean addListener(OnCheckRoomStatusChangeListener listener) {
        boolean result = false;

        synchronized (mOnCheckRoomStatusChangeListenerList) {
            if (null != listener) {
                boolean isExist = false;

                for (OnCheckRoomStatusChangeListener theListener : mOnCheckRoomStatusChangeListenerList) {
                    if (theListener == listener) {
                        isExist = true;
                        break;
                    }
                }

                if (!isExist) {
                    result = mOnCheckRoomStatusChangeListenerList.add(listener);
                }
            }
        }

        return result;
    }

    public void register(OnCheckRoomStatusChangeListener listener) {
        addListener(listener);

        LoginManager.getInstance().addListener(this);

        IMManager.getInstance().registerIMInviteLaunchEventListener(this);
        IMManager.getInstance().registerIMLiveRoomEventListener(this);
        IMManager.getInstance().registerIMOtherEventListener(this);
    }

    public void unRegister() {
        LoginManager.getInstance().removeListener(this);

        IMManager.getInstance().unregisterIMInviteLaunchEventListener(this);
        IMManager.getInstance().unregisterIMLiveRoomEventListener(this);
        IMManager.getInstance().unregisterIMOtherEventListener(this);

        // 清理数据
        clearData();
    }

    public void handlerClickEvent(Context context) {
        if (hasCurRoomInfo()) {
            if (isPrivateRoom()) {
                String userId = mCurRoomInfo.userInfo != null ? mCurRoomInfo.userInfo.userId : "";
                String userName = mCurRoomInfo.userInfo != null ? mCurRoomInfo.userInfo.nickName : "";
                String userUrl = mCurRoomInfo.userInfo != null ? mCurRoomInfo.userInfo.photoUrl : "";

                LiveRoomTransitionActivity.startNormalLiveRoom(context, mCurRoomInfo.roomId, userId, userName, userUrl);
            } else if (isPublicRoom()) {
                handlerListenerPublicRoomPreview();
            }
        }
    }

    //*********************************  interface  ****************************************
    private void handlerListenerOpen(String desc) {
        for (OnCheckRoomStatusChangeListener listener : mOnCheckRoomStatusChangeListenerList) {
            listener.onOpen(desc);
        }
    }

    private void handlerListenerHide() {
        for (OnCheckRoomStatusChangeListener listener : mOnCheckRoomStatusChangeListenerList) {
            listener.onHide();
        }
    }

    private void handlerListenerPublicRoomPreview() {
        for (OnCheckRoomStatusChangeListener listener : mOnCheckRoomStatusChangeListenerList) {
            listener.onPublicRoomPreview();
        }
    }

    public interface OnCheckRoomStatusChangeListener {
        void onOpen(String desc);

        void onHide();

        void onPublicRoomPreview();
    }

    private void LogMsg(String val) {
        Log.i("info", "-------------- " + val + " ------------------");
    }

    //*********************************  主动查询当前直播间信息  ****************************************

    /**
     * 主动查询当前直播间信息
     */
    public void getCurRoomInfo() {
        if (isGetRoomInfoRequest) {
            return;
        }

        isGetRoomInfoRequest = true;

        LiveRequestOperator.getInstance().GetCurrentRoomInfo(this);
    }

    @Override
    public void onGetCurrentRoomInfo(boolean isSuccess, int errCode, String errMsg, PushRoomInfoItem pushItem) {
        LogMsg("onGetCurrentRoomInfo");

        HttpRespObject respObject = new HttpRespObject(isSuccess, errCode, errMsg, pushItem);
        Message message = Message.obtain();
        message.what = RESP_CODE_GET_CUR_ROOM_INFO;
        message.obj = respObject;
        mUIHandler.sendMessage(message);
    }

    //*********************************  HTTP 接收 登录/退出登录 通知  ****************************************
    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

    }

    @Override
    public void onLogout(boolean isMannual) {
        LogMsg("http onLogout");

        sendMessageHide();
    }

    //*********************************  IM 接收 PC 进入直播间通知  ****************************************
    @Override
    public void OnRoomIn(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMRoomInItem roomInfo) {
        if (success) {
            LogMsg("OnRoomIn");
            sendMessageOpen();
        }
    }

    @Override
    public void OnRoomOut(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnAnchorSwitchFlow(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String[] pushUrl, IMClientListener.IMDeviceType deviceType) {

    }

    @Override
    public void OnSendImmediatePrivateInvite(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMSendInviteInfoItem inviteInfoItem) {

    }

    @Override
    public void OnRecvInviteReply(String inviteId, IMClientListener.InviteReplyType replyType, String roomId, LiveRoomType roomType, String anchorId, String nickName, String avatarImg) {

    }

    @Override
    public void OnGetInviteInfo(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMInviteListItem inviteItem) {

    }

    //*********************************  IM 接收 断线重连 通知  ****************************************
    @Override
    public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        if (errType == IMClientListener.LCC_ERR_TYPE.LCC_ERR_SUCCESS) {
            LogMsg("IM OnLogin");
            sendMessageOpen();
        }
    }

    @Override
    public void OnLogout(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnKickOff(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvAnchoeInviteNotify(String userId, String nickname, String photoUrl, String invitationId) {

    }

    @Override
    public void OnRecvBookingNotice(String roomId, String userId, String nickName, String avatarImg, int leftSeconds) {

    }

    //*********************************  IM 接收 PC 关闭直播间通知  ****************************************

    @Override
    public void OnRecvRoomCloseNotice(String roomId, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        LogMsg("OnRecvRoomCloseNotice");
        // 3.4.直播间关闭通知
        sendMessageHide();
    }

    @Override
    public void OnRecvRoomKickoffNotice(String roomId, IMClientListener.LCC_ERR_TYPE err, String errMsg) {
        LogMsg("OnRecvRoomKickoffNotice");
        // 3.5.接收踢出直播间通知
        sendMessageHide();
    }

    @Override
    public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl, String riderId, String riderName, String riderUrl, int fansNum, boolean isHasTicket) {
        LogMsg("OnRecvEnterRoomNotice");
    }

    @Override
    public void OnRecvLeaveRoomNotice(String roomId, String userId, String nickName, String photoUrl, int fansNum) {
        LogMsg("OnRecvLeaveRoomNotice");
    }

    @Override
    public void OnRecvLeavingPublicRoomNotice(String roomId, int leftSeconds, IMClientListener.LCC_ERR_TYPE err, String errMsg) {
        LogMsg("OnRecvLeavingPublicRoomNotice");
        // 3.8.接收关闭直播间倒数通知
        sendMessageHide();
    }

    @Override
    public void OnRecvAnchorLeaveRoomNotice(String roomId, String anchorId) {
        LogMsg("OnRecvAnchorLeaveRoomNotice");
        // 3.9.接收主播退出直播间通知
        sendMessageHide();
    }

    @Override
    public void OnSendRoomMsg(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem) {

    }

    @Override
    public void OnRecvRoomMsg(IMMessageItem msgItem) {

    }

    @Override
    public void OnRecvSendSystemNotice(IMMessageItem msgItem) {

    }

    @Override
    public void OnSendGift(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem) {

    }

    @Override
    public void OnRecvRoomGiftNotice(IMMessageItem msgItem) {

    }

    @Override
    public void OnRecvRoomToastNotice(IMMessageItem msgItem) {

    }

    @Override
    public void OnRecvTalentRequestNotice(String talentInvitationId, String name, String userId, String nickName) {

    }

    @Override
    public void OnRecvInteractiveVideoNotice(String roomId, String userId, String nickname, String avatarImg, IMClientListener.IMVideoInteractiveOperateType operateType, String[] pushUrls) {

    }


    private void sendMessageHide() {
        Message message = Message.obtain();
        message.what = RESP_CODE_ROOM_VIEW_HIDE;
        mUIHandler.sendMessage(message);
    }

    private void sendMessageOpen() {
        Message message = Message.obtain();
        message.what = RESP_CODE_ROOM_VIEW_OPEN;
        mUIHandler.sendMessage(message);
    }
}
