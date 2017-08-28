package com.qpidnetwork.livemodule.utils;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.Rect;
import android.os.Build;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

import com.qpidnetwork.livemodule.liveshow.LiveApplication;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

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

    /**
     * 获取Resource对象
     */
    public static Resources getResources() {
        return LiveApplication.getContext().getResources();
    }


    private static final String TAG = DisplayUtil.class.getSimpleName();

    /**
     * 第一种方式
     *
     * 初始化状态栏的UI样式,activity之间切换时失效
     * @param activity
     */
    public static void initWindowStatusBar(Activity activity, int color) {
        //透明状态栏 MIUI6设置失效，即使按照开发文档的设置也不行
        Window window = activity.getWindow();
        boolean isDebug = true;
        if(Build.MANUFACTURER.equals("Xiaomi") && isDebug){
            //http://dev.xiaomi.com/docs/appsmarket/technical_docs/system&device_identification/
            Log.w(TAG,"Build.MANUFACTURER:"+Build.MANUFACTURER +" Build.MODEL:"+Build.MODEL);
            String value = null;
            try {
                Class<?> c = Class.forName("android.os.SystemProperties");
                Method get = c.getMethod("get", String.class, String.class);
                value = (String)(get.invoke(c, "ro.miui.ui.version.name", "unknown" ));
            } catch (Exception e) {
                e.printStackTrace();
            }
            Log.w(TAG,"ro.miui.ui.version.name:"+value);
            if(null != value && value.equals("V6")){
                //http://dev.xiaomi.com/docs/appsmarket/technical_docs/immersion/
                //沉浸式菜单栏只能在MIUI 6的系统上实现，其他安卓系统没有效果
                //沉浸式效果对非MIUI系统的兼容性不会有任何影响
                //google的actionbar存在bug，不支持沉浸代码
                Class clazz = window.getClass();
                try {
                    int tranceFlag = 0;
                    int darkModeFlag = 0;
                    Class layoutParams = Class.forName("android.view.MiuiWindowManager$LayoutParams");
                    Field field = layoutParams.getField("EXTRA_FLAG_STATUS_BAR_TRANSPARENT");
                    tranceFlag = field.getInt(layoutParams);
                    field = layoutParams.getField("EXTRA_FLAG_STATUS_BAR_DARK_MODE");
                    darkModeFlag = field.getInt(layoutParams);
                    Method extraFlagField = clazz.getMethod("setExtraFlags", int.class, int.class);
                    //只需要状态栏透明
                    extraFlagField.invoke(window, tranceFlag, tranceFlag);
                    //状态栏透明且黑色字体
//                    extraFlagField.invoke(window, tranceFlag | darkModeFlag, tranceFlag | darkModeFlag);
                    //清除黑色字体
                    extraFlagField.invoke(window, 0, darkModeFlag);
                } catch (NoSuchMethodException e) {
                    e.printStackTrace();
                } catch (ClassNotFoundException e) {
                    e.printStackTrace();
                } catch (NoSuchFieldException e) {
                    e.printStackTrace();
                } catch (IllegalAccessException e) {
                    e.printStackTrace();
                } catch (IllegalArgumentException e) {
                    e.printStackTrace();
                } catch (InvocationTargetException e) {
                    e.printStackTrace();
                }
            }
        }else{
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS
                        /*| WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION*/);
                window.getDecorView().setSystemUiVisibility(/*View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                        | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                        | */View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
                window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
                window.setStatusBarColor(color);
//                window.setNavigationBarColor(Color.TRANSPARENT);
            }else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT){
//              window.setFlags(0,WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
//              window.setFlags(0,WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
                window.setFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS,WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
//                window.setFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION,WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
            }
        }
    }

    //第二种方式,不推荐,最新可参考https://github.com/laobie/StatusBarUtil
    private static final int INVALID_VAL = -1;
    private static final int COLOR_DEFAULT = Color.parseColor("#00000000");

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public static void compat(Activity activity, int statusColor){

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP){
            if (statusColor != INVALID_VAL){
                activity.getWindow().setStatusBarColor(statusColor);
            }
            return;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            int color = COLOR_DEFAULT;
            ViewGroup contentView = (ViewGroup) activity.findViewById(android.R.id.content);
            if (statusColor != INVALID_VAL) {
                color = statusColor;
            }
            View statusBarView = new View(activity);
            ViewGroup.LayoutParams lp = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                    getStatusBarHeight(activity));
            statusBarView.setBackgroundColor(color);
            contentView.addView(statusBarView, lp);
        }

    }

    public static void compat(Activity activity) {
        compat(activity, INVALID_VAL);
    }


    public static int getStatusBarHeight(Context context) {
        int result = 0;
        int resourceId = context.getResources().getIdentifier("status_bar_height", "dimen", "android");
        if (resourceId > 0) {
            result = context.getResources().getDimensionPixelSize(resourceId);
        }
        return result;
    }

    //第三种方式  应该是4.4+全机型兼容
    //修改当前 Activity 的显示模式，hideStatusBarBackground :true 全屏模式，false 着色模式
    //对于 Android 5.0 + ( >= 5.0 ) 的情况很容易懂，毕竟可以直接设置状态栏的颜色。
    // 对于 Android 4.4 + ( >= 4.4 且 < 5.0 ) 的情况，我这里并没有使用网上一些教程：
    // 向 DecorView 中添加一个高度为状态栏的高度 View，也就没有黑线的问题，
    // 而是通过修改根布局的背景色和根布局的 PaddingTop 来模拟着色模式
    public static void modifyStatusBar(Activity activity, boolean hideStatusBarBackground, int statusBarColor) {
        Window window = activity.getWindow();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            if (hideStatusBarBackground) {
                window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
            } else {
                window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_VISIBLE);
            }

            ViewGroup mContentView = (ViewGroup) window.findViewById(Window.ID_ANDROID_CONTENT);
            View mChildView = mContentView.getChildAt(0);
            if (mChildView != null) {
                if (hideStatusBarBackground) {
                    mChildView.setPadding(
                            mChildView.getPaddingLeft(),
                            0,
                            mChildView.getPaddingRight(),
                            mChildView.getPaddingBottom()
                    );
                } else {
                    int statusHeight = getStatusBarHeight(activity);
                    mChildView.setPadding(
                            mChildView.getPaddingLeft(),
                            statusHeight,
                            mChildView.getPaddingRight(),
                            mChildView.getPaddingBottom()
                    );
                }
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            if (hideStatusBarBackground) {
                window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
                window.setStatusBarColor(Color.TRANSPARENT);
                window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
            } else {
                window.setStatusBarColor(statusBarColor);
                window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
                window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_VISIBLE);
            }
        }
    }

    public static int getScreenWidth(Context context) {
        DisplayMetrics dm = new DisplayMetrics();
        ((Activity) context).getWindowManager().getDefaultDisplay().getMetrics(dm);
        return dm.widthPixels;
    }

    public static int getScreenHeight(Context context) {
        DisplayMetrics dm = new DisplayMetrics();
        ((Activity) context).getWindowManager().getDefaultDisplay().getMetrics(dm);
        return dm.heightPixels;
    }
}


