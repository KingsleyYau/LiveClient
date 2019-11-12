package com.qpidnetwork.livemodule.liveshow.livechat;


import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseListFragment;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.livechat.contact.ContactBean;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentPagerAdapter4Top;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder;
import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * 2018/11/17 Hardy
 * ChatList
 * Invitation List
 */
public class ChatOrInvitationListFragment extends BaseListFragment {

    private static final String VIEW_TYPE_KEY = "viewType";
    public static final int VIEW_TYPE_CHAT_LIST = 1;
    public static final int VIEW_TYPE_INVITATION_LIST = 2;

    // 当前的 ui 类型
    protected int mCurViewType = VIEW_TYPE_CHAT_LIST;
    protected ChatOrInvitationAdapter mAdapter;

    protected OnUnreadMsgListener mOnUnreadMsgListener;

    public ChatOrInvitationListFragment() {
        // Required empty public constructor
    }


    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        initView();
        initData();
    }

    @Override
    public void onResume() {
        super.onResume();
        Log.i("info", "--------- ChatOrInvitationListFragment ------------ onResume");
    }

    protected void initView() {
        mAdapter = new ChatOrInvitationAdapter(mContext);
        mAdapter.setViewType(mCurViewType);
        // 设置排序
        mAdapter.setComparator(ContactBean.getComparator());
        mAdapter.setOnItemClickListener(new ChatOrInvitationAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(int position, ContactBean item) {
                onItemClickEvent(position, item);
            }
        });
        getPullToRefreshListView().setAdapter(mAdapter);

        // 关闭上啦刷新
        closePullUpRefresh(true);
        closePullDownRefresh();

        setListViewBackgroundColor(R.color.white);

        // 初始化空数据
        setCustomEmptyView(getEmptyView());
    }

    protected void initData() {

    }

    protected void onItemClickEvent(int position, ContactBean item) {
        String urlChatActivity = LiveUrlBuilder.createLiveChatActivityUrl(item.userId, item.userName, item.photoURL);
        new AppUrlHandler(getActivity()).urlHandle(urlChatActivity);
    }

    private View getEmptyView() {
        View view = LayoutInflater.from(mContext).inflate(R.layout.view_chat_or_invitation_list_empty, getEmptyRootView(), false);

        TextView mTvTitle = view.findViewById(R.id.tvEmptyTitle);
        TextView mTvDesc = view.findViewById(R.id.tvEmptyDesc);

        switch (mCurViewType) {
            case VIEW_TYPE_CHAT_LIST:
                mTvTitle.setText(R.string.chat_list_empty_title);
                mTvDesc.setText(R.string.chat_list_empty_desc);
                break;

            case VIEW_TYPE_INVITATION_LIST:
                mTvTitle.setText(R.string.chat_invitation_empty_title);
                mTvDesc.setText(R.string.chat_invitation_empty_desc);
                break;

            default:
                break;
        }

        // 2019/10/17 根据公开直播间是否有权限来显示或隐藏与否
        View mLLPublicBroadcast = view.findViewById(R.id.llEmptyPublicBroadcast);
        LoginItem loginItem = LoginManager.getInstance().getLoginItem();
        if (loginItem != null && loginItem.userPriv != null) {
            mLLPublicBroadcast.setVisibility(loginItem.userPriv.isPublicRoomPriv ? View.VISIBLE : View.GONE);
        } else {
            mLLPublicBroadcast.setVisibility(View.GONE);
        }

        Button buttonRaised = view.findViewById(R.id.btnGuide);
        buttonRaised.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //点击空页引导，跳转回主页
                MainFragmentActivity.launchActivityWithListType(getActivity(), MainFragmentPagerAdapter4Top.TABS.TAB_INDEX_DISCOVER);
            }
        });

        return view;
    }




    //===================== interface   =====================================
    public void setOnUnreadMsgListener(OnUnreadMsgListener mOnUnreadMsgListener) {
        this.mOnUnreadMsgListener = mOnUnreadMsgListener;
    }

    /**
     * 是否有未读消息，告诉 Act 外层，更新 UI
     */
    public interface OnUnreadMsgListener {
        // 是否有邀请消息
        void onUnreadInviteMsg(boolean showRedCircle);

        // chat 列表消息数
        void onUnreadChatMsg(int unreadCount);
    }
    //===================== interface   =====================================
}
