package com.qpidnetwork.livemodule.liveshow.bubble;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetHangoutFriendsCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;
import com.qpidnetwork.livemodule.im.IMHangoutEventListener;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMDealInviteItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutCountDownItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutInviteItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRecommendItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvEnterRoomItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvKnockRequestItem;
import com.qpidnetwork.livemodule.im.listener.IMRecvLeaveRoomItem;
import com.qpidnetwork.livemodule.livechat.LCMessageItem;
import com.qpidnetwork.livemodule.livechat.LCUserItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerMessageListener;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerOtherListener;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatSessionInfoItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatUserCamStatus;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * 直播模块邀请冒泡管理器
 * @author Hunter
 * @since 2019.3.11
 */
public class BubbleMessageManager implements LiveChatManagerMessageListener, IMHangoutEventListener, LiveChatManagerOtherListener {

    private static final String TAG = BubbleMessageManager.class.getName();

    private final int BUBBLE_FILTER_CYCLE = 1 * 1000;       //检测筛选当前冒泡列表周期（单位：毫秒）
    private final int MAX_PRESHOW_LIST_SIZE = 4;            //待显示邀请列表最大长度为4个
    private final int MAX_SHOWING_LIVECHAT_SIZE = 4;        //当前展示列表Livechat邀请最大条数
    private final int MAX_SHOWING_HANGOUT_SIZE = 4;         //当前展示列表Hangout邀请最大条数
    private final int MESSAGE_SHOW_DELAY_TIME = 5 * 1000;   //冒泡消息间隔设置
    public static final int BUBBLE_SHOW_MAX_TIME = 45 * 1000;   //冒泡显示时常设置
    private final int ANCHOR_INVITE_SHOW_DURATION = 10 * 60 * 1000; //10分钟内同一个主播只能显示一次邀请消息

    private final int EVENT_LIVECHAT_RECV_INVITE = 1;
    private final int EVENT_HANGOUT_INVITE_NOTICE = 2;
    private final int EVENT_SCHEDULE_CHECK = 3;
    // 2019/4/16 Hardy 退出登录事件
    private final int EVENT_LOGOUT = 4;


    public Context mContext;
    public Handler mHandler;
    private LiveChatManager mLiveChatManager;
    private IMManager mIMManager;
    private List<BubbleMessageBean> mBubbleShowingMsgList;  //当前正在显示的冒泡列表
    private List<BubbleMessageBean> mBubblePreshowingMsgList;   //待选冒泡消息列表

    private HashMap<String, LCMessageItem> mLivechatInviteMap;     //收到邀请，需要更新头像，本地缓存消息列表
    private boolean mIsShowingListLocked = false;                  //showingList是否锁住（当且仅当检测添加新冒泡消息时锁住列表）

    private IBubbleMessageManagerListener mBubbleMessageManagerListener;    //事件监听器

    private HashMap<String, Long> mAnchorShowInTenMinutesMap;               //纪录10分钟内显示过的主播ID

