package com.qpidnetwork.livemodule.liveshow.livechat;


import android.os.Message;

import com.qpidnetwork.livemodule.livechat.contact.ContactBean;
import com.qpidnetwork.livemodule.livechat.contact.ContactManager;
import com.qpidnetwork.livemodule.livechat.contact.OnLCContactUpdateCallback;
import com.qpidnetwork.qnbridgemodule.util.ListUtils;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.List;

/**
 * 2018/11/19 Hardy
 * Chat List
 */
public class ChatListFragment extends ChatOrInvitationListFragment implements OnLCContactUpdateCallback {

    private static final int ACTION_CONTACT_UPDATE = 1;

    private ContactManager mContactManager;

    public ChatListFragment() {
        // Required empty public constructor
    }

    @Override
    protected void initView() {
        mCurViewType = VIEW_TYPE_CHAT_LIST;

        super.initView();

        mContactManager = ContactManager.getInstance();
        mContactManager.registerContactUpdate(this);
    }

    @Override
    protected void initData() {
        super.initData();

        queryList();
    }

    @Override
    public void onResume() {
        super.onResume();
        Log.i("info","--------- ChatListFragment ------------ onResume");
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

        if (mContactManager != null) {
            mContactManager.unregisterContactUpdata(this);
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
//        queryList();
//    }


    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        switch (msg.what) {
            case ACTION_CONTACT_UPDATE:
                List<ContactBean> contactList = (List<ContactBean>) msg.obj;
                updateList(contactList);
                break;

            default:
                break;
        }
    }

    private void queryList() {
        List<ContactBean> contactList = mContactManager.getContactList();

        updateList(contactList);

        onRefreshComplete();
    }

    private void updateList(List<ContactBean> contactList) {
        if (ListUtils.isList(contactList)) {
            mAdapter.replaceList(contactList);
            hideNodataPage();
        } else {
            mAdapter.clearList();
            showNodataPage();
        }

        // 回调外层更新未读数小红点 UI
        if (mOnUnreadMsgListener != null) {
            int count = mContactManager.getAllUnreadCount();
            mOnUnreadMsgListener.onUnreadChatMsg(count);
        }
    }

    //======================    interface   =============================
    @Override
    public void onContactUpdate(List<ContactBean> contactList) {
        /* 联系人列表更新处理 */
        Message msg = Message.obtain();
        msg.what = ACTION_CONTACT_UPDATE;
        msg.obj = contactList;
        sendUiMessage(msg);
    }
    //======================    interface   =============================
}
