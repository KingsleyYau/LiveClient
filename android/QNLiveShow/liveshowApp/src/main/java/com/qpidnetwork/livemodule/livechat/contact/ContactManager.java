package com.qpidnetwork.livemodule.livechat.contact;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.livechat.LCEmotionItem;
import com.qpidnetwork.livemodule.livechat.LCMagicIconItem;
import com.qpidnetwork.livemodule.livechat.LCMessageItem;
import com.qpidnetwork.livemodule.livechat.LCMessageItem.MessageType;
import com.qpidnetwork.livemodule.livechat.LCUserItem;
import com.qpidnetwork.livemodule.livechat.LCUserItem.ChatType;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerEmotionListener;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerMagicIconListener;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerMessageListener;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerOtherListener;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerPhotoListener;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerTryTicketListener;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerVideoListener;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerVoiceListener;
import com.qpidnetwork.livemodule.livechat.LiveChatMessageHelper;
import com.qpidnetwork.livemodule.livechat.camshare.LCCamShareClient.CamShareClientErrorType;
import com.qpidnetwork.livemodule.livechat.camshare.LCCamShareClient.OnLCCamShareClientListener;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient.UserStatusProtocol;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.KickOfflineType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.LiveChatErrType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.TalkEmfNoticeType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener.TryTicketEventType;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatSessionInfoItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatUserCamStatus;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat.VideoPhotoType;
import com.qpidnetwork.livemodule.livechathttprequest.item.Coupon;
import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconConfig;
import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigItem;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.manager.PushManager;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.model.http.RequestBaseResponse;
import com.qpidnetwork.livemodule.utils.ListUtils;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.qnbridgemodule.bean.NotificationTypeEnum;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;