    @SuppressLint("HandlerLeak")
    public BubbleMessageManager(Context context){
        mContext =context.getApplicationContext();
        mBubbleShowingMsgList = new ArrayList<BubbleMessageBean>();
        mBubblePreshowingMsgList = new ArrayList<BubbleMessageBean>();
        mLivechatInviteMap = new HashMap<String, LCMessageItem>();
        mAnchorShowInTenMinutesMap = new HashMap<String, Long>();
        mLiveChatManager = LiveChatManager.getInstance();
        mIMManager = IMManager.getInstance();
        mHandler = new Handler(){
            public void handleMessage(android.os.Message msg){
                Log.i(TAG, "handleMessage msg.what: " + msg.what);
                switch (msg.what){
                    case EVENT_LIVECHAT_RECV_INVITE:{
                        //收到邀请消息
                        LCMessageItem item = (LCMessageItem)msg.obj;
//                        if(!mAnchorShowInTenMinutesMap.containsKey(item.getUserItem().userId)) {
                            LiveChatTalkUserListItem talkUserItem = mLiveChatManager.GetLadyInfoById(item.getUserItem().userId);
                            if (talkUserItem != null) {
                                //本地缓存信息，有头像
                                addLiveChatInviteToPreshowList(item);
                            } else {
                                //通过GetUserInfo更新主播头像信息
                                if (mLiveChatManager.GetUserInfo(item.getUserItem().userId)) {
                                    Log.i(TAG, "EVENT_LIVECHAT_RECV_INVITE GetUserInfo usetId: " + item.getUserItem().userId);
                                    mLivechatInviteMap.put(item.getUserItem().userId, item);
                                }
                            }
//                        }
                    }break;

                    case EVENT_HANGOUT_INVITE_NOTICE: {
                        IMHangoutInviteItem hangoutInviteItem = (IMHangoutInviteItem) msg.obj;
                        if (!mAnchorShowInTenMinutesMap.containsKey(hangoutInviteItem.anchorId)){
                            addHangoutInviteToPreshowList(hangoutInviteItem);
                        }
                    }break;

                    case EVENT_SCHEDULE_CHECK:{

                        if(mBubbleShowingMsgList.size() > 0 || mBubblePreshowingMsgList.size() > 0 || mIsShowingListLocked){
                            //定时任务
                            sendEmptyMessageDelayed(EVENT_SCHEDULE_CHECK, BUBBLE_FILTER_CYCLE);
                        }

                        //检测并更新显示列表
                        checkShowingBubbleList();

                        //共用定时器解决超时处理及界面倒计时刷新
                        checkTimeoutAndUpdateNotice();

                        //清理10分钟内显示主播列表
                        clearAnchorListInTenMinutes();
                    }break;

                    // 2019/4/16 Hardy
                    case EVENT_LOGOUT:{
                        logout();
                    }
                    break;

                    default:
                        break;
                }
            }
        };

        registerEventListener();
    }

    /**
     * 绑定接收相关邀请
     */
    private void registerEventListener(){
        mLiveChatManager.RegisterMessageListener(this);
        mLiveChatManager.RegisterOtherListener(this);
        mIMManager.registerIMHangoutEventListener(this);
    }

    /**
     * 解绑相关监听事件
     */
    private void unregisterEventListener(){
        mLiveChatManager.UnregisterMessageListener(this);
        mLiveChatManager.UnregisterOtherListener(this);
        mIMManager.unregisterIMHangoutEventListener(this);
    }

    /**
     * 设置事件监听器
     * @param listener
     */
    public void setBubbleMessageManagerListener(IBubbleMessageManagerListener listener){
        mBubbleMessageManagerListener = listener;
    }

    /**
     * 同步获取当前正在显示的列表
     * @return
     */
    public List<BubbleMessageBean> getCurrentShowingList(){
        ArrayList<BubbleMessageBean> dataList = new ArrayList<BubbleMessageBean>();
        synchronized (mBubbleShowingMsgList){
            dataList.addAll(mBubbleShowingMsgList);
        }
        return dataList;
    }

    /**
     * 检测超时，执行删除操作并通知界面刷新
     */
    private void checkTimeoutAndUpdateNotice(){
        int count = 0;
        synchronized (mBubbleShowingMsgList){
            for(int i = 0; i < mBubbleShowingMsgList.size(); i++){
                BubbleMessageBean bean = mBubbleShowingMsgList.get(i);
                if(System.currentTimeMillis() - bean.firstShowTime >= BUBBLE_SHOW_MAX_TIME){
                    //超时
                    count++;
                }
            }
        }
        Log.i(TAG, "checkTimeoutAndUpdateNotice count: " + count);
        if(count > 0){
            //有超时冒泡消息
            removeShowingItem(0, count);

            if(mBubbleMessageManagerListener != null){
                mBubbleMessageManagerListener.onDataRemove(0, count);
            }
        }else{
            //无超时冒泡消息，通知界面刷新倒计时
            if(mBubbleMessageManagerListener != null){
                mBubbleMessageManagerListener.onDataChangeNotify();
            }
        }
    }

