package com.qpidnetwork.livemodule.liveshow.personal.mypackage;

import android.os.Bundle;
import android.os.Message;
import android.support.v4.widget.SwipeRefreshLayout;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.GridView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseLoadingFragment;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetRidesListCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.item.RideItem;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by Hunter on 17/9/26.
 */

public class MyRidesFragment extends BaseLoadingFragment implements SwipeRefreshLayout.OnRefreshListener {

    private static final int GET_PACKAGE_RIDERLIST_CALLBACK = 1;
    private static final int USE_OR_CANCEL_RIDER_CALLBCAK = 2;

    private SwipeRefreshLayout swipeRefreshLayout;
    private GridView mGridView;
    private PackageRidersAdapter mAdapter;
    private List<RideItem> mRideList;

    private boolean isVisibleToUser;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = super.onCreateView(inflater, container, savedInstanceState);
        setCustomContent(R.layout.fragment_package_rider);
        swipeRefreshLayout = (SwipeRefreshLayout)view.findViewById(R.id.swipeRefreshLayout);
        swipeRefreshLayout.setOnRefreshListener(this);

        mGridView = (GridView)view.findViewById(R.id.gridView);
        return view;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mRideList = new ArrayList<RideItem>();
        mAdapter = new PackageRidersAdapter(getActivity(), mRideList);
        mAdapter.setOnRideButtonClickListener(new PackageRidersAdapter.OnRideButtonClickListener() {
            @Override
            public void onRideClick(RideItem item) {
                //点击适用或取消座驾
                useOrCancelRider(item);
            }
        });
        mGridView.setAdapter(mAdapter);


        // 2018/10/26 Hardy
        if (isVisibleToUser) {
            loadDataWithLoading();
        }
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);

        //Fragment是否可见，用于viewpager切换时再加载
//        if(isVisibleToUser){
//            //切换到当前fragment
//            showLoadingProcess();
//            queryPackageRiderList();
//        }

        // 2018/10/26 Hardy
        this.isVisibleToUser = isVisibleToUser;
        if (isVisibleToUser && isCreatedView()) {
            loadDataWithLoading();
        }
    }

    private void loadDataWithLoading() {
        showLoadingProcess();
        queryPackageRiderList();
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        onRefreshComplete();
        HttpRespObject response = (HttpRespObject)msg.obj;
        if(getActivity() == null){
            return;
        }
        switch (msg.what){
            case GET_PACKAGE_RIDERLIST_CALLBACK:{
                if(response.isSuccess){
                    //列表刷新成功，更新未读
                    ScheduleInvitePackageUnreadManager.getInstance().GetPackageUnreadCount();

                    mRideList.clear();
                    RideItem[] packageRiders = (RideItem[])response.data;
                    if(packageRiders != null) {
                        mRideList.addAll(Arrays.asList(packageRiders));
                    }
                    mAdapter.notifyDataSetChanged();

                    if(mRideList.size() <= 0 ){
                        showEmptyView();
                    }else{
                        hideNodataPage();
                    }
                }else{
                    if(mRideList != null && mRideList.size() > 0){
                        if(getActivity() != null) {
                            Toast.makeText(getActivity(), response.errMsg, Toast.LENGTH_LONG).show();
                        }
                    }else{
                        showErrorPage();
                    }
                }
            }break;

            case USE_OR_CANCEL_RIDER_CALLBCAK:{
                RideItem rideItem = (RideItem)response.data;
                if(response.isSuccess){
                    //刷新列表
//                    for(RideItem item : mRideList){
//                        if(item.rideId.equals(rideItem.rideId)){
//                            item.isUsing = !item.isUsing;
//                        }
//                    }
//                    mAdapter.notifyDataSetChanged();
                    showLoadingProcess();
                    queryPackageRiderList();
                }else{
                    if(getActivity() != null) {
                        Toast.makeText(getActivity(), response.errMsg, Toast.LENGTH_LONG).show();
                    }
                }
            }break;
        }

    }

    @Override
    protected void onDefaultErrorRetryClick() {
        super.onDefaultErrorRetryClick();
//        showLoadingProcess();
//        queryPackageRiderList();
        loadDataWithLoading();
    }

    /**
     * 显示无数据页
     */
    private void showEmptyView(){
        setDefaultEmptyMessage(getResources().getString(R.string.my_package_rider_empty_tips));
        setDefaultEmptyButtonText("");
        showNodataPage();
    }

    /**
     * 获取背包座驾列表
     */
    private void queryPackageRiderList(){
        LiveRequestOperator.getInstance().GetRidesList(new OnGetRidesListCallback() {
            @Override
            public void onGetRidesList(boolean isSuccess, int errCode, String errMsg, RideItem[] rideList, int totalCount) {
                Message msg = Message.obtain();
                msg.what = GET_PACKAGE_RIDERLIST_CALLBACK;
                HttpRespObject response = new HttpRespObject(isSuccess,errCode, errMsg, rideList);
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    /**
     * 适用或取消适用座驾
     * @param item
     */
    private void useOrCancelRider(final RideItem item){
        showLoadingProcess();
        String riderId = "";
        if(!item.isUsing){
            //适用座驾时才需要配置riderId
            riderId = item.rideId;
        }
        LiveRequestOperator.getInstance().UseOrCancelRide(riderId, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                Message msg = Message.obtain();
                msg.what = USE_OR_CANCEL_RIDER_CALLBCAK;
                HttpRespObject response = new HttpRespObject(isSuccess,errCode, errMsg, item);
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    /**
     * 刷新完成UI
     */
    private void onRefreshComplete(){
        swipeRefreshLayout.setRefreshing(false);
        hideLoadingProcess();
    }

    @Override
    public void onRefresh() {
        queryPackageRiderList();
    }

    @Override
    public void onReloadDataInEmptyView() {
        queryPackageRiderList();
    }
}
