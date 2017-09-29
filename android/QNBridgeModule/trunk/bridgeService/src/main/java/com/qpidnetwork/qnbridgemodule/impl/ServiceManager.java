package com.qpidnetwork.qnbridgemodule.impl;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.text.TextUtils;

import com.qpidnetwork.qnbridgemodule.DialogActivity;
import com.qpidnetwork.qnbridgemodule.interfaces.IQNService;
import com.qpidnetwork.qnbridgemodule.interfaces.IServiceManager;

import java.util.HashMap;
import java.util.Map;

/**
 * 模块管理接口类（用于协调多个模块间通信）
 * (处理QN和直播的服务冲突)
 * Created by Jagger on 2017/9/15.
 */

public class ServiceManager implements IServiceManager {

    private final String KEY_URL_SCHEME = "qpidnetwork";
    private final String KEY_URL_AUTHORITY = "app";
    private final String KEY_URL_PATH = "/open";
    private final String KEY_URL_SERVICE = "service";
    public final static String KEY_URL_SERVICE_NAME_QN = "qn";
    public final static String KEY_URL_SERVICE_NAME_LIVE = "live";

    private Context mContext;
    private Map<String ,IQNService> mMapQNServices = new HashMap<>();
    private String mQNServiceName4Working;  //当前服务名
    private String mNewServiceName;         //新服务名
    private String mUrl;    //服务定向


    public static ServiceManager getInstance(Context c){
        if(mServiceManager == null){
            mServiceManager = new ServiceManager(c);
        }

        return mServiceManager;
    }

    private static ServiceManager mServiceManager;
    private ServiceManager(Context c){
        mContext = c.getApplicationContext();
    }



    @Override
    public void onSubServiceLoginStatusException(IQNService service) {

    }

    /**
     * 标识当前正在使用哪个服务
     * （功能启动时，如：camshare,livechat.　都调用这个方法）
     * @param service
     * @return 服务间是否有冲突
     */
    @Override
    public boolean startService(IQNService service) {
        boolean isConflict = false;

        if(TextUtils.isEmpty(mQNServiceName4Working)){
            //首次启动服务
            mQNServiceName4Working = service.getServiceName();
        }else{
            //再次启动服务
            if(!mQNServiceName4Working.equals(service.getServiceName())){
                //当是新的服务时
                mNewServiceName = service.getServiceName();
                //show Dialog
//                mContext.startActivity(new Intent(mContext , DialogActivity.class));
                Intent intent = new Intent(mContext, DialogActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS);
                mContext.startActivity(intent);

                //服务间有冲突
                isConflict = true;
            }
        }
        return isConflict;
    }

    /**
     * 将当前正在使用的服务已结束
     * @param service
     */
    @Override
    public void stopService(IQNService service) {
        if(mQNServiceName4Working.equals(service.getServiceName())){
            mQNServiceName4Working = "";
        }
    }

    /**
     * 注册到服务列表
     * （启动APP时　调用这个方法）
     * @param service
     */
    @Override
    public void registerService(IQNService service) {
        mMapQNServices.put(service.getServiceName() , service);
    }

    @Override
    public void unregisterService(IQNService service) {
        mMapQNServices.remove(service.getServiceName());
    }

    /**
     * 从通知栏触发
     * （点击通知栏　都调用这个方法）
     * @param url
     * @return 是否有对应服务
     */
    @Override
    public boolean openSpecifyService(String url) {
        mUrl = url;

        //从服务列表中取出对应服务
        if(mMapQNServices.containsKey(getServiceFromURL())){
            //startService
            if(!startService(mMapQNServices.get(getServiceFromURL()))){
                //是原来的服务
                //交由服务控制跳转
                mMapQNServices.get(mQNServiceName4Working).openUrl(mUrl);
            }
            return true;
        }
        return false;
    }

    /**
     * 对话框点击OK
     * @param activity
     */
    public void onDialogOK(DialogActivity activity){
        //必须是DialogActivity点确定才会执行

        if(activity.getClass().equals(DialogActivity.class) && !TextUtils.isEmpty(mUrl)){

            if(!getServiceFromURL().equals(mQNServiceName4Working)){
                //停止旧服务，替换为新服务
                mMapQNServices.get(mQNServiceName4Working).stopService();
                mQNServiceName4Working = mNewServiceName;
                mNewServiceName = null;
            }

            //交由服务控制跳转
            mMapQNServices.get(mQNServiceName4Working).openUrl(mUrl);
        }

    }

    /**
     * 解析URL
     * @return
     */
    private String getServiceFromURL(){
        String serivceName = "";

        Uri uri = Uri.parse(mUrl);
        String scheme = uri.getScheme();
        String authority = uri.getAuthority();
        String path = uri.getPath();
        if(scheme.equals(KEY_URL_SCHEME) && authority.equals(KEY_URL_AUTHORITY) && path.equals(KEY_URL_PATH)){
            serivceName = uri.getQueryParameter(KEY_URL_SERVICE);
        }

        return serivceName;
    }

    /**
     * 是否有服务正在运行
     * （也可以作为APP是否启动标识）
     * @return
     */
    public boolean isWorking(){
        return mMapQNServices.size() > 0?true : false;
    }
}
