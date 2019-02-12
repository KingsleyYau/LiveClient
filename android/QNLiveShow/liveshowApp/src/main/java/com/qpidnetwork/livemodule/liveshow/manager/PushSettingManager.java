package com.qpidnetwork.livemodule.liveshow.manager;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.im.IMLoginStatusListener;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.liveshow.authorization.IAuthorizationListener;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.personal.SettingPerfenceLive;
import com.qpidnetwork.livemodule.utils.ListUtils;
import com.qpidnetwork.livemodule.utils.SPUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Hardy on 2018/9/19.
 * 直播推送的开关设置管理器
 * 按用户帐号记录配置
 * <p>
 * <p>
 * 1. 刷新逻辑
 * 1) http登录成功后判断若本地配置文件不存在或提交标志为false，则请求《获取推送设置》接口，成功则生成/覆盖本地配置按帐号记录配置
 * 2) onCreate/viewDidLoad时，判断本地配置文件是否存在
 * a. 若存在，则按本地配置文件显示数据至界面
 * b. 若不存在，则请求《获取推送设置》接口，成功则生成本地配置文件并刷新界面，不成功则
 * <p>
 * 2. 修改逻辑
 * 1) 用户修改配置，则更新本地配置文件，并修改本地配置文件中的提交标志为true
 * 2) 当关闭“设置界面”时，则执行《2.5》
 * 3) 当IM断线重登录成功时，则执行《2.5》
 * 4) 当http登录成功时，则执行《2.5》
 * 5) 判断本地配置文件提交标志是否为true，若是则调用《修改推送设置》接口，成功则修改本地配置文件提交标志为false
 * <p>
 * 2018/09/28 Hardy 暂时去掉
 */
@Deprecated
public class PushSettingManager implements IAuthorizationListener, IMLoginStatusListener {

    /**
     * 文件是否被修改
     * value   Boolean
     * true:   修改
     * false:  没有修改
     */
    private static final String KEY_IS_LIVE_PUSH_FILE_EDIT = "key_is_live_push_file_edit";

    /**
     * 文件是否存在，绑定用户账号 ID
     * <p>
     * value    String
     * 空：   不存在
     * 非空：  存在
     */
    // 文件的名字+用户账号 ID
    private static final String LIVE_PUSH_FILE_NAME = "LivePushFileName";


    private static final int CODE_GET_PUSH_DATA = 1;
    private static final int CODE_CHANGE_PUSH_DATA = 2;


    private static final class HolderClass {
        private static final PushSettingManager INSTANCE = new PushSettingManager();
    }

    public static PushSettingManager getInstance() {
        return PushSettingManager.HolderClass.INSTANCE;
    }

    private Context mContext;
    private Handler mUIHandler;
    private List<IOnPushDataGetListener> mListenerList;

    /**
     * 初始化
     */
    public void init(Context context) {
        this.mContext = context.getApplicationContext();

        if (mListenerList == null) {
            mListenerList = new ArrayList<>();
        }

        if (mUIHandler == null) {
            mUIHandler = new Handler(Looper.getMainLooper()) {
                @Override
                public void handleMessage(Message msg) {
                    super.handleMessage(msg);

                    int what = msg.what;

                    // 获取用户 ID
                    String userId = getCurUserId();

                    switch (what) {
                        case CODE_GET_PUSH_DATA:        // 获取推送设置
                            // 设置本地文件存在
                            saveFileExist(userId);
                            // 设置本地文件修改记录为 false
                            saveFileEdit(userId, false);

                            // 2018/9/20 推送开关设置的记录
                            SettingPerfenceLive.NotificationItem notificationItem = (SettingPerfenceLive.NotificationItem) msg.obj;
                            SettingPerfenceLive.saveNotificationItem(mContext, notificationItem, userId);

                            // 通知外层
                            notificationAllListener(notificationItem);
                            break;

                        case CODE_CHANGE_PUSH_DATA:     // 修改推送设置
                            // 设置本地文件修改记录为 false
                            saveFileEdit(userId, false);
                            break;
                    }
                }
            };
        }

        registerLoginOrIMEvent();
    }

    public void onDestroy() {
        if (mUIHandler != null) {
            mUIHandler.removeCallbacksAndMessages(null);
        }

        if (ListUtils.isList(mListenerList)) {
            mListenerList.clear();
        }

        LoginManager.getInstance().unRegister(this);
        IMManager.getInstance().unregisterIMLoginStatusListener(this);
    }

