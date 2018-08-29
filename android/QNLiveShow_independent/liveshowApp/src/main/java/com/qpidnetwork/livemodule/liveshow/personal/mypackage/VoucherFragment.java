package com.qpidnetwork.livemodule.liveshow.personal.mypackage;

import android.os.Bundle;
import android.os.Message;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseListFragment;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetVouchersListCallback;
import com.qpidnetwork.livemodule.httprequest.item.VoucherItem;
import com.qpidnetwork.livemodule.liveshow.manager.ScheduleInvitePackageUnreadManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by Hunter on 17/9/26.
 */

public class VoucherFragment extends BaseListFragment{

    private VoucherListAdapter mAdapter;
    private List<VoucherItem> mVoucherList;

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mVoucherList = new ArrayList<VoucherItem>();
        mAdapter = new VoucherListAdapter(getActivity(), mVoucherList);
        getPullToRefreshListView().setAdapter(mAdapter);

        //关闭下拉刷新
//        closePullDownRefresh();
        //关闭上啦刷新
        closePullUpRefresh(true);
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        //Fragment是否可见，用于viewpager切换时再加载
        if(isVisibleToUser){
            //切换到当前fragment
            showLoadingProcess();
            queryVoucherList();
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        hideLoadingProcess();
        HttpRespObject response = (HttpRespObject)msg.obj;
        if(getActivity() == null){
            return;
        }
        if(response.isSuccess){
            //列表刷新成功，更新未读
            ScheduleInvitePackageUnreadManager.getInstance().GetPackageUnreadCount();

            mVoucherList.clear();
            VoucherItem[] voucherItems = (VoucherItem[])response.data;
            if(voucherItems != null) {
                mVoucherList.addAll(Arrays.asList(voucherItems));
            }
            mAdapter.notifyDataSetChanged();

            if(mVoucherList.size() <= 0 ){
                showEmptyView();
            }else{
                hideNodataPage();
            }
        }else{
            if(mVoucherList != null && mVoucherList.size() > 0){
                Toast.makeText(getActivity(), response.errMsg, Toast.LENGTH_LONG).show();
            }else{
                showErrorPage();
            }
        }
        onRefreshComplete();
    }

    @Override
    protected void onDefaultErrorRetryClick() {
        super.onDefaultErrorRetryClick();
        showLoadingProcess();
        queryVoucherList();
    }

    @Override
    protected void onDefaultEmptyGuide() {
        super.onDefaultEmptyGuide();
//        queryVoucherList();
    }

    /**
     * 显示无数据页
     */
    private void showEmptyView(){
        setDefaultEmptyMessage(getResources().getString(R.string.my_package_voucher_empty_tips));
        setDefaultEmptyButtonText("");//无按钮，隐藏
        showNodataPage();
    }

    /**
     * 下拉刷新
     */
    @Override
    public void onPullDownToRefresh() {
        super.onPullDownToRefresh();
        queryVoucherList();
    }

    @Override
    public void onReloadDataInEmptyView() {
        super.onReloadDataInEmptyView();
        queryVoucherList();
    }

    /**
     * 刷新试聊券列表
     */
    private void queryVoucherList(){
        LiveRequestOperator.getInstance().GetVouchersList(new OnGetVouchersListCallback() {
            @Override
            public void onGetVouchersList(boolean isSuccess, int errCode, String errMsg, VoucherItem[] voucherList, int totalCount) {
                Message msg = Message.obtain();
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, voucherList);
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

}
