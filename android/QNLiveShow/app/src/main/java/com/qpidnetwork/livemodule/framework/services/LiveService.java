package com.qpidnetwork.livemodule.framework.services;

import android.content.Context;
import android.util.Log;

import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.qnbridgemodule.impl.ServiceManager;
import com.qpidnetwork.qnbridgemodule.interfaces.IQNService;

/**
 * Created by Jagger on 2017/9/18.
 */

public class LiveService implements IQNService {

    private Context mContext;

    public static LiveService getInstance(Context c){
        if(mQNService == null){
            mQNService = new LiveService(c);
        }

        return mQNService;
    }

    private static LiveService mQNService;
    private LiveService(Context c){
        mContext = c.getApplicationContext();
    }

    @Override
    public void onMainServiceLogin() {

    }

    @Override
    public void onMainServiceLogout(LogoutType type, String tips) {

    }

    @Override
    public void onAppKickoff(String tips) {

    }

    @Override
    public String getServiceName() {
        return ServiceManager.KEY_URL_SERVICE_NAME_LIVE;
    }

    @Override
    public void openUrl(String url) {
        //...
        Log.i("Jagger","LiveService openUrl:" + url);
        URL2ActivityManager.getInstance(mContext).GotoActivity(url);
    }

    @Override
    public String isStopService(String url) {
        return null;
    }

    @Override
    public String getServiceConflict() {
        return null;
    }

    @Override
    public boolean stopService() {
        return false;
    }
}
