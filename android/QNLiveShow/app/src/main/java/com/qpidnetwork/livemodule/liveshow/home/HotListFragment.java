package com.qpidnetwork.livemodule.liveshow.home;

import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Message;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AbsListView;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseListFragment;
import com.qpidnetwork.livemodule.framework.canadapter.CanAdapter;
import com.qpidnetwork.livemodule.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.livemodule.framework.canadapter.CanOnItemListener;
import com.qpidnetwork.livemodule.httprequest.OnGetHotListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniLiveShow;
import com.qpidnetwork.livemodule.httprequest.item.AnchorLevelType;
import com.qpidnetwork.livemodule.httprequest.item.AnchorOnlineStatus;
import com.qpidnetwork.livemodule.httprequest.item.HotListItem;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.liveshow.LiveApplication;
import com.qpidnetwork.livemodule.liveshow.liveroom.LiveRoomTransitionActivity;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.qnbridgemodule.impl.ServiceManager;
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

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mAdapter = createAdapter();
        getPullToRefreshListView().addHeaderView(createHeaderView());
        getPullToRefreshListView().setAdapter(mAdapter);
        getPullToRefreshListView().setHeaderDividersEnabled(true);
        getPullToRefreshListView().setDivider(new ColorDrawable(getResources().getColor(R.color.hotlist_divider_color)));
        getPullToRefreshListView().setDividerHeight(DisplayUtil.dip2px(getActivity(), 4));
        showInitLoading();
        queryHotList(false);

        //test
        //打开QN广告
        URL2ActivityManager.getInstance(getActivity()).toLiveAD();
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            case GET_FOLLOWING_CALLBACK:{
                hideLoadingPage();
                HttpRespObject response = (HttpRespObject)msg.obj;
                if(response.isSuccess){
                    if(!(msg.arg1 == 1)){
                        mHotList.clear();
                    }
                    HotListItem[] followingArray = (HotListItem[])response.data;
                    if(followingArray != null){
                        mHotList.addAll(Arrays.asList(followingArray));
                        mAdapter.setList(mHotList);
                    }

                    //无数据
                    if(mHotList == null || mHotList.size() == 0){
                        showInitEmpty(getEmptyView());
                    }
                }else{
                    if(mHotList.size()>0){
                        if(getActivity() != null){
                            Toast.makeText(getActivity(), response.errMsg, Toast.LENGTH_LONG).show();
                        }
                    }else{
                        //无数据显示错误页，引导用户
                        showInitError();
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

    private void queryHotList(final boolean isLoadMore){
        int start = 0;
        if(isLoadMore){
            start = mHotList.size();
        }
        RequestJniLiveShow.GetHotLiveList(start, Default_Step, false, new OnGetHotListCallback() {
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

    @Override
    public void onInitRetry() {
        super.onInitRetry();
        //错误也点击刷新
        Log.i("hunetr", "onInitRetry ");
        mHotList.clear();
        showInitLoading();
        queryHotList(false);
    }

    /**
     * @return 设置emptyView
     */
    private View getEmptyView() {
        // TODO Auto-generated method stub
        View view  = LayoutInflater.from(getActivity()).inflate(R.layout.view_following_list_empty, null);
        //edit by Jagger 设置为主题颜色
        Button btnHotList= (Button)view.findViewById(R.id.btnHotList);
        ((TextView)view.findViewById(R.id.tvEmptyDesc)).setText(getResources().getString(R.string.followinglist_empty_text));
        btnHotList.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                if(getActivity() != null && getActivity() instanceof  MainFragmentActivity){
                    ((MainFragmentActivity)getActivity()).setCurrentPager(0);
                }
            }
        });
        return view;
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
    public void onRefreshComplete() {
        super.onRefreshComplete();
    }

    private CanAdapter<HotListItem> createAdapter(){
        CanAdapter<HotListItem> adapter = new CanAdapter<HotListItem>(LiveApplication.getContext(), R.layout.item_hot_list, mHotList) {
            @Override
            protected void setView(CanHolderHelper helper, int position, HotListItem bean) {

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
                if(!TextUtils.isEmpty(bean.roomPhotoUrl)){
                    Picasso.with(LiveApplication.getContext())
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
                HotListItem item = mHotList.get(position);
                switch (view.getId()){
                    case R.id.iv_roomBg: {
                        //点击Item，打开主播详情
                    }break;
                    case R.id.btnPrivate: {
                        //发起私密邀请
                        startActivity(LiveRoomTransitionActivity.getInviteIntent(mContext,
                                item.userId, item.nickName, item.photoUrl, "",item.roomPhotoUrl));
                    }break;
                    case R.id.btnPublic: {
                        //进入公共直播间
                        startActivity(LiveRoomTransitionActivity.getRoomInIntent(mContext,
                                item.userId, item.nickName, item.photoUrl, "",item.roomPhotoUrl));
                    }break;
                    case R.id.btnSchedule: {
                        //进入发送预约邀请
                    }break;
                }
            }
        });
        return adapter;
    }
}
