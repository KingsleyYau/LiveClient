package com.qpidnetwork.qnbridgemodule.sysPermissions.manager;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import com.qpidnetwork.qnbridgemodule.bean.CommonConstant;

/**
 * 权限被重置管理工具
 * @author Jagger 2018-7-25
 */
public class PermissionResetManager {

    private final static long TIME_DIFFERENCE = 2 * 1000;

    /**
     * APP启动时间
     */
    private static long gAppStartTime = 0;

    /**
     * 初始化APP启动时间
     */
    public static void initAppStartTime(){
        gAppStartTime = System.currentTimeMillis();
    }

    /**
     * 原因：权限被禁止后，用户调用系统“设置”打开权限再返回APP时，系统会重启APP，走了Application的onCreate()并回到当前界面，
     *      但APP所有变量都被重置了。所以只有重新走一次启动流程，才能正常运行。参考：https://www.jianshu.com/p/cb68ca511776
     *
     * 疑问：例如拍照后savedInstanceState不为空，这样是否会导致重启APP。
     *      经测试，Activity的android:screenOrientation="portrait"时，拍照后不会调用onCreate,
     *      所以这种方法来处理暂时是可行的
     *
     * @param context
     * @param savedInstanceState
     * @return
     */
    public static boolean isPermissionReset(Context context, Bundle savedInstanceState){
        boolean isReset = false;
        if (null != savedInstanceState && (System.currentTimeMillis() - gAppStartTime < TIME_DIFFERENCE)) {
            Intent intent = new Intent(CommonConstant.ACTION_NOTIFICATION_APP_PERMISSION_RESET);
            intent.setPackage(context.getPackageName());
            context.sendBroadcast(intent);
        }
        return isReset;
    }

}
