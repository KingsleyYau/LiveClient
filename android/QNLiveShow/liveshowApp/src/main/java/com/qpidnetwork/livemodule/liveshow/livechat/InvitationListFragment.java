package com.qpidnetwork.livemodule.liveshow.livechat;


import android.os.Message;

import com.qpidnetwork.livemodule.livechat.LCMessageItem;
import com.qpidnetwork.livemodule.livechat.LCUserItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerOtherListener;
import com.qpidnetwork.livemodule.livechat.LiveChatMessageHelper;
import com.qpidnetwork.livemodule.livechat.contact.ContactBean;
import com.qpidnetwork.livemodule.livechat.contact.ContactManager;
import com.qpidnetwork.livemodule.livechat.contact.OnNewInviteUpdateCallback;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatSessionInfoItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatUserCamStatus;
import com.qpidnetwork.qnbridgemodule.util.ListUtils;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

/**
 * 2018/11/19 Hardy
 * Invitation List
 * <p>
 * 按照原有邀请列表获取方式获取生成即可，
 * 即参考 QN 的 LivechatInviteListActivity
 */
public class InvitationListFragment extends ChatOrInvitationListFragment implements OnNewInviteUpdateCallback,
        LiveChatManagerOtherListener {

    // 列表的最大 item 数，参照 QN
    private static final int MAX_LIST_SIZE = 99;
    // action
    private static final int ACTION_NEW_INVITE = 1;     // 有新邀请消息
    private static final int ACTION_GET_USER_INFO = 2;  // 批量获取用户详情
    // manager
    private LiveChatManager mLiveChatManager;
    private ContactManager mContactManager;
    // list
    private List<ContactBean> mInviteListCache;         // 女士邀请缓存
    private List<ContactBean> mInviteList;             // 由于有异步修改列表数据，数据的变动在这做修改，最终赋值给 mInviteList，以免用户边滑动数据边刷新的问题
    // map
    private HashMap<String, String> mCurrInviteMap;        //存储所有当前邀请列表需要获取详情更新的对象列表

    public InvitationListFragment() {
        // Required empty public constructor
    }

    @Override
    protected void initView() {
        mCurViewType = VIEW_TYPE_INVITATION_LIST;

        super.initView();

        mLiveChatManager = LiveChatManager.getInstance();
        mLiveChatManager.RegisterOtherListener(this);
        mContactManager = ContactManager.getInstance();
        mContactManager.registerInviteUpdate(this);

        mInviteList = new ArrayList<>();
        mInviteListCache = new ArrayList<>();
        mCurrInviteMap = new HashMap<>();
    }

    @Override
    protected void initData() {
        super.initData();

        updateListData();
    }


    @Override
    public void onResume() {
        super.onResume();
        Log.i("info","--------- InvitationListFragment ------------ onResume");
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

        // 反注册
        if (mContactManager != null) {
            mContactManager.unregisterInviteUpdata(this);
        }
        if (mLiveChatManager != null) {
            mLiveChatManager.UnregisterOtherListener(this);
        }

        //清空缓存
        if (mInviteListCache != null) {
            mInviteListCache.clear();
        }
    }

    @Override
    protected void onItemClickEvent(int position, ContactBean item) {
        super.onItemClickEvent(position, item);

    }

//    @Override
//    public void onPullDownToRefresh() {
//        super.onPullDownToRefresh();
//
//        updateListData();
//    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        switch (msg.what) {
            case ACTION_GET_USER_INFO:
                LiveChatTalkUserListItem[] itemArray = (LiveChatTalkUserListItem[]) msg.obj;
                if (itemArray != null) {
                    for (LiveChatTalkUserListItem item : itemArray) {
                        updateListView(item);
                    }
                }
                break;

            case ACTION_NEW_INVITE:
                updateListData();
                break;

            default:
                break;
        }
    }


    /**
     * 刷新列表
     * （使用缓存中的数据替换掉真实数据再刷新）
     */
    private void refreshList() {
        if (mAdapter != null) {
            mInviteList.clear();
            mInviteList.addAll(mInviteListCache);
            mAdapter.replaceList(mInviteList);


            // Hardy
            if (ListUtils.isList(mInviteList)) {
                hideNodataPage();
            } else {
                showNodataPage();
            }
            // 回调外层更新未读数小红点 UI
            if (mOnUnreadMsgListener != null) {
                mOnUnreadMsgListener.onUnreadInviteMsg(ListUtils.isList(mInviteList));
            }
        }
    }

    /**
     * 获取女士详情返回
     *
     * @param item
     */
    private void updateListView(LiveChatTalkUserListItem item) {
        if (mInviteListCache != null) {
            int size = mInviteListCache.size();

            for (int i = 0; i < size; i++) {
                ContactBean inviteListItem = mInviteListCache.get(i);

                if (inviteListItem.userId.equals(item.userId)) {
                    //更新用户名称，防止自动邀请时用户名未更新
                    mLiveChatManager.GetUserWithId(inviteListItem.userId).userName = item.userName;

                    inviteListItem.userName = item.userName;
                    inviteListItem.photoURL = item.avatarImg;
                }
            }
        }

        //整体更新解决单个更新获取view异常导致Crash
        refreshList();
    }


    /**
     * 有新邀请更新数据
     */
    private void updateListData() {
        List<LCUserItem> allInviteList = mContactManager.getInviteList();

        //处理最多只显示最近 99 条
        List<LCUserItem> inviteList = new ArrayList<>();
        int inviteLength = allInviteList.size() > MAX_LIST_SIZE ? MAX_LIST_SIZE : allInviteList.size();
        for (int i = 0; i < inviteLength; i++) {
            inviteList.add(allInviteList.get(i));
        }

        mInviteListCache.clear();
        mCurrInviteMap.clear();

        if (inviteList != null) {
            for (LCUserItem item : inviteList) {
                LiveChatTalkUserListItem ladyInfo = mLiveChatManager.GetLadyInfoById(item.userId);

                ContactBean contactBean = new ContactBean();
                if (ladyInfo != null) {
                    contactBean.updateContactByLiveChatUserItem(ladyInfo);
                }else {
                    contactBean.userId = item.userId;
                    contactBean.userName = item.userName;
                }

                /*提示消息内容*/
                LCMessageItem lastMsg = item.getTheOtherLastMessage();
                if (lastMsg != null) {
//                    contactBean.msgHint = mContactManager.generateMsgHint(lastMsg);       // QN
                    contactBean.msgHint = LiveChatMessageHelper.generateMsgHint(mContext, lastMsg);

                    if (ladyInfo != null) {

                    } else {
                        mCurrInviteMap.put(item.userId, item.userId);
                    }

                    //新建一个列表数据
                    mInviteListCache.add(contactBean);
                }
            }


            /*10个分组获取女士详情更新*/
            List<String> userIdList = new ArrayList<>();
            Set<String> set = mCurrInviteMap.keySet();
            int i = 0;
            for (Iterator<String> iter = set.iterator(); iter.hasNext(); ) {
                String key = (String) iter.next();
                userIdList.add(key);
                i++;
                if (i >= 10) {
                    mLiveChatManager.GetUsersInfo((String[]) userIdList.toArray(new String[userIdList.size()]));
                    userIdList.clear();
                    i = 0;
                }
            }
            if (userIdList.size() > 0) {
                mLiveChatManager.GetUsersInfo((String[]) userIdList.toArray(new String[userIdList.size()]));
            }
        }

        // 更新界面
        refreshList();

        onRefreshComplete();
    }
    //======================    interface   =====================================

    @Override
    public void onNewInviteUpdate() {
        Message msg = Message.obtain();
        msg.what = ACTION_NEW_INVITE;
        sendUiMessage(msg);
    }

    @Override
    public void OnGetUserInfo(LiveChatClientListener.LiveChatErrType errType, String errmsg, String userId, LiveChatTalkUserListItem item) {

    }

    @Override
    public void OnGetUsersInfo(LiveChatClientListener.LiveChatErrType errType, String errmsg, String[] userIds, LiveChatTalkUserListItem[] itemList) {
        if (errType == LiveChatClientListener.LiveChatErrType.Success) {
            Message msg = Message.obtain();
            msg.what = ACTION_GET_USER_INFO;
            msg.obj = itemList;
            sendUiMessage(msg);
        }
    }

    @Override
    public void OnLogin(LiveChatClientListener.LiveChatErrType errType, String errmsg, boolean isAutoLogin) {

    }

    @Override
    public void OnLogout(LiveChatClientListener.LiveChatErrType errType, String errmsg, boolean isAutoLogin) {

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

//======================    interface   =====================================


}
