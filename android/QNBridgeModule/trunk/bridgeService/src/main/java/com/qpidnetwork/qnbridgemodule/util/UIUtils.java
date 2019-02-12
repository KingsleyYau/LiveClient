package com.qpidnetwork.qnbridgemodule.util;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.ContextWrapper;
import android.os.Build;
import android.os.Looper;
import android.support.v4.app.FragmentActivity;
import android.view.View;

/**
 * Created by Hardy on 2018/12/28.
 */
public class UIUtils {

    /**
     * Returns {@code true} if called on the main thread, {@code false} otherwise.
     */
    public static boolean isOnMainThread() {
        return Looper.myLooper() == Looper.getMainLooper();
    }

    /**
     * Returns {@code true} if called on the main thread, {@code false} otherwise.
     */
    public static boolean isOnBackgroundThread() {
        return !isOnMainThread();
    }

    /**
     * 判断Act是否存在
     *
     * @param context
     * @return
     */
    public static boolean isActExist(Context context) {
        if (context == null) {
            return false;

        } else {
            if (context instanceof FragmentActivity) {
                return assertNotDestroyed((FragmentActivity) context);
            } else if (context instanceof Activity) {
                return assertNotDestroyed((Activity) context);
                // 以下2个的判断顺序，不能调换，由于 Application 是 ContextWrapper 子类，则优先判断 Application，直接返回 true
            } else if (context instanceof Application) {
                return true;
            } else if (context instanceof ContextWrapper) {
                return isActExist(((ContextWrapper) context).getBaseContext());
            }
        }

        return false;
    }

    private static boolean assertNotDestroyed(Activity activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            if (activity != null && !activity.isFinishing() && !activity.isDestroyed()) {
                return true;
            }
        } else {
            if (activity != null && !activity.isFinishing()) {
                return true;
            }
        }
        return false;
    }


    /**
     * 获取 view 的宽高
     *
     * @param view
     * @return
     */
    public static int[] getViewWidthAndHeight(View view) {
        int[] wh = new int[2];

        if (view == null) {
            return wh;
        }

        view.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);
        wh[0] = view.getMeasuredWidth();
        wh[1] = view.getMeasuredHeight();

        return wh;
    }

    /**
     * 获取 View 在屏幕中的 x、y 坐标
     *
     * @param view
     * @return
     */
    public static int[] getLocationOnScreen(View view) {
        int[] location = new int[2];
        view.getLocationOnScreen(location);
        return location;
    }


}
