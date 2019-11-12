package com.qpidnetwork.livemodule.liveshow.flowergift.receiver;

import android.app.Activity;

import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetHotListCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetMyContactListCallback;
import com.qpidnetwork.livemodule.httprequest.item.ContactItem;
import com.qpidnetwork.livemodule.httprequest.item.HotListItem;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.qnbridgemodule.bean.BaseUserInfo;

import java.util.ArrayList;
import java.util.List;

/**
 * 获取收货人列表管理器（仅停留当前界面有效）
 * ps：获取规则，优先联系人，不足6人，由主播列表补充
 */
public class ReceiverListManager {

    private final int MAX_ANCHOR_COUNT = 6;
    private Activity mActivity;
    private List<BaseUserInfo> mTempAnchorList;
    private boolean mIsRequesting = false;
    private List<OnGetAnchorListCallback> mCallbackList;

    public ReceiverListManager(Activity activity){
        mActivity = activity;
        mTempAnchorList = new ArrayList<BaseUserInfo>();
        mCallbackList = new ArrayList<OnGetAnchorListCallback>();
    }

    /**
     * 对外开放，获取收货人列表
     * @param callback
     */
    public void getReceiversList(OnGetAnchorListCallback callback){
        synchronized (mCallbackList){
            mCallbackList.add(callback);
        }
        if(!mIsRequesting){
            mIsRequesting = true;
            if(mTempAnchorList.size() > 0){
                notifyCallbackList(mTempAnchorList);
            }else{
                getContactListInternal();
            }
        }
    }

    /**
     * 优先获取联系人列表
     */
    private void getContactListInternal(){
        LiveRequestOperator.getInstance().GetMyContactList(0, 30, new OnGetMyContactListCallback() {
            @Override
            public void onGetMyContactList(final boolean isSuccess, int errCode, String errMsg, final ContactItem[] contactList, int tatalCount) {
                //线程切换
                mActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if(isSuccess){
                            if(contactList != null && contactList.length > 0){
                                for(ContactItem item : contactList){
                                    if(item != null){
                                        if(mTempAnchorList.size() < MAX_ANCHOR_COUNT){
//                                            mTempAnchorList.add(new BaseUserInfo(item.anchorId, item.nickName, item.avatarImg));
                                            // 2019/10/23 Hardy 使用封面图
                                            mTempAnchorList.add(new BaseUserInfo(item.anchorId, item.nickName, item.coverImg));
                                        }else {
                                            break;
                                        }
                                    }
                                }
                            }
                        }

                        if(mTempAnchorList.size() >= MAX_ANCHOR_COUNT){
                            notifyCallbackList(mTempAnchorList);
                        }else{
                            //主播数目不足，获取主播列表补足
                            getAnchorListInternal();
                        }
                    }
                });
            }
        });
    }

    /**
     * 主播数目不足，获取热播列表补足显示数目（6个）
     */
    private void getAnchorListInternal(){
        LiveRequestOperator.getInstance().GetHotLiveList(0, 30, false, LiveModule.getInstance().getForTest(), new OnGetHotListCallback() {
            @Override
            public void onGetHotList(final boolean isSuccess, int errCode, String errMsg, final HotListItem[] hotList) {
                mActivity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if(isSuccess){
                            if(hotList != null && hotList.length > 0){
                                for(HotListItem item : hotList){
                                    if(item != null){
                                        if(mTempAnchorList.size() < MAX_ANCHOR_COUNT){
//                                            mTempAnchorList.add(new BaseUserInfo(item.userId, item.nickName, item.photoUrl));
                                            // 2019/10/23 Hardy 使用封面图
                                            mTempAnchorList.add(new BaseUserInfo(item.userId, item.nickName, item.roomPhotoUrl));
                                        }else {
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                        notifyCallbackList(mTempAnchorList);
                    }
                });
            }
        });
    }

    /**
     * 统一回调处理
     * @param anchorList
     */
    private void notifyCallbackList(List<BaseUserInfo> anchorList){
        mIsRequesting = false;
        boolean isSuccess = false;
        if(anchorList.size() > 0){
            isSuccess = true;
        }
        synchronized (mCallbackList){
            if(mCallbackList.size() > 0){
                for(OnGetAnchorListCallback callback : mCallbackList){
                    if(callback != null){
                        callback.onGetAnchorList(isSuccess, anchorList);
                    }
                }
            }
        }
    }

    public interface OnGetAnchorListCallback{
        public void onGetAnchorList(boolean isSuccess, List<BaseUserInfo> anchorList);
    }

}