    /**
     * 处理主播邀请显示列表
     */
    private void clearAnchorListInTenMinutes(){
        Log.i(TAG, "clearAnchorListInTenMinutes enter");
        synchronized (mAnchorShowInTenMinutesMap){
            List<String> keys = new ArrayList<String>();
            keys.addAll(mAnchorShowInTenMinutesMap.keySet());
            for(String key : keys){
                if(System.currentTimeMillis() - mAnchorShowInTenMinutesMap.get(key) > ANCHOR_INVITE_SHOW_DURATION){
                    Log.i(TAG, "clearAnchorListInTenMinutes remove anchorid: " + key);
                    mAnchorShowInTenMinutesMap.remove(key);
                }
            }
        }
    }

    /**
     * 删除指定区间item
     * @param startPosition
     * @param count
     */
    public void removeShowingItem(int startPosition, int count){
        synchronized (mBubbleShowingMsgList){
            if(mBubbleShowingMsgList.size() > startPosition ) {
                List<BubbleMessageBean> dataList = new ArrayList<BubbleMessageBean>();
                int endPostion = mBubbleShowingMsgList.size() > (startPosition + count) ? (startPosition + count):mBubbleShowingMsgList.size();
                for (int i = startPosition; i < endPostion; i++) {
                    dataList.add(mBubbleShowingMsgList.get(i));
                }
                mBubbleShowingMsgList.removeAll(dataList);
            }
        }
    }

    /**
     * 销毁逻辑
     */
    public void onDestroy(){
        unregisterEventListener();

        // 2019/4/16 Hardy
        clearVariable();

        //停掉定时器
//        mHandler.removeMessages(EVENT_SCHEDULE_CHECK);
//        mBubbleShowingMsgList.clear();
//        mBubblePreshowingMsgList.clear();
//        mLivechatInviteMap.clear();
//        mIsShowingListLocked = false;
    }

    //================  2019/4/16   Hardy   ===========================
    private void clearVariable(){
        //停掉定时器
        mHandler.removeMessages(EVENT_SCHEDULE_CHECK);
        mBubbleShowingMsgList.clear();
        mBubblePreshowingMsgList.clear();
        mLivechatInviteMap.clear();
        mIsShowingListLocked = false;
    }

    /**
     * Hardy
     * https://www.qoogifts.com.cn/zentaopms2/www/index.php?m=bug&f=view&bugID=17644
     * 登出后需要清空邀请，包括本地缓存下来的待显示队列
     */
    private void logout(){
        // 1.先记录需要清除的正在显示的冒泡数目
        int size = mBubbleShowingMsgList.size();

        // 2.清除全局变量
        clearVariable();

        // 3.通知外层主界面，清空所有正在显示的冒泡
        if(mBubbleMessageManagerListener != null && size > 0){
            mBubbleMessageManagerListener.onDataRemove(0, size);
        }
    }
    //================  2019/4/16   Hardy   ===========================

    /**
     * 添加Hangout邀请消息到待展示列表
     * @param item
     */
    private void addHangoutInviteToPreshowList(final IMHangoutInviteItem item){
        Log.i(TAG, "addHangoutInviteToPreshowList anchorID: " +  item.anchorId + "  anchorName: " + item.nickName);
        //同步主播好友列表
        LiveRequestOperator.getInstance().GetHangoutFriends(item.anchorId, new OnGetHangoutFriendsCallback() {
            @Override
            public void onGetHangoutFriends(boolean isSuccess, int errCode, String errMsg, HangoutAnchorInfoItem[] audienceList) {
                if(isSuccess){
                    String anchorFriendPhotoUrl = "";
                    if(audienceList != null && audienceList.length > 0){
                        anchorFriendPhotoUrl = audienceList[0].photoUrl;
                    }
                    BubbleMessageBean bean = new BubbleMessageBean(BubbleMessageType.Hangout, item.anchorId, item.nickName, item.avatarImg, item.inviteMessage);
                    bean.updateAnchorFriendPhotoUrl(anchorFriendPhotoUrl);
                    bean.updateAutoInviteFlag(item.isAnto);
                    addToPreshowListInternal(bean);
                }
            }
        });
    }


