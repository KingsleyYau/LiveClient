package com.qpidnetwork.liveshow.home.hometab;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.annotation.Nullable;
import android.support.v4.view.ViewCompat;
import android.support.v4.view.ViewPager;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.ListView;

import com.qpidnetwork.framework.base.BaseFragment;
import com.qpidnetwork.framework.canadapter.CanAdapter;
import com.qpidnetwork.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.framework.canadapter.CanOnItemListener;
import com.qpidnetwork.framework.widget.swipetoloadlayout.OnLoadMoreListener;
import com.qpidnetwork.framework.widget.swipetoloadlayout.OnRefreshListener;
import com.qpidnetwork.framework.widget.swipetoloadlayout.SwipeToLoadLayout;
import com.qpidnetwork.framework.widget.swipetoloadlayout.adapter.LoopViewPagerAdapter;
import com.qpidnetwork.framework.widget.swipetoloadlayout.model.Character;
import com.qpidnetwork.httprequest.OnGetLiveRoomListCallback;
import com.qpidnetwork.httprequest.RequestJniLiveShow;
import com.qpidnetwork.httprequest.item.LiveRoomInfoItem;
import com.qpidnetwork.liveshow.LiveApplication;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.liveshow.liveroom.AudienceLiveRoomActivity;
import com.qpidnetwork.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.utils.TestDataUtil;
import com.squareup.picasso.Picasso;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 */
public class HotFragment extends BaseFragment implements OnRefreshListener,OnLoadMoreListener {

    private SwipeToLoadLayout swipeToLoadLayout;

    private ListView listView;
    private ViewPager viewPager;

    private ViewGroup indicators;

    private CanAdapter<LiveRoomInfoItem> mAdapter;

    private LoopViewPagerAdapter mPagerAdapter;

    private List<LiveRoomInfoItem> allLiveRoomInfoItems = new ArrayList<LiveRoomInfoItem>();
    private List<LiveRoomInfoItem> liveRoomInfoItems = new ArrayList<LiveRoomInfoItem>();
    private List<Character> bannerData = new ArrayList<Character>();
    private int start=0,step = 6;

