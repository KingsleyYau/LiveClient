package com.qpidnetwork.livemodule.liveshow.manager;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.os.Message;

import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetMainUnreadNumCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetNoReadNumProgramCallback;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.httprequest.item.MainUnreadNumItem;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.livemessage.LMLiveRoomEventListener;
import com.qpidnetwork.livemodule.livemessage.LMManager;
import com.qpidnetwork.livemodule.livemessage.item.LiveMessageItem;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * 直播模块红点未读管理器
 * 1. 更新本地未读数据并通知界面刷新逻辑
     1) 主界面viewDidAppear/onResume则显示本地内存未读数量，并执行《1.4》
     2) 收到
            im-《13.1.接收意向信通知》-- [IMManager->OnRecvLoiNotice->SendRefreshShowNoRead->refreshUnReadData()]
            im-《9.3.背包更新通知》-- [IMManager->OnRecvBackpackUpdateNotice->SendRefreshShowNoRead->refreshUnReadData()]
            im-《13.2.接收EMF通知》-- [IMManager->OnRecvEMFNotice->SendRefreshShowNoRead->refreshUnReadData()]
            im-《12.2.接收私信文本消息通知》
            im-《11.1.接收节目开播通知》[IMManager->OnRecvProgramPlayNotice->SendRefreshShowNoRead->refreshUnReadData()]
        则执行《1.4》
     3) IM断线重登录成功则执行《1.4》-- [IMManager->OnLogin->SendRefreshShowNoRead->refreshUnReadData()]
     4) 调用http-《6.17.获取主界面未读数量》，成功则更新到本地内存并刷新界面
 2. 主界面左上角icon未读逻辑
     1) viewDidAppear/onResume时判断本地内存是否有未读，有则显示红点，否则不显示
     2) 收到上述《1.3》通知时判断本地内存是否有未读，有则显示红点，否则不显示
 3. 左侧菜单显示未读逻辑
     1) 左侧菜单打开时判断本地内存是否有未读，若不为0则对应栏位显示未读数量，否则不显示
     2) 收到上述《1.3》通知时，按《3.1》处理
 4. 处理外部链接（如qpidnetwork://xxxx）
 5. 点击用户头像
     1) 则打开QN个人资料界面
     2) 点击Logout则执行QN的注销流程，并显示CharmLive登录界面
 * Created by Hunter on 18/4/23.
 */

public class ShowUnreadManager implements LMLiveRoomEventListener, IAuthorizationListener {

    private static final String TAG = ShowUnreadManager.class.getName();

    private List<OnShowUnreadListener> mUnreadListenerList;

    private static ShowUnreadManager mShowUnreadManager;

    private int msgUnReadNum = 0;
    /**
     * 私信未读数量
     */
    public int getMsgUnReadNum(){ return msgUnReadNum; }

    private int mailUnReadNum = 0;
    /**
     * emf未读数量
     */
    public int getMailUnReadNum(){ return mailUnReadNum; }

    private int greetMailUnReadNum = 0;
    /**
     * 意向信未读数量
     */
    public int getGreetMailUnReadNum(){ return greetMailUnReadNum; }

    private int mShowTicketUnreadNum = 0;
    /**
     * 是否有节目购票未读
     */
    public int getShowTicketUnreadNum(){ return mShowTicketUnreadNum; }

    private int mBookingUnReadNum = 0;
    /**
     * 是否有预约未读
     */
    public int getBookingUnReadNum(){ return mBookingUnReadNum; }

    private int mBackpackUnreadNum = 0;
    /**
     * 是否有背包礼物更新未读
     */
    public int getBackpackUnreadNum(){ return mBackpackUnreadNum; }

    private int mSayHiUnreadNum = 0;
    /**
     * SayHi未读
     */
    public int getSayHiUnreadNum() {
        return mSayHiUnreadNum;
    }

    private int mLivechatVocherUnreadNum = 0;
    /**
     * 是否有背包礼物更新未读
     */
    public int getLivechatVocherUnreadNum(){ return mLivechatVocherUnreadNum; }

    /**
     * 构建单例
     * @return
     */
    public static ShowUnreadManager getInstance(){
        return mShowUnreadManager;
    }

    public static ShowUnreadManager newInstance(Context context){
        if(mShowUnreadManager == null){
            mShowUnreadManager = new ShowUnreadManager(context);
        }
        return mShowUnreadManager;
    }

    private Context mContext;
    private Handler mHandler = null;

