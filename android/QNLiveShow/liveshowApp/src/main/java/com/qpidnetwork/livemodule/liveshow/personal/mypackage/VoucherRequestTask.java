package com.qpidnetwork.livemodule.liveshow.personal.mypackage;

import android.app.Activity;

import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetChatVoucherListCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetVouchersListCallback;
import com.qpidnetwork.livemodule.httprequest.item.VoucherItem;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class VoucherRequestTask {

    private Activity mActivity;
    private OnGetVouchersListCallback mCallback;
    private List<VoucherItem> mTempVoucherList;

    public VoucherRequestTask(Activity activity){
        mActivity = activity;
        mTempVoucherList = new ArrayList<VoucherItem>();
    }

    public void queryVoucherList(OnGetVouchersListCallback callback){
        mCallback = callback;
        LiveRequestOperator.getInstance().GetVouchersList(new OnGetVouchersListCallback() {
            @Override
            public void onGetVouchersList(final boolean isSuccess, final int errCode, final String errMsg, final VoucherItem[] voucherList, final int totalCount) {
                mActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if(isSuccess){
                            if(voucherList != null){
                                mTempVoucherList.addAll(Arrays.asList(voucherList));
                            }
                            getLiveChatVoucherListInternal();
                        }else{
                            notifyCallback(isSuccess, errCode, errMsg, mTempVoucherList, totalCount);
                        }
                    }
                });
            }
        });
    }

    /**
     * 获取Livechat试聊券数目(和策划确认，不做分页，默认拿100条)
     */
    private void getLiveChatVoucherListInternal(){
        LiveRequestOperator.getInstance().GetChatVoucherList(0, 100, new OnGetChatVoucherListCallback() {
            @Override
            public void onGetChatVoucherList(boolean isSuccess, int errCode, String errMsg, VoucherItem[] voucherList, int totalCount) {
                if(voucherList != null){
                    mTempVoucherList.addAll(Arrays.asList(voucherList));
                }
                notifyCallback(isSuccess, errCode, errMsg, mTempVoucherList, totalCount);
            }
        });
    }

    /**
     * 处理完成通知外部
     * @param isSuccess
     * @param errCode
     * @param errMsg
     * @param voucherList
     * @param totalCount
     */
    private void notifyCallback(boolean isSuccess, int errCode, String errMsg, List<VoucherItem> voucherList, int totalCount){
        //按照发送事件降序排序
        Collections.sort(voucherList, new Comparator<VoucherItem>() {
            @Override
            public int compare(VoucherItem voucherItem1, VoucherItem voucherItem2) {
                return (int)(voucherItem2.grantedDate - voucherItem1.grantedDate);
            }
        });

        if(mCallback != null){
            mCallback.onGetVouchersList(isSuccess, errCode, errMsg, voucherList.toArray(new VoucherItem[voucherList.size()]), totalCount);
        }
    }
}
