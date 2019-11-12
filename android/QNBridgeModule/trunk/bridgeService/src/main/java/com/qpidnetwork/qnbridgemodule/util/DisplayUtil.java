package com.qpidnetwork.qnbridgemodule.util;

import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.util.DisplayMetrics;
import android.view.WindowManager;

import static android.os.Build.VERSION_CODES.LOLLIPOP;

/**
 * 界面显示相关的工具类
 * <p>
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
     * 获取屏幕的长宽属性
     *
     * @param context
     * @return
     */
    public static DisplayMetrics getDisplayMetrics(Context context) {
        DisplayMetrics dm = new DisplayMetrics();
        WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        wm.getDefaultDisplay().getMetrics(dm);
        return dm;
    }


    private static final String TAG = DisplayUtil.class.getSimpleName();

    /**
     * 获取状态栏高度
     *
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
     *
     * @param context
     * @return
     */
    public static int getScreenWidth(Context context) {
        DisplayMetrics dm = new DisplayMetrics();
//        ((Activity) context).getWindowManager().getDefaultDisplay().getMetrics(dm);
        // 2019/5/21 Hardy 参考直播的 DisplayUtil
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            ((Activity) context).getWindowManager().getDefaultDisplay().getRealMetrics(dm);
        }else{
            ((Activity) context).getWindowManager().getDefaultDisplay().getMetrics(dm);
        }
        return dm.widthPixels;
    }

    /**
     * 获取屏幕高度
     * 实际显示区域指定包含系统装饰的内容的显示部分 ： getRealSize（Point），getRealMetrics（DisplayMetrics）。
     * 应用程序显示区域指定可能包含应用程序窗口的显示部分，不包括系统装饰。 应用程序显示区域可以小于实际显示区域，因为系统减去诸如状态栏之类的装饰元素所需的空间。 使用以下方法查询应用程序显示区域：getSize（Point），getRectSize（Rect）和getMetrics（DisplayMetrics）。
     * @param context
     * @return
     */
    public static int getScreenHeight(Context context) {
        DisplayMetrics dm = new DisplayMetrics();
//        ((Activity) context).getWindowManager().getDefaultDisplay().getMetrics(dm);
        // 2019/5/21 Hardy 参考直播的 DisplayUtil
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            ((Activity) context).getWindowManager().getDefaultDisplay().getRealMetrics(dm);
        }else{
            ((Activity) context).getWindowManager().getDefaultDisplay().getMetrics(dm);
        }
        return dm.heightPixels;
    }

    /**
     * 应用程序显示区域指定可能包含应用程序窗口的显示部分，不包括系统装饰。 应用程序显示区域可以小于实际显示区域，因为系统减去诸如状态栏之类的装饰元素所需的空间。 使用以下方法查询应用程序显示区域：getSize（Point），getRectSize（Rect）和getMetrics（DisplayMetrics）。
     * @param context
     * @return
     */
    public static int getActivityHeight(Context context) {
        DisplayMetrics dm = new DisplayMetrics();
        ((Activity) context).getWindowManager().getDefaultDisplay().getMetrics(dm);
        return dm.heightPixels;
    }

    /**
     * 判断屏幕下方是否存在虚拟按键
     * 参考https://gist.github.com/fengzi422/9ad341d838943eff2232
     *
     * @param context
     * @return
     */
    private static boolean checkDeviceHasNavigationBar(Context context) {
        boolean hasNavigationBar = false;

        //Android 5.0以下不存在虚拟按键
        if (Build.VERSION.SDK_INT >= LOLLIPOP) {
            Resources rs = context.getResources();
            int id = rs.getIdentifier("config_showNavigationBar", "bool", "android");
            if (id > 0) {
                hasNavigationBar = rs.getBoolean(id);
            }

            /*
             2019/3/1 Hardy
             在某些没有底部虚拟导航栏的三星机器，例如 C7 Pro (SM-C7010) 上，以上资源 id 判断存在，
             并且 hasNavigationBar = rs.getBoolean(id); 返回 false ，符合事实。

             但在下面的反射代码里，navBarOverride 获取出的值又是 0，导致判断出错。

             经搜索资料，"qemu.hw.mainkeys" 该属性，在 8.0 机器上已失效，或者可以通过 root 手机去修改，又或者手机在厂家出厂时，没有修改该值，都会导致该
             检查方法失效，故这里屏蔽
             */

//            try {
//                Class systemPropertiesClass = Class.forName("android.os.SystemProperties");
//                Method m = systemPropertiesClass.getMethod("get", String.class);
//                String navBarOverride = (String) m.invoke(systemPropertiesClass, "qemu.hw.mainkeys");
//                if ("1".equals(navBarOverride)) {
//                    hasNavigationBar = false;
//                } else if ("0".equals(navBarOverride)) {
//                    hasNavigationBar = true;
//                }
//            } catch (Exception e) {
//                e.printStackTrace();
//            }
        }
        Log.d(TAG, "checkDeviceHasNavigationBar-hasNavigationBar:" + hasNavigationBar);
        return hasNavigationBar;
    }

    /**
     * 获取屏幕底部虚拟键盘的高度
     * 参考https://gist.github.com/fengzi422/9ad341d838943eff2232
     *
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
        Log.d(TAG, "getNavigationBarHeight-navigationBarHeight:" + navigationBarHeight);
        return navigationBarHeight;
    }

    /**
     * 私密直播间-亲密度等级-图标
     *
     * @param level
     * @return
     */
    public static Drawable getLevelDrawableByResName(Context context, int level) {
        Log.d(TAG, "getPrivateRoomLoveLevelDrawable-level:" + level);
        Drawable drawable = null;
        try {
            int drawableResId = context.getResources().getIdentifier("ic_level_icon_" + level,
                    "drawable", context.getPackageName());
            drawable = context.getResources().getDrawable(drawableResId);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return drawable;
    }
}


