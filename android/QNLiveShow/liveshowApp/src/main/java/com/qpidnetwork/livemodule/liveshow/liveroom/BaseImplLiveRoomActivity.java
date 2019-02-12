package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.os.Bundle;
import android.text.SpannableString;
import android.text.TextUtils;
import android.view.View;

import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetAccountBalanceCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetAudienceDetailInfoCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetAudienceListCallback;
import com.qpidnetwork.livemodule.httprequest.item.AudienceBaseInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.AudienceInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.im.IMInviteLaunchEventListener;
import com.qpidnetwork.livemodule.im.IMLiveRoomEventListener;
import com.qpidnetwork.livemodule.im.IMLoginStatusListener;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.IMOtherEventListener;
import com.qpidnetwork.livemodule.im.listener.IMAuthorityItem;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMInviteErrItem;
import com.qpidnetwork.livemodule.im.listener.IMInviteListItem;
import com.qpidnetwork.livemodule.im.listener.IMInviteReplyItem;
import com.qpidnetwork.livemodule.im.listener.IMLoveLeveItem;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.im.listener.IMRebateItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.downloader.IFileDownloadedListener;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.OnRoomRebateCountTimeEndListener;
import com.qpidnetwork.livemodule.liveshow.liveroom.tariffprompt.TariffPromptManager;
import com.qpidnetwork.livemodule.view.SoftKeyboradListenFrameLayout;
import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * Description:直播间接口实现基类
 * 1.view层baseactivity或者业务层roomactivity需要重写该类响应的方法以实现对应的视图刷新/业务处理逻辑
 * 2.重点是封装视图业务层同底层的接口交互，从而使得上层各view模块只用关心自己对应的update method
 * <p>
 * Created by Harry on 2017/9/1.
 */