    private WeakReference<MainFragmentActivity> mActivity;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }


    public HotFragment() {
        // Required empty public constructor
        TAG = HotFragment.class.getSimpleName();
        Log.d(TAG,TAG+"()");
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        super.onCreateView(inflater,container,savedInstanceState);
        mActivity = new WeakReference<MainFragmentActivity>((MainFragmentActivity) getActivity());
        View rootView = inflater.inflate(R.layout.fragment_hot_list, container, false);
        initView(inflater,rootView);
        return rootView;
    }



    private void initView(LayoutInflater inflater, final View rootView){
        View pagerView = inflater.inflate(R.layout.swipetoloadlayout_layout_viewpager, listView, false);
        swipeToLoadLayout = (SwipeToLoadLayout) rootView.findViewById(R.id.swipeToLoadLayout);
        listView = (ListView) rootView.findViewById(R.id.swipe_target);
        viewPager = (ViewPager) pagerView.findViewById(R.id.viewPager);
        indicators = (ViewGroup) pagerView.findViewById(R.id.indicators);
        viewPager.addOnPageChangeListener(mPagerAdapter);
        listView.addHeaderView(pagerView);
        mAdapter = new CanAdapter<LiveRoomInfoItem>(LiveApplication.getContext(),R.layout.item_hot_list,liveRoomInfoItems) {
            @Override
            protected void setView(CanHolderHelper helper, int position, LiveRoomInfoItem bean) {
                helper.setText(R.id.tv_roomOnLineStatus,LiveApplication.getContext().getString(bean.status == LiveRoomInfoItem.LiveRoomStatus.live ? R.string.txt_roomstatus_online : R.string.txt_roomstatus_offline));
                helper.setText(R.id.tv_roomPersonNumb,String.valueOf(bean.fansnum));
                helper.setText(R.id.tv_hostLocation,bean.country);
                helper.setText(R.id.tv_roomTag,bean.roomName);
                helper.setText(R.id.tv_roomTitle,bean.nickName);
                if(!TextUtils.isEmpty(bean.roomPhotoUrl)){
                    Picasso.with(LiveApplication.getContext())
                            .load(bean.roomPhotoUrl)
                            .into(helper.getImageView(R.id.iv_roomBg));
                }
            }

            @Override
            protected void setItemListener(CanHolderHelper helper) {
                //只有这里设置了setItemChildClickListener,对adapter的setOnItemListener才会有效
                helper.setItemChildClickListener(R.id.tv_roomOnLineStatus);
                helper.setItemChildClickListener(R.id.tv_roomPersonNumb);
                helper.setItemChildClickListener(R.id.tv_hostLocation);
                helper.setItemChildClickListener(R.id.tv_roomTag);
                helper.setItemChildClickListener(R.id.tv_roomTitle);
                helper.setItemChildClickListener(R.id.iv_roomBg);
            }
        };
        listView.setAdapter(mAdapter);
        listView.setOnScrollListener(new AbsListView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(AbsListView view, int scrollState) {
                if (scrollState == AbsListView.OnScrollListener.SCROLL_STATE_IDLE) {
                    if (view.getLastVisiblePosition() == view.getCount() - 1 && !ViewCompat.canScrollVertically(view, 1)) {
                        swipeToLoadLayout.setLoadingMore(true);
                    }
                }
            }

            @Override
            public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
                if (firstVisibleItem == 0) {
                    if (mPagerAdapter != null) {
                        mPagerAdapter.start();
                    }

                } else {
                    if (mPagerAdapter != null) {
                        mPagerAdapter.stop();
                    }
                }
            }
        });

        mAdapter.setOnItemListener(new CanOnItemListener(){
            @Override
            public void onItemChildClick(View view, int position) {
                Log.d(TAG,"onItemChildClick-position:"+position);
                LiveRoomInfoItem item = liveRoomInfoItems.get(position);
//                Intent intent = new Intent(mActivity.get(), AudienceActivity.class);
//                intent.putExtra("isHost",false);
//                intent.putExtra("roomId",item.roomId);
//                intent.putExtra("hostPhotoUrl",item.photoUrl);
//                intent.putExtra("hostNickName",item.nickName);
//                intent.putExtra("roomPhotoUrl",item.roomPhotoUrl);
//                intent.putExtra("fansnum",item.fansnum);
//                intent.putExtra("hostId",item.userId);
////                roomStreamUrl = getIntent().getStringExtra("roomStreamUrl");
//                startActivity(intent);
//                Intent intent = new Intent(mActivity.get(), AudienceLiveRoomActivity.class);
                startActivity(AudienceLiveRoomActivity.getIntent(mActivity.get(), item.roomId));
            }
        });
        swipeToLoadLayout.setOnRefreshListener(this);
        swipeToLoadLayout.setOnLoadMoreListener(this);
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        swipeToLoadLayout.post(new Runnable() {
            @Override
            public void run() {
                swipeToLoadLayout.setRefreshing(true);
            }
        });
    }

    private final int MSG_WHAT_REFRESH_RSP = 0;
    private final int MSG_WHAT_LOADMORE_RSP = 1;
    private Handler handler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            HttpRespObject object = null;
            switch (msg.what){
                case MSG_WHAT_LOADMORE_RSP:
                    object = (HttpRespObject)msg.obj;
                    if(object.isSuccess){
                        LiveRoomInfoItem[] roomList = (LiveRoomInfoItem[])object.data;
                        dealWithRoomListData(roomList);
                    }else{
                        if(null != mActivity && mActivity.get()!=null){
                            mActivity.get().showToast(object.errMsg);
                        }
                    }
                    swipeToLoadLayout.setRefreshing(false);
                    swipeToLoadLayout.setLoadingMore(false);
                    break;
                case MSG_WHAT_REFRESH_RSP:
                    object = (HttpRespObject)msg.obj;
                    if(object.isSuccess){
                        LiveRoomInfoItem[] roomList = (LiveRoomInfoItem[])object.data;
                        dealWithRoomListData(roomList);
                        dealWithBannerData();
                    }else{
                        if(null != mActivity && mActivity.get()!=null){
                            mActivity.get().showToast(object.errMsg);
                        }
                        if(10003 == object.errCode){

                        }
                    }
                    swipeToLoadLayout.setRefreshing(false);
                    swipeToLoadLayout.setLoadingMore(false);
                    break;
            }
            super.handleMessage(msg);
        }
    };

    private void dealWithBannerData(){
        if(0 == start){
            //bannerData.clear();//刷新Banner
        }
        //更新ViewPage-Banner
        if (viewPager.getAdapter() == null) {
            mPagerAdapter = new LoopViewPagerAdapter(viewPager, indicators);
            viewPager.setAdapter(mPagerAdapter);
            viewPager.addOnPageChangeListener(mPagerAdapter);
            mPagerAdapter.setList(bannerData);
            viewPager.setBackgroundDrawable(getResources().getDrawable(R.drawable.swipetoloadlayout_bg_viewpager));
        } else {
            mPagerAdapter = (LoopViewPagerAdapter) viewPager.getAdapter();
            mPagerAdapter.setList(bannerData);
            mPagerAdapter.notifyDataSetChanged();
        }
    }

    private void dealWithRoomListData(LiveRoomInfoItem[] roomList){
        if(0 == start){
            liveRoomInfoItems.clear();
        }
        List<LiveRoomInfoItem> respLiveRoomInfoItems = Arrays.asList(roomList);
        liveRoomInfoItems.addAll(respLiveRoomInfoItems);
        mAdapter.setList(liveRoomInfoItems);
        mAdapter.notifyDataSetChanged();
    }

    @Override
    public void onRefresh() {
        start = 0;
        bannerData = TestDataUtil.initBannerData(bannerData);
//        allLiveRoomInfoItems = TestDataUtil.initRoomInfoData(allLiveRoomInfoItems);
        mActivity.get().showToast("正在刷新");
        RequestJniLiveShow.GetHotLiveList(start, step, new OnGetLiveRoomListCallback() {
            @Override
            public void onGetLiveRoomList(boolean isSuccess, int errCode, String errMsg, LiveRoomInfoItem[] roomList) {
                HttpRespObject object = new HttpRespObject(isSuccess,errCode,errMsg,roomList);
                Message msg = handler.obtainMessage(MSG_WHAT_REFRESH_RSP);
                msg.obj = object;
                handler.sendMessage(msg);
            }
        });
    }




    @Override
    public void onResume() {
        super.onResume();
        if (mPagerAdapter != null) {
            mPagerAdapter.start();
        }
    }

    @Override
    public void onPause() {
        super.onPause();
//        LiveApplication.getRequestQueue().cancelAll(TAG);
        if (swipeToLoadLayout.isRefreshing()) {
            swipeToLoadLayout.setRefreshing(false);
        }
        if (swipeToLoadLayout.isLoadingMore()) {
            swipeToLoadLayout.setLoadingMore(false);
        }
        if (mPagerAdapter != null) {
            mPagerAdapter.stop();
        }
    }

    @Override
    public void onLoadMore() {
        mActivity.get().showToast("正在加载");
        RequestJniLiveShow.GetHotLiveList(start, step, new OnGetLiveRoomListCallback() {
            @Override
            public void onGetLiveRoomList(boolean isSuccess, int errCode, String errMsg, LiveRoomInfoItem[] roomList) {
                HttpRespObject object = new HttpRespObject(isSuccess,errCode,errMsg,roomList);
                Message msg = handler.obtainMessage(MSG_WHAT_LOADMORE_RSP);
                msg.obj = object;
                handler.sendMessage(msg);
            }
        });
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if(null != mActivity && mActivity.get()!=null){
            mActivity.clear();
            mActivity = null;
        }
    }
}