    /**
     * 添加Livechat邀请消息到待展示列表
     */
    private void addLiveChatInviteToPreshowList(LCMessageItem item){
        LiveChatTalkUserListItem talkUserItem = mLiveChatManager.GetLadyInfoById(item.getUserItem().userId);
        Log.i(TAG, "addLiveChatInviteToPreshowList talkUserItem: " + talkUserItem);
        if(talkUserItem != null) {
            //本地缓存信息，有头像
            BubbleMessageBean bubbleMsgBean = new BubbleMessageBean(BubbleMessageType.LiveChat,
                    talkUserItem.userId, talkUserItem.userName, talkUserItem.avatarImg, item.getTextItem().message);
            addToPreshowListInternal(bubbleMsgBean);
        }
    }

    /**
     * 增加或替换邀请列表
     * @param bean
     */
    private void addToPreshowListInternal(BubbleMessageBean bean){
        Log.i(TAG, "addToPreshowListInternal bean: " + bean);
        synchronized (mBubblePreshowingMsgList){
            //当本地列表超出最大数目时，清除头部邀请
            if(mBubblePreshowingMsgList.size() >= MAX_PRESHOW_LIST_SIZE){
                //删除头部
                mBubblePreshowingMsgList.remove(0);
            }
            mBubblePreshowingMsgList.add(bean);
        }

        //检测数组并启动定时刷新业务
        checkAndStartSchedule();
    }

    /**
     * 读取待展示列表第一条数据
     */
    private BubbleMessageBean getFirstPreshowlistItem(){
        BubbleMessageBean bean = null;
        synchronized (mBubblePreshowingMsgList){
            if(mBubblePreshowingMsgList.size() > 0) {
                bean = mBubblePreshowingMsgList.remove(0);
            }
        }
        return bean;
    }

    /**
     * 检测开启定时器
     */
    private void checkAndStartSchedule(){
        Log.i(TAG, "checkAndStartSchedule mBubbleShowingMsgList size: " + mBubbleShowingMsgList.size() + "  mBubblePreshowingMsgList.size: " + mBubblePreshowingMsgList.size());
        if(mBubbleShowingMsgList.size() == 0 && mBubblePreshowingMsgList.size() > 0){
            Log.i(TAG, "checkAndStartSchedule time start");
            //显示列表为空，待显示列表不为空
            //停掉旧的定时器
            mHandler.removeMessages(EVENT_SCHEDULE_CHECK);
            //开启新定时器
            mHandler.sendEmptyMessage(EVENT_SCHEDULE_CHECK);
        }
    }

    /**
     *  检测是否需要更新冒泡列表
     */
    private void checkShowingBubbleList(){
        int maxShowingListLength = MAX_PRESHOW_LIST_SIZE + MAX_SHOWING_LIVECHAT_SIZE;
        Log.i(TAG, "checkShowingBubbleList maxShowingListLength: " + maxShowingListLength + " mIsShowingListLocked: " + mIsShowingListLocked + " showListSize: " + mBubbleShowingMsgList.size());
        if(!mIsShowingListLocked && (mBubbleShowingMsgList.size() < maxShowingListLength)){
            mIsShowingListLocked = true;
            //读取待展示列表第一条
            BubbleMessageBean bean = getFirstPreshowlistItem();
            if(bean !=  null) {
                if (bean.bubbleMsgType == BubbleMessageType.Hangout) {
                    checkHangoutInivteShowCondition(bean);
                } else {
                    insertToShowingBubbleList(bean);
                }
            }else{
                mIsShowingListLocked = false;
            }
        }
    }