public class BaseImplLiveRoomActivity extends BaseFragmentActivity
        implements View.OnClickListener, SoftKeyboradListenFrameLayout.InputWindowListener,
        IFileDownloadedListener, IMInviteLaunchEventListener,IMLiveRoomEventListener,
        IMOtherEventListener, TariffPromptManager.OnGetRoomTariffInfoListener,
        OnGetAudienceListCallback, OnGetAudienceDetailInfoCallback, IMLoginStatusListener,
        OnRoomRebateCountTimeEndListener {

    //数据及管理
    protected String mRoomInId;           //房间ID,从过渡页传入
    public IMRoomInItem mIMRoomInItem;    //房间信息
    public IMAuthorityItem mAuthorityItem;     //主播权限
    protected int mRoomAudienceNum = 0;
    protected String roomPhotoUrl = null;
    protected LoginItem loginItem = null;
    protected boolean isHasPermission;

    //管理房间信用点及返点
    public LiveRoomCreditRebateManager mLiveRoomCreditRebateManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        TAG = BaseImplLiveRoomActivity.class.getSimpleName();
        super.onCreate(savedInstanceState);
        mLiveRoomCreditRebateManager = LiveRoomCreditRebateManager.getInstance();
        initData();
        //后绑定listener，防止未初始化完成收到通知异常
        initIMListener();
        //
        getRoomInItem();
    }

    /**
     * 数据初始化
     */
    private void initData(){
        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(LiveRoomTransitionActivity.LIVEROOM_ROOMINFO_ID)){
                mRoomInId = bundle.getString(LiveRoomTransitionActivity.LIVEROOM_ROOMINFO_ID);
                Log.d(TAG,"initData-mRoomInId:"+mRoomInId);
            }

            if(bundle.containsKey(LiveRoomTransitionActivity.LIVEROOM_InviterErr_ITEM)){
                IMInviteErrItem inviteErrItem = (IMInviteErrItem)bundle.getSerializable(LiveRoomTransitionActivity.LIVEROOM_InviterErr_ITEM);
                mAuthorityItem = inviteErrItem.priv;
                Log.d(TAG,"initData-mAuthorityItem:"+mAuthorityItem);
            }

            if(bundle.containsKey(LiveRoomTransitionActivity.LIVEROOM_ROOMINFO_ROOMPHOTOURL)){
                roomPhotoUrl = bundle.getString(LiveRoomTransitionActivity.LIVEROOM_ROOMINFO_ROOMPHOTOURL);
                Log.d(TAG,"initData-roomPhotoUrl:"+roomPhotoUrl);
            }

            if(bundle.containsKey(LiveRoomTransitionActivity.KEY_HAS_PERMISSION)){
                isHasPermission = bundle.getBoolean(LiveRoomTransitionActivity.KEY_HAS_PERMISSION);
            }
        }

        if(mIMRoomInItem != null){
            //更新本地信用点/返点及房间人数信息
            mLiveRoomCreditRebateManager.setCredit(mIMRoomInItem.credit);
            mLiveRoomCreditRebateManager.setImRebateItem(mIMRoomInItem.rebateItem);
            mRoomAudienceNum = mIMRoomInItem.fansNum;
        }
        LoginManager loginManager = LoginManager.getInstance();
        if(null != loginManager){
            loginItem = loginManager.getLoginItem();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        clearIMListener();
        mIMManager.cleanRoomInItems();
    }

    /**
     * 获取用于信用点余额
     */
    public void GetCredit(){
        LiveRequestOperator.getInstance().GetAccountBalance(new OnGetAccountBalanceCallback() {
            @Override
            public void onGetAccountBalance(boolean isSuccess, int errCode, String errMsg, final double balance, int coupon) {
                if(isSuccess){
                    mLiveRoomCreditRebateManager.setCredit(balance);
                    //通知信用点刷新
                    onCreditUpdate();
                }
            }
        });
    }

    /**
     * 在IMManager中找出对应房间信息
     */
    private void getRoomInItem(){
        if(!TextUtils.isEmpty(mRoomInId)){
            mIMRoomInItem = mIMManager.getRoomInItem(mRoomInId);
            Log.d(TAG,"getRoomInItem:"+ mIMRoomInItem.roomId);
        }
    }

    /**************************** 公共统一处理逻辑  *****************************************/
    /**
     * 房间人数改变通知
     */
    protected void onRoomAudienceChangeUpdate(){
        Log.d(TAG,"onRoomAudienceChangeUpdate");
    }

    /**
     * 收到返点通知
     */
    protected void onRebateUpdate(){
        Log.d(TAG,"onRebateUpdate");
    }

    protected void addRebateGrantedMsg(double rebateGranted){
        Log.d(TAG,"addRebateGrantedMsg-pre_credit:"+rebateGranted);
    }

    /**
     * 信用点
     */
    protected void onCreditUpdate(){
        Log.d(TAG,"onCreditUpdate");
    }

    /**
     * 是否是当前房间
     * @param roomId
     * @return
     */
    protected boolean isCurrentRoom(String roomId){
        boolean isCurrent = false;
        if(mIMRoomInItem != null && !TextUtils.isEmpty(mIMRoomInItem.roomId)
                && roomId.equals(mIMRoomInItem.roomId)){
            isCurrent = true;
        }
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
        mIMManager.registerIMLoginStatusListener(this);
    }

    /**
     * 清除IM底层类相关监听事件
     */
    protected void clearIMListener(){
        mIMManager.unregisterIMInviteLaunchEventListener(this);
        mIMManager.unregisterIMLiveRoomEventListener(this);
        mIMManager.unregisterIMOtherEventListener(this);
        mIMManager.unregisterIMLoginStatusListener(this);
    }

    //------------------点击事件-------------------------------
    @Override
    public void onClick(View v) {

    }

    //------------------软键盘监听、视图高度发生变化--------------
    @Override
    public void onSoftKeyboardShow() {

    }

    @Override
    public void onSoftKeyboardHide() {

    }

    //------------------图片文件等的下载监听--------------
    @Override
    public void onCompleted(boolean isSuccess, String localFilePath, String fileUrl) {

    }

    @Override
    public void onProgress(String fileUrl, int progress) {

    }

    //------------------用户进入房间、退出房间、直播开始、发送私密邀请、取消私密邀请、邀请响应--------------

    @Override
    public void OnRoomIn(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMRoomInItem roomInfo, IMAuthorityItem authorityItem) {
        Log.d(TAG,"OnRoomIn-reqId:"+reqId+" success:"+success+" errType:"+errType+" errMsg:"+roomInfo+" roomInfo:"+roomInfo);
        if(success){
            mIMRoomInItem = roomInfo;
            mAuthorityItem = authorityItem;
            if(mIMRoomInItem != null){
                //更新本地信用点/返点及房间人数信息
                mLiveRoomCreditRebateManager.setCredit(mIMRoomInItem.credit);
                onCreditUpdate();
//                if(mLiveRoomCreditRebateManager.getImRebateItem().cur_credit<mIMRoomInItem.rebateItem.cur_credit){
//                    addRebateGrantedMsg(mIMRoomInItem.rebateItem.cur_credit-mLiveRoomCreditRebateManager.getImRebateItem().cur_credit);
//                }
                mLiveRoomCreditRebateManager.setImRebateItem(mIMRoomInItem.rebateItem);
                onRebateUpdate();
                mRoomAudienceNum = mIMRoomInItem.fansNum;
            }
        }
    }

    @Override
    public void OnRoomOut(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType,
                          String errMsg) {
        Log.d(TAG,"OnFansRoomOut-reqId:"+reqId+" success:"+success+" errType:"+errType+" errMsg:"+errMsg);
    }

    @Override
    public void OnRecvLiveStart(String roomId, int leftSeconds, String[] playUrls) {

    }

    @Override
    public void OnGetInviteInfo(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMInviteListItem inviteItem, IMAuthorityItem priv) {

    }

    @Override
    public void OnSendImmediatePrivateInvite(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String invitationId, int timeout, String roomId, IMInviteErrItem errItem) {

    }

    @Override
    public void OnCancelImmediatePrivateInvite(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String roomId) {

    }

    @Override
    public void OnRecvInviteReply(IMInviteReplyItem replyItem) {
        Log.d(TAG,"OnRecvInviteReply-inviteId:"+replyItem.inviteId +" replyType:"+replyItem.replyType +" roomId:"+replyItem.roomId
                +" roomType:"+replyItem.roomType +" anchorId:"+replyItem.anchorId +" nickName:"+replyItem.nickName +" avatarImg:"+replyItem.avatarImg
                +" message:"+replyItem.message);
    }

    //------------------直播间IM事件监听--------------
    @Override
    public void OnRecvRoomCloseNotice(String roomId, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMAuthorityItem privItem) {
        Log.d(TAG,"OnRecvRoomCloseNotice-roomId:"+" errType:"+errType+" errMsg:"+errMsg);
        if(!isCurrentRoom(roomId)){
            return;
        }
    }

    @Override
    public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl,
                                      String riderId, String riderName,
                                      String riderUrl, final int fansNum, String honorImg, boolean isHasTicket) {
        if(!isCurrentRoom(roomId)){
            return;
        }
        Log.d(TAG,"OnRecvEnterRoomNotice-roomId:"+roomId+" userId:"+userId
                +" nickName:"+nickName+" photoUrl:"+photoUrl+" riderId:"+riderId
                +" riderName:"+riderName+" riderUrl:"+riderUrl+" fansNum:"+fansNum+" honorImg:"+honorImg);
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
    public void OnRecvRebateInfoNotice(String roomId, IMRebateItem item) {
        if(!isCurrentRoom(roomId)){
            return;
        }
        Log.d(TAG,"OnRecvRebateInfoNotice-roomId:"+roomId+" item:"+item);
        if(isCurrentRoom(roomId)) {
            //插入返点公告
            addRebateGrantedMsg(item.pre_credit);

            mLiveRoomCreditRebateManager.setImRebateItem(item);
            onRebateUpdate();
        }
    }

    @Override
    public void OnRecvLeavingPublicRoomNotice(String roomId, int leftSeconds, IMClientListener.LCC_ERR_TYPE err, String errMsg, IMAuthorityItem privItem) {
        if(!isCurrentRoom(roomId)){
            return;
        }
        Log.d(TAG,"OnRecvLeavingPublicRoomNotice-roomId:"+roomId+" err:"+err+" errMsg:"+errMsg);
    }

    @Override
    public void OnRecvRoomKickoffNotice(String roomId, IMClientListener.LCC_ERR_TYPE err, String errMsg, double credit, IMAuthorityItem privItem) {
        if(!isCurrentRoom(roomId)){
            return;
        }
        Log.d(TAG,"OnRecvRoomKickoffNotice-roomId:"+roomId+" err:"+err+" errMsg:"+errMsg
                +" credit:"+credit);
        if(isCurrentRoom(roomId)){
            mLiveRoomCreditRebateManager.setCredit(credit);
            onCreditUpdate();
        }
    }

    @Override
    public void OnRecvChangeVideoUrl(String roomId, boolean isAnchor, String[] playUrls) {
        Log.d(TAG,"OnRecvChangeVideoUrl-roomId:"+roomId+" isAnchor:"+isAnchor+" playUrl:"+playUrls);
        if(!isCurrentRoom(roomId)){
            return;
        }
    }

    @Override
    public void OnControlManPush(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType,
                                 String errMsg, String[] manPushUrl) {
        Log.d(TAG,"OnControlManPush-reqId:"+reqId+" success:"+success+" errType:"+errType
                +" errMsg:"+errMsg+" manPushUrl:"+manPushUrl);
    }

    @Override
    public void OnSendRoomMsg(boolean success, IMClientListener.LCC_ERR_TYPE errType,
                              String errMsg, IMMessageItem msgItem) {
        Log.d(TAG,"OnSendRoomMsg-success:"+success+" errType:"+errType+" errMsg:"+errMsg);
    }

    @Override
    public void OnRecvRoomMsg(IMMessageItem msgItem) {
        if(!isCurrentRoom(msgItem.roomId)){
            return;
        }
        Log.d(TAG,"OnRecvRoomMsg:+msgItem:"+msgItem);
    }

    @Override
    public void OnSendGift(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg,
                           IMMessageItem msgItem, double credit, double rebateCredit) {
        Log.d(TAG,"OnSendGift-success:"+success+" errType:"+errType+" errMsg:"+errMsg
                +" credit:"+credit+" rebateCredit:"+rebateCredit);
        if(success){
            if(-1d != credit){
                mLiveRoomCreditRebateManager.setCredit(credit);
                onCreditUpdate();
            }
//            if(mLiveRoomCreditRebateManager.getImRebateItem().cur_credit<rebateCredit){
//                //一般送礼、弹幕都是会消耗返点的，所以一般不会走到这一步
//                addRebateGrantedMsg(rebateCredit-mLiveRoomCreditRebateManager.getImRebateItem().cur_credit);
//            }
            if(-1d != rebateCredit){
                mLiveRoomCreditRebateManager.updateRebateCredit(rebateCredit);
                onRebateUpdate();
            }
        }
    }

    @Override
    public void OnRecvRoomGiftNotice(IMMessageItem msgItem) {
        if(!isCurrentRoom(msgItem.roomId)){
            return;
        }
        if(null != msgItem && null != msgItem.giftMsgContent){
            Log.d(TAG,"OnRecvRoomGiftNotice-gift.id:"+msgItem.giftMsgContent.giftId
                    +" gift.name:"+msgItem.giftMsgContent.giftName+" msgItem:"+msgItem);
        }

    }

    @Override
    public void OnRecvSendSystemNotice(IMMessageItem msgItem) {
        if(!isCurrentRoom(msgItem.roomId)){
            return;
        }
        Log.d(TAG,"OnRecvSendSystemNotice-msgItem:"+msgItem);

    }

    @Override
    public void OnSendBarrage(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg,
                              IMMessageItem msgItem, double credit, double rebateCredit) {
        Log.d(TAG,"OnSendBarrage-success:"+success+" errType:"+errType+" errMsg:"+errMsg
                +" credit:"+credit+" rebateCredit:"+rebateCredit);
        if(success){
            if(-1d != credit){
                mLiveRoomCreditRebateManager.setCredit(credit);
                onCreditUpdate();
            }
//            if(mLiveRoomCreditRebateManager.getImRebateItem().cur_credit<rebateCredit){
//                //一般送礼、弹幕都是会消耗返点的，所以一般不会走到这一步
//                addRebateGrantedMsg(rebateCredit-mLiveRoomCreditRebateManager.getImRebateItem().cur_credit);
//            }
            if(-1d != rebateCredit){
                mLiveRoomCreditRebateManager.updateRebateCredit(rebateCredit);
                onRebateUpdate();
            }
        }
    }

    @Override
    public void OnRecvRoomToastNotice(IMMessageItem msgItem) {
        if(!isCurrentRoom(msgItem.roomId)){
            return;
        }
        Log.d(TAG,"OnRecvRoomToastNotice-msgItem:"+msgItem);
    }

    @Override
    public void OnSendTalent(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String talentInviteId, String talentId ) {
        Log.d(TAG,"OnSendTalent-reqId:"+reqId+" success:"+success+" errType:"+errType+" errMsg:"+errMsg + " talentInviteId: " + talentInviteId + ",talentId:" + talentId);
    }

    @Override
    public void OnRecvSendTalentNotice(String roomId, String talentInviteId, String talentId, String name,
                                       double credit, IMClientListener.TalentInviteStatus status, double rebateCredit, String giftId, String giftName, int giftNum) {
        Log.d(TAG,"OnRecvSendTalentNotice-roomId:"+roomId+" talentInviteId:"+talentInviteId+" talentId:"+talentId
                +" name:"+name+" credit:"+credit+" status:"+status+" rebateCredit:"+rebateCredit);
        if(!isCurrentRoom(roomId)){
            return;
        }
        //接收直播间才艺点播回复通知
        if(-1d != credit){
            mLiveRoomCreditRebateManager.setCredit(credit);
            onCreditUpdate();
        }
//        if(mLiveRoomCreditRebateManager.getImRebateItem().cur_credit<rebateCredit){
//            //一般送礼、弹幕都是会消耗返点的，所以一般不会走到这一步
//            addRebateGrantedMsg(rebateCredit-mLiveRoomCreditRebateManager.getImRebateItem().cur_credit);
//        }
        if(-1d != rebateCredit){
            mLiveRoomCreditRebateManager.updateRebateCredit(rebateCredit);
            onRebateUpdate();
        }
    }

    @Override
    public void OnRecvTalentPromptNotice(String roomId, String introduction) {

    }

    @Override
    public void OnRecvHonorNotice(String honorId, String honorUrl) {
        Log.d(TAG,"OnRecvHonorNotice-honorId:"+honorId+" honorUrl:"+honorUrl);
        mIMRoomInItem.honorId = honorId;
        mIMRoomInItem.honorImg = honorUrl;
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
    public void OnRecvLackOfCreditNotice(String roomId, String message, double credit) {
        if(!isCurrentRoom(roomId)){
            return;
        }
        Log.d(TAG,"OnRecvLackOfCreditNotice-roomId:"+roomId+" message:"+message+" credit:"+credit);
        if(isCurrentRoom(roomId)){
            mLiveRoomCreditRebateManager.setCredit(credit);
            onCreditUpdate();
        }
    }

    @Override
    public void OnRecvCreditNotice(String roomId, double credit) {
        if(!isCurrentRoom(roomId)){
            return;
        }
        Log.d(TAG,"OnRecvCreditNotice-roomId:"+roomId+" credit:"+credit);
        if(isCurrentRoom(roomId)){
            mLiveRoomCreditRebateManager.setCredit(credit);
            onCreditUpdate();
        }
    }

    @Override
    public void OnRecvAnchoeInviteNotify(String logId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {
        Log.d(TAG,"OnRecvAnchoeInviteNotify-logId:"+logId+" anchorId:"+anchorId+" anchorName:"+anchorName
                +" anchorPhotoUrl:"+anchorPhotoUrl+" message:"+message);
    }

    @Override
    public void OnRecvScheduledInviteNotify(String inviteId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {
        Log.d(TAG,"OnRecvScheduledInviteNotify-inviteId:"+inviteId+" anchorId:"+anchorId+" anchorName:"+anchorName
                +" anchorPhotoUrl:"+anchorPhotoUrl+" message:"+message);
    }

    @Override
    public void OnRecvSendBookingReplyNotice(String inviteId, IMClientListener.BookInviteReplyType replyType) {
        Log.d(TAG,"OnRecvSendBookingReplyNotice-inviteId:"+inviteId+" replyType:"+replyType);
    }

    @Override
    public void OnRecvBookingNotice(String roomId, String userId, String nickName, String photoUrl, int leftSeconds) {
        Log.d(TAG,"OnRecvBookingNotice-roomId:"+roomId+" userId:"+userId+" nickName:"+nickName
                +" photoUrl:"+photoUrl+" leftSeconds:"+leftSeconds);
    }

    @Override
    public void OnRecvLevelUpNotice(int level) {
        Log.d(TAG,"OnRecvLevelUpNotice-level:"+level);
        mIMRoomInItem.manLevel = level;
    }

    @Override
    public void OnRecvLoveLevelUpNotice(IMLoveLeveItem lovelevelItem) {
        if(lovelevelItem != null){
            Log.d(TAG,"OnRecvLoveLevelUpNotice-lovelevel:"+lovelevelItem.loveLevel);
            mIMRoomInItem.loveLevel = lovelevelItem.loveLevel;
        }
    }

    @Override
    public void OnRecvBackpackUpdateNotice(IMPackageUpdateItem item) {
        Log.d(TAG,"OnRecvBackpackUpdateNotice");
    }

    //----------------------------其他自定义--------------------------

    @Override
    public void onGetRoomTariffInfo(SpannableString tariffPromptSpan, boolean showOkBtn) {

    }

    @Override
    public void onGetAudienceList(boolean isSuccess, int errCode, String errMsg, AudienceInfoItem[] audienceList) {
        Log.d(TAG,"onGetAudienceList-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg
                +(null==audienceList ? "" : " audienceList.length:"+audienceList.length));
    }

    @Override
    public void onGetAudienceDetailInfo(boolean isSuccess, int errCode, String errMsg, AudienceBaseInfoItem audienceInfo) {
        Log.d(TAG,"onGetAudienceDetailInfo-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg+" audienceInfo:"+audienceInfo);
    }

    @Override
    public void onIMAutoReLogined() {
        Log.d(TAG,"onIMAutoReLogined");
//        loginItem = LoginManager.getInstance().getLoginItem();
    }

    @Override
    public void onRoomRebateCountTimeEnd() {
        Log.d(TAG,"onRoomRebateCountTimeEnd");
    }

    //------------------勋章---------------------------------
}
