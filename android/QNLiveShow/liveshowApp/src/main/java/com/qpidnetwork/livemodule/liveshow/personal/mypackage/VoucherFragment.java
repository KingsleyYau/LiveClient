package com.qpidnetwork.livemodule.liveshow.personal.mypackage;

import android.os.Bundle;
import android.os.Message;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseListFragment;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetVouchersListCallback;
import com.qpidnetwork.livemodule.httprequest.item.VoucherItem;
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

        //关闭上啦刷新和下拉刷新
        closePullDownRefresh();
        closePullUpRefresh(true);
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        //Fragment是否可见，用于viewpager切换时再加载
        if(isVisibleToUser){
            //切换到当前fragment
            queryVoucherList();
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        hideLoadingProcess();
        HttpRespObject response = (HttpRespObject)msg.obj;
        if(response.isSuccess){
            mVoucherList.clear();
            VoucherItem[] voucherItems = (VoucherItem[])response.data;
            if(voucherItems != null) {
                mVoucherList.addAll(Arrays.asList(voucherItems));
                mAdapter.notifyDataSetChanged();
            }

            if(mVoucherList.size() <= 0 ){
                showEmptyView();
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
        queryVoucherList();
    }

    @Override
    protected void onDefaultEmptyGuide() {
        super.onDefaultEmptyGuide();
        queryVoucherList();
    }

    /**
     * 显示无数据页
     */
    private void showEmptyView(){
        setDefaultEmptyMessage(getResources().getString(R.string.followinglist_empty_text));
        setDefaultEmptyButtonText(getResources().getString(R.string.common_hotlist_guide));
        showNodataPage();
    }

    /**
     * 刷新试聊券列表
     */
    private void queryVoucherList(){
        showLoadingProcess();
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