    public void registerLoginOrIMEvent() {
        LoginManager.getInstance().register(this);
        IMManager.getInstance().registerIMLoginStatusListener(this);
    }

    public void addListener(IOnPushDataGetListener listener) {
        synchronized (mListenerList) {
            if (listener != null) {
                boolean isExit = false;
                for (IOnPushDataGetListener iOnPushDataGetListener : mListenerList) {
                    if (iOnPushDataGetListener == listener) {
                        isExit = true;
                        break;
                    }
                }

                if (!isExit) {
                    mListenerList.add(listener);
                }
            }
        }
    }

    public void removeListener(IOnPushDataGetListener listener) {
        synchronized (mListenerList) {
            if (listener != null) {
                mListenerList.remove(listener);
            }
        }
    }

    public void notificationAllListener(SettingPerfenceLive.NotificationItem notificationItem) {
        synchronized (mListenerList) {
            for (IOnPushDataGetListener iOnPushDataGetListener : mListenerList) {
                iOnPushDataGetListener.onGetData(notificationItem);
            }
        }
    }

    /**
     * 外层调用，检测并执行以下时机
     * 1——1)
     * 2.修改逻辑
     *
     * @param isGetServerData 如果不存在本地文件，是否执行获取推送设置的服务器数据
     */
    public void syncPushData(boolean isGetServerData) {
        String userId = getCurUserId();
        if (TextUtils.isEmpty(userId)) {
            return;
        }

        boolean isExist = isFileExist(userId);
        boolean isEdit = isFileEdit(userId);

        if (isExist && isEdit) {
            // TODO: 2018/9/20   调用《修改推送设置》接口，成功则修改本地配置文件提交标志为false


        } else if (isGetServerData) {
            //  TODO: 2018/9/20  《获取推送设置》接口，成功则生成/覆盖本地配置按帐号记录配置


        }
    }


    private void saveFileExist(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        SPUtils.put(mContext, LIVE_PUSH_FILE_NAME, LIVE_PUSH_FILE_NAME + userId, userId);
    }

    private boolean isFileExist(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return false;
        }
        String userIdTemp = (String) SPUtils.get(mContext, LIVE_PUSH_FILE_NAME, LIVE_PUSH_FILE_NAME + userId, "");
        return !TextUtils.isEmpty(userIdTemp);
    }

    private void saveFileEdit(String userId, boolean isEdit) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }
        SPUtils.put(mContext, LIVE_PUSH_FILE_NAME, KEY_IS_LIVE_PUSH_FILE_EDIT + userId, isEdit);
    }

    private boolean isFileEdit(String userId) {
        if (TextUtils.isEmpty(userId)) {
            return false;
        }
        return (boolean) SPUtils.get(mContext, LIVE_PUSH_FILE_NAME, KEY_IS_LIVE_PUSH_FILE_EDIT + userId, false);
    }

    public String getCurUserId() {
        String userId = LoginManager.getInstance().getLoginItem() != null ? LoginManager.getInstance().getLoginItem().userId : null;
        if (TextUtils.isEmpty(userId)) {
            userId = LoginManager.getInstance().getAccountInfo() != null ? LoginManager.getInstance().getAccountInfo().memberId : null;
        }

        return userId;
    }

    public SettingPerfenceLive.NotificationItem getNotificationItem() {
        if (!isFileExist(getCurUserId())) {
            return null;
        }
        return SettingPerfenceLive.getNotificationItem(mContext, getCurUserId());
    }

    public void saveNotificationItem(SettingPerfenceLive.NotificationItem notificationItem) {
        String userId = getCurUserId();
        SettingPerfenceLive.saveNotificationItem(mContext, notificationItem, userId);
        // 记录本地修改
        saveFileExist(userId);
        saveFileEdit(userId, true);
    }


    /**
     * interface
     */
    public interface IOnPushDataGetListener {
        void onGetData(SettingPerfenceLive.NotificationItem notificationItem);
    }


    //===================   登录状态 回调 ==============================================
    @Override
    public void onLogin(boolean isSuccess, int errCode, String errMsg, LoginItem item) {
        if (isSuccess) {
            syncPushData(true);
        }
    }

    @Override
    public void onLogout(boolean isMannual) {

    }

    //===================   登录状态 回调 ==============================================

    //===================   IM 断线重连成功 回调 ==============================================
    @Override
    public void onIMAutoReLogined() {
        syncPushData(false);
    }
    //===================   IM 断线重连成功 回调 ==============================================
}
