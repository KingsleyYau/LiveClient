package com.qpidnetwork.livemodule.liveshow.flowergift.store;

import android.animation.Animator;
import android.os.Handler;
import android.support.v4.view.animation.FastOutSlowInInterpolator;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationSet;
import android.view.animation.AnimationUtils;

import com.qpidnetwork.livemodule.R;

/**
 * Created by Hardy on 2019/10/8.
 * 鲜花礼品的相关动画工具类
 */
public class FlowersGiftAnimUtils {

    /**
     *
     * @param targetView    动画 view
     * @param handler       传入 handler ，是为了做延时隐藏，并且在界面销毁时，做统一反注册，避免内存泄漏
     */
    public static void showCartTipBubble(final View targetView, final Handler handler) {
        targetView.setVisibility(View.VISIBLE);

        int w = targetView.getMeasuredWidth();
        int h = targetView.getMeasuredHeight();

        targetView.setScaleX(0);
        targetView.setScaleY(0);
        // 动画开始的锚点
        targetView.setPivotX(w);
        targetView.setPivotY(h / 2);

        targetView.animate().scaleX(1.0f).scaleY(1.0f)
                .setDuration(300)
                .setInterpolator(new FastOutSlowInInterpolator())
                .setListener(new Animator.AnimatorListener() {
                    @Override
                    public void onAnimationStart(Animator animation) {

                    }

                    @Override
                    public void onAnimationEnd(Animator animation) {
//                        hideCartTipBubble(targetView, handler);
                    }

                    @Override
                    public void onAnimationCancel(Animator animation) {

                    }

                    @Override
                    public void onAnimationRepeat(Animator animation) {

                    }
                }).start();
    }

    private static void hideCartTipBubble(final View targetView, final Handler handler) {
//        handler.postDelayed(new Runnable() {
//            @Override
//            public void run() {

                int w = targetView.getMeasuredWidth();
                int h = targetView.getMeasuredHeight();

                targetView.setScaleX(1f);
                targetView.setScaleY(1f);
                // 动画开始的锚点
                targetView.setPivotX(w);
                targetView.setPivotY(h / 2);

                targetView.animate().scaleX(0).scaleY(0)
                        .setDuration(300)
                        .setInterpolator(new FastOutSlowInInterpolator())
                        .setListener(new Animator.AnimatorListener() {
                            @Override
                            public void onAnimationStart(Animator animation) {

                            }

                            @Override
                            public void onAnimationEnd(Animator animation) {
                                targetView.setVisibility(View.INVISIBLE);
                            }

                            @Override
                            public void onAnimationCancel(Animator animation) {

                            }

                            @Override
                            public void onAnimationRepeat(Animator animation) {

                            }
                        }).start();
//            }
//        }, 3000);
    }


    public static void showFlowerTypeViewAnim(FlowersTypeLayout flowersTypeLayout, Animation.AnimationListener listener) {
        flowersTypeLayout.setVisibility(View.VISIBLE);

        flowersTypeLayout.getListView().clearAnimation();

        // 背景 view
        View bgView = flowersTypeLayout.getBgView();
        bgView.setAlpha(0f);
        bgView.animate().alpha(1f).setDuration(300).start();

        // 列表 view
        AnimationSet animationSet = (AnimationSet) AnimationUtils.
                loadAnimation(flowersTypeLayout.getContext(), R.anim.anim_top_in);
        animationSet.setAnimationListener(listener);
        flowersTypeLayout.getListView().startAnimation(animationSet);
    }


    public static void hideFlowerTypeViewAnim(final FlowersTypeLayout flowersTypeLayout, Animation.AnimationListener listener) {
        flowersTypeLayout.setVisibility(View.VISIBLE);

        flowersTypeLayout.getListView().clearAnimation();

        // 列表 view
        AnimationSet animationSet = (AnimationSet) AnimationUtils.
                loadAnimation(flowersTypeLayout.getContext(), R.anim.anim_top_out);
        animationSet.setAnimationListener(listener);
        flowersTypeLayout.getListView().startAnimation(animationSet);

        // 背景 view
        View bgView = flowersTypeLayout.getBgView();
        bgView.setAlpha(1f);
        bgView.animate().alpha(0f).setDuration(300).start();
    }

}
