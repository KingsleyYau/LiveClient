package com.qpidnetwork.qnbridgemodule.util;

import android.app.Activity;
import android.content.Context;
import android.graphics.Rect;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.FrameLayout;

/**
 * 解决全屏模式下，ADJUST_RESIZE softInput模式无效的问题
 *
 * 受getWindow().clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);属性影响
 *
 * @author Hunter Mun
 */
public class AndroidBug5497Workaround {
    // For more information, see https://code.google.com/p/android/issues/detail?id=5497  
    // To use this class, simply invoke assistActivity() on an Activity that already has its content view set.
    private Context mContext;

    public static void assistActivity(Activity activity) {
        new AndroidBug5497Workaround(activity, false);
    }

    public static void assistActivity(Activity activity, boolean isFullScreen) {
        new AndroidBug5497Workaround(activity, isFullScreen);
    }

    private boolean isFullScreen;

    private View mChildOfContent;
    private int usableHeightPrevious;
    private FrameLayout.LayoutParams frameLayoutParams;

    //    private AndroidBug5497Workaround(Activity activity) {
    private AndroidBug5497Workaround(Activity activity, boolean isFullScreen) {
        this.isFullScreen = isFullScreen;
        this.mContext = activity;

        FrameLayout content = (FrameLayout) activity.findViewById(android.R.id.content);
        mChildOfContent = content.getChildAt(0);
        mChildOfContent.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            public void onGlobalLayout() {
                possiblyResizeChildOfContent();
            }
        });
        frameLayoutParams = (FrameLayout.LayoutParams) mChildOfContent.getLayoutParams();
    }

    private void possiblyResizeChildOfContent() {
        int usableHeightNow = computeUsableHeight();
        if (usableHeightNow != usableHeightPrevious) {
            int usableHeightSansKeyboard = mChildOfContent.getRootView().getHeight() - NavgationbarUtils.getNavigationBarHeight(mContext);    // 需要减去底部虚拟导航栏的高度
            int heightDifference = usableHeightSansKeyboard - usableHeightNow;
            if (heightDifference > (usableHeightSansKeyboard / 4)) {
                // keyboard probably just became visible  
                frameLayoutParams.height = usableHeightSansKeyboard - heightDifference;
            } else {
                // keyboard probably just became hidden  
                frameLayoutParams.height = usableHeightSansKeyboard;
            }
            mChildOfContent.requestLayout();
            usableHeightPrevious = usableHeightNow;
        }
    }

    private int computeUsableHeight() {
        Rect r = new Rect();
        mChildOfContent.getWindowVisibleDisplayFrame(r);

//        return (r.bottom - r.top);

        // 2019/2/26 Hardy
        // https://blog.csdn.net/qq_23901559/article/details/70169980
//        全屏模式下，可用高度 = rect.bottom
//        非全屏模式，可用高度 = rect.bottom - rect.top
        int height = isFullScreen ? r.bottom : (r.bottom - r.top);
        return height;
    }
}
