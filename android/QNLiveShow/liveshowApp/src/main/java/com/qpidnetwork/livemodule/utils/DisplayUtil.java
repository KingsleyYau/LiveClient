package com.qpidnetwork.livemodule.utils;

import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.os.Build;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;

import com.qpidnetwork.livemodule.framework.widget.statusbar.StatusBarUtil;

import java.lang.reflect.Field;
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

    public static int getStatusBarHeight(Context context) {
        int result = 0;
        int resourceId = context.getResources().getIdentifier("status_bar_height", "dimen", "android");
        if (resourceId > 0) {
            result = context.getResources().getDimensionPixelSize(resourceId);
        }
        return result;
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

    //-------------------修改状态栏，白底黑字适配方案----------------------------------
    // 参考http://www.jianshu.com/p/7f5a9969be53
    /**
     * 修改状态栏颜色，支持4.4以上版本
     * @param activity
     * @param colorId
     */
    public static void setStatusBarColor(Activity activity,int colorId) {

        if (Build.VERSION.SDK_INT >= LOLLIPOP) {
            Window window = activity.getWindow();
//      window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(activity.getResources().getColor(colorId));
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            //使用SystemBarTint库使4.4版本状态栏变色，需要先将状态栏设置为透明
            StatusBarUtil.setColor(activity,activity.getResources().getColor(colorId));
        }
    }

    /**
     *状态栏亮色模式，设置状态栏黑色文字、图标，
     * 适配4.4以上版本MIUIV、Flyme和6.0以上版本其他Android
     * @param activity
     * @return 1:MIUUI 2:Flyme 3:android6.0
     */
    public static int setStatusBarLightMode(Activity activity){
        int result=0;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            if(setMIUIStatusBarLightMode(activity, true)){
                result=1;
            }else if(setFlymeSetStatusBarLightMode(activity.getWindow(), true)){
                result=2;
            }else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                activity.getWindow().getDecorView().setSystemUiVisibility( View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN|View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
                result=3;
            }
        }
        return result;
    }

    /**
     * 已知系统类型时，设置状态栏黑色文字、图标。
     * 适配4.4以上版本MIUIV、Flyme和6.0以上版本其他Android
     * @param activity
     * @param type 1:MIUUI 2:Flyme 3:android6.0
     */
    public static void setStatusBarLightMode(Activity activity,int type){
        if(type==1){
            setMIUIStatusBarLightMode(activity, true);
        }else if(type==2){
            setFlymeSetStatusBarLightMode(activity.getWindow(), true);
        }else if(type==3){
            activity.getWindow().getDecorView().setSystemUiVisibility( View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN|View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
        }

    }

    /**
     * 状态栏暗色模式，清除MIUI、flyme或6.0以上版本状态栏黑色文字、图标
     */
    public static void setStatusBarDarkMode(Activity activity,int type){
        if(type==1){
            setMIUIStatusBarLightMode(activity, false);
        }else if(type==2){
            setFlymeSetStatusBarLightMode(activity.getWindow(), false);
        }else if(type==3){
            activity.getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_VISIBLE);
        }

    }


    /**
     * 设置状态栏图标为深色和魅族特定的文字风格
     * 可以用来判断是否为Flyme用户
     * @param window 需要设置的窗口
     * @param dark 是否把状态栏文字及图标颜色设置为深色
     * @return  boolean 成功执行返回true
     *
     */
    public static boolean setFlymeSetStatusBarLightMode(Window window, boolean dark) {
        boolean result = false;
        if (window != null) {
            try {
                WindowManager.LayoutParams lp = window.getAttributes();
                Field darkFlag = WindowManager.LayoutParams.class
                        .getDeclaredField("MEIZU_FLAG_DARK_STATUS_BAR_ICON");
                Field meizuFlags = WindowManager.LayoutParams.class
                        .getDeclaredField("meizuFlags");
                darkFlag.setAccessible(true);
                meizuFlags.setAccessible(true);
                int bit = darkFlag.getInt(null);
                int value = meizuFlags.getInt(lp);
                if (dark) {
                    value |= bit;
                } else {
                    value &= ~bit;
                }
                meizuFlags.setInt(lp, value);
                window.setAttributes(lp);
                result = true;
            } catch (Exception e) {

            }
        }
        return result;
    }

    /**
     * 需要MIUIV6以上
     * @param activity
     * @param dark 是否把状态栏文字及图标颜色设置为深色
     * @return  boolean 成功执行返回true
     *
     */
    public static boolean setMIUIStatusBarLightMode(Activity activity, boolean dark) {
        boolean result = false;
        Window window=activity.getWindow();
        if (window != null) {
            Class clazz = window.getClass();
            try {
                int darkModeFlag = 0;
                Class layoutParams = Class.forName("android.view.MiuiWindowManager$LayoutParams");
                Field field = layoutParams.getField("EXTRA_FLAG_STATUS_BAR_DARK_MODE");
                darkModeFlag = field.getInt(layoutParams);
                Method extraFlagField = clazz.getMethod("setExtraFlags", int.class, int.class);
                if(dark){
                    extraFlagField.invoke(window,darkModeFlag,darkModeFlag);//状态栏透明且黑色字体
                }else{
                    extraFlagField.invoke(window, 0, darkModeFlag);//清除黑色字体
                }
                result=true;

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    //开发版 7.7.13 及以后版本采用了系统API，旧方法无效但不会报错，所以两个方式都要加上
                    if(dark){
                        activity.getWindow().getDecorView().setSystemUiVisibility( View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN| View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
                    }else {
                        activity.getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_VISIBLE);
                    }
                }
            }catch (Exception e){
                e.printStackTrace();
            }
        }
        return result;
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

    public static void setTxtUnReadBgDrawable(TextView textView, int bgColor){
        GradientDrawable digitalHintGD = new GradientDrawable();
        digitalHintGD.setCornerRadius(90f);
        digitalHintGD.setColor(bgColor);
        textView.measure(0,0);
        //字体大小或者高度值,相对来说依据字体大小而言值更小些，但是当unReadNumb>99是就显示不全了,
        //而依据高度或者宽度而言，当unReadNumb<10时，宽度小于高度，其他情况则是宽度大于高度
        //另外一种解决方案是tv_digitalHint的宽高写死，待定
        int measureWidth = textView.getMeasuredWidth();
        int measureHeight = textView.getMeasuredHeight();
        Log.d(TAG,"setTxtUnReadBgDrawable-measureWidth:"+measureWidth+" measureHeight:"+measureHeight);
        digitalHintGD.setSize(measureWidth,measureHeight);
        textView.setBackgroundDrawable(digitalHintGD);
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


