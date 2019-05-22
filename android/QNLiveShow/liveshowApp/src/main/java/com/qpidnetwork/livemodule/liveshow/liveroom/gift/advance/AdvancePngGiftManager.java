package com.qpidnetwork.livemodule.liveshow.liveroom.gift.advance;

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
import com.facebook.imagepipeline.image.ImageInfo;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.List;

/**
 * 大礼物播放管理器（支持本地文件已存在的播放）
 * Created by Hunter Mun on 2017/7/4.
 */

public class AdvancePngGiftManager {

    private final String TAG = AdvancePngGiftManager.class.getSimpleName();
    private SimpleDraweeView sdv_pngAnim;        //Png播放器(吧台礼物播放控件)
    private List<AdvanceGiftItem> bigGiftAnimItems;
    //是否正在播放大礼物动画
    private boolean isAnimationRunning = false;

    public AdvancePngGiftManager(SimpleDraweeView simpleDraweeView){
        this.sdv_pngAnim = simpleDraweeView;
        bigGiftAnimItems = new ArrayList<>();
    }

    /**
     * 添加大礼物/吧台礼物消息
     * @param bigGiftAnimItem
     */
    public void addPngGiftAnimItem(AdvanceGiftItem bigGiftAnimItem){
        if(isAnimationRunning){
            //动画播放中
            addBigGiftItemToQueue(bigGiftAnimItem);
        }else{
            playBigGiftAnim(bigGiftAnimItem);
        }
    }

    private Runnable pngAnimRunnable;

    /**
     * 开始播放大礼物动画
     * @param bigGiftAnimItem
     */
    private void playBigGiftAnim(final AdvanceGiftItem bigGiftAnimItem){
        ControllerListener controllerListener = new BaseControllerListener<ImageInfo>() {
            @Override
            public void onFinalImageSet(
                    String id,
                    @Nullable ImageInfo imageInfo,
                    @Nullable final Animatable anim) {
                    Log.d(TAG,"playBigGiftAnim-onFinalImageSet anim:"+anim+" giftType:"+bigGiftAnimItem.giftAnimType);
                    playStaticImgAnim(bigGiftAnimItem);
            }
        };

        Uri uri = new Uri.Builder()
                .scheme(UriUtil.LOCAL_FILE_SCHEME)
                .path(bigGiftAnimItem.srcWebLocalPath)
                .build();

        DraweeController controller = Fresco.newDraweeControllerBuilder()
                .setUri(uri)
                .setOldController(sdv_pngAnim.getController())
                .setControllerListener(controllerListener)
                .build();
        sdv_pngAnim.setVisibility(View.VISIBLE);
//            sdv_pngAnim.setController(controller);

        // 2019/4/26 Hardy OOM
        try {
            sdv_pngAnim.setController(controller);
        } catch (Throwable e) {
            e.printStackTrace();
        }
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
    private void playStaticImgAnim(final AdvanceGiftItem bigGiftAnimItem){
        Log.d(TAG,"playStaticImgAnim-bigGiftAnimItem:"+bigGiftAnimItem);
        if(bigGiftAnimItem.playTime>0){
            isAnimationRunning = true;
            //animationSet方式会出现问题，当播放完吧台礼物再次播放豪华礼物时，会出现礼物动画显示不出来的bug
            if(null == pngAnimEndRunnable){
                pngAnimEndRunnable = new Runnable() {
                    @Override
                    public void run() {
                        Log.d(TAG,"需播放"+bigGiftAnimItem.sendNum+"此，当前第"+currPlayedCount+"次播放");
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
    private void playBarGiftOutAnim(final View animView, final AdvanceGiftItem bigGiftAnimItem){
        ViewGroup.LayoutParams lp = animView.getLayoutParams();
        Log.d(TAG,"playBarGiftOutAnim-lp.height:"+lp.height);
        viewPropertyAnimator = animView.animate();
        viewPropertyAnimator = viewPropertyAnimator.translationY(lp.height*3/5).translationY(lp.height*2/5)
                .scaleX(0.25f).scaleY(0.25f).alpha(0f).setDuration(600l);
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
                            if(currPlayedCount >= bigGiftAnimItem.sendNum){
                                isAnimationRunning = false;
                                currPlayedCount = 0;
                                AdvanceGiftItem item = getNextPlayBigGiftItem();
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

    //插队列
    private void addBigGiftItemToQueue(AdvanceGiftItem bigGiftAnimItem){
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
    private AdvanceGiftItem getNextPlayBigGiftItem(){
        AdvanceGiftItem item = null;
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

        if(sdv_pngAnim != null){
            sdv_pngAnim.setVisibility(View.GONE);
            sdv_pngAnim.removeCallbacks(pngAnimRunnable);
            sdv_pngAnim.removeCallbacks(pngAnimEndRunnable);
            sdv_pngAnim.removeCallbacks(animAfterPngRunnable);
        }
        pngAnimRunnable = null;
        pngAnimEndRunnable = null;
        isAnimationRunning = false;
        currPlayedCount = 0;
    }
}
