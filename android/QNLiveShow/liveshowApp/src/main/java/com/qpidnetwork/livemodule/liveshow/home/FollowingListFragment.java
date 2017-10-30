package com.qpidnetwork.livemodule.liveshow.home;

import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Message;
import android.text.TextUtils;
import android.view.View;
import android.widget.AbsListView;
import android.widget.ImageView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseListFragment;
import com.qpidnetwork.livemodule.framework.canadapter.CanAdapter;
import com.qpidnetwork.livemodule.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.livemodule.framework.canadapter.CanOnItemListener;
import com.qpidnetwork.livemodule.httprequest.OnGetFollowingListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniLiveShow;
import com.qpidnetwork.livemodule.httprequest.item.AnchorLevelType;
import com.qpidnetwork.livemodule.httprequest.item.AnchorOnlineStatus;
import com.qpidnetwork.livemodule.httprequest.item.FollowingListItem;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomTransitionActivity;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.personal.book.BookPrivateActivity;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by Hunter Mun on 2017/9/6.
 */

public class FollowingListFragment extends BaseListFragment{

    private static final int GET_FOLLOWING_CALLBACK = 1;

    private CanAdapter<FollowingListItem> mAdapter;
    private List<FollowingListItem> mFollowingList = new ArrayList<FollowingListItem>();

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mAdapter = createAdapter();
        getPullToRefreshListView().addHeaderView(createHeaderView());
        getPullToRefreshListView().setAdapter(mAdapter);
        getPullToRefreshListView().setHeaderDividersEnabled(true);
        getPullToRefreshListView().setDivider(new ColorDrawable(getResources().getColor(R.color.hotlist_divider_color)));
        getPullToRefreshListView().setDividerHeight(DisplayUtil.dip2px(getActivity(), 4));
        onDefaultErrorRetryClick();
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            case GET_FOLLOWING_CALLBACK:{
                hideLoadingProcess();
                HttpRespObject response = (HttpRespObject)msg.obj;
                if(response.isSuccess){
                    if(!(msg.arg1 == 1)){
                        mFollowingList.clear();
                    }
                    FollowingListItem[] followingArray = (FollowingListItem[])response.data;
                    if(followingArray != null) {
                        mFollowingList.addAll(Arrays.asList(followingArray));
                        mAdapter.setList(mFollowingList);
                    }
                    //无数据
                    if(mFollowingList == null || mFollowingList.size() == 0){
                        showEmptyView();
                    }
                }else{
                    if(mFollowingList.size()>0){
                        if(getActivity() != null){
                            Toast.makeText(getActivity(), response.errMsg, Toast.LENGTH_LONG).show();
                        }
                    }else{
                        //无数据显示错误页，引导用户
                        showErrorPage();
                    }
                }
            }break;
        }
        onRefreshComplete();
    }

    /**
     * 生成列表头
     * @return
     */
    private View createHeaderView(){
        ImageView imageView = new ImageView(getActivity());
        imageView.setImageResource(R.drawable.hotlist_default_header);
        return  imageView;
    }

    private void queryFollowingList(final boolean isLoadMore){
        int start = 0;
        if(isLoadMore){
            start = mFollowingList.size();
        }
        RequestJniLiveShow.GetFollowingLiveList(start, Default_Step, new OnGetFollowingListCallback() {
            @Override
            public void onGetFollowingList(boolean isSuccess, int errCode, String errMsg, FollowingListItem[] followingList) {
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, followingList);
                Message msg = Message.obtain();
                msg.what = GET_FOLLOWING_CALLBACK;
                msg.arg1 = isLoadMore?1:0;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    /**
     * 显示无数据页
     */
    private void showEmptyView(){
        setDefaultEmptyMessage(getResources().getString(R.string.followinglist_empty_text));
        setDefaultEmptyButtonText(getResources().getString(R.string.common_hotlist_guide));
        showNodataPage();
    }

    @Override
    protected void onDefaultErrorRetryClick() {
        super.onDefaultErrorRetryClick();
        //错误也点击刷新
        mFollowingList.clear();
        showLoadingProcess();
        queryFollowingList(false);
    }

    @Override
    protected void onDefaultEmptyGuide() {
        super.onDefaultEmptyGuide();
        if(getActivity() != null && getActivity() instanceof  MainFragmentActivity){
            ((MainFragmentActivity)getActivity()).setCurrentPager(0);
        }
    }

    @Override
    public void onPullDownToRefresh() {
        super.onPullDownToRefresh();
        queryFollowingList(false);
    }

    @Override
    public void onPullUpToRefresh() {
        super.onPullUpToRefresh();
        queryFollowingList(true);
    }
    @Override
    public void onRefreshComplete() {
        super.onRefreshComplete();
    }

    private CanAdapter<FollowingListItem> createAdapter(){
        CanAdapter<FollowingListItem> adapter = new CanAdapter<FollowingListItem>(getActivity(), R.layout.item_hot_list, mFollowingList) {
            @Override
            protected void setView(CanHolderHelper helper, int position, FollowingListItem bean) {
                //处理item大小（宽高相同）
                AbsListView.LayoutParams params = (AbsListView.LayoutParams)helper.getConvertView().getLayoutParams();
                params.height = DisplayUtil.getScreenWidth(helper.getContext());

                helper.setImageResource(R.id.ivOnlineStatus, bean.onlineStatus == AnchorOnlineStatus.Online ? R.drawable.circle_solid_green :
                        R.drawable.circle_solid_grey);
                helper.setText(R.id.tvName,bean.nickName);

                //兴趣爱好区域
                helper.setVisibility(R.id.ivInterest1, View.GONE);
                helper.setVisibility(R.id.ivInterest2, View.GONE);
                helper.setVisibility(R.id.ivInterest3, View.GONE);
                if(bean.interests != null && bean.interests.size() > 0){
                    if(bean.interests.size() >= 3){
                        helper.setVisibility(R.id.ivInterest1, View.VISIBLE);
                        helper.setVisibility(R.id.ivInterest2, View.VISIBLE);
                        helper.setVisibility(R.id.ivInterest3, View.VISIBLE);
                        helper.setImageResource(R.id.ivInterest1, ImageUtil.getImageResoursceByName(bean.interests.get(0).name()));
                        helper.setImageResource(R.id.ivInterest2, ImageUtil.getImageResoursceByName(bean.interests.get(1).name()));
                        helper.setImageResource(R.id.ivInterest3, ImageUtil.getImageResoursceByName(bean.interests.get(2).name()));
                    }else if(bean.interests.size() == 2){
                        helper.setVisibility(R.id.ivInterest1, View.VISIBLE);
                        helper.setVisibility(R.id.ivInterest2, View.VISIBLE);
                        helper.setImageResource(R.id.ivInterest1, ImageUtil.getImageResoursceByName(bean.interests.get(0).name()));
                        helper.setImageResource(R.id.ivInterest2, ImageUtil.getImageResoursceByName(bean.interests.get(1).name()));
                    }else{
                        helper.setVisibility(R.id.ivInterest1, View.VISIBLE);
                        helper.setImageResource(R.id.ivInterest1, ImageUtil.getImageResoursceByName(bean.interests.get(0).name()));
                    }
                }

                //按钮区域
                if(bean.onlineStatus == AnchorOnlineStatus.Online){
                    if(bean.roomType != LiveRoomType.Unknown) {
                        //在线直播中
                        helper.setVisibility(R.id.btnSchedule, View.GONE);
                        helper.setVisibility(R.id.llStartContent, View.VISIBLE);
                        helper.setVisibility(R.id.ivLiveType, View.VISIBLE);
                        if (bean.roomType == LiveRoomType.FreePublicRoom
                                || bean.roomType == LiveRoomType.PaidPublicRoom) {
                            helper.setImageResource(R.id.ivLiveType, R.drawable.room_type_public);
                            helper.setVisibility(R.id.btnPrivate, View.VISIBLE);
                            helper.setVisibility(R.id.btnPublic, View.VISIBLE);
                        } else {
                            helper.setImageResource(R.id.ivLiveType, R.drawable.room_type_private);
                            helper.setVisibility(R.id.btnPrivate, View.VISIBLE);
                            helper.setVisibility(R.id.btnPublic, View.GONE);
                        }

                        final ImageView btnPrivate = helper.getView(R.id.btnPrivate);
                        Drawable privateDrawable = btnPrivate.getDrawable();
                        if ((privateDrawable != null)
                                && (privateDrawable instanceof AnimationDrawable)) {
                            ((AnimationDrawable) privateDrawable).stop();
                        }

                        switch (bean.roomType) {
                            case FreePublicRoom: {
                                helper.setImageResource(R.id.btnPrivate, R.drawable.list_button_start_normal_private_broadcast);
                                helper.setImageResource(R.id.btnPublic, R.drawable.list_button_view_free_public_broadcast);
                            }
                            break;
                            case PaidPublicRoom: {
                                setAndStartAdvancePrivateAnimation(btnPrivate);
                                helper.setImageResource(R.id.btnPublic, R.drawable.list_button_view_paid_public_broadcast);
                            }
                            break;
                            case AdvancedPrivateRoom: {
                                setAndStartAdvancePrivateAnimation(btnPrivate);
                            }
                            break;
                            case NormalPrivateRoom: {
                                helper.setImageResource(R.id.btnPrivate, R.drawable.list_button_start_normal_private_broadcast);
                            }
                            break;
                        }
                    }else{
                        //在线未直播
                        helper.setVisibility(R.id.btnSchedule, View.GONE);
                        helper.setVisibility(R.id.llStartContent, View.VISIBLE);
                        helper.setVisibility(R.id.ivLiveType, View.GONE);
                        helper.setVisibility(R.id.btnPrivate, View.VISIBLE);
                        helper.setVisibility(R.id.btnPublic, View.GONE);
                        ImageView btnPrivate = helper.getView(R.id.btnPrivate);
                        if(bean.anchorType == AnchorLevelType.gold){
                            setAndStartAdvancePrivateAnimation(btnPrivate);
                        }else{
                            helper.setImageResource(R.id.btnPrivate, R.drawable.list_button_start_normal_private_broadcast);
                        }
                    }
                }else{
                    helper.setVisibility(R.id.ivLiveType, View.GONE);
                    helper.setVisibility(R.id.llStartContent, View.GONE);
                    helper.setVisibility(R.id.btnSchedule, View.VISIBLE);
                    helper.setImageResource(R.id.btnSchedule, R.drawable.list_button_send_schedule);
                }

                helper.setImageResource(R.id.iv_roomBg, R.drawable.rectangle_transparent_drawable);
                if(!TextUtils.isEmpty(bean.roomPhotoUrl) && getActivity() != null){
                    Picasso.with(getActivity().getApplicationContext())
                            .load(bean.roomPhotoUrl)
                            .placeholder(R.drawable.rectangle_transparent_drawable)
                            .error(R.drawable.rectangle_transparent_drawable)
                            .into(helper.getImageView(R.id.iv_roomBg));
                }
            }

            /**
             * 设置启动帧动画
             * @param view
             */
            private void setAndStartAdvancePrivateAnimation(final ImageView view){
                view.setImageResource(R.drawable.anim_private_broadcast_button);
                postUiDelayed(new Runnable() {
                    @Override
                    public void run() {
                        Drawable tempDrawable = view.getDrawable();
                        if((tempDrawable != null)
                                && (tempDrawable instanceof AnimationDrawable)){
                            ((AnimationDrawable)tempDrawable).start();
                        }
                    }
                }, 200);
            }

            @Override
            protected void setItemListener(CanHolderHelper helper) {
                //只有这里设置了setItemChildClickListener,对adapter的setOnItemListener才会有效
                helper.setItemChildClickListener(R.id.btnPrivate);
                helper.setItemChildClickListener(R.id.btnPublic);
                helper.setItemChildClickListener(R.id.btnSchedule);
                helper.setItemChildClickListener(R.id.iv_roomBg);
            }

        };
        adapter.setOnItemListener(new CanOnItemListener(){
            @Override
            public void onItemChildClick(View view, int position) {
                FollowingListItem item = mFollowingList.get(position);
                int i = view.getId();
                if (i == R.id.iv_roomBg) {
                } else if (i == R.id.btnPrivate) {
                    startActivity(LiveRoomTransitionActivity.getIntent(mContext,
                            LiveRoomTransitionActivity.CategoryType.Audience_Invite_Enter_Room,
                            item.userId, item.nickName, item.photoUrl, "", item.roomPhotoUrl));
                } else if (i == R.id.btnPublic) {
                    startActivity(LiveRoomTransitionActivity.getIntent(mContext,
                            LiveRoomTransitionActivity.CategoryType.Enter_Public_Room,
                            item.userId, item.nickName, item.photoUrl, "", item.roomPhotoUrl));
                } else if (i == R.id.btnSchedule) {
                    startActivity(BookPrivateActivity.getIntent(mContext, item.userId, item.nickName));
                }
            }
        });
        return adapter;
    }
}