public class ContactManager implements IAuthorizationListener,
        LiveChatManagerOtherListener, LiveChatManagerEmotionListener,
        LiveChatManagerMessageListener, LiveChatManagerPhotoListener,
        LiveChatManagerVideoListener, LiveChatManagerVoiceListener,
        LiveChatManagerTryTicketListener, LiveChatManagerMagicIconListener
        , OnLCCamShareClientListener {

    /**
     * 请求消息
     */
    private enum RequestFlag {
        REQUEST_LIVECHAT_NOTIFICATION_SUCCESS
    }

    protected final String tag = getClass().getName();

    private static final long CONTACTLIST_STATUS_INTERVAL = 5 * 60 * 1000; // 获取联系人在线状态，5分钟一次

    private Context mContext;
    private List<OnLCContactUpdateCallback> mCallbackList;
    private List<ContactBean> mContactList;
    private Map<String, ContactBean> mContactsMap;// 简历联系人索引方便读取及查找

    private LiveChatManager mLiveChatManager;
    private HandlerThread mHandlerThread;

    public Handler mHandler;
    public String mWomanId = "";// 当前正在聊天的女士Id，方便未读统计

    //获取女士资料接口
    private LiveChatGetLadyInfoManager mLiveChatGetLadyInfoManager;

    /* invite 更新监控 */
    private List<OnNewInviteUpdateCallback> mInviteCallbackList;

    // 未读消息数的接口
    private List<OnChatUnreadUpdateCallback> mChatUnreadUpdateCallbackList;

    //单例
    private static ContactManager mContactManager;

    public static ContactManager newInstance(Context context) {
        if (mContactManager == null) {
            mContactManager = new ContactManager(context);
        }
        return mContactManager;
    }

    public static ContactManager getInstance() {
        return mContactManager;
    }

    @SuppressLint("HandlerLeak")
    public void InitHandler() {
        // TODO Auto-generated method stub
        mHandler = new Handler() {
            public void handleMessage(Message msg) {
                switch (RequestFlag.values()[msg.what]) {
                    case REQUEST_LIVECHAT_NOTIFICATION_SUCCESS: {
                        // 非当前在聊女士
                        RequestBaseResponse obj = (RequestBaseResponse) msg.obj;
                        LCMessageItem item = (LCMessageItem) obj.body;
                        String tips = "";
                        if (item.msgType != MessageType.Text) {
                            if (item.getUserItem() != null) {
                                tips = item.getUserItem().userName + ": "
                                        + LiveChatMessageHelper.generateMsgHint(mContext, item);
                            }
                        } else {
                            String msgTemp = (item.getTextItem().message != null) ? item
                                    .getTextItem().message : "";
                            msgTemp = msgTemp.replaceAll("\\[\\w*:[0-9]*\\]",
                                    "[smiley]");
                            if (item.getUserItem() != null) {
                                tips = item.getUserItem().userName + ": " + msgTemp;
                            }
                        }
                        if(!TextUtils.isEmpty(tips) && item != null){
                            String url = URL2ActivityManager.createLiveChatActivityUrl(item.getUserItem().userId, item.getUserItem().userName, "");
                            PushManager.getInstance().ShowNotification(NotificationTypeEnum.LIVE_LIVECHAT_NOTIFICATION,
                                    mContext.getResources().getString(R.string.app_name),
                                    tips,
                                    url, true);
                        }
                    }
                    break;

                    default:
                        break;
                }
            }

            ;
        };
    }

    /**
     * 实现任务线程，实现同步操作
     */
    private Handler handler = new Handler(getLooper()) {
        public void handleMessage(Message msg) {
            if (msg.obj instanceof Runnable) {
                Runnable task = (Runnable) (msg.obj);
                task.run();
            }
        }

        ;
    };

    private Looper getLooper() {
        mHandlerThread = new HandlerThread("Contacts");
        mHandlerThread.start();
        return mHandlerThread.getLooper();
    }

    public ContactManager(Context context) {
        this.mContext = context;
        mCallbackList = new ArrayList<OnLCContactUpdateCallback>();
        mContactList = new ArrayList<ContactBean>();
        mContactsMap = new HashMap<String, ContactBean>();
        mLiveChatManager = LiveChatManager.getInstance();
        mInviteCallbackList = new ArrayList<OnNewInviteUpdateCallback>();
        mChatUnreadUpdateCallbackList = new ArrayList<>();

        //初始化女士详情管理器
        mLiveChatGetLadyInfoManager = new LiveChatGetLadyInfoManager();
        mLiveChatGetLadyInfoManager.init();

        resetContact();
        addLiveChatListener();

        // 初始化事件监听
        InitHandler();
    }

    /**
     * 资源回收
     */
    public void onDestroy() {

        if (mLiveChatGetLadyInfoManager != null) {
            mLiveChatGetLadyInfoManager.uninit();
        }

        if (mHandlerThread != null) {
            mHandlerThread.interrupt();
            mHandlerThread = null;
        }
        Log.d("contact",
                "ContactManager::onDestroy() synchronized mContactList begin");
        synchronized (mContactList) {
            if (mContactList != null) {
                mContactList.clear();
            }
            if (mContactsMap != null) {
                mContactsMap.clear();
            }
        }
        Log.d("contact",
                "ContactManager::onDestroy() synchronized mContactList end");
    }

    /**
     * 注册联系人状态更新回调
     *
     * @param callback
     */
    public void registerContactUpdate(OnLCContactUpdateCallback callback) {
        Log.d("contact",
                "ContactManager::registerContactUpdate() synchronized mCallbackList begin");
        synchronized (mCallbackList) {
            if (mCallbackList != null) {
                mCallbackList.add(callback);
            }
        }
        Log.d("contact",
                "ContactManager::registerContactUpdate() synchronized mCallbackList end");
    }

    /**
     * 注销联系人状态更新回调
     *
     * @param callback
     */
    public void unregisterContactUpdata(OnLCContactUpdateCallback callback) {
        Log.d("contact",
                "ContactManager::unregisterContactUpdata() synchronized mCallbackList begin");
        synchronized (mCallbackList) {
            if (callback != null) {
                if (mCallbackList.contains(callback)) {
                    mCallbackList.remove(callback);
                }
            }
        }
        Log.d("contact",
                "ContactManager::unregisterContactUpdata() synchronized mCallbackList end");
    }

    /**
     * 联系人更新回调
     */
    private void onContactListUpdateCallback() {
        Log.d("contact",
                "ContactManager::onContactListUpdateCallback() synchronized mCallbackList begin");
        synchronized (mCallbackList) {
            for (OnLCContactUpdateCallback callback : mCallbackList) {
                callback.onContactUpdate(mContactList);
            }

            // 2018/11/20 Hardy 未读数更新，依赖联系人列表更新
            onChatUnreadUpdateCallback();
        }
        Log.d("contact",
                "ContactManager::onContactListUpdateCallback() synchronized mCallbackList end");
    }

    /**
     * 获取联系人列表
     *
     * @return
     */
    public List<ContactBean> getContactList() {
        Log.d("contact",
                "ContactManager::getContactList() synchronized mContactList begin");
        List<ContactBean> clone = null;
        synchronized (mContactList) {
            /* 返回浅拷贝列表，防止列表数目变化异常 */
            clone = new ArrayList<ContactBean>(mContactList);
        }
        Log.d("contact",
                "ContactManager::getContactList() synchronized mContactList end");

        return clone;
    }

    /**
     * 根据Id索引获取指定联系人
     *
     * @param womanId
     * @return
     */
    public ContactBean getContactById(String womanId) {
        if (mContactsMap != null) {
            if (mContactsMap.containsKey(womanId)) {
                return mContactsMap.get(womanId);
            }
        }
        return null;
    }


    /**
     * 点击进入聊天界面清除当前正在聊天的女士的未读条数显示
     *
     * @param womanid
     */
    public void clearContactUnreadCount(String womanid) {
        Log.d("contact",
                "ContactManager::clearContactUnreadCount() synchronized mContactList begin");
        synchronized (mContactList) {
            if (mContactsMap.containsKey(womanid)) {
                mContactsMap.get(womanid).unreadCount = 0;
                /* 需要刷新列表状态显示 */
                onContactListUpdateCallback();
            }
        }
        Log.d("contact",
                "ContactManager::clearContactUnreadCount() synchronized mContactList end");
    }

    /**
     * 获取当前联系人未读消息条数
     *
     * @return
     */
    public int getAllUnreadCount() {
        int unreadCount = 0;
        Log.d("contact",
                "ContactManager::getAllUnreadCount() synchronized mContactList begin");
        synchronized (mContactList) {
            for (ContactBean bean : mContactList) {
                unreadCount += bean.unreadCount;
            }
        }
        Log.d("contact",
                "ContactManager::getAllUnreadCount() synchronized mContactList end");
        return unreadCount;
    }

    /**
     * 2018/11/24 Hardy
     * 获取与指定 id 女士的 LiveChat 未读消息数
     * @return
     */
    public int getWomanUnreadCount(String womanId){
        ContactBean bean = getContactById(womanId);
        return bean != null ? bean.unreadCount : 0;
    }

    /**
     * 判断是否是联系人
     *
     * @param womanId
     * @return
     */
    public boolean isMyContact(String womanId) {
        boolean isContact = false;
        Log.d("contact",
                "ContactManager::isMyContact() synchronized mContactList begin");
        synchronized (mContactList) {
            isContact = mContactsMap.containsKey(womanId);
        }
        Log.d("contact",
                "ContactManager::isMyContact() synchronized mContactList end");
        return isContact;
    }

    private Runnable statusUpdate = new Runnable() {

        @Override
        public void run() {
            synchronized (mContactList) {
                String[] userIds = new String[mContactList.size()];
                for (int i = 0; i < mContactList.size(); i++) {
                    userIds[i] = mContactList.get(i).userId;
                }
                if (mLiveChatManager.IsLogin()) {
                    /* 登陆成功才调用Peter获取状态接口 */
                    mLiveChatManager.GetUserStatus(userIds);
//                    /*刷新Cam是否打开状态*/
//                    String[] onlineUserIds = GetOnlineConatcts();
//                    if (onlineUserIds != null && onlineUserIds.length > 0) {
//                        mLiveChatManager.GetUsersCamStatus(onlineUserIds);
//                    }
                }
                handler.postDelayed(statusUpdate, CONTACTLIST_STATUS_INTERVAL);
            }

        }
    };

    /**
     * 获取联系人中在线的联系人IDs
     */
    private String[] GetOnlineConatcts() {
        List<String> userIds = new ArrayList<String>();
        synchronized (mContactList) {
            if (mContactList != null) {
                for (ContactBean bean : mContactList) {
                    LCUserItem userItem = mLiveChatManager.GetUserWithId(bean.userId);
                    if (userItem.isOnline()) {
                        userIds.add(userItem.userId);
                    }
                }
            }
        }
        String[] tempUserArray = new String[userIds.size()];
        userIds.toArray(tempUserArray);
        return tempUserArray;
    }

    /***********************************************  增加或更新联系人  *****************************************************/

    /**
     * 发送消息成功或收到消息
     *
     * @param userId
     * @param needCheckSession 是否需要check会话状态
     */
    private void addOrUpdateContact(String userId, boolean needCheckSession) {
        LCUserItem userItem = mLiveChatManager.GetUserWithId(userId);
        boolean isUpdate = false;
        if (userItem != null) {
            synchronized (mContactList) {
                if (mContactsMap.containsKey(userItem.userId)) {
                    ContactBean contactBean = mContactsMap.get(userItem.userId);
                    updateContactMsgHint(userItem.userId, contactBean);
                    isUpdate = true;
                } else if (!needCheckSession || (userItem.chatType == ChatType.InChatCharge)
                        || (userItem.chatType == ChatType.InChatUseTryTicket)
                        || (userItem.chatType == ChatType.ManInvite)) {
                    getLadyInfoForContact(userItem.userId);
                }
            }
            if (isUpdate) {
                //通知界面刷新
                onContactListUpdateCallback();
            }
        }
    }

    /**
     * 获取联系人列表增加联系人（如已存在更新信息）
     *
     * @param userListItems
     */
    private void addOrUpdateContact(LiveChatTalkUserListItem[] userListItems) {
        synchronized (mContactList) {
            for (LiveChatTalkUserListItem item : userListItems) {
                if (!mContactsMap.containsKey(item.userId)) {
                    ContactBean contact = new ContactBean();
                    //新增联系人需要同步msgHint
                    updateContactMsgHint(item.userId, contact);
                    mContactList.add(contact);
                    mContactsMap.put(item.userId, contact);
                }
                mContactsMap.get(item.userId).updateContactByLiveChatUserItem(item);
            }
        }

        //通知界面刷新
        onContactListUpdateCallback();
    }

    /**
     * 通过用户Id添加联系人
     *
     * @param userId
     */
    private void getLadyInfoForContact(String userId) {
        mLiveChatGetLadyInfoManager.getLadyInfo(userId, new LiveChatGetLadyInfoManager.OnLiveChatGetLadyInfoCallback() {
            @Override
            public void onLiveChatGetLadyInfo(boolean isSuccess, LiveChatTalkUserListItem userInfo) {
                if (isSuccess) {
                    addOrUpdateContactInfoByUserInfo(userInfo);
                }
            }
        });
    }

    /**
     * 更新联系人信息
     *
     * @param userInfo
     */
    private void addOrUpdateContactInfoByUserInfo(LiveChatTalkUserListItem userInfo) {
        synchronized (mContactList) {
            if (!mContactsMap.containsKey(userInfo.userId)) {
                ContactBean contact = new ContactBean();
                //新增联系人需要同步msgHint
                updateContactMsgHint(userInfo.userId, contact);
                mContactList.add(contact);
                mContactsMap.put(userInfo.userId, contact);
            }
            mContactsMap.get(userInfo.userId).updateContactByLiveChatUserItem(userInfo);
        }

        //通知界面刷新
        onContactListUpdateCallback();
    }

    /**
     * 更新联系人hint信息
     *
     * @param userId
     */
    private void updateContactMsgHint(String userId, ContactBean contactBean) {
        LCUserItem userItem = mLiveChatManager.GetUserWithId(userId);
        if (userItem != null) {
            synchronized (userItem.getMsgList()) {
                if (!userItem.getMsgList().isEmpty()) {
                    for (int i = userItem.getMsgList().size() - 1; i >= 0; i--) {
                        LCMessageItem item = userItem.getMsgList().get(i);
                        if (item.msgType == MessageType.Text
                                || item.msgType == MessageType.Emotion
                                || item.msgType == MessageType.Photo
                                || item.msgType == MessageType.Voice
                                || item.msgType == MessageType.Video
                                || item.msgType == MessageType.MagicIcon) {
                            /* 通过最后一条正常通讯消息生成提示，否则界面使用默认最后更新时间提示 */
                            contactBean.msgHint = LiveChatMessageHelper.generateMsgHint(mContext, item);
                            if(item.createTime > contactBean.lasttime) {
                                contactBean.lasttime = item.createTime;
                            }
                        }
                        break;
                    }
                }
            }
        }
    }


    /**
     * 获取在线联系人列表
     *
     * @return
     */
    private List<ContactBean> getOnlieOnly() {
        List<ContactBean> tempList = new ArrayList<ContactBean>();
        Log.d("contact",
                "ContactManager::getOnlieOnly() synchronized mContactList begin");
        synchronized (mContactList) {
            if (mContactList != null) {
                for (ContactBean bean : mContactList) {
                    LCUserItem userItem = mLiveChatManager.GetUserWithId(bean.userId);
                    if (userItem.isOnline()) {
                        tempList.add(bean);
                    }
                }
            }
        }
        Log.d("contact",
                "ContactManager::getOnlieOnly() synchronized mContactList end");
        return tempList;
    }

    /**
     * 获取所有不在线联系人列表
     *
     * @return
     */
    private List<ContactBean> getOfflineOnly() {
        List<ContactBean> tempList = new ArrayList<ContactBean>();
        Log.d("contact",
                "ContactManager::getOfflineOnly() synchronized mContactList begin");
        synchronized (mContactList) {
            if (mContactList != null) {
                for (ContactBean bean : mContactList) {
                    LCUserItem userItem = mLiveChatManager.GetUserWithId(bean.userId);
                    if (!userItem.isOnline()) {
                        tempList.add(bean);
                    }
                }
            }
        }
        Log.d("contact",
                "ContactManager::getOfflineOnly() synchronized mContactList end");
        return tempList;
    }

    /**
     * 获取有Video的联系人列表
     *
     * @return
     */
    private List<ContactBean> getWithVideoList() {
        List<ContactBean> tempList = new ArrayList<ContactBean>();
        Log.d("contact",
                "ContactManager::getWithVideoList() synchronized mContactList begin");
        synchronized (mContactList) {
            if (mContactList != null) {
                for (ContactBean bean : mContactList) {
                    if (bean.videoCount > 0) {
                        tempList.add(bean);
                    }
                }
            }
        }
        Log.d("contact",
                "ContactManager::getWithVideoList() synchronized mContactList end");
        return tempList;
    }

    /**
     * 模糊查找联系人列表（ID或用户名）
     *
     * @param key
     * @return
     */
    public List<ContactBean> getContactsByIdOrName(String key) {
        key = key.toUpperCase(Locale.ENGLISH);
        List<ContactBean> tempList = new ArrayList<ContactBean>();
        String keyEncode = Pattern.quote(key);
        Pattern p = Pattern.compile("^(.*" + keyEncode + ".*)$");
        Log.d("contact",
                "ContactManager::getContactsByIdOrName() synchronized mContactList begin");
        synchronized (mContactList) {
            for (ContactBean bean : mContactList) {
                if ((p.matcher(bean.userId.toUpperCase(Locale.ENGLISH)).find())
                        || (p.matcher(bean.userName
                        .toUpperCase(Locale.ENGLISH)).find())) {
                    tempList.add(bean);
                }
            }
        }
        Log.d("contact",
                "ContactManager::getContactsByIdOrName() synchronized mContactList end");
        return tempList;
    }

    /**
     * 删除指定联系人
     *
     * @param userId
     */
    public void deleteContactByUserId(String[] userId) {
        synchronized (mContactList) {
            for (int i = 0; i < userId.length; i++) {
                if (mContactsMap.containsKey(userId[i])) {
                    ContactBean bean = mContactsMap.get(userId[i]);
                    mContactList.remove(bean);
                    mContactsMap.remove(userId[i]);
                }
            }
        }
        /* 通知界面更新 */
        onContactListUpdateCallback();
    }


    /**
     * ================================= Live chat 回调单线程处理，解决ContactList 同步问题  =================================
     */
    /**
     * 发送消息增加联系人
     * @param userId
     * @param userName
     * @param photoUrl
     */
    public void updateOrAddContactBySendMessage(String userId, String userName, String photoUrl){
        LCUserItem userItem = mLiveChatManager.GetUserWithId(userId);
        if (userItem != null) {
            synchronized (mContactList) {
                ContactBean contactBean = mContactsMap.get(userItem.userId);
                if(contactBean == null){
                    contactBean = new ContactBean();
                    contactBean.userId = userId;
                    contactBean.userName = userName;
                    contactBean.photoURL = photoUrl;
                    mContactList.add(contactBean);
                    mContactsMap.put(userId, contactBean);
                }
                updateContactMsgHint(userItem.userId, contactBean);
            }

            //通知界面刷新
            onContactListUpdateCallback();

            //刷新用户信息
            getLadyInfoForContact(userItem.userId);
        }
    }

    /**
     * 根据联系人ID更新或添加联系人
     *
     * @param userId
     */
    public void updateOrAddContact(final String userId) {
        Runnable task = new Runnable() {

            @Override
            public void run() {
                // TODO Auto-generated method stub
                addOrUpdateContact(userId, false);
            }
        };
        handler.post(task);
    }

    /**
     * 获取联系人返回添加联系人
     */
    private void onGetContactsCallback(final LiveChatTalkUserListItem[] list) {
        Runnable task = new Runnable() {

            @Override
            public void run() {
                // TODO Auto-generated method stub
                addOrUpdateContact(list);
            }
        };
        handler.post(task);
    }

    /**
     * 女士状态更新，通知联系人刷新
     */
    private void onReceiveUpdateStatus() {
        Runnable task = new Runnable() {

            @Override
            public void run() {
                onContactListUpdateCallback();
            }
        };
        handler.post(task);
    }

    /**
     * 收到会话结束通知，清除msgHint并通知界面更新
     * @param userItem
     */
    private void onReceiveEndTalkUpdate(final LCUserItem userItem){
        Runnable task = new Runnable() {

            @Override
            public void run() {
                //会话结束，清除最后一条hit提示
                if(userItem != null){
                    synchronized (mContactList){
                        ContactBean contactBean = mContactsMap.get(userItem.userId);
                        if(contactBean != null){
                            contactBean.msgHint = "";
                        }
                    }
                }
                onContactListUpdateCallback();
            }
        };
        handler.post(task);
    }

    /**
     * 收到聊天信息（文字，语音，图片，高级表情），更新联系人状态
     *
     * @param item
     */
    private void onReceiveMessage(final LCMessageItem item) {
        Runnable task = new Runnable() {

            @Override
            public void run() {
                // Add by Max for show notification
                if (item.getUserItem().isInCharging()) {
                    // 消息为inchat用户发出
                    if ((item.getUserItem().userId.compareTo(mWomanId) != 0) ||
                            SystemUtils.isBackground(mContext)) {
                        // 非当前在聊女士
                        Message msg = Message.obtain();
                        RequestBaseResponse obj = new RequestBaseResponse();
                        obj.body = item;
                        msg.obj = obj;
                        msg.what = RequestFlag.REQUEST_LIVECHAT_NOTIFICATION_SUCCESS
                                .ordinal();
                        mHandler.sendMessage(msg);
                    }
                }
                //处理联系人相关
                if (item != null && item.getUserItem() != null) {

                    //本地维护唯独消息数目
                    synchronized (mContactList) {
                        if (mWomanId != null) {
                            if (!item.fromId.equals(mWomanId)) {
                                /* 不是当前正在聊天的对象且室联系人发来消息，通知未读条数 */
                                if (mContactsMap.containsKey(item.fromId)) {
                                    mContactsMap.get(item.fromId).unreadCount++;
                                }
                            }
                        }
                    }

                    addOrUpdateContact(item.getUserItem().userId, true);

                    //邀请处理
                    if (!item.getUserItem().isInSession()) {
                        /* 通知邀请更新 */
                        onNewInviteUpdateCallback();
                    }
                }
            }
        };
        handler.post(task);
    }

    /**
     * 和女士聊天信息历史列表更新，更新联系人状态
     *
     * @param userItems
     */
    private void onReceiveHistoryMessages(final LCUserItem[] userItems) {
        Runnable task = new Runnable() {

            @Override
            public void run() {
                // TODO Auto-generated method stub
                if (userItems != null) {
                    for (LCUserItem userItem : userItems) {
                        if (userItem != null) {
                            addOrUpdateContact(userItem.userId, true);
                        }
                    }
                }
            }
        };
        handler.post(task);
    }

    /**
     * 指定女士聊天信息历史列表更新，更新联系人状态
     */
    private void onReceiveHistoryMessage(final LCUserItem userItem) {
        /* 获取在聊最近聊天列表，需更新联系人 */
        Runnable task = new Runnable() {

            @Override
            public void run() {
                // TODO Auto-generated method stub
                if (userItem != null) {
                    addOrUpdateContact(userItem.userId, true);
                }
            }
        };
        handler.post(task);

    }

    /**
     * 在聊列表更新，更新联系人列表
     */
    private void onReceiveTalkList() {
        Runnable task = new Runnable() {

            @Override
            public void run() {
                // TODO Auto-generated method stub
                List<LCUserItem> chatingList = mLiveChatManager.GetChatingUsers();
                if (chatingList != null) {
                    for (LCUserItem userItem : chatingList) {
                        if (userItem != null) {
                            addOrUpdateContact(userItem.userId, true);
                        }
                    }
                }
            }
        };
        handler.post(task);
    }

    /**
     * 聊天状态改变时间接收，更新主界面右侧下方邀请列表状态（邀请转在聊等）
     */
    private void onReceiveTalkEvent(LCUserItem userItem) {
        Runnable task = new Runnable() {

            @Override
            public void run() {
                onNewInviteUpdateCallback();
            }
        };
        handler.post(task);
    }

    /**
     * 发送消息成功通知刷新邀请列表
     */
    private void onSendMessageUpdate(){
        Runnable task = new Runnable() {

            @Override
            public void run() {
                onNewInviteUpdateCallback();
            }
        };
        handler.post(task);
    }


    /* =================================== 2018/11/20 Hardy 未读消息数 逻辑处理 ==================================== */

    /**
     * 注册未读消息更新监听
     *
     * @param callback
     */
    public void registerChatUnreadUpdateUpdate(OnChatUnreadUpdateCallback callback) {
        Log.d("contact",
                "ContactManager::registerChatUnreadUpdateUpdate() synchronized mChatUnreadUpdateCallbackList begin");
        synchronized (mChatUnreadUpdateCallbackList) {
            if (mChatUnreadUpdateCallbackList != null) {
                mChatUnreadUpdateCallbackList.add(callback);
            }
        }
        Log.d("contact",
                "ContactManager::registerChatUnreadUpdateUpdate() synchronized mChatUnreadUpdateCallbackList end");
    }

    /**
     * 注销未读消息更新监听
     *
     * @param callback
     */
    public void unregisterChatUnreadUpdateUpdata(OnChatUnreadUpdateCallback callback) {
        Log.d("contact",
                "ContactManager::unregisterChatUnreadUpdateUpdata() synchronized mChatUnreadUpdateCallbackList begin");
        synchronized (mChatUnreadUpdateCallbackList) {
            if (mChatUnreadUpdateCallbackList != null) {
                if (mChatUnreadUpdateCallbackList.contains(callback)) {
                    mChatUnreadUpdateCallbackList.remove(callback);
                }
            }
        }
        Log.d("contact",
                "ContactManager::unregisterChatUnreadUpdateUpdata() synchronized mChatUnreadUpdateCallbackList end");
    }

    /**
     * 来新的未读消息，通知界面
     */
    private void onChatUnreadUpdateCallback() {
        Log.d("contact",
                "ContactManager::onChatUnreadUpdateCallback() synchronized mChatUnreadUpdateCallbackList begin");
        synchronized (mChatUnreadUpdateCallbackList) {
            // 未读数
            int unreadChatCount = getAllUnreadCount();
            // 未读小红点
            int unreadInviteCount = getInviteListSize();

            for (OnChatUnreadUpdateCallback callback : mChatUnreadUpdateCallbackList) {
                callback.onUnreadUpdate(unreadChatCount, unreadInviteCount);
            }
        }
        Log.d("contact",
                "ContactManager::onChatUnreadUpdateCallback() synchronized mChatUnreadUpdateCallbackList end");
    }

    public int getInviteListSize(){
        List<LCUserItem> allInviteList = getInviteList();
        int unreadInviteCount = ListUtils.isList(allInviteList) ? allInviteList.size() : 0;
        return unreadInviteCount;
    }
    /* =================================== 2018/11/20 Hardy 未读消息数 逻辑处理 ==================================== */



    /* =================================== Invite 逻辑处理 ==================================== */


    /**
     * 2018/11/20 Hardy
     * 获取邀请列表
     *
     * @return
     */
    public List<LCUserItem> getInviteList() {
        return mLiveChatManager.GetInviteUsers();
    }

    /**
     * 注册新邀请消息更新监听
     *
     * @param callback
     */
    public void registerInviteUpdate(OnNewInviteUpdateCallback callback) {
        Log.d("contact",
                "ContactManager::registerInviteUpdate() synchronized mInviteCallbackList begin");
        synchronized (mInviteCallbackList) {
            if (mInviteCallbackList != null) {
                mInviteCallbackList.add(callback);
            }
        }
        Log.d("contact",
                "ContactManager::registerInviteUpdate() synchronized mInviteCallbackList end");
    }

    /**
     * 注销新邀请消息更新监听
     *
     * @param callback
     */
    public void unregisterInviteUpdata(OnNewInviteUpdateCallback callback) {
        Log.d("contact",
                "ContactManager::unregisterInviteUpdata() synchronized mInviteCallbackList begin");
        synchronized (mInviteCallbackList) {
            if (mInviteCallbackList != null) {
                if (mInviteCallbackList.contains(callback)) {
                    mInviteCallbackList.remove(callback);
                }
            }
        }
        Log.d("contact",
                "ContactManager::unregisterInviteUpdata() synchronized mInviteCallbackList end");
    }

    /**
     * 来新邀请，通知界面
     */
    private void onNewInviteUpdateCallback() {
        Log.d("contact",
                "ContactManager::onNewInviteUpdateCallback() synchronized mInviteCallbackList begin");
        synchronized (mInviteCallbackList) {
            for (OnNewInviteUpdateCallback callback : mInviteCallbackList) {
                callback.onNewInviteUpdate();
            }

            // 2018/11/20 Hardy 未读数更新，依赖邀请列表更新
            onChatUnreadUpdateCallback();
        }
        Log.d("contact",
                "ContactManager::onNewInviteUpdateCallback() synchronized mInviteCallbackList end");
    }

    /* ======================= ContactManager 注销回收重置逻辑 =================== */

    /**
     * 注销时，通知界面列表清除，防止聊天界面等打开列表时异常，注销列表不清楚
     */
    private void onLogoutDataUpdate() {
        Runnable task = new Runnable() {

            @Override
            public void run() {
                onContactListUpdateCallback();
            }
        };
        handler.post(task);
    }

    /**
     * 监听livechat的来消息，邮件推送等
     */
    private void addLiveChatListener() {
        mLiveChatManager.RegisterOtherListener(this);
        mLiveChatManager.RegisterEmotionListener(this);
        mLiveChatManager.RegisterMessageListener(this);
        mLiveChatManager.RegisterPhotoListener(this);
        mLiveChatManager.RegisterVideoListener(this);
        mLiveChatManager.RegisterVoiceListener(this);
        mLiveChatManager.RegisterTryTicketListener(this);
        mLiveChatManager.registerCamShareStatusListener(this);
        mLiveChatManager.RegisterMagicIconListener(this);
    }

    /**
     * 重置状态
     */
    private void resetContact() {
        Log.d("contact",
                "ContactManager::resetContact() synchronized mContactList begin");
        synchronized (mContactList) {
            mContactList.clear();
            mContactsMap.clear();
            handler.removeCallbacks(statusUpdate);
        }
        Log.d("contact",
                "ContactManager::resetContact() synchronized mContactList end");
    }

    @Override
    public void onLogin(boolean isSuccess, int errno, String errmsg, LoginItem item) {

    }

    @Override
    public void onLogout(boolean mannual) {
        resetContact();
        onLogoutDataUpdate();
    }

    /*** Livechat Listener */

    /* ======================= LiveChatManagerOtherListener =================== */
    @Override
    public void OnLogin(LiveChatErrType errType, String errmsg,
                        boolean isAutoLogin) {
        /* 联系人下载成功开始更新在线状态 */
        if (errType == LiveChatErrType.Success) {
            handler.removeCallbacks(statusUpdate);
            handler.post(statusUpdate);
        }
    }

    @Override
    public void OnLogout(LiveChatErrType errType, String errmsg,
                         boolean isAutoLogin) {

    }

    @Override
    public void OnGetTalkList(LiveChatErrType errType, String errmsg) {
        /* 获取在聊列表，更新联系人列表 */
        onReceiveTalkList();
    }

    @Override
    public void OnGetHistoryMessage(boolean success, String errno,
                                    String errmsg, LCUserItem userItem) {
        /* 获取指定用户聊天历史，更新联系人列表 */
        onReceiveHistoryMessage(userItem);
    }

    @Override
    public void OnGetUsersHistoryMessage(boolean success, String errno,
                                         String errmsg, LCUserItem[] userItems) {
        onReceiveHistoryMessages(userItems);
    }

    @Override
    public void OnSetStatus(LiveChatErrType errType, String errmsg) {

    }

    @Override
    public void OnGetUserStatus(LiveChatErrType errType, String errmsg,
                                LCUserItem[] userList) {
        onReceiveUpdateStatus();
    }

    @Override
    public void OnGetUsersInfo(LiveChatErrType errType, String errmsg, String[] userIds,
                               LiveChatTalkUserListItem[] itemList) {
        // TODO Auto-generated method stub

    }

    @Override
    public void OnGetContactList(LiveChatErrType errType, String errmsg, LiveChatTalkUserListItem[] list) {
        if (errType == LiveChatErrType.Success) {
            onGetContactsCallback(list);
        }
    }

    @Override
    public void OnUpdateStatus(LCUserItem userItem) {
        /* Live chat 女士状态更新推送 */
        onReceiveUpdateStatus();
    }

    @Override
    public void OnChangeOnlineStatus(LCUserItem userItem) {

    }

    @Override
    public void OnRecvKickOffline(KickOfflineType kickType) {
    }

    @Override
    public void OnRecvEMFNotice(String fromId, TalkEmfNoticeType noticeType) {

    }

    /*
     * ======================= LiveChatManagerEmotionListener
     * ===================
     */

    @Override
    public void OnGetEmotionConfig(boolean success, String errno,
                                   String errmsg, OtherEmotionConfigItem item) {

    }

    @Override
    public void OnSendEmotion(LiveChatErrType errType, String errmsg,
                              LCMessageItem item) {

    }

    @Override
    public void OnRecvEmotion(LCMessageItem item) {
        /* 收到高级表情，更新联系人列表 */
        onReceiveMessage(item);
    }

    @Override
    public void OnGetEmotionImage(boolean success, LCEmotionItem emotionItem) {

    }

    @Override
    public void OnGetEmotionPlayImage(boolean success, LCEmotionItem emotionItem) {

    }

    @Override
    public void OnGetEmotion3gp(boolean success, LCEmotionItem emotionItem) {

    }

    /*
     * ======================= LiveChatManagerMessageListener
     * ===================
     */
    @Override
    public void OnSendMessage(LiveChatErrType errType, String errmsg,
                              LCMessageItem item) {
        onSendMessageUpdate();
    }

    @Override
    public void OnRecvMessage(LCMessageItem item) {
        /* 收到聊天信息，更新列表 */
        onReceiveMessage(item);
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
    public void OnSendMessageListFail(LiveChatErrType errType,
                                      ArrayList<LCMessageItem> msgList) {

    }

    /* ======================= LiveChatManagerPhotoListener =================== */
    @Override
    public void OnSendPhoto(LiveChatErrType errType, String errno,
                            String errmsg, LCMessageItem item) {

    }

    @Override
    public void OnPhotoFee(boolean success, String errno, String errmsg,
                           LCMessageItem item) {

    }

    @Override
    public void OnGetPhoto(LiveChatErrType errType, String errno,
                           String errmsg, LCMessageItem item) {

    }

    @Override
    public void OnRecvPhoto(LCMessageItem item) {
        /* 获取照片类信息，更新联系人 */
        onReceiveMessage(item);
    }

    /* ======================= LiveChatManagerVideoListener =================== */
    @Override
    public void OnGetVideoPhoto(LiveChatErrType errType, String errno,
                                String errmsg, String userId, String inviteId, String videoId,
                                VideoPhotoType type, String filePath,
                                ArrayList<LCMessageItem> msgList) {

    }

    @Override
    public void OnVideoFee(boolean success, String errno, String errmsg,
                           LCMessageItem item) {

    }

    @Override
    public void OnStartGetVideo(String userId, String videoId, String inviteId,
                                String videoPath, ArrayList<LCMessageItem> msgList) {

    }

    @Override
    public void OnGetVideo(LiveChatErrType errType, String userId,
                           String videoId, String inviteId, String videoPath,
                           ArrayList<LCMessageItem> msgList) {

    }

    @Override
    public void OnRecvVideo(LCMessageItem item) {
        /* 获取小视频信息，更新联系人 */
        onReceiveMessage(item);
    }

    /* ======================= LiveChatManagerVideoListener =================== */
    @Override
    public void OnSendVoice(LiveChatErrType errType, String errno,
                            String errmsg, LCMessageItem item) {

    }

    @Override
    public void OnGetVoice(LiveChatErrType errType, String errmsg,
                           LCMessageItem item) {

    }

    @Override
    public void OnRecvVoice(LCMessageItem item) {
        /* 收取语音聊天信息 */
        onReceiveMessage(item);
    }

    /*
     * ======================= LiveChatManagerTryTicketListener
     * ===================
     */
    @Override
    public void OnUseTryTicket(LiveChatErrType errType, String errno,
                               String errmsg, String userId, TryTicketEventType eventType) {

    }

    @Override
    public void OnRecvTryTalkBegin(LCUserItem userItem, int time) {

    }

    @Override
    public void OnRecvTryTalkEnd(LCUserItem userItem) {

    }

    @Override
    public void OnCheckCoupon(boolean success, String errno, String errmsg,
                              Coupon item) {

    }

    @Override
    public void OnEndTalk(LiveChatErrType errType, String errmsg,
                          LCUserItem userItem) {
        onReceiveEndTalkUpdate(userItem);
    }

    @Override
    public void OnRecvTalkEvent(LCUserItem item) {
        if (item != null) {
            onReceiveTalkEvent(item);
        }
    }

    /*
     * ======================= LiveChatManagerMagicIconListener
     * ===================
     */
    @Override
    public void OnGetMagicIconConfig(boolean success, String errno,
                                     String errmsg, MagicIconConfig item) {
        // TODO Auto-generated method stub

    }

    @Override
    public void OnSendMagicIcon(LiveChatErrType errType, String errmsg,
                                LCMessageItem item) {
        // TODO Auto-generated method stub

    }

    @Override
    public void OnRecvMagicIcon(LCMessageItem item) {
        /* 收到小高级表情，更新联系人列表 */
        onReceiveMessage(item);
    }

    @Override
    public void OnGetMagicIconSrcImage(boolean success,
                                       LCMagicIconItem magicIconItem) {
        // TODO Auto-generated method stub

    }

    @Override
    public void OnGetMagicIconThumbImage(boolean success,
                                         LCMagicIconItem magicIconItem) {
        // TODO Auto-generated method stub

    }

    @Override
    public void OnGetLadyCamStatus(LiveChatErrType errType, String errmsg,
                                   String womanId, boolean isCam) {
        //女士Cam状态改变通知，刷新界面
        onReceiveUpdateStatus();
    }

    @Override
    public void OnGetUsersCamStatus(LiveChatErrType errType, String errmsg,
                                    LiveChatUserCamStatus[] userIds) {
        //女士Cam状态改变通知，刷新界面
        onReceiveUpdateStatus();
    }

    @Override
    public void OnRecvLadyCamStatus(String userId, UserStatusProtocol statuType) {
        //女士Cam状态改变通知，刷新界面
        onReceiveUpdateStatus();
    }

    @Override
    public void OnGetUserInfo(LiveChatErrType errType, String errmsg,
                              String userId, LiveChatTalkUserListItem item) {
        // TODO Auto-generated method stub

    }

    @Override
    public void OnGetSessionInfo(LiveChatErrType errType, String errmsg,
                                 String userId, LiveChatSessionInfoItem item) {
        //会话状态改变
        onReceiveUpdateStatus();
    }

    /*------------------------ CamShare状态改变刷新联系人列表 ----------------------------------------*/
    @Override
    public void onCamShareInviteStart(String userId) {
        //通知界面添加联系人且刷新状态
        updateOrAddContact(userId);
    }

    @Override
    public void onCamShareInviteFinish(boolean isSuccess,
                                       CamShareClientErrorType errorType, String userId, String inviteId) {
        //应邀时添加联系人失败时更新状态
        updateOrAddContact(userId);
    }

    @Override
    public void onStreamMediaConnected(String userId) {
        // TODO Auto-generated method stub

    }

    @Override
    public void onStreamMediaReconnect(String userId) {
        // TODO Auto-generated method stub
    }

    @Override
    public void onCamShareClientFailed(String userId,
                                       CamShareClientErrorType errType) {
        // TODO Auto-generated method stub
        //通知界面刷新会话状态
        onReceiveUpdateStatus();
    }
}
