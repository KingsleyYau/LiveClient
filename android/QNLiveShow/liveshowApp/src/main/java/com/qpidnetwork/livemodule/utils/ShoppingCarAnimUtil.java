package com.qpidnetwork.livemodule.utils;

import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.Animatable;
import android.os.Build;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.AnimationSet;
import android.view.animation.LinearInterpolator;
import android.view.animation.ScaleAnimation;
import android.view.animation.TranslateAnimation;
import android.widget.LinearLayout;

import com.facebook.drawee.controller.BaseControllerListener;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.imagepipeline.image.ImageInfo;
import com.qpidnetwork.livemodule.R;

import java.lang.ref.WeakReference;

/**
 * 购物车动画
 *
 * @author Jagger
 * @date 2019/9/27
 */
public class ShoppingCarAnimUtil {
    //缩放率
    private float SCALE_FROM_X = 1.2f;
    private float SCALE_FROM_Y = 1.2f;
    private float SCALE_TO_X = 0.2f;
    private float SCALE_TO_Y = 0.2f;
    private int SCALE_TIME = 2500;
    //平移率
    private int TRANS_MIN_TIME = 300;

    private WeakReference<Activity> mActivity;
    private AnimListener mListener;
    private long time;
    private final View startView;
    private final View endView;
    private final String imageUrl;
    private View animView;
    private double scale;
    private int animWidth;
    private int animHeight;
    private ViewGroup animMaskLayout;

    private ShoppingCarAnimUtil() {
        this(new Builder());
    }

    ShoppingCarAnimUtil(Builder builder) {
        this.mActivity = builder.activity;
        this.startView = builder.startView;
        this.endView = builder.endView;
        this.time = builder.time;
        this.mListener = builder.listener;
        this.animView = builder.animView;
        this.imageUrl = builder.imageUrl;
        this.scale = builder.scale;
        this.animWidth = builder.animWidth;
        this.animHeight = builder.animHeight;
    }


    /**
     * 开始动画
     */
    public void startAnim() {
        if (startView == null || endView == null) {
            throw new NullPointerException("startView or endView must not null");
        }
        int[] startLocation = new int[2];
        int[] endLocation = new int[2];
        startView.getLocationOnScreen(startLocation);
        endView.getLocationOnScreen(endLocation);

        if (animView != null) {
            setAnim(startLocation, endLocation);
        } else if (!TextUtils.isEmpty(imageUrl)) {
            createImageAndAnim(startLocation, endLocation);
        }
    }

    private void createImageAndAnim(final int[] startLocation,final int[] endLocation) {
        final SimpleDraweeView animImageView = new SimpleDraweeView(getActivity());
//        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(DisplayUtil.dip2px(getActivity(), animWidth),
//                DisplayUtil.dip2px(getActivity(), animHeight));
        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams( animWidth,animHeight);
        animImageView.setLayoutParams(layoutParams);

        // TODO: 2019/10/11
//        FrescoLoadUtil.loadUrl(getActivity(), animImageView, imageUrl, animWidth, R.color.black4, false);
//        setAnim(animImageView, startLocation, endLocation);

        // 把ImageView添加到动画层
        animMaskLayout = createAnimLayout(getActivity());
        animMaskLayout.addView(animImageView);

        // 加载图片
        FrescoLoadUtil.loadUrl(getActivity(), animImageView, imageUrl, new BaseControllerListener<ImageInfo>(){
            @Override
            public void onFinalImageSet(
                    String id,
                    @Nullable ImageInfo imageInfo,
                    @Nullable Animatable anim) {
                setAnim(animImageView, startLocation, endLocation);
            }

            @Override
            public void onFailure(String id, Throwable throwable) {
                super.onFailure(id, throwable);
//                Log.i("Jagger" , "购物车动画加载回调 onFailure" + throwable.toString());
                //加载失败，照跑动画
                setAnim(animImageView, startLocation, endLocation);
            }

            @Override
            public void onIntermediateImageFailed(String id, Throwable throwable) {
                super.onIntermediateImageFailed(id, throwable);
//                Log.i("Jagger" , "购物车动画加载回调 onIntermediateImageFailed" + throwable.toString());
                //加载失败，照跑动画
                setAnim(animImageView, startLocation, endLocation);
            }
        }, animWidth, R.color.transparent_full, R.color.black4, false, 6, 6, 6, 6);
    }


