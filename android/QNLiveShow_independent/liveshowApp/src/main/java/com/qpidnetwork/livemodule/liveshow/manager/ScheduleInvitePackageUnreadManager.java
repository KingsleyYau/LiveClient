package com.qpidnetwork.livemodule.liveshow.manager;

import android.os.Handler;
import android.os.Message;

import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetCountOfUnreadAndPendingInviteCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetPackageUnreadCountCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniPackage;
import com.qpidnetwork.livemodule.httprequest.RequstJniSchedule;
import com.qpidnetwork.livemodule.httprequest.item.PackageUnreadCountItem;
import com.qpidnetwork.livemodule.httprequest.item.ScheduleInviteUnreadItem;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.IMOtherEventListener;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.utils.Log;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Created by Hunter Mun on 2017/9/13.
 */

public class ScheduleInvitePackageUnreadManager implements IMOtherEventListener{

    private static final String TAG = ScheduleInvitePackageUnreadManager.class.getName();

    private PackageUnreadCountItem mPackageUnreadCountItem;
    private ScheduleInviteUnreadItem mScheduleInviteUnreadItem;
    private IMManager mIMManager;
    private List<OnUnreadListener> mUnreadListenerList;
    private static ScheduleInvitePackageUnreadManager mScheduleInvitePackageUnreadManager;
    private Handler handler;
    private final int EVENT_UPDATE_CENTER_UNREAD_INVITE = 2001;
    private final int EVENT_UPDATE_CENTER_UNREAD_BACKPACK = 2002;

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
        mIMManager = IMManager.getInstance();
        mIMManager.registerIMOtherEventListener(this);
        handler = new Handler(){
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                switch (msg.what){
                    case EVENT_UPDATE_CENTER_UNREAD_INVITE:
                        GetCountOfUnreadAndPendingInvite();
                        break;
                    case EVENT_UPDATE_CENTER_UNREAD_BACKPACK:
                        GetPackageUnreadCount();
                        break;
                }
            }
        };
    }

    /**
     * 注册邀请启动监听器
     * @param listener
     * @return
     */
    public boolean registerUnreadListener(OnUnreadListener listener){
        boolean result = false;
        synchronized(mUnreadListenerList) {
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
    public boolean unregisterUnreadListener(OnUnreadListener listener) {
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
                if(isSuccess){
                    mScheduleInviteUnreadItem = new ScheduleInviteUnreadItem(total, pendingNum,
                            confirmedUnreadCount, otherUnreadCount);
                    onScheduleUnreadCallback(mScheduleInviteUnreadItem);
                }
            }
        });
    }

    /**
     * 获取背包未读数目
     */
    public void GetPackageUnreadCount(){
        LiveRequestOperator.getInstance().GetPackageUnreadCount(new OnGetPackageUnreadCountCallback() {
            @Override
            public void onGetPackageUnreadCount(boolean isSuccess, int errCode, String errMsg, int total,
                                                int voucherNum, int giftNum, int rideNum) {
                Log.d(TAG,"onGetPackageUnreadCount-isSuccess:"+isSuccess+" errCode:"+errCode
                        +" errMsg:"+errMsg+" total:"+total+" voucherNum:"+voucherNum
                        +" giftNum:"+giftNum+" rideNum:"+rideNum);
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

    @Override
    public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {}

    @Override
    public void OnLogout(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {}

    @Override
    public void OnKickOff(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {}

    @Override
    public void OnRecvLackOfCreditNotice(String roomId, String message, double credit) {}

    @Override
    public void OnRecvCreditNotice(String roomId, double credit) {}

    @Override
    public void OnRecvAnchoeInviteNotify(String logId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {}

    @Override
    public void OnRecvScheduledInviteNotify(String inviteId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {
        //主播预约私密邀请通知
        Log.d(TAG,"OnRecvScheduledInviteNotify-inviteId:"+inviteId+" anchorId:"+anchorId+" anchorName:"+anchorName
                +" anchorPhotoUrl:"+anchorPhotoUrl+" message:"+message);
        if(null != handler){
            handler.sendEmptyMessage(EVENT_UPDATE_CENTER_UNREAD_INVITE);
        }
    }

    @Override
    public void OnRecvSendBookingReplyNotice(String inviteId, IMClientListener.BookInviteReplyType replyType) {
        //主播预约私密邀请回复
        Log.d(TAG,"OnRecvSendBookingReplyNotice-inviteId:"+inviteId+" replyType:"+replyType);
        if(null != handler){
            handler.sendEmptyMessage(EVENT_UPDATE_CENTER_UNREAD_INVITE);
        }
    }

    @Override
    public void OnRecvBookingNotice(String roomId, String userId, String nickName, String photoUrl, int leftSeconds) {

    }

    @Override
    public void OnRecvLevelUpNotice(int level) {
    }

    @Override
    public void OnRecvLoveLevelUpNotice(int lovelevel) {
    }

    @Override
    public void OnRecvBackpackUpdateNotice(IMPackageUpdateItem item) {
        //背包更新通知
        if(null != handler){
            handler.sendEmptyMessage(EVENT_UPDATE_CENTER_UNREAD_BACKPACK);
        }
    }

    /**
     * 清除本地数据
     */
    public void clearResetSelf(){
        mPackageUnreadCountItem = null;
        mScheduleInviteUnreadItem = null;
    }
}
