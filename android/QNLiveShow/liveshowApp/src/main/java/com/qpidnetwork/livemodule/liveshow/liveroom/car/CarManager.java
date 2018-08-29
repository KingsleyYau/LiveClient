package com.qpidnetwork.livemodule.liveshow.liveroom.car;

import android.animation.Animator;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.app.Activity;
import android.support.annotation.NonNull;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.LinearInterpolator;
import android.widget.LinearLayout;

import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.Log;

import java.lang.ref.WeakReference;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadFactory;

/**
 * Description:
 * <p>
 * 1.初始化布局
 * 2.增加setData方法
 * 3.创建manager进行parentview的add和delete
 * 4.增加动画播放逻辑
 * 5.队列播放动画逻辑
 * Created by Harry on 2017/9/4.
 */

public class CarManager {

    public static final long normalAnimStartPlayTime = 1000l;
    public static final long normalAnimPlayingTime = 1000l;
    public static final long normalAnimEndPlayTime = 500l;
    private ExecutorService carAnimExcutorSer = null;
    private LinkedBlockingQueue<CarInfo> carInfoLBQueue;
    private WeakReference<Activity> mActivity;
    private AnimatorSet animationSet;
    private final String TAG = CarManager.class.getSimpleName();
    private LinearLayout ll_entranceCar;

    public CarManager(){
        carAnimExcutorSer = Executors.newSingleThreadExecutor(new ThreadFactory() {
            @Override
            public Thread newThread(@NonNull Runnable r) {
                Thread t = new Thread(r);
                t.setName("逐一执行座驾入场动画的单一线程池");
                return t;
            }
        });
        carInfoLBQueue = new LinkedBlockingQueue();
    }

    /**
     * 初始化
     * @param activity
     * @param rootView
     */
    public void init(Activity activity, LinearLayout rootView, int txtColor, int bgResId){
        mActivity = new WeakReference<Activity>(activity);
        this.bgResId = bgResId;
        this.txtColor = txtColor;
        ll_entranceCar = rootView;
        ll_entranceCar.removeAllViews();
        executeNextAnimTask();
    }

    /**
     * 存队列
     * @param carInfo
     */
    public void putLiveRoomCarInfo(CarInfo carInfo){
        Log.d(TAG,"putLiveRoomCarInfo-carInfo:"+carInfo);
        try {
            carInfoLBQueue.put(carInfo);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    /**
     * 取队列
     * @return
     */
    private CarInfo takeLiveRoomCarInfo(){
        CarInfo item = null;
        try {
            item = carInfoLBQueue.take();
            Log.d(TAG,"takeLiveRoomCarInfo-item:"+item);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        return item;
    }

    /**
     * 清空送礼请求任务队列
     */
    public void clearCarInfoLBQueue(){
        Log.d(TAG,"clearCarInfoLBQueue-carInfoLBQueue.size:"+carInfoLBQueue.size());
        carInfoLBQueue.clear();
    }

    /**
     * 执行下一个送礼请求任务
     */
    public void executeNextAnimTask(){
        Log.d(TAG,"executeNextAnimTask");
        if(null != carAnimExcutorSer){
            carAnimExcutorSer.execute(new LiveRoomCarAnimThread());
        }
    }

    /**
     * 立即关停giftSendReqExecService，并尝试中断所有正在被执行的任务
     */
    public void shutDownAnimQueueServNow(){
        Log.d(TAG,"shutDownAnimQueueServNow");
        //通过调用Thread.interrupt()方法来实现的，但是该方法作用有限，如果线程中没有sleep、wait、condition、定时锁
        //等的应用，interrupt方法是无法中断当前的线程的
        clearCarInfoLBQueue();
        carAnimExcutorSer.shutdownNow();
        carAnimExcutorSer = null;
        if(null != animationSet){
            animationSet.cancel();
        }
        mActivity.clear();
    }

    private class LiveRoomCarAnimThread implements Runnable{
        @Override
        public void run() {
            final CarInfo item = takeLiveRoomCarInfo();
            Log.d(TAG,"LiveRoomCarAnimThreadrun-item:"+item);
            if(null != mActivity){
                Activity tempActivity = mActivity.get();{
                    if(tempActivity != null){
                        tempActivity.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                playLiveRoomCarAnim(item);
                            }
                        });
                    }
                }
            }
        }
    }

