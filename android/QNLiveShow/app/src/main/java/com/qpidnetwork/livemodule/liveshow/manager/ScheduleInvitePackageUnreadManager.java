package com.qpidnetwork.livemodule.liveshow.manager;

import android.content.Context;

import com.qpidnetwork.livemodule.httprequest.OnGetCountOfUnreadAndPendingInviteCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetPackageUnreadCountCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniPackage;
import com.qpidnetwork.livemodule.httprequest.RequstJniSchedule;
import com.qpidnetwork.livemodule.httprequest.item.PackageUnreadCountItem;
import com.qpidnetwork.livemodule.httprequest.item.ScheduleInviteUnreadItem;
import com.qpidnetwork.livemodule.utils.Log;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Created by Hunter Mun on 2017/9/13.
 */

public class ScheduleInvitePackageUnreadManager {

    private static final String TAG = ScheduleInvitePackageUnreadManager.class.getName();

    private PackageUnreadCountItem mPackageUnreadCountItem;
    private ScheduleInviteUnreadItem mScheduleInviteUnreadItem;

    private List<OnUnreadListener> mUnreadListenerList;
    private static ScheduleInvitePackageUnreadManager mScheduleInvitePackageUnreadManager;

    /**
     * 构建单例
     * @return
     */
    public static ScheduleInvitePackageUnreadManager getInstance(){
        if(mScheduleInvitePackageUnreadManager == null){
            mScheduleInvitePackageUnreadManager = new ScheduleInvitePackageUnreadManager();
        }
        return mScheduleInvitePackageUnreadManager;
    }

    private ScheduleInvitePackageUnreadManager(){
        mUnreadListenerList = new ArrayList<OnUnreadListener>();
    }

    /**
     * 注册邀请启动监听器
     * @param listener
     * @return
     */
    public boolean registerUnreadListener(OnUnreadListener listener){
        boolean result = false;
        synchronized(mUnreadListenerList)
        {
            if (null != listener) {
                boolean isExist = false;

                for (Iterator<OnUnreadListener> iter = mUnreadListenerList.iterator(); iter.hasNext(); ) {
                    OnUnreadListener theListener = iter.next();
                    if (theListener == listener) {
                        isExist = true;
                        break;
                    }
                }

                if (!isExist) {
                    result = mUnreadListenerList.add(listener);
                }
                else {
                    Log.d(TAG, String.format("%s::%s() fail, listener:%s is exist", TAG, "registerUnreadListener", listener.getClass().getSimpleName()));
                }
            }
            else {
                Log.e(TAG, String.format("%s::%s() fail, listener is null", TAG, "registerUnreadListener"));
            }
        }
        return result;
    }

    /**
     * 注销邀请启动监听器
     * @param listener
     * @return
     */
    public boolean unregisterUnreadListener(OnUnreadListener listener) {
        boolean result = false;
        synchronized(mUnreadListenerList)
        {
            result = mUnreadListenerList.remove(listener);
        }

        if (!result) {
            Log.e(TAG, String.format("%s::%s() fail, listener:%s", TAG, "unregisterUnreadListener", listener.getClass().getSimpleName()));
        }
        return result;
    }

    /**
     * 获取邀请未读数目
     */
    public void GetCountOfUnreadAndPendingInvite(){
        RequstJniSchedule.GetCountOfUnreadAndPendingInvite(new OnGetCountOfUnreadAndPendingInviteCallback() {
            @Override
            public void onGetCountOfUnreadAndPendingInvite(boolean isSuccess, int errCode, String errMsg, int total, int pendingNum, int confirmedUnreadCount, int otherUnreadCount) {
                if(isSuccess){
                    mScheduleInviteUnreadItem = new ScheduleInviteUnreadItem(total, pendingNum, confirmedUnreadCount, otherUnreadCount);
                    onScheduleUnreadCallback(mScheduleInviteUnreadItem);
                }
            }
        });
    }

    /**
     * 获取背包未读数目
     */
    public void GetPackageUnreadCount(){
        RequestJniPackage.GetPackageUnreadCount(new OnGetPackageUnreadCountCallback() {
            @Override
            public void onGetPackageUnreadCount(boolean isSuccess, int errCode, String errMsg, int total, int voucherNum, int giftNum, int rideNum) {
                if(isSuccess){
                    mPackageUnreadCountItem = new PackageUnreadCountItem(total, voucherNum, giftNum, rideNum);
                    onPackageUnreadCallback(mPackageUnreadCountItem);
                }
            }
        });
    }

    /**
     * 读取本地预约邀请未读条数
     * @return
     */
    public ScheduleInviteUnreadItem getScheduleInviteUnreadItem(){
        return mScheduleInviteUnreadItem;
    }

    /**
     * 读取本地背包未读数目
     * @return
     */
    public PackageUnreadCountItem getPackageUnreadCountItem(){
        return mPackageUnreadCountItem;
    }

    /**
     * 预约邀请未读分发器
     * @param item
     */
    private void onScheduleUnreadCallback(ScheduleInviteUnreadItem item){
        synchronized(mUnreadListenerList){
            for (Iterator<OnUnreadListener> iter = mUnreadListenerList.iterator(); iter.hasNext(); ) {
                OnUnreadListener listener = iter.next();
                listener.onScheduleInviteUnreadUpdate(item);
            }
        }
    }

    /**
     * 背包未读分发器
     * @param item
     */
    private void onPackageUnreadCallback(PackageUnreadCountItem item){
        synchronized(mUnreadListenerList){
            for (Iterator<OnUnreadListener> iter = mUnreadListenerList.iterator(); iter.hasNext(); ) {
                OnUnreadListener listener = iter.next();
                listener.onPackageUnreadUpdate(item);
            }
        }
    }

    public interface OnUnreadListener{
        void onScheduleInviteUnreadUpdate(ScheduleInviteUnreadItem item);
        void onPackageUnreadUpdate(PackageUnreadCountItem item);
    }
}
