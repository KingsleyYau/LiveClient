package com.qpidnetwork.anchor.framework.services;

import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;

/**
 * APP被杀清除通知栏服务
 */
public class KillNotificationsService extends Service {
    public class KillBinder extends Binder {
        public final Service service;

        public KillBinder(Service service) {
            this.service = service;
        }

    }


    private final IBinder mBinder = new KillBinder(this);


    @Override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }


    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return Service.START_STICKY;
    }


    @Override
    public void onCreate() {
    }

    @Override
    public void onTaskRemoved(Intent rootIntent) {
        NotificationManager notifyManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        notifyManager.cancelAll();
    }
}
