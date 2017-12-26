package com.qpidnetwork.livemodule.liveshow.home;

import android.app.Activity;
import android.graphics.Bitmap;
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
import com.qpidnetwork.livemodule.framework.services.LiveService;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetHotListCallback;
import com.qpidnetwork.livemodule.httprequest.item.AnchorLevelType;
import com.qpidnetwork.livemodule.httprequest.item.AnchorOnlineStatus;
import com.qpidnetwork.livemodule.httprequest.item.HotListItem;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomTransitionActivity;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.personal.book.BookPrivateActivity;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.IPConfigUtil;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by Hunter Mun on 2017/9/6.
 */

public class HotListFragment extends BaseListFragment{
    private static final int GET_FOLLOWING_CALLBACK = 1;

    private CanAdapter<HotListItem> mAdapter;
    private List<HotListItem> mHotList = new ArrayList<HotListItem>();
    private BannerItem bannerItem;
    private ImageView headerView = null;

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        initListHeaderView();
        mAdapter = createAdapter();
        getPullToRefreshListView().addHeaderView(headerView);
        //隐藏滚动条
        getPullToRefreshListView().setVerticalScrollBarEnabled(false);
        getPullToRefreshListView().setFastScrollEnabled(false);
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
                        mHotList.clear();
                    }
                    HotListItem[] followingArray = (HotListItem[])response.data;
                    if(followingArray != null){
                        mHotList.addAll(Arrays.asList(followingArray));
                    }
                    mAdapter.setList(mHotList);

                    //hot数据为空时只展示banner
                    if(mHotList == null || mHotList.size() == 0){
                        showEmptyView();
                    }
                }else{
                    if(mHotList.size()>0){
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

    public void updateBannerImg(BannerItem bannerItem){
        this.bannerItem = bannerItem;
        if(null != headerView && null != bannerItem && !TextUtils.isEmpty(bannerItem.bannerImgUrl)
                && !TextUtils.isEmpty(bannerItem.bannerLinkUrl) && (getActivity() != null)){
            Picasso.with(getActivity()).load(bannerItem.bannerImgUrl)
                    .placeholder(getActivity().getResources().getDrawable(R.drawable.hotlist_default_header))
                    .error(getActivity().getResources().getDrawable(R.drawable.hotlist_default_header))
                    .into(headerView);
        }
    }

    /**
     * 生成列表头
     * @return
     */
    private void initListHeaderView(){
        headerView = new ImageView(getActivity());
        headerView.setAdjustViewBounds(true);
        if(null != bannerItem && !TextUtils.isEmpty(bannerItem.bannerImgUrl) && !TextUtils.isEmpty(bannerItem.bannerLinkUrl)){
            Picasso.with(getActivity()).load(bannerItem.bannerImgUrl)
                    .placeholder(getActivity().getResources().getDrawable(R.drawable.hotlist_default_header))
                    .error(getActivity().getResources().getDrawable(R.drawable.hotlist_default_header))
                    .into(headerView);

        }else{
            headerView.setImageResource(R.drawable.hotlist_default_header);
        }

        headerView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(null != bannerItem && !TextUtils.isEmpty(bannerItem.bannerLinkUrl)){
                    startActivity(WebViewActivity.getIntent(getActivity(),
                            bannerItem.bannerName,
                            IPConfigUtil.addCommonParamsToH5Url(bannerItem.bannerLinkUrl),
                            true));
                }

            }
        });

    }

    private void queryHotList(final boolean isLoadMore){
        int start = 0;
        if(isLoadMore){
            start = mHotList.size();
        }
        LiveRequestOperator.getInstance().GetHotLiveList(start, Default_Step, false, LiveService.getInstance().getForTest(), new OnGetHotListCallback() {
            @Override
            public void onGetHotList(boolean isSuccess, int errCode, String errMsg, HotListItem[] followingList) {
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
        //不处理，用户自己下啦刷新
//        setDefaultEmptyMessage(getResources().getString(R.string.followinglist_empty_text));
//        setDefaultEmptyButtonText(getResources().getString(R.string.common_hotlist_guide));
//        showNodataPage();
//        getPullToRefreshListView().setVisibility(View.VISIBLE);
    }

    @Override
    protected void onDefaultErrorRetryClick() {
        super.onDefaultErrorRetryClick();
        //错误也点击刷新
        mHotList.clear();
        showLoadingProcess();
        queryHotList(false);
    }

    @Override
    protected void onDefaultEmptyGuide() {
//        super.onDefaultEmptyGuide();
//        if(getActivity() != null && getActivity() instanceof  MainFragmentActivity){
//            ((MainFragmentActivity)getActivity()).setCurrentPager(0);
//        }
    }

    @Override
    public void onPullDownToRefresh() {
        super.onPullDownToRefresh();
        queryHotList(false);
    }

    @Override
    public void onPullUpToRefresh() {
        super.onPullUpToRefresh();
        queryHotList(true);
    }

    @Override
    public void onReloadDataInEmptyView() {
        super.onReloadDataInEmptyView();
        queryHotList(false);
    }

    @Override
    public void onRefreshComplete() {
        super.onRefreshComplete();
    }

    private CanAdapter<HotListItem> createAdapter(){
        CanAdapter<HotListItem> adapter = new CanAdapter<HotListItem>(getActivity(), R.layout.item_hot_list, mHotList) {
            @Override
            protected void setView(CanHolderHelper helper, int position, HotListItem bean) {

                //处理item大小（宽高相同）
                AbsListView.LayoutParams params = (AbsListView.LayoutParams)helper.getConvertView().getLayoutParams();
                params.height = DisplayUtil.getScreenWidth(helper.getContext());

                helper.setImageResource(R.id.ivOnlineStatus,
                        bean.onlineStatus == AnchorOnlineStatus.Online ? R.drawable.circle_solid_green :
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
                        //房间类型
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
//                                helper.setImageResource(R.id.btnPrivate, R.drawable.list_button_start_normal_private_broadcast);
                                setAndStartAdvancePrivateAnimation(btnPrivate);
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
//                                helper.setImageResource(R.id.btnPrivate, R.drawable.list_button_start_normal_private_broadcast);
                                setAndStartAdvancePrivateAnimation(btnPrivate);
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
//                            helper.setImageResource(R.id.btnPrivate, R.drawable.list_button_start_normal_private_broadcast);
                            setAndStartAdvancePrivateAnimation(btnPrivate);
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
                    ImageView imgView = helper.getImageView(R.id.iv_roomBg);
                    Picasso.with(getActivity())
                            .load(bean.roomPhotoUrl)
                            .transform(new PicassoRoundTransform(
                                    params.height,   //宽    //因为这个Item宽高都一样,以屏幕宽为准.
                                    params.height, //高
                                    0))//弧度
                            .placeholder(R.drawable.rectangle_transparent_drawable)
                            .error(R.drawable.rectangle_transparent_drawable)
                            .config(Bitmap.Config.RGB_565)
                            .into(imgView);
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
                String action = "";
                String label = "";

                HotListItem item = mHotList.get(position);
                int i = view.getId();
                if (i == R.id.iv_roomBg) {
                    startActivity(AnchorProfileActivity.getAnchorInfoIntent(getActivity(),
                            getResources().getString(R.string.live_webview_anchor_profile_title),
                            item.userId, false));
                } else if (i == R.id.btnPrivate) {
                    startActivity(LiveRoomTransitionActivity.getIntent(mContext,
                            LiveRoomTransitionActivity.CategoryType.Audience_Invite_Enter_Room,
                            item.userId, item.nickName, item.photoUrl, "", item.roomPhotoUrl));
                    //GA统计
                    if(item.anchorType == AnchorLevelType.gold){
                        action = getResources().getString(R.string.Live_EnterBroadcast_Action_VIPPrivateBroadcast);
                        label = getResources().getString(R.string.Live_EnterBroadcast_Label_VIPPrivateBroadcast);
                    }else{
                        action = getResources().getString(R.string.Live_EnterBroadcast_Action_PrivateBroadcast);
                        label = getResources().getString(R.string.Live_EnterBroadcast_Label_PrivateBroadcast);
                    }
                } else if (i == R.id.btnPublic) {
                    startActivity(LiveRoomTransitionActivity.getIntent(mContext,
                            LiveRoomTransitionActivity.CategoryType.Enter_Public_Room,
                            item.userId, item.nickName, item.photoUrl, "", item.roomPhotoUrl));
                    //GA统计
                    if(item.anchorType == AnchorLevelType.gold){
                        action = getResources().getString(R.string.Live_EnterBroadcast_Action_VIPPublicBroadcast);
                        label = getResources().getString(R.string.Live_EnterBroadcast_Label_VIPPublicBroadcast);
                    }else{
                        action = getResources().getString(R.string.Live_EnterBroadcast_Action_PublicBroadcast);
                        label = getResources().getString(R.string.Live_EnterBroadcast_Label_PublicBroadcast);
                    }
                } else if (i == R.id.btnSchedule) {
                    startActivity(BookPrivateActivity.getIntent(mContext, item.userId, item.nickName));
                    //GA统计
                    action = getResources().getString(R.string.Live_EnterBroadcast_Action_RequestBooking);
                    label = getResources().getString(R.string.Live_EnterBroadcast_Label_RequestBooking);
                }

                //GA统计
                Activity activity = getActivity();
                if(!TextUtils.isEmpty(action) && activity != null
                        && activity instanceof AnalyticsFragmentActivity){
                    ((AnalyticsFragmentActivity)activity).onAnalyticsEvent(getResources().getString(R.string.Live_EnterBroadcast_Category), action, label);
                }

            }
        });
        return adapter;
    }
}