    @SuppressLint("HandlerLeak")
    private ShowUnreadManager(Context context){
        mUnreadListenerList = new ArrayList<OnShowUnreadListener>();

        this.mContext = context.getApplicationContext();
        mHandler = new Handler() {
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                refreshUnReadData();
            }
        };

    }

    /**
     * 刷新节目未读数目
     */
    @Deprecated
    public void GetNoReadNumProgram(){
        LiveRequestOperator.getInstance().GetNoReadNumProgram(new OnGetNoReadNumProgramCallback() {
            @Override
            public void onGetNoReadNumProgram(boolean isSuccess, int errCode, String errMsg, int num) {
                if(isSuccess){
                    onShowUnreadCallback(num);
                }
            }
        });
    }

    /**
     * 刷新未读数据
     * 调用http-《6.17 获取主界面未读数量》
     */
    public void refreshUnReadData(){
        Log.d(TAG,"refreshUnReadData");
        LiveRequestOperator.getInstance().GetMainUnreadNum(new OnGetMainUnreadNumCallback() {
            @Override
            public void onGetMainUnreadNum(boolean isSuccess, int errCode, String errMsg, MainUnreadNumItem unreadItem) {
                Log.d(TAG,"onGetMainUnreadNum-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg+" unreadItem:"+unreadItem);
                if(isSuccess && null != unreadItem){
                    //更新本地
                    msgUnReadNum = unreadItem.privateMessageUnreadNum;
                    mailUnReadNum = unreadItem.emfUnreadNum;
                    greetMailUnReadNum = unreadItem.loiUnreadNum;
                    mShowTicketUnreadNum = unreadItem.showTicketUnreadNum;
                    mBackpackUnreadNum = unreadItem.backpackUnreadNum;
                    mBookingUnReadNum = unreadItem.bookingUnreadNum;
                    mSayHiUnreadNum = unreadItem.sayHiResponseUnreadNum;
                    mLivechatVocherUnreadNum = unreadItem.livechatVocherUnreadNum;
                    //需要注意的是这里并不是UI线程--刷新界面
                    for(OnShowUnreadListener listener : mUnreadListenerList){
                        listener.onUnReadDataUpdate();
                    }
                }
            }
        });
    }

    /**
     * 注册邀请启动监听器
     * @param listener
     * @return
     */
    public boolean registerUnreadListener(OnShowUnreadListener listener){
        boolean result = false;
        synchronized(mUnreadListenerList) {
            if (null != listener) {
                boolean isExist = false;
                for (Iterator<OnShowUnreadListener> iter = mUnreadListenerList.iterator(); iter.hasNext(); ) {
                    OnShowUnreadListener theListener = iter.next();
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
    public boolean unregisterUnreadListener(OnShowUnreadListener listener) {
        boolean result = false;
        synchronized(mUnreadListenerList) {
            result = mUnreadListenerList.remove(listener);
        }
        Log.d(TAG,"unregisterUnreadListener-result:"+result);
        return result;
    }

    /**
     * 节目未读分发器
     * @param num
     */
    @Deprecated
    private void onShowUnreadCallback(int num){
        synchronized(mUnreadListenerList){
            for (Iterator<OnShowUnreadListener> iter = mUnreadListenerList.iterator(); iter.hasNext(); ) {
                OnShowUnreadListener listener = iter.next();
                listener.onShowUnreadUpdate(num);
            }
        }
    }

    public interface OnShowUnreadListener{
        /**
         *
         * @param unreadNum
         */
        @Deprecated
        void onShowUnreadUpdate(int unreadNum);
        void onUnReadDataUpdate();
    }

    @Override
    public void OnUpdateFriendListNotice(boolean success, HttpLccErrType errType, String errMsg) {

    }

    @Override
    public void OnRefreshPrivateMsgWithUserId(boolean success, HttpLccErrType errType, String errMsg, String userId, LiveMessageItem[] messageList, int reqId) {

    }

    @Override
    public void OnGetMorePrivateMsgWithUserId(boolean success, HttpLccErrType errType, String errMsg, String userId, LiveMessageItem[] messageList, int reqId, boolean canMore) {

    }

    @Override
    public void OnUpdatePrivateMsgWithUserId(String userId, LiveMessageItem[] messageList) {

    }

    @Override
    public void OnSendPrivateMessage(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String userId, LiveMessageItem messageItem) {

    }

    @Override
    public void OnRecvUnReadPrivateMsg(LiveMessageItem messageItem) {
        Log.d(TAG,"OnRecvPrivateMessage-messageItem:"+messageItem);
        if(null != mHandler){
            //接收到IM 12.2 接收私信文本消息通知后，需要调用http 6.17 获取主界面未读数量接口
            mHandler.sendEmptyMessage(1);
        }
    }

    @Override
    public void OnRepeatSendPrivateMsgNotice(String userId, LiveMessageItem[] messageList) {

    }

    //登录监听
    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {

    }

    @Override
    public void onLogout(boolean isMannual) {
        //清空未读数
        msgUnReadNum = 0;
        mailUnReadNum = 0;
        greetMailUnReadNum = 0;
        mShowTicketUnreadNum = 0;
        mBackpackUnreadNum = 0;
        mBookingUnReadNum = 0;
        mSayHiUnreadNum = 0;
        mLivechatVocherUnreadNum = 0;
        //需要注意的是这里并不是UI线程--刷新界面
        for(OnShowUnreadListener listener : mUnreadListenerList){
            listener.onUnReadDataUpdate();
        }
    }

}
