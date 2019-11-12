package com.qpidnetwork.anchor.liveshow.liveroom;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.Window;

import com.qpidnetwork.anchor.bean.CommonConstant;
import com.qpidnetwork.anchor.framework.base.BaseFragmentActivity;
import com.qpidnetwork.anchor.httprequest.OnGetAudienceDetailInfoCallback;
import com.qpidnetwork.anchor.httprequest.OnGetAudienceListCallback;
import com.qpidnetwork.anchor.httprequest.OnGetGiftListCallback;
import com.qpidnetwork.anchor.httprequest.OnGetHangoutFriendRelationCallback;
import com.qpidnetwork.anchor.httprequest.OnGiftLimitNumListCallback;
import com.qpidnetwork.anchor.httprequest.OnHangoutGiftListCallback;
import com.qpidnetwork.anchor.httprequest.item.AnchorHangoutGiftListItem;
import com.qpidnetwork.anchor.httprequest.item.AnchorInfoItem;
import com.qpidnetwork.anchor.httprequest.item.AudienceBaseInfoItem;
import com.qpidnetwork.anchor.httprequest.item.AudienceInfoItem;
import com.qpidnetwork.anchor.httprequest.item.GiftItem;
import com.qpidnetwork.anchor.httprequest.item.GiftLimitNumItem;
import com.qpidnetwork.anchor.httprequest.item.LiveRoomType;
import com.qpidnetwork.anchor.httprequest.item.LoginItem;
import com.qpidnetwork.anchor.im.IMHangOutRoomEventListener;
import com.qpidnetwork.anchor.im.IMInviteLaunchEventListener;
import com.qpidnetwork.anchor.im.IMLiveRoomEventListener;
import com.qpidnetwork.anchor.im.IMManager;
import com.qpidnetwork.anchor.im.IMOtherEventListener;
import com.qpidnetwork.anchor.im.listener.IMClientListener;
import com.qpidnetwork.anchor.im.listener.IMDealInviteItem;
import com.qpidnetwork.anchor.im.listener.IMHangoutRecommendItem;
import com.qpidnetwork.anchor.im.listener.IMHangoutRoomItem;
import com.qpidnetwork.anchor.im.listener.IMInviteListItem;
import com.qpidnetwork.anchor.im.listener.IMKnockRequestItem;
import com.qpidnetwork.anchor.im.listener.IMMessageItem;
import com.qpidnetwork.anchor.im.listener.IMOtherInviteItem;
import com.qpidnetwork.anchor.im.listener.IMRecvEnterRoomItem;
import com.qpidnetwork.anchor.im.listener.IMRecvHangoutGiftItem;
import com.qpidnetwork.anchor.im.listener.IMRecvLeaveRoomItem;
import com.qpidnetwork.anchor.im.listener.IMRoomInItem;
import com.qpidnetwork.anchor.im.listener.IMSendInviteInfoItem;
import com.qpidnetwork.anchor.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.anchor.liveshow.authorization.LoginManager;
import com.qpidnetwork.anchor.liveshow.datacache.file.downloader.IFileDownloadedListener;
import com.qpidnetwork.anchor.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.anchor.liveshow.pushmanager.PushManager;
import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.view.SoftKeyboradListenFrameLayout;

/**
 * Description:直播间接口实现基类
 * 1.view层baseactivity或者业务层roomactivity需要重写该类响应的方法以实现对应的视图刷新/业务处理逻辑
 * 2.重点是封装视图业务层同底层的接口交互，从而使得上层各view模块只用关心自己对应的update method
 * <p>
 * Created by Harry on 2017/9/1.
 */

