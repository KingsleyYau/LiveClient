package com.qpidnetwork.anchor.utils;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/12/11.
 */

import android.app.AppOpsManager;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.graphics.PixelFormat;
import android.os.Build;
import android.os.Handler;
import android.os.Message;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.Toast;

import com.qpidnetwork.anchor.R;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.Timer;
import java.util.TimerTask;

/**
 * Description: 参考:
 * <p>https://raw.githubusercontent.com/Blincheng/EToast2/master/etoast2/src/main/java/com/mic/etoast2/EToast2.java
 * Created by Harry on 2017/9/18.
 */
public class EToast2 {

    private WindowManager manger;
    private Long time = 2000L;
    private static View contentView;
    private WindowManager.LayoutParams params;
    private static Timer timer;
    private Toast toast;
    private static Toast oldToast;
    public static final int LENGTH_SHORT = 0;
    public static final int LENGTH_LONG = 1;
    private static Handler handler;
    private CharSequence text;
    private Context mContext;
    private static final String TAG = EToast2.class.getSimpleName();

    private EToast2(Context context, CharSequence text, int HIDE_DELAY){
        manger = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        this.mContext = context.getApplicationContext();
        this.text = text;

        if(HIDE_DELAY == EToast2.LENGTH_SHORT)
            this.time = 2000L;
        else if(HIDE_DELAY == EToast2.LENGTH_LONG)
            this.time = 3000L;

        if(oldToast == null){
            toast = new Toast(context);
            contentView = View.inflate(context, R.layout.view_custom_toast, null);
            toast.setView(contentView);
            toast.setText(text);
        }

        params = new WindowManager.LayoutParams();
        params.height = WindowManager.LayoutParams.WRAP_CONTENT;
        params.width = WindowManager.LayoutParams.WRAP_CONTENT;
        params.format = PixelFormat.TRANSLUCENT;
        params.windowAnimations = -1;
        params.setTitle("EToast2");
        params.flags = WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                | WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE;
        params.gravity = Gravity.CENTER_HORIZONTAL | Gravity.BOTTOM;
        params.y = DisplayUtil.dip2px(context,64f);

        if(handler == null){
            handler = new Handler(){
                @Override
                public void handleMessage(Message msg) {
                    EToast2.this.cancel();
                }
            };
        }
    }

    public static EToast2 makeText(Context context, String text, int HIDE_DELAY){
        EToast2 toast = new EToast2(context, text, HIDE_DELAY);
        return toast;
    }

    public static EToast2 makeText(Context context, int resId, int HIDE_DELAY) {
        return makeText(context,context.getText(resId).toString(),HIDE_DELAY);
    }

    public EToast2 setGravity(int gravity){
        if(null != params){
            params.gravity = gravity;
            if(gravity == Gravity.CENTER){
                params.y = 0;
            }else if(gravity == (Gravity.CENTER_HORIZONTAL|Gravity.BOTTOM)){
                params.y = DisplayUtil.dip2px(mContext,64f);
            }
        }
        return this;
    }

    public void show(){
        if(oldToast == null){
            oldToast = toast;
            manger.addView(contentView, params);
        }else{
            manger.updateViewLayout(contentView,params);
            timer.cancel();
            oldToast.setText(text);
        }
        timer = new Timer();
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                handler.sendEmptyMessage(1);
            }
        }, time);
    }

    public void cancel(){
        try {
            manger.removeView(contentView);
        } catch (IllegalArgumentException e) {
            //这边由于上下文被销毁后removeView可能会抛出IllegalArgumentException
            //暂时这么处理，因为EToast2是轻量级的，不想和Context上下文的生命周期绑定在一块儿
            //其实如果真的想这么做，可以参考博文2的第一种实现方式，添加一个空的fragment来做生命周期绑定
        }
        timer.cancel();
        oldToast.cancel();
        timer = null;
        toast = null;
        oldToast = null;
        contentView = null;
        handler = null;
    }
    public void setText(CharSequence s){
        toast.setText(s);
    }

    private static final String CHECK_OP_NO_THROW = "checkOpNoThrow";
    private static final String OP_POST_NOTIFICATION = "OP_POST_NOTIFICATION";
    /**
     * 用来判断是否开启通知权限
     * */
    public static boolean isNotificationEnabled(Context context){
        boolean isNotificationEnabled = true;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            AppOpsManager mAppOps = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
            ApplicationInfo appInfo = context.getApplicationInfo();
            String pkg = context.getApplicationContext().getPackageName();
            int uid = appInfo.uid;
            Class appOpsClass = null; /* Context.APP_OPS_MANAGER */
            try {
                appOpsClass = Class.forName(AppOpsManager.class.getName());
                Method checkOpNoThrowMethod = appOpsClass.getMethod(CHECK_OP_NO_THROW, Integer.TYPE, Integer.TYPE, String.class);
                Field opPostNotificationValue = appOpsClass.getDeclaredField(OP_POST_NOTIFICATION);
                int value = (int)opPostNotificationValue.get(Integer.class);
                isNotificationEnabled = ((int)checkOpNoThrowMethod.invoke(mAppOps,value, uid, pkg) == AppOpsManager.MODE_ALLOWED);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        Log.d(TAG,"isNotificationEnabled-isNotificationEnabled:"+isNotificationEnabled);
        return isNotificationEnabled;
    }

    public static boolean isErrToastDevice(){
        boolean isErrToastDevice = false;
        for(String deviceName: errShowToastDeviceNames){
            if(deviceName.equals(android.os.Build.MODEL)){
                isErrToastDevice = true;
                Log.d(TAG,"isErrToastDevice-deviceName:"+deviceName+" isErrToastDevice:"+isErrToastDevice);
                break;
            }
        }
        return isErrToastDevice;
    }

    /**
     * 无法正常弹出toast的设备名称
     */
    private static final String[] errShowToastDeviceNames = {
            "SM-J3300"
    };
}