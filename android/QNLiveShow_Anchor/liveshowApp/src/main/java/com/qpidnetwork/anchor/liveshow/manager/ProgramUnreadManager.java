package com.qpidnetwork.anchor.liveshow.manager;

import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.OnGetNoReadNumProgramCallback;
import com.qpidnetwork.anchor.utils.Log;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * 节目未读管理器
 * Created by Hunter on 18/4/23.
 */

public class ProgramUnreadManager {

    private static final String TAG = ProgramUnreadManager.class.getName();

    private List<OnProgramUnreadListener> mUnreadListenerList;

    private static ProgramUnreadManager mShowUnreadManager;

    private int mShowNoRead = 0;

    /**
     * 构建单例
     * @return
     */
    public static ProgramUnreadManager getInstance(){
        if(mShowUnreadManager == null){
            mShowUnreadManager = new ProgramUnreadManager();
        }
        return mShowUnreadManager;
    }

    private ProgramUnreadManager(){
        mUnreadListenerList = new ArrayList<OnProgramUnreadListener>();
    }

    /**
     * 注册邀请启动监听器
     * @param listener
     * @return
     */
    public boolean registerUnreadListener(OnProgramUnreadListener listener){
        boolean result = false;
        synchronized(mUnreadListenerList) {
            if (null != listener) {
                boolean isExist = false;
                for (Iterator<OnProgramUnreadListener> iter = mUnreadListenerList.iterator(); iter.hasNext(); ) {
                    OnProgramUnreadListener theListener = iter.next();
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
    public boolean unregisterUnreadListener(OnProgramUnreadListener listener) {
        boolean result = false;
        synchronized(mUnreadListenerList) {
            result = mUnreadListenerList.remove(listener);
        }
        Log.d(TAG,"unregisterUnreadListener-result:"+result);
        return result;
    }

    /**
     * 刷新节目未读数目
     */
    public void GetNoReadNumProgram(){
        LiveRequestOperator.getInstance().GetNoReadNumProgram(new OnGetNoReadNumProgramCallback() {
            @Override
            public void onGetNoReadNumProgram(boolean isSuccess, int errCode, String errMsg, int num) {
                if(isSuccess){
                    mShowNoRead = num;
                    onShowUnreadCallback(num);
                }
            }
        });
    }

    /**
     * 读取本地未读数目
     * @return
     */
    public int GetLocalShowNoRead(){
        return mShowNoRead;
    }

    /**
     * 清除本地未读数
     */
    public void clearLocalParams(){
        mShowNoRead = 0;
    }

    /**
     * 节目未读分发器
     * @param num
     */
    private void onShowUnreadCallback(int num){
        synchronized(mUnreadListenerList){
            for (Iterator<OnProgramUnreadListener> iter = mUnreadListenerList.iterator(); iter.hasNext(); ) {
                OnProgramUnreadListener listener = iter.next();
                listener.onProgramUnreadUpdate(num);
            }
        }
    }

    public interface OnProgramUnreadListener{
        void onProgramUnreadUpdate(int unreadNum);
    }

}
