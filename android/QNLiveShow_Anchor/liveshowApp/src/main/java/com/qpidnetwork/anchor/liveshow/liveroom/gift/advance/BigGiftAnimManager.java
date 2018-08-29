package com.qpidnetwork.anchor.liveshow.liveroom.gift.advance;

import android.animation.Animator;
import android.graphics.drawable.Animatable;
import android.net.Uri;
import android.support.annotation.Nullable;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewPropertyAnimator;

import com.facebook.common.util.UriUtil;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.controller.BaseControllerListener;
import com.facebook.drawee.controller.ControllerListener;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.fresco.animation.drawable.AnimatedDrawable2;
import com.facebook.imagepipeline.image.ImageInfo;
import com.qpidnetwork.anchor.utils.Log;

import java.util.ArrayList;
import java.util.List;

/**
 * 大礼物播放管理器（支持本地文件已存在的播放）
 * Created by Hunter Mun on 2017/7/4.
 */

public class BigGiftAnimManager {

    private final String TAG = BigGiftAnimManager.class.getSimpleName();
    private SimpleDraweeView sdv_webpAnim;        //webP播放器
    private SimpleDraweeView sdv_pngAnim;        //webP播放器
    private List<BigGiftAnimItem> bigGiftAnimItems;
    //是否正在播放大礼物动画
    private boolean isAnimationRunning = false;

    public BigGiftAnimManager(SimpleDraweeView simpleDraweeView){
        this.sdv_webpAnim = simpleDraweeView;
        bigGiftAnimItems = new ArrayList<BigGiftAnimItem>();
    }

    /**
     * 设置吧台礼物播放控件
     * @param sdv_pngAnim
     */
    public void setBarGiftAnimView(SimpleDraweeView sdv_pngAnim){
        this.sdv_pngAnim = sdv_pngAnim;
    }

    /**
     * 添加大礼物/吧台礼物消息
     * @param bigGiftAnimItem
     */
    public void addBigGiftAnimItem(BigGiftAnimItem bigGiftAnimItem){
        if(isAnimationRunning){
            //动画播放中
            addBigGiftItemToQueue(bigGiftAnimItem);
        }else{
            playBigGiftAnim(bigGiftAnimItem);
        }
    }

    private Runnable webpAnimRunnable;

    /**
     * 开始播放大礼物动画
     * @param bigGiftAnimItem
     */
    private void playBigGiftAnim(final BigGiftAnimItem bigGiftAnimItem){
        ControllerListener controllerListener = new BaseControllerListener<ImageInfo>() {
            @Override
            public void onFinalImageSet(
                    String id,
                    @Nullable ImageInfo imageInfo,
                    @Nullable final Animatable anim) {
                Log.d(TAG,"playBigGiftAnim-onFinalImageSet anim:"+anim+" giftType:"+bigGiftAnimItem.giftAnimType);
                if(bigGiftAnimItem.giftAnimType == BigGiftAnimItem.BigGiftAnimType.BarGift){
                    playStaticImgAnim(bigGiftAnimItem);
                }else{
                    playWebpAnim(anim, bigGiftAnimItem);
                }
            }
        };

        Uri uri = new Uri.Builder()
                .scheme(UriUtil.LOCAL_FILE_SCHEME)
                .path(bigGiftAnimItem.bigAnimFileLocalPath)
                .build();

        SimpleDraweeView sdv_anim = null;
        if(bigGiftAnimItem.giftAnimType == BigGiftAnimItem.BigGiftAnimType.BarGift){
            sdv_anim = sdv_pngAnim;
            sdv_webpAnim.setVisibility(View.GONE);
        }else{
            sdv_anim = sdv_webpAnim;
            if(null != sdv_pngAnim){
                sdv_pngAnim.setVisibility(View.GONE);
            }
        }

        DraweeController controller = Fresco.newDraweeControllerBuilder()
                .setUri(uri)
                .setOldController(sdv_anim.getController())
                .setControllerListener(controllerListener)
                .build();
        sdv_anim.setVisibility(View.VISIBLE);
        sdv_anim.setController(controller);
    }

    private int currPlayedCount = 0;
    private Runnable pngAnimEndRunnable;
    private Runnable animAfterPngRunnable;

    /**
     * 播放吧台礼物动画(静态图片动画)
     * TODO:
     * 1.参照PC 增加移出效果 垂直向下缩小 到吧台礼物列表img大小 移动到吧台礼物列表上不边缘就隐藏 0.2s
     * 2.吧台礼物播放区域 占用 窗格区域的四分一直 也即width、height均为屏幕宽度的1/4
     * @param bigGiftAnimItem
     */
    private void playStaticImgAnim(final BigGiftAnimItem bigGiftAnimItem){
        Log.d(TAG,"playStaticImgAnim-bigGiftAnimItem:"+bigGiftAnimItem);
        if(bigGiftAnimItem.playTime>0){
            isAnimationRunning = true;
            //animationSet方式会出现问题，当播放完吧台礼物再次播放豪华礼物时，会出现礼物动画显示不出来的bug
            if(null == pngAnimEndRunnable){
                pngAnimEndRunnable = new Runnable() {
                    @Override
                    public void run() {
                        Log.d(TAG,"需播放"+bigGiftAnimItem.giftNum+"此，当前第"+currPlayedCount+"次播放");
                        playBarGiftOutAnim(sdv_pngAnim,bigGiftAnimItem);
                    }
                };
            }
            sdv_pngAnim.postDelayed(pngAnimEndRunnable, bigGiftAnimItem.playTime);
        }
    }

    private ViewPropertyAnimator viewPropertyAnimator;

