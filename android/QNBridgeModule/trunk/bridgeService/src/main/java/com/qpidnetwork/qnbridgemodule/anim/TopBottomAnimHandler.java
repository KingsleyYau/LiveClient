package com.qpidnetwork.qnbridgemodule.anim;

import android.support.v4.view.ViewCompat;
import android.support.v4.view.ViewPropertyAnimatorListener;
import android.support.v4.view.animation.FastOutSlowInInterpolator;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Interpolator;

/**
 * Created by Hardy on 2017/1/12.
 * <p>
 * View 的上下显示、隐藏的动画
 */
public class TopBottomAnimHandler {

    private static final Interpolator INTERPOLATOR = new FastOutSlowInInterpolator();

    public static void showView(View mFab, boolean isShow) {
        if (isShow) {
            animateIn(mFab);
        } else {
            animateOut(mFab);
        }
    }

    public static void resetViewLocation(View mFab) {
        // 暂停动画，避免动画结束 onAnimationEnd 的操作影响外层的 view 显示或隐藏
        ViewCompat.animate(mFab).cancel();

        mFab.setTranslationY(0);
    }

    private static void animateOut(final View button) {
        int height = button.getHeight() + getMarginBottom(button);

        ViewCompat.animate(button).translationY(height).setInterpolator(INTERPOLATOR).withLayer()
                .setListener(new ViewPropertyAnimatorListener() {
                    public void onAnimationStart(View view) {
                    }

                    public void onAnimationCancel(View view) {
                    }

                    public void onAnimationEnd(View view) {
                        view.setVisibility(View.GONE);
                    }
                }).start();
    }

    private static void animateIn(View button) {
        button.setVisibility(View.VISIBLE);

        ViewCompat.animate(button).translationY(0)
                .setInterpolator(INTERPOLATOR).withLayer().setListener(null)
                .start();
    }

    private static int getMarginBottom(View v) {
        int marginBottom = 0;
        final ViewGroup.LayoutParams layoutParams = v.getLayoutParams();
        if (layoutParams instanceof ViewGroup.MarginLayoutParams) {
            marginBottom = ((ViewGroup.MarginLayoutParams) layoutParams).bottomMargin;
        }
        return marginBottom;
    }

}
