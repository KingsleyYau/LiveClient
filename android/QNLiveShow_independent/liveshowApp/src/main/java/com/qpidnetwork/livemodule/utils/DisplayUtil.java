package com.qpidnetwork.livemodule.utils;

import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.util.DisplayMetrics;

import java.lang.reflect.Method;

import static android.os.Build.VERSION_CODES.LOLLIPOP;

/**
 * 界面显示相关的工具类
 *
 * Created by Harry(魏海涛) on 2017-05-19
 */
public class DisplayUtil {
    /**
     * dip转化成px
     */
    public static int dip2px(Context context, float dpValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    /**
     * px转化成dip
     */
    public static int px2dip(Context context, float pxValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (pxValue / scale + 0.5f);
    }

    /**
     * px转化成sp
     */
    public static int px2sp(Context context, float pxValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (pxValue / scale + 0.5f);
    }

    /**
     * sp转化成px
     */
    public static int sp2px(Context context, float spValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (spValue * scale + 0.5f);
    }


    private static final String TAG = DisplayUtil.class.getSimpleName();

    /**
     * 获取状态栏高度
     * @param context
     * @return
     */
    public static int getStatusBarHeight(Context context) {
        int result = 0;
        int resourceId = context.getResources().getIdentifier("status_bar_height", "dimen", "android");
        if (resourceId > 0) {
            result = context.getResources().getDimensionPixelSize(resourceId);
        }
        return result;
    }

    /**
     * 获取屏幕宽度
     * @param context
     * @return
     */
    public static int getScreenWidth(Context context) {
        DisplayMetrics dm = new DisplayMetrics();
        ((Activity) context).getWindowManager().getDefaultDisplay().getMetrics(dm);
        return dm.widthPixels;
    }

    /**
     * 获取屏幕高度
     * @param context
     * @return
     */
    public static int getScreenHeight(Context context) {
        DisplayMetrics dm = new DisplayMetrics();
        ((Activity) context).getWindowManager().getDefaultDisplay().getMetrics(dm);
        return dm.heightPixels;
    }

    /**判断屏幕下方是否存在虚拟按键
     * 参考https://gist.github.com/fengzi422/9ad341d838943eff2232
     * @param context
     * @return
     */
    private static boolean checkDeviceHasNavigationBar(Context context) {
        boolean hasNavigationBar = false;
        //Android 5.0以下不存在虚拟按键
        if(Build.VERSION.SDK_INT>=LOLLIPOP) {
            Resources rs = context.getResources();
            int id = rs.getIdentifier("config_showNavigationBar", "bool", "android");
            if (id > 0) {
                hasNavigationBar = rs.getBoolean(id);
            }
            try {
                Class systemPropertiesClass = Class.forName("android.os.SystemProperties");
                Method m = systemPropertiesClass.getMethod("get", String.class);
                String navBarOverride = (String) m.invoke(systemPropertiesClass, "qemu.hw.mainkeys");
                if ("1".equals(navBarOverride)) {
                    hasNavigationBar = false;
                } else if ("0".equals(navBarOverride)) {
                    hasNavigationBar = true;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        Log.d(TAG,"checkDeviceHasNavigationBar-hasNavigationBar:"+hasNavigationBar);
        return hasNavigationBar;
    }

    /**
     * 获取屏幕底部虚拟键盘的高度
     * 参考https://gist.github.com/fengzi422/9ad341d838943eff2232
     * @param context
     * @return
     */
    public static int getNavigationBarHeight(Context context) {
        int navigationBarHeight = 0;
        Resources rs = context.getResources();
        int id = rs.getIdentifier("navigation_bar_height", "dimen", "android");
        if (id > 0 && checkDeviceHasNavigationBar(context)) {
            navigationBarHeight = rs.getDimensionPixelSize(id);
        }
        Log.d(TAG,"getNavigationBarHeight-navigationBarHeight:"+navigationBarHeight);
        return navigationBarHeight;
    }

    /**
     * 私密直播间-亲密度等级-图标
     * @param level
     * @return
     */
    public static Drawable getLevelDrawableByResName(Context context, int level){
        Log.d(TAG,"getPrivateRoomLoveLevelDrawable-level:"+level);
        Drawable drawable = null;
        try {
            int drawableResId = context.getResources().getIdentifier("ic_level_icon_" + level,
                    "drawable", context.getPackageName());
            drawable = context.getResources().getDrawable(drawableResId);
        }catch (Exception e){
            e.printStackTrace();
        }
        return drawable;
    }
}


