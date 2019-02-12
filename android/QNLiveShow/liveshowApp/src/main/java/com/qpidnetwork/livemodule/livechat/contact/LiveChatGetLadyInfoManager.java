package com.qpidnetwork.livemodule.livechat.contact;

import com.qpidnetwork.livemodule.livechat.LCUserItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerOtherListener;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClient;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatSessionInfoItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatTalkUserListItem;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatUserCamStatus;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class LiveChatGetLadyInfoManager implements LiveChatManagerOtherListener{

    private LiveChatManager mLiveChatManager;
    private HashMap<String, List<OnLiveChatGetLadyInfoCallback>> mGetLadyCallbackMap;
    private HashMap<String, Boolean> mGetLadyInfoRequestingMap;

    public LiveChatGetLadyInfoManager(){
        mLiveChatManager = LiveChatManager.getInstance();
        mGetLadyCallbackMap = new HashMap<String, List<OnLiveChatGetLadyInfoCallback>>() ;
        mGetLadyInfoRequestingMap = new HashMap<String, Boolean>();
    }

    /**
     *  初始化
     */
    public void init(){
        //绑定监听事件
        mLiveChatManager.RegisterOtherListener(this);
    }

    /**
     * 反初始化
     */
    public void uninit(){
        mGetLadyCallbackMap.clear();
        mLiveChatManager.UnregisterOtherListener(this);
    }

    /**
     * 查询用户信息
     * @param userId
     * @param callback
     */
    public void getLadyInfo(String userId, OnLiveChatGetLadyInfoCallback callback){
        LiveChatTalkUserListItem userInfo = mLiveChatManager.GetLadyInfoById(userId);
        if(userInfo != null){
            if(callback != null){
                callback.onLiveChatGetLadyInfo(true, userInfo);
            }
        }else{
            //添加到callback列表
            if(callback != null) {
                addToCallbackList(userId, callback);
            }

            if(!isGetLadyInfo(userId)){
                addToRequestingMap(userId);
                //获取信息
                if(!mLiveChatManager.GetUserInfo(userId)){
                    notifyAllListener(userId, false, null);
                }
            }
        }
    }

    /**
     * 增加请求中状态
     * @param userId
     */
    private void addToRequestingMap(String userId){
        synchronized (mGetLadyInfoRequestingMap){
            if(!mGetLadyInfoRequestingMap.containsKey(userId)){
                mGetLadyInfoRequestingMap.put(userId, true);
            }
        }
    }

    /**
     * 删除请求中状态
     * @param userId
     */
    private void removeFromRequestingMap(String userId){
        synchronized (mGetLadyInfoRequestingMap){
            mGetLadyInfoRequestingMap.remove(userId);
        }
    }

    /**
     * 是否请求中，用于处理多次同一个用户请求
     * @param userId
     * @return
     */
    private boolean isGetLadyInfo(String userId){
        boolean isRequesting = false;
        synchronized (mGetLadyInfoRequestingMap){
            isRequesting = mGetLadyInfoRequestingMap.containsKey(userId);
        }
        return isRequesting;
    }

    /**
     * 添加callback到callbackList
     * @param userId
     * @param callback
     */
    public void addToCallbackList(String userId, OnLiveChatGetLadyInfoCallback callback){
        synchronized (mGetLadyCallbackMap){
            List<OnLiveChatGetLadyInfoCallback> callbackList = mGetLadyCallbackMap.get(userId);
            if(callbackList == null){
                callbackList = new ArrayList<OnLiveChatGetLadyInfoCallback>();
                mGetLadyCallbackMap.put(userId, callbackList);
            }
            callbackList.add(callback);
        }
    }

    /**
     * 统一回调通知处理
     * @param userId
     * @param isSuccess
     * @param userInfo
     */
    public void notifyAllListener(String userId, boolean isSuccess, LiveChatTalkUserListItem userInfo){
        synchronized (mGetLadyCallbackMap){
            List<OnLiveChatGetLadyInfoCallback> callbackList = mGetLadyCallbackMap.get(userId);
            if(callbackList != null){
                for(OnLiveChatGetLadyInfoCallback callback : callbackList){
                    if(callback != null){
                        callback.onLiveChatGetLadyInfo(isSuccess, userInfo);
                    }
                }
            }
            mGetLadyCallbackMap.remove(userId);
        }
        removeFromRequestingMap(userId);
    }

    /***********************************  LiveChatManager Callback  ********************************/
    @Override
    public void OnLogin(LiveChatClientListener.LiveChatErrType errType, String errmsg, boolean isAutoLogin) {

    }

    @Override
    public void OnLogout(LiveChatClientListener.LiveChatErrType errType, String errmsg, boolean isAutoLogin) {

    }

    @Override
    public void OnGetTalkList(LiveChatClientListener.LiveChatErrType errType, String errmsg) {

    }

    @Override
    public void OnGetHistoryMessage(boolean success, String errno, String errmsg, LCUserItem userItem) {

    }

    @Override
    public void OnGetUsersHistoryMessage(boolean success, String errno, String errmsg, LCUserItem[] userItems) {

    }

    @Override
    public void OnSetStatus(LiveChatClientListener.LiveChatErrType errType, String errmsg) {

    }

    @Override
    public void OnGetUserStatus(LiveChatClientListener.LiveChatErrType errType, String errmsg, LCUserItem[] userList) {

    }

    @Override
    public void OnGetUserInfo(LiveChatClientListener.LiveChatErrType errType, String errmsg, String userId, LiveChatTalkUserListItem item) {
        notifyAllListener(userId, errType == LiveChatClientListener.LiveChatErrType.Success ? true : false, item);
    }

    @Override
    public void OnGetUsersInfo(LiveChatClientListener.LiveChatErrType errType, String errmsg, String[] userIds, LiveChatTalkUserListItem[] itemList) {

    }

    @Override
    public void OnGetContactList(LiveChatClientListener.LiveChatErrType errType, String errmsg, LiveChatTalkUserListItem[] list) {

    }

    @Override
    public void OnUpdateStatus(LCUserItem userItem) {

    }

    @Override
    public void OnChangeOnlineStatus(LCUserItem userItem) {

    }

    @Override
    public void OnRecvKickOffline(LiveChatClientListener.KickOfflineType kickType) {

    }

    @Override
    public void OnRecvEMFNotice(String fromId, LiveChatClientListener.TalkEmfNoticeType noticeType) {

    }

    @Override
    public void OnGetLadyCamStatus(LiveChatClientListener.LiveChatErrType errType, String errmsg, String womanId, boolean isCam) {

    }

    @Override
    public void OnGetUsersCamStatus(LiveChatClientListener.LiveChatErrType errType, String errmsg, LiveChatUserCamStatus[] userIds) {

    }

    @Override
    public void OnRecvLadyCamStatus(String userId, LiveChatClient.UserStatusProtocol statuType) {

    }

    @Override
    public void OnGetSessionInfo(LiveChatClientListener.LiveChatErrType errType, String errmsg, String userId, LiveChatSessionInfoItem item) {

    }


    /***********************************  LiveChatGetLadyInfo接口  ********************************/
    public interface OnLiveChatGetLadyInfoCallback{
        public void onLiveChatGetLadyInfo(boolean isSuccess, LiveChatTalkUserListItem userInfo);
    }
}
