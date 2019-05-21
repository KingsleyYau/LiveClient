package com.qpidnetwork.qnbridgemodule.util;

import android.app.Activity;
import android.content.Context;
import android.content.ContextWrapper;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.FitWindowsLinearLayout;
import android.view.ContextThemeWrapper;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.LinearLayout;

/**
 * Created by zy2 on 2019/3/1.
 * NavgationBar 工具类
 * https://blog.csdn.net/lfc18606951877/article/details/87100517
 */
public class NavgationbarUtils {

    /**
     * @return false 关闭了NavgationBar ,true 开启了
     */
    public static boolean navgationbarIsOpen(Context context) {
        ViewGroup rootLinearLayout = findRootLinearLayout(context);
        int navigationBarHeight = 0;

        if (rootLinearLayout != null) {
            ViewGroup.MarginLayoutParams layoutParams = (ViewGroup.MarginLayoutParams) rootLinearLayout.getLayoutParams();
            navigationBarHeight = layoutParams.bottomMargin;
        }
        if (navigationBarHeight == 0) {
            return false;
        } else {
            return true;
        }
    }

    /**
     * 导航栏高度，关闭的时候返回0,开启时返回对应值
     *
     * @param context
     * @return
     */
    public static int getNavigationBarHeight(Context context) {
        ViewGroup rootLinearLayout = findRootLinearLayout(context);
        int navigationBarHeight = 0;
        if (rootLinearLayout != null) {
            ViewGroup.MarginLayoutParams layoutParams = (ViewGroup.MarginLayoutParams) rootLinearLayout.getLayoutParams();
            navigationBarHeight = layoutParams.bottomMargin;
        }
        return navigationBarHeight;
    }

    /**
     * 从R.id.content从上遍历，拿到 DecorView 下的唯一子布局LinearLayout
     * 获取对应的bottomMargin 即可得到对应导航栏的高度，0为关闭了或没有导航栏
     */
    private static ViewGroup findRootLinearLayout(Context context) {
        ViewGroup onlyLinearLayout = null;
        try {
            Window window = getWindow(context);
            if (window != null) {
                ViewGroup decorView = (ViewGroup) getWindow(context).getDecorView();
                Activity activity = getActivity(context);
                View contentView = activity.findViewById(android.R.id.content);
                if (contentView != null) {
                    View tempView = contentView;
                    while (tempView.getParent() != decorView) {
                        ViewGroup parent = (ViewGroup) tempView.getParent();
                        if (parent instanceof LinearLayout) {
                            //如果style设置了不带toolbar,mContentView上层布局会由原来的 ActionBarOverlayLayout->FitWindowsLinearLayout)
                            if (parent instanceof FitWindowsLinearLayout) {
                                tempView = parent;
                                continue;
                            } else {
                                onlyLinearLayout = parent;
                                break;
                            }
                        } else {
                            tempView = parent;
                        }
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return onlyLinearLayout;
    }


    private static Window getWindow(Context context) {
        if (getAppCompActivity(context) != null) {
            return getAppCompActivity(context).getWindow();
        } else {
            return scanForActivity(context).getWindow();
        }
    }

    private static Activity getActivity(Context context) {
        if (getAppCompActivity(context) != null) {
            return getAppCompActivity(context);
        } else {
            return scanForActivity(context);
        }
    }


    private static AppCompatActivity getAppCompActivity(Context context) {
        if (context == null) return null;
        if (context instanceof AppCompatActivity) {
            return (AppCompatActivity) context;
        } else if (context instanceof ContextThemeWrapper) {
            return getAppCompActivity(((ContextThemeWrapper) context).getBaseContext());
        }
        return null;
    }

    private static Activity scanForActivity(Context context) {
        if (context == null) return null;

        if (context instanceof Activity) {
            return (Activity) context;
        } else if (context instanceof ContextWrapper) {
            return scanForActivity(((ContextWrapper) context).getBaseContext());
        }
        return null;
    }

}
