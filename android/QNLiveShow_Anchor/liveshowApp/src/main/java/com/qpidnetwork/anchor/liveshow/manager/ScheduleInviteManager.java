
package com.qpidnetwork.anchor.liveshow.manager;

import com.qpidnetwork.anchor.bean.ScheduleInviteUnreadItem;
import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.OnGetCountOfUnreadAndPendingInviteCallback;
import com.qpidnetwork.anchor.httprequest.OnGetScheduledAcceptNumCallback;
import com.qpidnetwork.anchor.utils.Log;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Created by Hunter Mun on 2017/9/13.
 */

public class ScheduleInviteManager {

    private static final String TAG = ScheduleInviteManager.class.getName();

    private ScheduleInviteUnreadItem mScheduleInviteUnreadItem;
    private int mScheduleInviteCount = 0;
    private List<OnScheduleInviteChangeListener> mUnreadListenerList;
    private static ScheduleInviteManager mScheduleInviteManager;

    /**
     * 构建单例
     * @return
     */
    public static ScheduleInviteManager getInstance(){
        if(mScheduleInviteManager == null){
            mScheduleInviteManager = new ScheduleInviteManager();
        }
        return mScheduleInviteManager;
    }

    private ScheduleInviteManager(){
        mUnreadListenerList = new ArrayList<OnScheduleInviteChangeListener>();
    }

    /**
     * 注册邀请启动监听器
     * @param listener
     * @return
     */
    public boolean registerScheduleInviteChangeListener(OnScheduleInviteChangeListener listener){
        boolean result = false;
        synchronized(mUnreadListenerList) {
            if (null != listener) {
                boolean isExist = false;
                for (Iterator<OnScheduleInviteChangeListener> iter = mUnreadListenerList.iterator(); iter.hasNext(); ) {
                    OnScheduleInviteChangeListener theListener = iter.next();
                    if (theListener == listener) {
                        isExist = true;
                        break;
                    }
                }

                if (!isExist) {
                    result = mUnreadListenerList.add(listener);
                }
            }
        }
        Log.d(TAG,"registerUnreadListener-result:"+result);
        return result;
    }

    /**
     * 注销邀请启动监听器
     * @param listener
     * @return
     */
    public boolean unregisterScheduleInviteChangeListener(OnScheduleInviteChangeListener listener) {
        boolean result = false;
        synchronized(mUnreadListenerList) {
            result = mUnreadListenerList.remove(listener);
        }
        Log.d(TAG,"unregisterUnreadListener-result:"+result);
        return result;
    }

    /**
     * 获取邀请未读数目
     */
    public void GetCountOfUnreadAndPendingInvite(){
        LiveRequestOperator.getInstance().GetCountOfUnreadAndPendingInvite(new OnGetCountOfUnreadAndPendingInviteCallback() {
            @Override
            public void onGetCountOfUnreadAndPendingInvite(boolean isSuccess, int errCode,
                                                           String errMsg, int total, int pendingNum,
                                                           int confirmedUnreadCount, int otherUnreadCount) {
                Log.d(TAG,"onGetCountOfUnreadAndPendingInvite-isSuccess:"+isSuccess+" errCode:"+errCode
                        +" errMsg:"+errMsg+" total:"+total+" pendingNum:"+pendingNum
                        +" confirmedUnreadCount:"+confirmedUnreadCount+" otherUnreadCount:"+otherUnreadCount);
            }
        });
    }

    /**
     * 获取已确定预约邀请数目
     */
    public void GetAllScheduledInviteCount(){
        LiveRequestOperator.getInstance().GetScheduledAcceptNum(new OnGetScheduledAcceptNumCallback() {
            @Override
            public void onGetScheduledAcceptNum(boolean isSuccess, int errCode, String errMsg, int scheduledNum) {
                Log.d(TAG,"onGetScheduledAcceptNum-isSuccess:"+isSuccess+" errCode:"+errCode
                        +" errMsg:"+errMsg+" scheduledNum:"+ String.valueOf(scheduledNum));
            }
        });
    }

    /**
     * 刷新预约邀请未读或待处理数量通知及回调处理
     * @param total
     * @param pendingNum
     * @param confirmedUnreadCount
     * @param otherUnreadCount
     */
    public void onRecvGetScheduleListNReadNumSuccess(int total, int pendingNum, int confirmedUnreadCount, int otherUnreadCount){
        Log.d(TAG,"onGetCountOfUnreadAndPendingInvite-total:"+total+" pendingNum:"+pendingNum
                +" confirmedUnreadCount:"+confirmedUnreadCount+" otherUnreadCount:"+otherUnreadCount);
        mScheduleInviteUnreadItem = new ScheduleInviteUnreadItem(total, pendingNum,
                confirmedUnreadCount, otherUnreadCount);
        onScheduleUnreadCallback();
    }

    /**
     * 刷新获取已确认预约数处理
     * @param scheduleNum
     */
    public void onRecvGetScheduledAcceptNumSuccess(int scheduleNum) {
        Log.d(TAG,"onGetScheduledAcceptNum-scheduledNum:"+ String.valueOf(scheduleNum));
        mScheduleInviteCount = scheduleNum;
        onScheduleUnreadCallback();
    }

    /**
     * 读取本地预约邀请未读条数
     * @return
     */
    public ScheduleInviteUnreadItem getScheduleInviteUnreadItem(){
        return mScheduleInviteUnreadItem;
    }

    /**
     * 获取所有已确认邀请数目
     * @return
     */
    public int getAllScheduledInviteCount(){
        return mScheduleInviteCount;
    }

    /**
     * 预约邀请未读分发器
     */
    private void onScheduleUnreadCallback(){
        synchronized(mUnreadListenerList){
            for (Iterator<OnScheduleInviteChangeListener> iter = mUnreadListenerList.iterator(); iter.hasNext(); ) {
                OnScheduleInviteChangeListener listener = iter.next();
                listener.onScheduleInviteUpdate(mScheduleInviteUnreadItem, mScheduleInviteCount);
            }
        }
    }

    public interface OnScheduleInviteChangeListener{
        void onScheduleInviteUpdate(ScheduleInviteUnreadItem item, int scheduledInvite);
    }

    /**
     * 清除本地数据
     */
    public void clearResetSelf(){
        mScheduleInviteCount = 0;
        mScheduleInviteUnreadItem = null;
    }
}

