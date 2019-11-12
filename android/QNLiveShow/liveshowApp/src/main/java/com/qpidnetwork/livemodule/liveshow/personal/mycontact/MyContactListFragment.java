package com.qpidnetwork.livemodule.liveshow.personal.mycontact;


import android.os.Message;
import android.support.v7.widget.LinearLayoutManager;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseRecyclerViewFragment;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetMyContactListCallback;
import com.qpidnetwork.livemodule.httprequest.item.ContactItem;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentPagerAdapter4Top;
import com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomTransitionActivity;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.personal.book.BookPrivateActivity;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder;
import com.qpidnetwork.qnbridgemodule.util.ListUtils;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;

import java.util.Arrays;
import java.util.List;

/**
 * 2019/8/9 Hardy
 * My Contacts 列表
 */
public class MyContactListFragment extends BaseRecyclerViewFragment implements OnGetMyContactListCallback {

    private static final int GET_LIST_CALLBACK = 1;

    private MyContactsAdapter mAdapter;

    public MyContactListFragment() {
        // Required empty public constructor
    }

    @Override
    protected void initView(View view) {
        super.initView(view);

        setRootContentBackgroundColor(R.color.white);

        // recyclerView
        mAdapter = new MyContactsAdapter(mContext);
        mAdapter.setMyContactsOperateListener(new MyContactsAdapter.IMyContactsOperateListener() {
            @Override
            public void onClickIcon(int pos) {
                // 暂时无用
            }

            @Override
            public void onClickItem(int pos) {
                // 主播个人详情
                ContactItem bean = mAdapter.getItemBean(pos);
                if (bean != null) {
                    AnchorProfileActivity.launchAnchorInfoActivty(mContext,
                            mContext.getResources().getString(R.string.live_webview_anchor_profile_title),
                            bean.anchorId, false, AnchorProfileActivity.TagType.Album);
                }
            }

            @Override
            public void onClickFunClick(int pos, MyContactsFunEnum myContactsFunEnum) {
                ContactItem bean = mAdapter.getItemBean(pos);
                if (bean != null) {
                    handlerItemClick(bean, myContactsFunEnum);
                }
            }
        });
        LinearLayoutManager lin = new LinearLayoutManager(mContext);
        refreshRecyclerView.getRecyclerView().setLayoutManager(lin);
        refreshRecyclerView.getRecyclerView().setHasFixedSize(true);
        refreshRecyclerView.setAdapter(mAdapter);

        // refresh
        refreshRecyclerView.setEnableRefresh(true);
        refreshRecyclerView.setEnableLoadMore(false);

        // emptyView
        setCustomEmptyViewHasRefresh(getEmptyView());
        hideNodataPage();
    }

    @Override
    protected void initData() {
        super.initData();

        // 第一次进来，先显示 loading
        showLoadingProcess();
        loadListData();
    }

    @Override
    public void onPullDownToRefresh() {
        super.onPullDownToRefresh();
        loadListData();
    }

    @Override
    public void onReloadDataInEmptyView() {
        super.onReloadDataInEmptyView();
        // 无数据界面的下拉刷新
        loadListData();
    }

    @Override
    protected void onDefaultErrorRetryClick() {
        super.onDefaultErrorRetryClick();
        // 展示 loading
        showLoadingProcess();
        // 出错重试
        loadListData();
    }

    private void loadListData() {
        LiveRequestOperator.getInstance().GetMyContactList(0, 500, this);
    }

    private void handlerItemClick(ContactItem bean, MyContactsFunEnum type) {
        if (bean == null) {
            return;
        }
        // 参考 LiveRoomListAdapter 的点击跳转事件
        switch (type) {
            case ONE_ON_ONE:
                startActivity(LiveRoomTransitionActivity.getIntent(mContext,
                        LiveRoomTransitionActivity.CategoryType.Audience_Invite_Enter_Room,
                        bean.anchorId, bean.nickName, bean.avatarImg, "", ""));
                break;

            case CHAT:
                String chatUrl = LiveUrlBuilder.createLiveChatActivityUrl(bean.anchorId, bean.nickName, bean.avatarImg);
                new AppUrlHandler(mContext).urlHandle(chatUrl);
                break;

            case MAIL:
                String sendMailUrl = LiveUrlBuilder.createSendMailActivityUrl(bean.anchorId);
                new AppUrlHandler(mContext).urlHandle(sendMailUrl);
                break;

            case BOOKING:
                startActivity(BookPrivateActivity.getIntent(mContext, bean.anchorId, bean.nickName));
                break;

            default:
                break;
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        HttpRespObject response = (HttpRespObject) msg.obj;

        List<ContactItem> list = (List<ContactItem>) response.data;

        switch (msg.what) {
            case GET_LIST_CALLBACK: {
                // 隐藏 loading
                hideLoadingProcess();

                if (response.isSuccess) {
                    if (ListUtils.isList(list)) {
                        hideNodataPage();
                        hideErrorPage();

                        mAdapter.setData(list);
                    } else if (mAdapter.getItemCount() == 0) {
                        mAdapter.setData(null);
                        // 展示空数据页
                        showNodataPage();
                    }
                } else {
                    if (mAdapter.getItemCount() == 0) {
                        // 展示出错页
                        showErrorPage();
                    } else {
                        // 出错，暂时提示
                        ToastUtil.showToast(getContext(), response.errMsg);
                    }
                }

                // 恢复初始化状态
                onRefreshComplete();
            }
            break;

            default:
                break;
        }
    }

    private View getEmptyView() {
        View view = LayoutInflater.from(mContext).inflate(R.layout.view_chat_or_invitation_list_empty, getEmptyRootView(), false);

        TextView mTvTitle = view.findViewById(R.id.tvEmptyTitle);
        TextView mTvDesc = view.findViewById(R.id.tvEmptyDesc);
        ImageView mIvIcon = view.findViewById(R.id.tvEmptyIcon);

        mIvIcon.setVisibility(View.VISIBLE);
        mTvTitle.setText(R.string.my_contact_list_empty_title);
        mTvDesc.setText(R.string.my_contact_list_empty_desc);

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

    @Override
    public void onGetMyContactList(boolean isSuccess, int errCode, String errMsg, ContactItem[] contactList, int tatalCount) {
        List<ContactItem> list = null;

        if (contactList != null) {
            list = Arrays.asList(contactList);
        }

        HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, list);

        Message msg = Message.obtain();
        msg.what = GET_LIST_CALLBACK;
        msg.obj = response;

        sendUiMessage(msg);
    }
}