public class BaseImplLiveRoomActivity extends BaseFragmentActivity
        implements SoftKeyboradListenFrameLayout.InputWindowListener,
        IFileDownloadedListener, IMInviteLaunchEventListener,IMLiveRoomEventListener,
        IMOtherEventListener, IMHangOutRoomEventListener, OnGetAudienceListCallback, OnGetGiftListCallback,
        OnGiftLimitNumListCallback,OnGetAudienceDetailInfoCallback,OnHangoutGiftListCallback, OnGetHangoutFriendRelationCallback {

    public static final String LIVEROOM_ROOMINFO_ITEM = "roomInItem";
    public static final String HANGOUT_ROOMINFO_ITEM = "hangOutRoomItem";
    public static final String LIVEROOM_MAN_PHOTOURL = "manPhotoUrl";
    public static final String TRANSITION_USER_ID = "anchorId";
    public static final String LIVEROOM_MAN_NICKNAME = "manNickname";

    //数据及管理
    protected IMRoomInItem mIMRoomInItem;    //房间信息
    public IMHangoutRoomItem mIMHangOutRoomItem;    //房间信息
    //用于私密直播间结束页面男士头像显示
    protected String manPhotoUrl = null;
    protected String manUserId = null;
    protected String manNickName = "";
    protected int mRoomAudienceNum = 0;
    protected LoginItem loginItem = null;

    /**
     * 获取当前直播间类型
     * @return
     */
    public IMRoomInItem.IMLiveRoomType getCurrentRoomType(){
        IMRoomInItem.IMLiveRoomType roomType = null;
        if(null != mIMRoomInItem){
            roomType = mIMRoomInItem.roomType;
        }else if(null != mIMHangOutRoomItem){
            roomType = mIMHangOutRoomItem.roomType;
        }
        Log.d(TAG,"getCurrentRoomType-roomType:"+roomType);
        return roomType;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = BaseImplLiveRoomActivity.class.getSimpleName();
        //后绑定listener，防止未初始化完成收到通知异常
        initIMListener();
        initServiceConflicReceiver();
    }

    /**
     * 数据初始化
     */
    public void initData(){
        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(LIVEROOM_ROOMINFO_ITEM)){
                mIMRoomInItem = (IMRoomInItem)bundle.getSerializable(LIVEROOM_ROOMINFO_ITEM);
                Log.d(TAG,"initData-mIMRoomInItem:"+mIMRoomInItem);
            }

            if(bundle.containsKey(HANGOUT_ROOMINFO_ITEM)){
                mIMHangOutRoomItem = (IMHangoutRoomItem) bundle.getSerializable(HANGOUT_ROOMINFO_ITEM);
                Log.d(TAG,"initData-mIMHangOutRoomItem:"+mIMHangOutRoomItem);
            }
            if(bundle.containsKey(LIVEROOM_MAN_PHOTOURL)){
                manPhotoUrl = (String) bundle.getSerializable(LIVEROOM_MAN_PHOTOURL);
                Log.d(TAG,"initData-manPhotoUrl:"+manPhotoUrl);
            }
            if(bundle.containsKey(TRANSITION_USER_ID)){
                manUserId = (String) bundle.getSerializable(TRANSITION_USER_ID);
                Log.d(TAG,"initData-manUserId:"+manUserId);
            }
            if(bundle.containsKey(LIVEROOM_MAN_NICKNAME)){
                manNickName = (String) bundle.getSerializable(LIVEROOM_MAN_NICKNAME);
                Log.d(TAG,"initData-manNickName:"+manNickName);
            }
        }
        LoginManager loginManager = LoginManager.getInstance();
        if(null != loginManager){
            loginItem = loginManager.getLoginItem();
        }

        //直播间为节目时清除当前所有push消息
        if(mIMRoomInItem != null
                && mIMRoomInItem.liveShowType == IMRoomInItem.IMPublicRoomType.Program){
            PushManager.getInstance().CancelAll();
        }
    }

    /**
     * 注册服务冲突接收器
     */
    private void initServiceConflicReceiver(){
        //注册广播
        IntentFilter filter = new IntentFilter();
        filter.addAction(CommonConstant.ACTION_NOTIFICATION_SERVICE_CONFLICT_ACTION);
        registerReceiver(mServiceConfictReceiver, filter);
    }

    /**
     * 注销服务冲突接收器
     */
    public void unRegisterConfictReceiver(){
        //反注册被踢下线广播接收器
        if(mServiceConfictReceiver != null){
            unregisterReceiver(mServiceConfictReceiver);
            mServiceConfictReceiver = null;
        }
    }

    /**
     * 广播接收器
     */
    private BroadcastReceiver mServiceConfictReceiver = new BroadcastReceiver(){

        @Override
        public void onReceive(Context context, Intent intent) {
            if(intent.getAction().equals(CommonConstant.ACTION_NOTIFICATION_SERVICE_CONFLICT_ACTION)){
                String jumpUrl = "";
                Bundle bundle = intent.getExtras();
                //仅接受并处理服务冲突通知
                if(bundle != null && bundle.containsKey(CommonConstant.ACTION_NOTIFICATION_SERVICE_CONFLICT_JUMPURL)){
                    jumpUrl = bundle.getString(CommonConstant.ACTION_NOTIFICATION_SERVICE_CONFLICT_JUMPURL);
                }
                Log.d(TAG,"onReceive-jumpUrl:"+jumpUrl);
                //收到服务通知确认通知，退出直播间，跳转到主页
                onServiceConflictExitRoom(jumpUrl);
            }
        }

    };

    @Override
    protected void onDestroy() {
        super.onDestroy();
        clearIMListener();
        unRegisterConfictReceiver();
    }

    /**************************** 公共统一处理逻辑  *****************************************/

    /**
     * 收到服务冲突确认通知，执行退出直播间倒数，倒数完成进入直播间逻辑
     * @param url
     */
    private void onServiceConflictExitRoom(String url){
        Log.logD(TAG,"onServiceConflictExitRoom-url:"+url);
        URL2ActivityManager manager = URL2ActivityManager.getInstance();
        String roomId = "";
        String invitationId = "";
        IMUserBaseInfoItem userInfo = new IMUserBaseInfoItem();
        if(!TextUtils.isEmpty(url)){
            roomId = manager.getRoomIdByUrl(url);
            invitationId = manager.getInvitationIdByUrl(url);
            userInfo = manager.getUserBaseInfo(url);
        }
        if(!TextUtils.isEmpty(roomId)){
            //url中含有roomId则视为预约到期
            onScheduledInvitePushNotify(roomId, userInfo);
        }else if(!TextUtils.isEmpty(invitationId)){
            //url中含有invitationId则视为邀请
            if(manager.isHangOutRoom(url)){
                onManInvite2HangOutPushNotify(invitationId,userInfo);
            }else{
                onAudienceInvitePushNotify(invitationId, userInfo);
            }
        }
    }

    /**
     * 点击男士HangOut邀请push通知
     * @param invitationId
     * @param userInfo
     */
    protected void onManInvite2HangOutPushNotify(String invitationId, IMUserBaseInfoItem userInfo){
        Log.d(TAG,"onManInvite2HangOutPushNotify-roomId:"+invitationId+" userInfo:"+userInfo);
    }

    /**
     * 点击立即私密邀请push通知
     * @param invitationId
     * @param userInfo
     */
    protected void onAudienceInvitePushNotify(String invitationId, IMUserBaseInfoItem userInfo){
        Log.d(TAG,"onAudienceInvitePushNotify-roomId:"+invitationId+" userInfo:"+userInfo);
    }

    /**
     * 点击预约到期push通知
     * @param roomId
     * @param userInfo
     */
    protected void onScheduledInvitePushNotify(String roomId, IMUserBaseInfoItem userInfo){
        Log.d(TAG,"onScheduledInvitePushNotify-roomId:"+roomId+" userInfo:"+userInfo);
    }

    /**
     * 房间人数改变通知,触发条件
     * 1.观众进入直播间
     * 2.观众离开直播间
     * 接受通知后查询头像列表，更新数据到界面上
     */
    protected void onRoomAudienceChangeUpdate(){
        Log.d(TAG,"onRoomAudienceChangeUpdate");
    }

    /**
     * 是否是当前房间
     * @param roomId
     * @return
     */
    protected boolean isCurrentRoom(String roomId){
        boolean isCurrent = false;
        if(null != mIMRoomInItem){
            Log.d(TAG,"isCurrentRoom-targetRoomId:"+roomId+" currRoomId:"+mIMRoomInItem.roomId);
            isCurrent = !TextUtils.isEmpty(mIMRoomInItem.roomId) && roomId.equals(mIMRoomInItem.roomId);
        }else if(null != mIMHangOutRoomItem){
            Log.d(TAG,"isCurrentRoom-targetRoomId:"+roomId+" currRoomId:"+mIMHangOutRoomItem.roomId);
            isCurrent = !TextUtils.isEmpty(mIMHangOutRoomItem.roomId) && roomId.equals(mIMHangOutRoomItem.roomId);
        }

        Log.d(TAG,"isCurrentRoom-isCurrent:"+isCurrent);
        return isCurrent;
    }

    //----------------------------------IM相关---------------------------------------
    public IMManager mIMManager;
    /**
     * 初始化IM底层相关
     */
    private void initIMListener(){
        mIMManager = IMManager.getInstance();
        mIMManager.registerIMInviteLaunchEventListener(this);
        mIMManager.registerIMLiveRoomEventListener(this);
        mIMManager.registerIMOtherEventListener(this);
        mIMManager.registerIMHangOutRoomEventListener(this);
    }

    /**
     * 清除IM底层类相关监听事件
     */
    public void clearIMListener(){
        mIMManager.unregisterIMInviteLaunchEventListener(this);
        mIMManager.unregisterIMLiveRoomEventListener(this);
        mIMManager.unregisterIMOtherEventListener(this);
        mIMManager.unregisterIMHangOutRoomEventListener(this);
    }

    //------------------点击事件-------------------------------
    @Override
    public void onClick(View v) {}

    //------------------软键盘监听、视图高度发生变化--------------
    @Override
    public void onSoftKeyboardShow() {}

    @Override
    public void onSoftKeyboardHide() {}

    //------------------图片文件等的下载监听--------------
    @Override
    public void onCompleted(boolean isSuccess, String localFilePath, String fileUrl) {}

    //------------------用户进入房间、退出房间、直播开始、发送私密邀请、取消私密邀请、邀请响应--------------
    @Override
    public void OnRoomIn(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType,
                         String errMsg, final IMRoomInItem roomInfo) {
        Log.d(TAG,"OnRoomIn-reqId:"+reqId+" success:"+success+" errType:"+errType+" errMsg:"
                +roomInfo+" roomInfo:"+roomInfo);
        if(success){
            mIMRoomInItem = roomInfo;
        }
    }

    @Override
    public void OnRoomOut(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType,
                          String errMsg) {
        Log.d(TAG,"OnFansRoomOut-reqId:"+reqId+" success:"+success+" errType:"+errType+" errMsg:"+errMsg);
    }

    @Override
    public void OnAnchorSwitchFlow(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String[] pushUrl, IMClientListener.IMDeviceType deviceType) {

    }

    @Override
    public void OnSendImmediatePrivateInvite(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMSendInviteInfoItem inviteInfoItem) {
        Log.d(TAG,"OnSendImmediatePrivateInvite-reqId:"+reqId+" success:"+success
                +" errType:"+errType+" errMsg:"+errMsg+" invitationId:"+inviteInfoItem.inviteId+" timeout:"+inviteInfoItem.timeOut+" roomId:"+inviteInfoItem.roomId);
    }


    @Override
    public void OnGetInviteInfo(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType,
                                String errMsg, IMInviteListItem inviteItem) {
    }

