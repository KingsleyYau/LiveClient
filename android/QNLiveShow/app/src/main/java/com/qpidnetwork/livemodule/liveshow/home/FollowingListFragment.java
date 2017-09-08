package com.qpidnetwork.livemodule.liveshow.home;

import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.text.TextUtils;
import android.view.View;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseListFragment;
import com.qpidnetwork.livemodule.framework.canadapter.CanAdapter;
import com.qpidnetwork.livemodule.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.livemodule.framework.canadapter.CanOnItemListener;
import com.qpidnetwork.livemodule.httprequest.OnGetFollowingListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniLiveShow;
import com.qpidnetwork.livemodule.httprequest.item.AnchorOnlineStatus;
import com.qpidnetwork.livemodule.httprequest.item.FollowingListItem;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.liveshow.LiveApplication;
import com.qpidnetwork.livemodule.liveshow.liveroom.AudienceLiveRoomActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.BaseCommonLiveRoomActivity;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
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
        getPullToRefreshListView().setAdapter(mAdapter);
        queryFollowingList(false);
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            case GET_FOLLOWING_CALLBACK:{
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
                }else{
                    if(mFollowingList.size()>0){
                        String errorMsg = (String)msg.obj;
                        if(getActivity() != null){
                            Toast.makeText(getActivity(), errorMsg, Toast.LENGTH_LONG).show();
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

    @Override
    public void onInitRetry() {
        super.onInitRetry();
        //错误也点击刷新
        mFollowingList.clear();
        queryFollowingList(false);
    }

    @Override
    public void onPullDownToRefresh() {
        // TODO Auto-generated method stub
        super.onPullDownToRefresh();
        queryFollowingList(false);
    }

    @Override
    public void onPullUpToRefresh() {
        // TODO Auto-generated method stub
        super.onPullUpToRefresh();
        queryFollowingList(true);
    }
    @Override
    public void onRefreshComplete() {
        // TODO Auto-generated method stub
        super.onRefreshComplete();
    }

    private CanAdapter<FollowingListItem> createAdapter(){
        CanAdapter<FollowingListItem> adapter = new CanAdapter<FollowingListItem>(LiveApplication.getContext(), R.layout.item_hot_list, mFollowingList) {
            @Override
            protected void setView(CanHolderHelper helper, int position, FollowingListItem bean) {

                helper.setImageResource(R.id.ivOnlineStatus, bean.onlineStatus == AnchorOnlineStatus.Online ? R.drawable.circle_solid_green :
                        R.drawable.circle_solid_grey);
                helper.setText(R.id.tvName,bean.nickName);

                //按钮区域
                if(bean.onlineStatus == AnchorOnlineStatus.Online
                        && bean.roomType != LiveRoomType.Unknown){
                    //房间类型
                    helper.setVisibility(R.id.btnSchedule, View.GONE);
                    helper.setVisibility(R.id.llStartContent, View.VISIBLE);
                    helper.setVisibility(R.id.ivLiveType, View.VISIBLE);
                    if(bean.roomType == LiveRoomType.FreePublicRoom
                            || bean.roomType == LiveRoomType.PaidPublicRoom){
                        helper.setImageResource(R.id.ivLiveType, R.drawable.room_type_public);
                        helper.setVisibility(R.id.rlPrivateContent, View.VISIBLE);
                        helper.setVisibility(R.id.rlPublicContent, View.VISIBLE);
                    }else{
                        helper.setImageResource(R.id.ivLiveType, R.drawable.room_type_private);
                        helper.setVisibility(R.id.rlPrivateContent, View.VISIBLE);
                        helper.setVisibility(R.id.rlPublicContent, View.GONE);
                    }

                    switch (bean.roomType){
                        case FreePublicRoom:{
                            helper.setImageResource(R.id.btnPrivate, R.drawable.button_start_private_broadcast);
                            helper.setImageResource(R.id.btnPublic, R.drawable.button_view_free_public_broadcast);
                        }break;
                        case PaidPublicRoom:{
                            helper.setImageResource(R.id.btnPrivate, R.drawable.button_start_private_broadcast);
                            helper.setImageResource(R.id.btnPublic, R.drawable.button_view_paid_public_broadcast);
                        }break;
                        case AdvancedPrivateRoom:{
                            helper.setImageResource(R.id.btnPrivate, R.drawable.button_start_private_broadcast);
                        }break;
                        case NormalPrivateRoom:{
                            helper.setImageResource(R.id.btnPrivate, R.drawable.button_start_private_broadcast);
                        }break;
                    }
                }else{
                    helper.setVisibility(R.id.ivLiveType, View.GONE);
                    helper.setVisibility(R.id.llStartContent, View.GONE);
                    helper.setVisibility(R.id.btnSchedule, View.VISIBLE);
                    helper.setImageResource(R.id.btnSchedule, R.drawable.button_send_schedule);
                }

                if(!TextUtils.isEmpty(bean.photoUrl)){
                    Picasso.with(LiveApplication.getContext())
                            .load(bean.photoUrl)
                            .into(helper.getImageView(R.id.iv_roomBg));
                }
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
                switch (view.getId()){
                    case R.id.iv_roomBg: {
                        //点击Item，打开主播详情
                    }break;
                    case R.id.btnPrivate: {
                        //发出邀请
                    }break;
                    case R.id.btnPublic: {
                        //进入公共直播间
                    }break;
                    case R.id.btnSchedule: {
                        //进入发送预约邀请
                    }break;
                }
                Intent intent = new Intent(getActivity(), AudienceLiveRoomActivity.class);
                intent.putExtra(BaseCommonLiveRoomActivity.LIVEROOM_HOST_ID, item.userId);
                startActivity(intent);
            }
        });
        return adapter;
    }
}