    /**
     * 播放座驾入场动画
     * @param carInfo
     */
    public void playLiveRoomCarAnim(CarInfo carInfo){
        if(null== mActivity || null == mActivity.get()){
            return;
        }
        CarView carView = generateEntranceCarView(mActivity.get(),carInfo);
        LinearLayout.LayoutParams entranceCarLp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, DisplayUtil.dip2px(mActivity.get(),34f));
        ll_entranceCar.addView(carView,entranceCarLp);

        playCarInAnim(carView);
    }

    /**
     * 入场
     * @param carView
     */
    private void playCarInAnim(final CarView carView){
        carView.requestLayout();
        animationSet = new AnimatorSet();
        float translationX = carView.getTranslationX();
        float translationY = carView.getTranslationY();
        carView.measure(0,0);
        int carViewMeasureHeight = carView.getMeasuredHeight();
        int carViewMeasureWidth = carView.getMeasuredWidth();
        ObjectAnimator animator1 = ObjectAnimator.ofFloat(carView, "alpha", 0.3f,1f);
        animator1.setDuration(normalAnimStartPlayTime);
        ObjectAnimator animator2 = ObjectAnimator.ofFloat(carView, "translationX",
                translationX+carViewMeasureWidth, translationX);
        animator2.setDuration(normalAnimStartPlayTime);
        ObjectAnimator animator3 = ObjectAnimator.ofFloat(carView, "translationY",
                translationY, translationY);
        animator3.setDuration(normalAnimStartPlayTime);
        animationSet.playTogether(animator1,animator2,animator3);

        animationSet.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {
                carView.setVisibility(View.VISIBLE);
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                playCarStayAnim(carView);

            }

            @Override
            public void onAnimationCancel(Animator animation) {}

            @Override
            public void onAnimationRepeat(Animator animation) {}
        });
        //先加速后减速
        animationSet.setInterpolator(new LinearInterpolator());
        animationSet.start();
    }

    /**
     * 停留动画
     * @param carView
     */
    private void playCarStayAnim(final CarView carView){
        animationSet = new AnimatorSet();
        ObjectAnimator animator1 = ObjectAnimator.ofFloat(carView, "alpha", 1f);
        animator1.setDuration(normalAnimPlayingTime);
        animationSet.play(animator1);
        animationSet.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {}

            @Override
            public void onAnimationEnd(Animator animation) {
                playCarOutAnim(carView);
            }

            @Override
            public void onAnimationCancel(Animator animation) {}

            @Override
            public void onAnimationRepeat(Animator animation) {}
        });
        animationSet.start();
    }

    /**
     * 淡出动画
     * @param carView
     */
    private void playCarOutAnim(final CarView carView){
        animationSet = new AnimatorSet();
        ObjectAnimator animator1 = ObjectAnimator.ofFloat(carView, "alpha", 1f,0f);
        animator1.setDuration(normalAnimEndPlayTime);
        animationSet.play(animator1);
        animationSet.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {}

            @Override
            public void onAnimationEnd(Animator animation) {
                carView.setVisibility(View.INVISIBLE);
                ll_entranceCar.removeAllViews();
                executeNextAnimTask();
            }

            @Override
            public void onAnimationCancel(Animator animation) {}

            @Override
            public void onAnimationRepeat(Animator animation) {}
        });
        animationSet.start();
    }

    private int bgResId = 0;
    private int txtColor = 0;

    /**
     * 生成座驾控件
     * @param activity
     * @param carInfo
     * @return
     */
    public CarView generateEntranceCarView(Activity activity,CarInfo carInfo){
        CarView carView = new CarView(activity);
        carView.init(txtColor,bgResId);
        carView.setCarMasterName(carInfo.nickName);
        carView.setCarImgLocalPath(carInfo.riderLocalPath);
        return carView;
    }
}