    private void checkHangoutInivteShowCondition(final BubbleMessageBean bean){
        Log.i(TAG, "checkHangoutInivteShowCondition anchorName: " + bean.anchorName);
        LiveRequestOperator.getInstance().AutoInvitationHangoutLiveDisplay(bean.anchorId, bean.isAuto, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                if(isSuccess){
                    insertToShowingBubbleList(bean);
                }else{
                    //消息丢掉，解锁
                    mIsShowingListLocked = false;
                }
            }
        });
    }

    /**
     * 检测并插入冒泡显示列表
     * @param bean
     */
    private void insertToShowingBubbleList(final BubbleMessageBean bean){
        boolean isCanAdd = false;
        //获取需要检测，无法直接插入的列表最小数目
        int typeMinLimit = MAX_SHOWING_LIVECHAT_SIZE > MAX_SHOWING_HANGOUT_SIZE ? MAX_SHOWING_HANGOUT_SIZE : MAX_SHOWING_LIVECHAT_SIZE;
        synchronized (mBubbleShowingMsgList){
            if(mBubbleShowingMsgList.size() >= typeMinLimit){
                int currentTypeCount = 0;
                for(BubbleMessageBean msgBean : mBubbleShowingMsgList){
                    if(msgBean.bubbleMsgType == bean.bubbleMsgType){
                        currentTypeCount ++;
                    }
                }
                if(currentTypeCount < getMaxShowCountByMessageType(bean.bubbleMsgType)){
                    //列表当前类型数目小于可展示最大数目，插入并展示列表，否则丢掉
                    isCanAdd = true;
                }
            }else{
                //列表当前数目小于需要检测的最小数目，直接插入
                isCanAdd = true;
            }
        }

        Log.i(TAG, "insertToShowingBubbleList isCanAdd: " + isCanAdd + " anchorName: " + bean.anchorName);

        if(isCanAdd){
            //延时5秒钟冒泡展示
            mHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    bean.updateFirstShowTime(System.currentTimeMillis());
                    //头部插入
                    mBubbleShowingMsgList.add(bean);
                    //消息显示，解锁
                    mIsShowingListLocked = false;
                    //纪录展示的主播
                    if(bean.bubbleMsgType == BubbleMessageType.Hangout) {
                        synchronized (mAnchorShowInTenMinutesMap) {
                            mAnchorShowInTenMinutesMap.put(bean.anchorId, Long.valueOf(System.currentTimeMillis()));
                        }
                    }
                    Log.i(TAG, "insertToShowingBubbleList postDelayed add anchorName: " + bean.anchorName);
                    //通知界面同步插入数据
                    if(mBubbleMessageManagerListener != null){
                        mBubbleMessageManagerListener.onDataAdd(bean);
                    }
                }
            }, MESSAGE_SHOW_DELAY_TIME);
        }else{
            //消息丢掉，解锁
            mIsShowingListLocked = false;
        }
    }

    /**
     * 读取本地消息类型最大条数设置
     * @return
     */
    private int getMaxShowCountByMessageType(BubbleMessageType msgType){
        int maxCount = 0;
        switch (msgType){
            case LiveChat:{
                maxCount = MAX_SHOWING_LIVECHAT_SIZE;
            }break;
            case Hangout:{
                maxCount = MAX_SHOWING_HANGOUT_SIZE;
            }break;
            default:
                break;
        }
        return maxCount;
    }




    /**************************************   LiveChat邀请相关   ***********************************************/
    @Override
    public void OnSendMessage(LiveChatClientListener.LiveChatErrType errType, String errmsg, LCMessageItem item) {

    }

    @Override
    public void OnRecvMessage(LCMessageItem item) {
        Log.i(TAG, "OnRecvMessage username: " + item.getUserItem().userName + " chatType: " + item.getUserItem().chatType.name() + " msgType: " + item.msgType.name());
        if(item != null && item.getUserItem() != null
            && !item.getUserItem().isInSession() && (item.msgType == LCMessageItem.MessageType.Text)){
            Message msg = Message.obtain();
            msg.what = EVENT_LIVECHAT_RECV_INVITE;
            msg.obj = item;
            mHandler.sendMessage(msg);
        }
    }

    @Override
    public void OnSendInviteMessage(LCMessageItem item) {

    }

    @Override
    public void OnRecvWarning(LCMessageItem item) {

    }

    @Override
    public void OnRecvEditMsg(String fromId) {

    }

    @Override
    public void OnRecvSystemMsg(LCMessageItem item) {

    }

    @Override
    public void OnSendMessageListFail(LiveChatClientListener.LiveChatErrType errType, ArrayList<LCMessageItem> msgList) {

    }

    @Override
    public void OnLogin(LiveChatClientListener.LiveChatErrType errType, String errmsg, boolean isAutoLogin) {

    }

    @Override
    public void OnLogout(LiveChatClientListener.LiveChatErrType errType, String errmsg, boolean isAutoLogin) {
        Log.i("info","BubbleMessageManager------------------OnLogout=--------------------------");

        // 2019/4/16 Hardy 登出后需要清空邀请
        Message msg = Message.obtain();
        msg.what = EVENT_LOGOUT;
        mHandler.sendMessage(msg);
    }

    @Override
    public void OnGetTalkList(LiveChatClientListener.LiveChatErrType errType, String errmsg) {

    }

    @Override
    public void OnGetHistoryMessage(boolean success, String errno, String errmsg, LCUserItem userItem) {

    }

    @Override
    public void OnGetUsersHistoryMessage(boolean success, String errno, String errmsg, LCUserItem[] userItems) {

    }

    @Override
    public void OnSetStatus(LiveChatClientListener.LiveChatErrType errType, String errmsg) {

    }

    @Override
    public void OnGetUserStatus(LiveChatClientListener.LiveChatErrType errType, String errmsg, LCUserItem[] userList) {

    }

    @Override
    public void OnGetUserInfo(LiveChatClientListener.LiveChatErrType errType, String errmsg, String userId, LiveChatTalkUserListItem item) {
        if(!TextUtils.isEmpty(userId) && mLivechatInviteMap.containsKey(userId)){
            LCMessageItem messageItem = mLivechatInviteMap.remove(userId);
            addLiveChatInviteToPreshowList(messageItem);
        }
    }

    @Override
    public void OnGetUsersInfo(LiveChatClientListener.LiveChatErrType errType, String errmsg, String[] userIds, LiveChatTalkUserListItem[] itemList) {

    }

    @Override
    public void OnGetContactList(LiveChatClientListener.LiveChatErrType errType, String errmsg, LiveChatTalkUserListItem[] list) {

    }

    @Override
    public void OnUpdateStatus(LCUserItem userItem) {

    }

    @Override
    public void OnChangeOnlineStatus(LCUserItem userItem) {

    }

    @Override
    public void OnRecvKickOffline(LiveChatClientListener.KickOfflineType kickType) {

    }

    @Override
    public void OnRecvEMFNotice(String fromId, LiveChatClientListener.TalkEmfNoticeType noticeType) {

    }

    @Override
    public void OnGetLadyCamStatus(LiveChatClientListener.LiveChatErrType errType, String errmsg, String womanId, boolean isCam) {

    }

    @Override
    public void OnGetUsersCamStatus(LiveChatClientListener.LiveChatErrType errType, String errmsg, LiveChatUserCamStatus[] userIds) {

    }

    @Override
    public void OnRecvLadyCamStatus(String userId, LiveChatClient.UserStatusProtocol statuType) {

    }

    @Override
    public void OnGetSessionInfo(LiveChatClientListener.LiveChatErrType errType, String errmsg, String userId, LiveChatSessionInfoItem item) {

    }

    /**************************************   hangout邀请相关   ***********************************************/

    @Override
    public void OnRecvRecommendHangoutNotice(IMHangoutRecommendItem item) {

    }

    @Override
    public void OnRecvDealInvitationHangoutNotice(IMDealInviteItem item) {

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
    public void OnSendHangoutGift( boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem item, double credit) {

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
    public void OnSendHangoutRoomMsg(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem item) {

    }

    @Override
    public void OnRecvHangoutRoomMsg(IMMessageItem item) {

    }

    @Override
    public void OnRecvAnchorCountDownEnterHangoutRoomNotice(IMHangoutCountDownItem item) {

    }

    @Override
    public void OnRecvHandoutInviteNotice(IMHangoutInviteItem item) {
        Log.i(TAG, "OnRecvHandoutInviteNotice anchorID: " + item.anchorId + "  anchorName: " + item.nickName);
        if(item != null){
            Message msg = Message.obtain();
            msg.what = EVENT_HANGOUT_INVITE_NOTICE;
            msg.obj = item;
            mHandler.sendMessage(msg);
        }
    }

    @Override
    public void OnRecvHangoutCreditRunningOutNotice(String roomId, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }
}