//    @Override
//    public void OnSendImmediatePrivateInvite(int reqId, boolean success,
//                                             IMClientListener.LCC_ERR_TYPE errType, String errMsg,
//                                             String invitationId, int timeout, String roomId) {
//        Log.d(TAG,"OnSendImmediatePrivateInvite-reqId:"+reqId+" success:"+success
//                +" errType:"+errType+" errMsg:"+errMsg+" invitationId:"+invitationId+" timeout:"+timeout+" roomId:"+roomId);
//    }

    @Override
    public void OnRecvInviteReply(String inviteId, IMClientListener.InviteReplyType replyType,
                                  String roomId, LiveRoomType roomType, String userId,
                                  String nickName, String avatarImg) {
        Log.d(TAG,"OnRecvInviteReply-inviteId:"+inviteId +" replyType:"+replyType +" roomId:"+roomId
                +" roomType:"+roomType +" userId:"+userId +" nickName:"+nickName +" avatarImg:"+avatarImg);
    }

    //------------------直播间IM事件监听--------------
    @Override
    public void OnRecvRoomCloseNotice(String roomId, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        Log.d(TAG,"OnRecvRoomCloseNotice-roomId:"+roomId+" errType:"+errType+" errMsg:"+errMsg);
    }

    @Override
    public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl,
                                      String riderId, String riderName,
                                      String riderUrl, final int fansNum, boolean isHasTicket) {
        Log.d(TAG,"OnRecvEnterRoomNotice-roomId:"+roomId+" userId:"+userId
                +" nickName:"+nickName+" photoUrl:"+photoUrl+" riderId:"+riderId
                +" riderName:"+riderName+" riderUrl:"+riderUrl+" fansNum:"+fansNum+" isHasTicket:"+isHasTicket);
        mRoomAudienceNum = fansNum;
        onRoomAudienceChangeUpdate();
    }

    @Override
    public void OnRecvLeaveRoomNotice(String roomId, String userId, String nickName, String photoUrl, final int fansNum) {
        if(!isCurrentRoom(roomId)){
            return;
        }
        Log.d(TAG,"OnRecvLeaveRoomNotice-roomId:"+roomId+" userId:"+userId+" nickName:"+nickName+" photoUrl:"+photoUrl+" fansNum:"+fansNum);
        //更新房间人数，通知房间人数改变
        mRoomAudienceNum = fansNum;
        onRoomAudienceChangeUpdate();
    }

    @Override
    public void OnRecvLeavingPublicRoomNotice(String roomId, int leftSeconds, IMClientListener.LCC_ERR_TYPE err,
                                              String errMsg) {
        Log.d(TAG,"OnRecvLeavingPublicRoomNotice-roomId:"+roomId+" err:"+err+" errMsg:"+errMsg);
    }

    @Override
    public void OnRecvAnchorLeaveRoomNotice(String roomId, String anchorId) {
        Log.d(TAG,"OnRecvAnchorLeaveRoomNotice-roomId:"+roomId+" anchorId:"+anchorId);
    }

    @Override
    public void OnRecvRoomKickoffNotice(String roomId, IMClientListener.LCC_ERR_TYPE err, String errMsg) {
        Log.d(TAG,"OnRecvRoomKickoffNotice-roomId:"+roomId+" err:"+err+" errMsg:"+errMsg);
    }

    @Override
    public void OnSendRoomMsg(boolean success, IMClientListener.LCC_ERR_TYPE errType,
                              String errMsg, IMMessageItem msgItem) {
        Log.d(TAG,"OnSendRoomMsg-success:"+success+" errType:"+errType+" errMsg:"+errMsg);
    }

    @Override
    public void OnRecvRoomMsg(IMMessageItem msgItem) {
        Log.d(TAG,"OnRecvRoomMsg:+msgItem:"+msgItem);
    }

    @Override
    public void OnSendGift(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem) {
        Log.d(TAG,"OnSendGift-success:"+success+" errType:"+errType+" errMsg:"+errMsg);
    }

    @Override
    public void OnRecvRoomGiftNotice(IMMessageItem msgItem) {
        if(null != msgItem && null != msgItem.giftMsgContent){
            Log.d(TAG,"OnRecvRoomGiftNotice-gift.id:"+msgItem.giftMsgContent.giftId
                    +" gift.name:"+msgItem.giftMsgContent.giftName+" msgItem:"+msgItem);
        }

    }

    @Override
    public void OnRecvSendSystemNotice(IMMessageItem msgItem) {
        Log.d(TAG,"OnRecvSendSystemNotice-msgItem:"+msgItem);

    }

    @Override
    public void OnRecvRoomToastNotice(IMMessageItem msgItem) {
        Log.d(TAG,"OnRecvRoomToastNotice-msgItem:"+msgItem);
    }

    @Override
    public void OnRecvTalentRequestNotice(String talentInvitationId, String name, String userId, String nickName) {
        Log.d(TAG,"OnRecvTalentRequestNotice-talentInvitationId:" + talentInvitationId
                + " name: " + name + " userId: " + userId + " nickName: " + nickName);
    }

    @Override
    public void OnRecvInteractiveVideoNotice(String roomId, String userId, String nickname, String avatarImg,
                                             IMClientListener.IMVideoInteractiveOperateType operateType, String[] pushUrls) {
        Log.d(TAG,"OnRecvInteractiveVideoNotice-roomId:" + roomId + " userId:" + userId
                + " nickName:" + nickname + " operateType:" + operateType.name());
        if(!isCurrentRoom(roomId)){
            return;
        }

    }

    //------------------------其他断线重连、踢出房间等IM消息监听-------------------------------
    @Override
    public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        Log.d(TAG,"OnLogin-errType:"+errType+" errMsg:"+errMsg);
    }

    @Override
    public void OnLogout(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        Log.d(TAG,"OnLogout-errType:"+errType+" errMsg:"+errMsg);
    }

    @Override
    public void OnKickOff(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        Log.d(TAG,"OnKickOff-errType:"+errType+" errMsg:"+errMsg);
    }

    @Override
    public void OnRecvAnchoeInviteNotify(String logId, String anchorId, String anchorName, String anchorPhotoUrl) {
        Log.d(TAG,"OnRecvAnchoeInviteNotify-logId:"+logId+" anchorId:"+anchorId+" anchorName:"+anchorName +" anchorPhotoUrl:"+anchorPhotoUrl);
    }

    @Override
    public void OnRecvBookingNotice(String roomId, String userId, String nickName, String photoUrl, int leftSeconds) {
        Log.d(TAG,"OnRecvBookingNotice-roomId:"+roomId+" userId:"+userId+" nickName:"+nickName
                +" photoUrl:"+photoUrl+" leftSeconds:"+leftSeconds);
    }

    //----------------------------其他自定义--------------------------

    @Override
    public void onGetAudienceList(boolean isSuccess, int errCode, String errMsg, AudienceInfoItem[] audienceList) {
        Log.d(TAG,"onGetAudienceList-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg
                +(null==audienceList ? "" : " audienceList.length:"+audienceList.length));
    }

    @Override
    public void onGetGiftList(boolean isSuccess, int errCode, String errMsg, GiftItem[] giftList) {
        Log.d(TAG,"onGetGiftList-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
    }

    @Override
    public void onGiftLimitNumList(boolean isSuccess, int errCode, String errMsg, GiftLimitNumItem[] giftIds) {
        Log.d(TAG,"onGetSendableGiftList-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
    }

    @Override
    public void onHangoutGiftList(boolean isSuccess, int errCode, String errMsg, AnchorHangoutGiftListItem giftItem) {
        Log.d(TAG,"onHangoutGiftList-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
    }

    @Override
    public void onGetAudienceDetailInfo(boolean isSuccess, int errCode, String errMsg, AudienceBaseInfoItem audienceInfo) {
        Log.d(TAG,"onGetAudienceDetailInfo-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg+" audienceInfo:"+audienceInfo);
    }

    @Override
    public void OnEnterHangoutRoom(int reqId, final boolean success, IMClientListener.LCC_ERR_TYPE errType,
                                   final String errMsg, final IMHangoutRoomItem hangoutRoomItem, int expire) {
        Log.d(TAG, "OnEnterHangoutRoom-reqId"+reqId+" success:"+success+" errType:"
                +errType+" errMsg:"+errMsg+" hangoutRoomItem:"+hangoutRoomItem+" expire:"+expire);
        if(success && null != hangoutRoomItem && isCurrentRoom(hangoutRoomItem.roomId)){
            this.mIMHangOutRoomItem = hangoutRoomItem;
        }
    }

    @Override
    public void OnLeaveHangoutRoom(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        Log.d(TAG, "OnLeaveHangoutRoom-reqId"+reqId+" success:"+success+" errType:"
                +errType+" errMsg:"+errMsg);
    }

    @Override
    public void OnRecvAnchorRecommendHangoutNotice(IMHangoutRecommendItem item) {
        Log.d(TAG,"OnRecvAnchorRecommendHangoutNotice-item:"+item);
    }

    @Override
    public void OnRecvAnchorDealKnockRequestNotice(IMKnockRequestItem item) {
        Log.d(TAG,"OnRecvAnchorDealKnockRequestNotice-item:"+item);
    }

    @Override
    public void OnRecvAnchorOtherInviteNotice(IMOtherInviteItem item) {
        Log.d(TAG,"OnRecvAnchorOtherInviteNotice-item:"+item);
    }

    @Override
    public void OnRecvAnchorDealInviteNotice(IMDealInviteItem item) {
        Log.d(TAG,"OnRecvAnchorDealInviteNotice-item:"+item);
    }

    @Override
    public void OnRecvAnchorEnterRoomNotice(IMRecvEnterRoomItem item) {
        Log.d(TAG,"OnRecvAnchorEnterRoomNotice-item:"+item);
    }

    @Override
    public void OnRecvAnchorLeaveRoomNotice(IMRecvLeaveRoomItem item) {
        Log.d(TAG,"OnRecvAnchorLeaveRoomNotice-item:"+item);
    }

    @Override
    public void OnRecvAnchorChangeVideoUrl(String roomId, boolean isAnchor, String userId, String[] playUrl) {
        Log.d(TAG,"OnRecvAnchorChangeVideoUrl-roomId:"+roomId+" isAnchor:"+isAnchor+" userId:"+userId);
    }

    @Override
    public void OnSendHangoutGift(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        Log.d(TAG,"OnSendHangoutGift-reqId:"+reqId+" success:"+success+" errType:"+errType+" errMsg:"+errMsg);
    }

    @Override
    public void OnRecvAnchorGiftNotice(IMRecvHangoutGiftItem item) {
        Log.d(TAG,"OnRecvAnchorGiftNotice-item:"+item);
    }

    @Override
    public void OnRecvHangoutInteractiveVideoNotice(String roomId, String userId, String nickname,
                                                    String avatarImg, IMClientListener.IMVideoInteractiveOperateType operateType,
                                                    String[] pushUrls) {
        Log.d(TAG,"OnRecvHangoutInteractiveVideoNotice-roomId:"+roomId+" userId:"+userId
                +" nickname:"+nickname+" avatarImg:"+avatarImg+" operateType:"+operateType);
    }

    @Override
    public void OnSendHangoutMsg(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        Log.d(TAG,"OnSendHangoutMsg-reqId:"+reqId+" success:"+success+" errType:"+errType+" errMsg:"+errMsg);
    }

    @Override
    public void OnRecvHangoutMsg(IMMessageItem imMessageItem) {
        Log.d(TAG,"OnRecvHangoutMsg-imMessageItem:"+imMessageItem);
    }

    @Override
    public void OnRecvAnchorCountDownEnterRoomNotice(String roomId, String anchorId, int leftSecond) {
        Log.d(TAG,"OnRecvAnchorCountDownEnterRoomNotice-roomId:"+roomId+" anchorId:"+anchorId+" leftSecond:"+leftSecond);
    }

    @Override
    public void onGetHangoutFriendRelation(boolean isSuccess, int errCode, String errMsg, AnchorInfoItem item) {
        Log.d(TAG,"onGetHangoutFriendRelation-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg+" item:"+item);
    }
}