    private void setAnim(int[] startLocation, int[] endLocation) {
        setAnim(animView, startLocation, endLocation);
    }

    private void setAnim(final View v, int[] startLocation, int[] endLocation) {
//        animMaskLayout = createAnimLayout(getActivity());
//        // 把动画小球添加到动画层
//        animMaskLayout.addView(v);
        final View view = addViewToAnimLayout(v, startLocation);

        //缩放
        Animation animationScale = new ScaleAnimation(
                SCALE_FROM_X, SCALE_TO_X, SCALE_FROM_Y, SCALE_TO_Y,
                Animation.RELATIVE_TO_SELF, 0.0f, Animation.RELATIVE_TO_SELF, 0.0f);    //居左上角缩放
        animationScale.setDuration(SCALE_TIME);
        animationScale.setFillAfter(true);

        //渐隐
        Animation animationAlpha = new AlphaAnimation(1.0f, 0.2f);
        animationAlpha.setDuration(TRANS_MIN_TIME);
        animationAlpha.setFillAfter(true);

        //终点位置
//        int endX = endLocation[0] ;//- (endView.getMeasuredWidth()); //- startLocation[0] + 20;
        int endX = endLocation[0] - startLocation[0];
        // 动画位移的y坐标
        int endY = endLocation[1] - startLocation[1];

        TranslateAnimation translateAnimationX = new TranslateAnimation(0, endX, 0, 0);
        translateAnimationX.setInterpolator(new LinearInterpolator());
        // 动画重复执行的次数
        translateAnimationX.setRepeatCount(0);
        translateAnimationX.setFillAfter(true);

        TranslateAnimation translateAnimationY = new TranslateAnimation(0, 0, 0, endY);
        translateAnimationY.setInterpolator(new AccelerateInterpolator());
        translateAnimationY.setRepeatCount(0);
        translateAnimationX.setFillAfter(true);

        AnimationSet set = new AnimationSet(false);
        set.addAnimation(animationScale);
        set.addAnimation(animationAlpha);
        set.setFillAfter(true);
        set.addAnimation(translateAnimationY);
        set.addAnimation(translateAnimationX);

        if (scale == 1) {
            // 计算屏幕最远两个点的直线距离
            double diagonalDef = Math.sqrt(Math.pow(getScreenWidth(getActivity()), 2) + Math.pow(getScreenHeight(getActivity()), 2));
            // 计算实际两点的距离
            double diagonal = Math.abs(Math.sqrt(Math.pow(startLocation[0] - endLocation[0], 2) + Math.pow(startLocation[1] - endLocation[1], 2)));
            // 计算一个值,不同距离动画执行的时间不同
            scale = diagonal / diagonalDef;
        }
        // 动画的执行时间,计算出的时间小于300ms默认为300ms
        set.setDuration((time * scale) < TRANS_MIN_TIME ? TRANS_MIN_TIME : (long) (time * scale));
        view.startAnimation(set);
        // 动画监听事件
        set.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {
                v.setVisibility(View.VISIBLE);
                if (mListener != null) {
                    mListener.setAnimBegin(ShoppingCarAnimUtil.this);
                }
            }

            @Override
            public void onAnimationRepeat(Animation animation) {
            }

            // 动画的结束调用的方法
            @Override
            public void onAnimationEnd(Animation animation) {
                v.setVisibility(View.GONE);
                stopAnim();
                if (mListener != null) {
                    mListener.setAnimEnd(ShoppingCarAnimUtil.this);
                }
            }
        });
    }

    public void stopAnim() {
        if (animMaskLayout != null && animMaskLayout.getChildCount() > 0) {
            animMaskLayout.removeAllViews();
        }
        ViewGroup rootView = (ViewGroup) getActivity().getWindow().getDecorView();
        rootView.removeView(animMaskLayout);
    }

    private ViewGroup createAnimLayout(Activity mainActivity) {
        ViewGroup rootView = (ViewGroup) mainActivity.getWindow().getDecorView();
        LinearLayout animLayout = new LinearLayout(mainActivity);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT);
        animLayout.setLayoutParams(lp);
        animLayout.setId(R.id.anim_icon);
        animLayout.setBackgroundResource(android.R.color.transparent);
        rootView.addView(animLayout);
        return animLayout;
    }

    private View addViewToAnimLayout(final View view, int[] location) {
        int x = location[0];
        int y = location[1];
        LinearLayout.LayoutParams lp = (LinearLayout.LayoutParams)view.getLayoutParams();
        lp.leftMargin = x;
        lp.topMargin = y;
        view.setLayoutParams(lp);
        return view;
    }

    /**
     * 自定义时间
     *
     * @param time
     * @return
     */
    public long setTime(long time) {
        this.time = time;
        return time;
    }

    private Activity getActivity() {
        return mActivity.get();
    }

    /**
     * dip转化成px
     */
    private int dip2px(Context context, float dpValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    /**
     * 获取屏幕宽度
     *
     * @param context
     * @return
     */
    private int getScreenWidth(Context context) {
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
    private int getScreenHeight(Context context) {
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

    public void setOnAnimListener(AnimListener listener) {
        mListener = listener;
    }

    //回调监听
    public interface AnimListener {

        void setAnimBegin(ShoppingCarAnimUtil a);

        void setAnimEnd(ShoppingCarAnimUtil a);

    }

    public static final class Builder {
        WeakReference<Activity> activity;
        View startView;
        View endView;
        View animView;
        String imageUrl;
        long time;
        double scale;
        int animWidth;
        int animHeight;
        AnimListener listener;

        public Builder() {
            this.time = 1000;
            this.scale = 1;
            this.animHeight = 25;
            this.animWidth = 25;
        }

        public Builder with(Activity activity) {
            this.activity = new WeakReference<>(activity);
            return this;
        }

        public Builder startView(View startView) {
            if (startView == null) {
                throw new NullPointerException("startView is null");
            }
            this.startView = startView;
            return this;
        }

        public Builder endView(View endView) {
            if (endView == null) {
                throw new NullPointerException("endView is null");
            }
            this.endView = endView;
            return this;
        }

        public Builder animView(View animView) {
            if (animView == null) {
                throw new NullPointerException("animView is null");
            }
            this.animView = animView;
            return this;
        }

        public Builder listener(AnimListener listener) {
            if (listener == null) {
                throw new NullPointerException("listener is null");
            }
            this.listener = listener;
            return this;
        }

        public Builder imageUrl(String imageUrl) {
            this.imageUrl = imageUrl;
            return this;
        }

        public Builder time(long time) {
            if (time <= 0) {
                throw new IllegalArgumentException("time must be greater than zero");
            }
            this.time = time;
            return this;
        }

        public Builder scale(double scale) {
            this.scale = scale;
            return this;
        }

        public Builder animWidth(int width) {
            if (width <= 0) {
                throw new IllegalArgumentException("width must be greater than zero");
            }
            this.animWidth = width;
            return this;
        }

        public Builder animHeight(int height) {
            if (height <= 0) {
                throw new IllegalArgumentException("height must be greater than zero");
            }
            this.animHeight = height;
            return this;
        }

        public ShoppingCarAnimUtil build() {
            return new ShoppingCarAnimUtil(this);
        }
    }
}
