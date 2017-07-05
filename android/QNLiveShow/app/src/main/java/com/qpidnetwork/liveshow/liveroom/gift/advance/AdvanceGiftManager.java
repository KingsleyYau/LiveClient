package com.qpidnetwork.liveshow.liveroom.gift.advance;

import android.app.Activity;
import android.graphics.drawable.Animatable;
import android.net.Uri;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.View;

import com.facebook.common.util.UriUtil;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.controller.BaseControllerListener;
import com.facebook.drawee.controller.ControllerListener;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.imagepipeline.animated.base.AbstractAnimatedDrawable;
import com.facebook.imagepipeline.image.ImageInfo;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;

/**
 * 大礼物播放管理器（支持本地文件已存在的播放）
 * Created by Hunter Mun on 2017/7/4.
 */

public class AdvanceGiftManager {

    private Activity mActivity;
    private SimpleDraweeView mSimpleDraweeView;        //webP播放器
    private List<String> mAdvanceGiftList;             //待播放大礼物本地地址列表
    private boolean isAnimationRunning = false;        //是否正在播放大礼物动画

    public AdvanceGiftManager(Activity activity, SimpleDraweeView simpleDraweeView){
        this.mActivity = activity;
        this.mSimpleDraweeView = simpleDraweeView;
        mAdvanceGiftList = new ArrayList<String>();
    }

    /**
     * 添加webp动画
     * @param path //webp动画本地地址
     */
    public void addAdvanceGiftItem(String path){
        if(isAnimationRunning){
            //动画播放中
            addGiftPath(path);
        }else{
            startPlayAdvanceAnimation(path);
        }
    }

    /**
     * 开始播放大礼物动画
     * @param path
     */
    private void startPlayAdvanceAnimation(String path){
        ControllerListener controllerListener = new BaseControllerListener<ImageInfo>() {
            @Override
            public void onFinalImageSet(
                    String id,
                    @Nullable ImageInfo imageInfo,
                    @Nullable final Animatable anim) {
                if (anim != null) {
                    int animationDuration = 0;
                    if (anim instanceof AbstractAnimatedDrawable) {
                        AbstractAnimatedDrawable animatedDrawable = (AbstractAnimatedDrawable) anim;

                        //反射尝试设置循环播放仅1次
                        try {
                            Field field = AbstractAnimatedDrawable.class.getDeclaredField("mLoopCount");
                            field.setAccessible(true);
                            field.set(animatedDrawable, 1);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        animationDuration = animatedDrawable.getDuration();
                    }
                    if(animationDuration > 0){
                        isAnimationRunning = true;
//                        mSimpleDraweeView.setVisibility(View.VISIBLE);
                        anim.start();
                        mSimpleDraweeView.postDelayed(new Runnable() {
                            @Override
                            public void run() {
                                if(anim.isRunning()){
                                    anim.stop();
                                }
                                isAnimationRunning = false;
                                mSimpleDraweeView.setVisibility(View.GONE);
                                String path = getNextPlayGiftPath();
                                if(!TextUtils.isEmpty(path)) {
                                    startPlayAdvanceAnimation(path);
                                }
                            }
                        }, animationDuration);
                    }
                }
            }
        };

        Uri uri = new Uri.Builder()
                .scheme(UriUtil.LOCAL_FILE_SCHEME)
                .path(path)
                .build();

        DraweeController controller = Fresco.newDraweeControllerBuilder()
                .setUri(uri)
                .setOldController(mSimpleDraweeView.getController())
                .setControllerListener(controllerListener)
                .build();
        mSimpleDraweeView.setVisibility(View.VISIBLE);
        mSimpleDraweeView.setController(controller);
    }

    /**
     * 加入到待播放列表
     * @param path
     */
    private void addGiftPath(String path){
        synchronized (mAdvanceGiftList){
            if(mAdvanceGiftList != null){
                mAdvanceGiftList.add(path);
            }
        }
    }

    /**
     * 取出下一个待播放动画
     * @return
     */
    private String getNextPlayGiftPath(){
        String path = "";
        synchronized (mAdvanceGiftList){
            if(mAdvanceGiftList.size() > 0){
                path = mAdvanceGiftList.remove(0);
            }
        }
        return path;
    }
}