    /**
     * 播放吧台礼物淡出动画
     * @param animView
     * @param bigGiftAnimItem
     */
    private void playBarGiftOutAnim(final View animView, final BigGiftAnimItem bigGiftAnimItem){
        ViewGroup.LayoutParams lp = animView.getLayoutParams();
        Log.d(TAG,"playBarGiftOutAnim-lp.height:"+lp.height);
        viewPropertyAnimator = animView.animate();
        viewPropertyAnimator = viewPropertyAnimator.translationY(lp.height*3/5)
                .scaleX(0.25f).scaleY(0.25f).alpha(0f).setDuration(200l);
        viewPropertyAnimator.setListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {

            }

            @Override
            public void onAnimationEnd(Animator animation) {
                currPlayedCount+=1;
                sdv_pngAnim.setVisibility(View.GONE);
                sdv_pngAnim.setScaleX(1f);
                sdv_pngAnim.setTranslationY(0f);
                sdv_pngAnim.setScaleY(1f);
                sdv_pngAnim.setAlpha(1f);
                if(animAfterPngRunnable == null){
                    animAfterPngRunnable = new Runnable() {
                        @Override
                        public void run() {
                            if(currPlayedCount >= bigGiftAnimItem.giftNum){
                                isAnimationRunning = false;
                                currPlayedCount = 0;
                                BigGiftAnimItem item = getNextPlayBigGiftItem();
                                if(null != item) {
                                    playBigGiftAnim(item);
                                }
                            }else{
                                playBigGiftAnim(bigGiftAnimItem);
                            }
                        }
                    };
                }
                sdv_pngAnim.post(animAfterPngRunnable);
            }

            @Override
            public void onAnimationCancel(Animator animation) {

            }

            @Override
            public void onAnimationRepeat(Animator animation) {

            }
        });
        viewPropertyAnimator.start();
    }


    /**
     * 播放webp文件格式的大礼物动画,可以忽略BigGiftAnimItem#playTime字段,由webp文件来自动计算
     * @param anim
     * @param bigGiftAnimItem
     */
    private void playWebpAnim(@Nullable final Animatable anim, BigGiftAnimItem bigGiftAnimItem) {
        Log.d(TAG,"playWebpAnim-bigGiftAnimItem:"+bigGiftAnimItem);
        if (anim != null) {
            final int repeatTimes = bigGiftAnimItem.giftNum;
            long animationDuration = 0;
//            if (anim instanceof AbstractAnimatedDrawable) {
//                AbstractAnimatedDrawable animatedDrawable = (AbstractAnimatedDrawable) anim;
//
//                //反射尝试设置循环播放次数
//                try {
//                    Field field = AbstractAnimatedDrawable.class.getDeclaredField("mLoopCount");
//                    field.setAccessible(true);
//                    field.set(animatedDrawable, bigGiftAnimItem.giftNum);
//                } catch (Exception e) {
//                    e.printStackTrace();
//                }
//                animationDuration = animatedDrawable.getDuration()* bigGiftAnimItem.giftNum;
//                Log.d(TAG,"playWebpAnim-animationDuration:"+animationDuration
//                        +" giftNum:"+ bigGiftAnimItem.giftNum);
//            }
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
                if(null == webpAnimRunnable){
                    webpAnimRunnable = new Runnable() {
                        @Override
                        public void run() {
                            if(anim.isRunning()){
                                anim.stop();
                            }
                            Log.d(TAG,"playWebpAnim-播放完毕");
                            isAnimationRunning = false;
                            sdv_webpAnim.setVisibility(View.GONE);
                            BigGiftAnimItem item = getNextPlayBigGiftItem();
                            if(null != item) {
                                playBigGiftAnim(item);
                            }
                        }
                    };
                }
                sdv_webpAnim.postDelayed(webpAnimRunnable, animationDuration);
            }
        }
    }

    //插队列
    private void addBigGiftItemToQueue(BigGiftAnimItem bigGiftAnimItem){
        synchronized (bigGiftAnimItems){
            if(bigGiftAnimItems != null){
                bigGiftAnimItems.add(bigGiftAnimItem);
            }
        }
    }


    /**
     * 取出下一个待播放动画
     * @return
     */
    private BigGiftAnimItem getNextPlayBigGiftItem(){
        BigGiftAnimItem item = null;
        synchronized (bigGiftAnimItems){
            if(bigGiftAnimItems.size() > 0){
                item = bigGiftAnimItems.remove(0);
            }
        }
        return item;
    }

    /**
     * 清除资源
     */
    public void onDestroy(){
        synchronized (bigGiftAnimItems){
            bigGiftAnimItems.clear();
        }

        if(null != viewPropertyAnimator){
            viewPropertyAnimator.cancel();
        }

        //清除动画
        if(sdv_webpAnim != null){
            sdv_webpAnim.setVisibility(View.GONE);
            sdv_webpAnim.removeCallbacks(webpAnimRunnable);
            sdv_webpAnim.removeCallbacks(pngAnimEndRunnable);
            sdv_webpAnim.removeCallbacks(animAfterPngRunnable);
        }
        if(sdv_pngAnim != null){
            sdv_pngAnim.setVisibility(View.GONE);
            sdv_pngAnim.removeCallbacks(webpAnimRunnable);
            sdv_pngAnim.removeCallbacks(pngAnimEndRunnable);
            sdv_pngAnim.removeCallbacks(animAfterPngRunnable);
        }
        webpAnimRunnable = null;
        pngAnimEndRunnable = null;
        isAnimationRunning = false;
        currPlayedCount = 0;
    }
}
