package com.qpidnetwork.livemodule.liveshow.liveroom.gift.advance;

import android.graphics.drawable.Animatable;
import android.net.Uri;
import android.support.annotation.Nullable;
import android.view.View;

import com.facebook.common.util.UriUtil;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.controller.BaseControllerListener;
import com.facebook.drawee.controller.ControllerListener;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.fresco.animation.drawable.AnimatedDrawable2;
import com.facebook.imagepipeline.image.ImageInfo;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.List;

/**
 * 大礼物播放管理器（支持本地文件已存在的播放）
 * Created by Hunter Mun on 2017/7/4.
 */

public class AdvanceGiftManager {

    private final String TAG = AdvanceGiftManager.class.getSimpleName();
    private SimpleDraweeView mSimpleDraweeView;        //webP播放器
    private List<AdvanceGiftItem> advanceGiftItems;
    private boolean isAnimationRunning = false;        //是否正在播放大礼物动画

    public AdvanceGiftManager(SimpleDraweeView simpleDraweeView){
        this.mSimpleDraweeView = simpleDraweeView;
        advanceGiftItems = new ArrayList<AdvanceGiftItem>();
    }

    public void addAdvanceGiftItem(AdvanceGiftItem advanceGiftItem){
        if(isAnimationRunning){
            //动画播放中
            addAdvanceGiftItemToQueue(advanceGiftItem);
        }else{
            startPlayAdvanceAnimation(advanceGiftItem);
        }
    }

    private Runnable runnable;

    /**
     * 开始播放大礼物动画
     * @param advanceGiftItem
     */
    private void startPlayAdvanceAnimation(AdvanceGiftItem advanceGiftItem){
        final int repeatTimes = advanceGiftItem.sendNum;

        ControllerListener controllerListener = new BaseControllerListener<ImageInfo>() {
            @Override
            public void onFinalImageSet(
                    String id,
                    @Nullable ImageInfo imageInfo,
                    @Nullable final Animatable anim) {
                if (anim != null) {
                    long animationDuration = 0;
//                    if (anim instanceof AbstractAnimatedDrawable) {
//                        AbstractAnimatedDrawable animatedDrawable = (AbstractAnimatedDrawable) anim;
//
//                        //反射尝试设置循环播放次数
//                        try {
//                            Field field = AbstractAnimatedDrawable.class.getDeclaredField("mLoopCount");
//                            field.setAccessible(true);
//                            field.set(animatedDrawable, advanceGiftItem.sendNum);
//                        } catch (Exception e) {
//                            e.printStackTrace();
//                        }
//                        animationDuration = animatedDrawable.getDuration()*advanceGiftItem.sendNum;
//                        Log.d(TAG,"startPlayAdvanceAnimation-onFinalImageSet animationDuration:"+animationDuration
//                                +" sendNum:"+advanceGiftItem.sendNum);
//                    }
                    //edit by Jagger 2018-6-22 Frecso升级到1.9.0改版本
                    if (anim instanceof AnimatedDrawable2) {
                        AnimatedDrawable2 animatedDrawable = (AnimatedDrawable2) anim;
                        animationDuration = animatedDrawable.getLoopDurationMs() * repeatTimes;
                        Log.d(TAG,"startPlayAdvanceAnimation-onFinalImageSet animationDuration:"+animationDuration
                                +" sendNum:"+repeatTimes);
                    }

                    if(animationDuration > 0){
                        isAnimationRunning = true;
                        anim.start();
                        if(null == runnable){
                            runnable = new Runnable() {
                                @Override
                                public void run() {
                                    if(anim.isRunning()){
                                        anim.stop();
                                    }
                                    isAnimationRunning = false;
                                    mSimpleDraweeView.setVisibility(View.GONE);
                                    AdvanceGiftItem item = getNextPlayAdvanceGiftItem();
                                    if(null != item) {
                                        startPlayAdvanceAnimation(item);
                                    }
                                }
                            };
                        }
                        mSimpleDraweeView.postDelayed(runnable, animationDuration);
                    }
                }
            }
        };

        Uri uri = new Uri.Builder()
                .scheme(UriUtil.LOCAL_FILE_SCHEME)
                .path(advanceGiftItem.srcWebLocalPath)
                .build();

        DraweeController controller = Fresco.newDraweeControllerBuilder()
                .setUri(uri)
                .setOldController(mSimpleDraweeView.getController())
                .setControllerListener(controllerListener)
                .build();
        mSimpleDraweeView.setVisibility(View.VISIBLE);
//        mSimpleDraweeView.setController(controller);

        // 2019/4/26 Hardy OOM
        try {
            mSimpleDraweeView.setController(controller);
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }


    private void addAdvanceGiftItemToQueue(AdvanceGiftItem advanceGiftItem){
        synchronized (advanceGiftItems){
            if(advanceGiftItems != null){
                advanceGiftItems.add(advanceGiftItem);
            }
        }
    }


    /**
     * 取出下一个待播放动画
     * @return
     */
    private AdvanceGiftItem getNextPlayAdvanceGiftItem(){
        AdvanceGiftItem item = null;
        synchronized (advanceGiftItems){
            if(advanceGiftItems.size() > 0){
                item = advanceGiftItems.remove(0);
            }
        }
        return item;
    }

    /**
     * 清除资源
     */
    public void onDestroy(){
        synchronized (advanceGiftItems){
            advanceGiftItems.clear();
        }
        //清除动画
        if(mSimpleDraweeView != null){
            mSimpleDraweeView.setVisibility(View.GONE);
            mSimpleDraweeView.removeCallbacks(runnable);
            mSimpleDraweeView.destroyDrawingCache();
        }
        runnable = null;
        isAnimationRunning = false;
    }
}
