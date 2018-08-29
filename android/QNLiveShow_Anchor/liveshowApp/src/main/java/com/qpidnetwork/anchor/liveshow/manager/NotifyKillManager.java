package com.qpidnetwork.anchor.liveshow.manager;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;

import com.qpidnetwork.anchor.framework.services.KillNotificationsService;

/**
 * APP被杀清除通知栏
 * Created by Jagger on 2018/3/30.
 */
public class NotifyKillManager {

    private Context mContext;
    private ServiceConnection mConnection;

    public static NotifyKillManager getInstance(Context c) {
        if (singleton == null) {
            singleton = new NotifyKillManager(c);
        }

        return singleton;
    }

    private static NotifyKillManager singleton;

    private NotifyKillManager(Context c) {
        mContext = c.getApplicationContext();

        mConnection = new ServiceConnection() {
            public void onServiceConnected(ComponentName className, IBinder binder) {
                ((KillNotificationsService.KillBinder) binder).service.startService(new Intent(mContext, KillNotificationsService.class));
            }

            public void onServiceDisconnected(ComponentName className) {
            }
        };
    }

    /**
     * 绑定服务
     */
    public void init(){
        //
        mContext.bindService(new Intent(mContext, KillNotificationsService.class), mConnection, Context.BIND_AUTO_CREATE);
    }

    /**
     * 解绑服务
     */
    public void unbind(){
        try{
            mContext.unbindService(mConnection);
        }catch (Exception e){}

    }
}
