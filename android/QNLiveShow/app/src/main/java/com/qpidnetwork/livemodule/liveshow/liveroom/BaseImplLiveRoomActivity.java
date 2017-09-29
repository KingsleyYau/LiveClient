package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.os.Bundle;
import android.text.SpannableString;
import android.text.TextUtils;
import android.view.View;

import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.OnGetAccountBalanceCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetAudienceDetailInfoCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetAudienceListCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetSendableGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniOther;
import com.qpidnetwork.livemodule.httprequest.item.AudienceBaseInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.AudienceInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.httprequest.item.SendableGiftItem;
import com.qpidnetwork.livemodule.im.IMInviteLaunchEventListener;
import com.qpidnetwork.livemodule.im.IMLiveRoomEventListener;
import com.qpidnetwork.livemodule.im.IMLoginStatusListener;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.IMOtherEventListener;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMInviteListItem;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.im.listener.IMRebateItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.PackageGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.downloader.IFileDownloadedListener;
import com.qpidnetwork.livemodule.liveshow.liveroom.tariffprompt.TariffPromptManager;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.TestDataUtil;
import com.qpidnetwork.livemodule.view.SoftKeyboradListenFrameLayout;

import java.util.List;

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
        OnGetAudienceListCallback, NormalGiftManager.OnRoomShowSendableGiftDataChangeListener,
        PackageGiftManager.OnPackageGiftDataChangeListener,OnGetGiftListCallback,
        OnGetSendableGiftListCallback,OnGetAudienceDetailInfoCallback, IMLoginStatusListener {

    //数据及管理
    protected IMRoomInItem mIMRoomInItem;    //房间信息
    protected int mRoomAudienceNum = 0;
    protected String mRoomPhotoUrl="";

    //管理房间信用点及返点
    protected LiveRoomCreditRebateManager mLiveRoomCreditRebateManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        TAG = BaseImplLiveRoomActivity.class.getSimpleName();
        super.onCreate(savedInstanceState);
        mLiveRoomCreditRebateManager = LiveRoomCreditRebateManager.getInstance();
        TestDataUtil.isContinueTestTask = false;
        initIMListener();
        initData();
    }

    /**
     * 数据初始化
     */
    private void initData(){
        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(LiveRoomTransitionActivity.LIVEROOM_ROOMINFO_ITEM)){
                mIMRoomInItem = (IMRoomInItem)bundle.getSerializable(LiveRoomTransitionActivity.LIVEROOM_ROOMINFO_ITEM);
            }
            if(bundle.containsKey(LiveRoomTransitionActivity.LIVEROOM_ROOMINFO_ROOMPHOTOURL)){
                mRoomPhotoUrl = bundle.getString(LiveRoomTransitionActivity.LIVEROOM_ROOMINFO_ROOMPHOTOURL);
            }
        }

        if(mIMRoomInItem != null){
            //更新本地信用点/返点及房间人数信息
            mLiveRoomCreditRebateManager.setCredit(mIMRoomInItem.credit);
            mLiveRoomCreditRebateManager.setImRebateItem(mIMRoomInItem.rebateItem);
            mRoomAudienceNum = mIMRoomInItem.fansNum;
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if(TestDataUtil.isContinueTestTask){
            TestDataUtil.isContinueTestTask = false;
        }
        clearIMListener();
    }

    /**
     * 获取用于信用点余额
     */
    public void GetCredit(){
        RequestJniOther.GetAccountBalance(new OnGetAccountBalanceCallback() {
            @Override
            public void onGetAccountBalance(boolean isSuccess, int errCode, String errMsg, final double balance) {
                if(isSuccess){
                    mLiveRoomCreditRebateManager.setCredit(balance);
                    //通知信用点刷新
                    onCreditUpdate();
                }
            }
        });
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
    protected IMManager mIMManager;
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
    private void clearIMListener(){
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

    //------------------用户进入房间、退出房间、直播开始、发送私密邀请、取消私密邀请、邀请响应--------------
    @Override
    public void OnRoomIn(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType,
                         String errMsg, final IMRoomInItem roomInfo) {
        Log.d(TAG,"OnRoomIn-reqId:"+reqId+" success:"+success+" errType:"+errType+" errMsg:"+roomInfo+" roomInfo:"+roomInfo);
        if(success){
            mIMRoomInItem = roomInfo;
            if(mIMRoomInItem != null){
                //更新本地信用点/返点及房间人数信息
                mLiveRoomCreditRebateManager.setCredit(mIMRoomInItem.credit);
                mLiveRoomCreditRebateManager.setImRebateItem(mIMRoomInItem.rebateItem);
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
    public void OnRecvLiveStart(String roomId, int leftSeconds) {

    }

    @Override
    public void OnGetInviteInfo(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMInviteListItem inviteItem) {

    }

    @Override
    public void OnSendImmediatePrivateInvite(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String invitationId, int timeout, String roomId) {

    }

    @Override
    public void OnCancelImmediatePrivateInvite(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String roomId) {

    }

    @Override
    public void OnRecvInviteReply(String inviteId, IMClientListener.InviteReplyType replyType,
                                  String roomId, LiveRoomType roomType, String anchorId,
                                  String nickName, String avatarImg, String message) {
        Log.d(TAG,"OnRecvRoomCloseNotice-inviteId:"+inviteId +" replyType:"+replyType +" roomId:"+roomId
                +" roomType:"+roomType +" anchorId:"+anchorId +" nickName:"+nickName +" avatarImg:"+avatarImg
                +" message:"+message);
    }

    //------------------直播间IM事件监听--------------
    @Override
    public void OnRecvRoomCloseNotice(String roomId, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        Log.d(TAG,"OnRecvRoomCloseNotice-roomId:"+" errType:"+errType+" errMsg:"+errMsg);
    }

    @Override
    public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl,
                                      String riderId, String riderName,
                                      String riderUrl, final int fansNum) {
        Log.d(TAG,"OnRecvEnterRoomNotice-roomId:"+roomId+" userId:"+userId
                +" nickName:"+nickName+" photoUrl:"+photoUrl+" riderId:"+riderId
                +" riderName:"+riderName+" riderUrl:"+riderUrl+" fansNum:"+fansNum);
        mRoomAudienceNum = fansNum;
        onRoomAudienceChangeUpdate();
    }

    @Override
    public void OnRecvLeaveRoomNotice(String roomId, String userId, String nickName, String photoUrl, final int fansNum) {
        Log.d(TAG,"OnRecvLeaveRoomNotice-roomId:"+roomId+" userId:"+userId+" nickName:"+nickName+" photoUrl:"+photoUrl+" fansNum:"+fansNum);
        //更新房间人数，通知房间人数改变
        mRoomAudienceNum = fansNum;
        onRoomAudienceChangeUpdate();
    }

    @Override
    public void OnRecvRebateInfoNotice(String roomId, IMRebateItem item) {
        Log.d(TAG,"OnRecvRebateInfoNotice-roomId:"+roomId+" item:"+item);
        if(isCurrentRoom(roomId)) {
            mLiveRoomCreditRebateManager.setImRebateItem(item);
            onRebateUpdate();
        }
    }

    @Override
    public void OnRecvLeavingPublicRoomNotice(String roomId, IMClientListener.LCC_ERR_TYPE err,
                                              String errMsg) {
        Log.d(TAG,"OnRecvLeavingPublicRoomNotice-roomId:"+roomId+" err:"+err+" errMsg:"+errMsg);
    }

    @Override
    public void OnRecvRoomKickoffNotice(String roomId, IMClientListener.LCC_ERR_TYPE err,
                                        String errMsg, double credit) {
        Log.d(TAG,"OnRecvRoomKickoffNotice-roomId:"+roomId+" err:"+err+" errMsg:"+errMsg
                +" credit:"+credit);
        if(isCurrentRoom(roomId)){
            mLiveRoomCreditRebateManager.setCredit(credit);
            onCreditUpdate();
        }
    }

    @Override
    public void OnRecvChangeVideoUrl(String roomId, boolean isAnchor, String playUrl) {
        Log.d(TAG,"OnRecvChangeVideoUrl-roomId:"+roomId+" isAnchor:"+isAnchor+" playUrl:"+playUrl);
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
        Log.d(TAG,"OnRecvRoomMsg");
    }

    @Override
    public void OnSendGift(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg,
                           IMMessageItem msgItem, double credit, double rebateCredit) {
        Log.d(TAG,"OnSendGift-success:"+success+" errType:"+errType+" errMsg:"+errMsg
                +" credit:"+credit+" rebateCredit:"+rebateCredit);
        if(success){
            mLiveRoomCreditRebateManager.setCredit(credit);
            onCreditUpdate();
            mLiveRoomCreditRebateManager.updateRebateCredit(rebateCredit);
            onRebateUpdate();
        }
    }

    @Override
    public void OnRecvRoomGiftNotice(IMMessageItem msgItem) {
        if(null != msgItem && null != msgItem.giftMsgContent){
            Log.d(TAG,"OnRecvRoomGiftNotice-gift.id:"+msgItem.giftMsgContent.giftId
                    +" gift.name:"+msgItem.giftMsgContent.giftName);
        }

    }

    @Override
    public void OnRecvSendSystemNotice(IMMessageItem msgItem) {
        Log.d(TAG,"OnRecvSendSystemNotice");

    }

    @Override
    public void OnSendBarrage(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg,
                              IMMessageItem msgItem, double credit, double rebateCredit) {
        if(success){
            mLiveRoomCreditRebateManager.setCredit(credit);
            onCreditUpdate();
            mLiveRoomCreditRebateManager.updateRebateCredit(rebateCredit);
            onRebateUpdate();
        }
    }

    @Override
    public void OnRecvRoomToastNotice(IMMessageItem msgItem) {
        Log.d(TAG,"OnRecvRoomToastNotice-msgItem:"+msgItem);
    }

    @Override
    public void OnSendTalent(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvSendTalentNotice(String roomId, String talentInviteId, String talentId,
                                       String name, double credit, IMClientListener.TalentInviteStatus status) {

    }

    //------------------------其他断线重连、踢出房间等IM消息监听-------------------------------
    @Override
    public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnLogout(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnKickOff(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvLackOfCreditNotice(String roomId, String message, double credit) {
        if(isCurrentRoom(roomId)){
            mLiveRoomCreditRebateManager.setCredit(credit);
            onCreditUpdate();
        }
    }

    @Override
    public void OnRecvCreditNotice(String roomId, double credit) {
        if(isCurrentRoom(roomId)){
            mLiveRoomCreditRebateManager.setCredit(credit);
            onCreditUpdate();
        }
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
    public void OnRecvLoveLevelUpNotice(int lovelevel) {

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
    public void onPackageGiftDataChanged(String currRoomId) {
        Log.d(TAG,"onPackageGiftDataChanged-currRoomId:"+currRoomId+" mIMRoomItem.roomId:"+mIMRoomInItem.roomId);
    }

    @Override
    public void onGetGiftList(boolean isSuccess, int errCode, String errMsg, GiftItem[] giftList) {
        Log.d(TAG,"onGetGiftList-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
    }

    @Override
    public void onGetSendableGiftList(boolean isSuccess, int errCode, String errMsg, SendableGiftItem[] giftIds) {
        Log.d(TAG,"onGetSendableGiftList-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
    }

    @Override
    public void onRoomSendableGiftChanged(String roomId, List<GiftItem> sendableGiftItemList) {
        Log.d(TAG,"onRoomSendableGiftChanged-roomId:"+roomId);
    }

    @Override
    public void onGetAudienceDetailInfo(boolean isSuccess, int errCode, String errMsg, AudienceBaseInfoItem audienceInfo) {
        Log.d(TAG,"onGetAudienceDetailInfo-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg+" audienceInfo:"+audienceInfo);
    }

    @Override
    public void onIMAutoReLogined() {
        Log.d(TAG,"onIMAutoReLogined");
    }
}
