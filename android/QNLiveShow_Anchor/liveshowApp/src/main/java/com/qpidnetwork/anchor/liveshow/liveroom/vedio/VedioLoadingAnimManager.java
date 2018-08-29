package com.qpidnetwork.anchor.liveshow.liveroom.vedio;

import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.Drawable;
import android.view.View;
import android.widget.ImageView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.utils.Log;

/**
 * Description:直播间视频loading动画管理器
 * <p>
 * Created by Harry on 2017/12/6.
 */

public class VedioLoadingAnimManager {
    private final String TAG = VedioLoadingAnimManager.class.getSimpleName();
    private ImageView animPlayerView;
    private boolean isLoadingAnimShowing = false;

    public VedioLoadingAnimManager(ImageView animPlayerView){
        if(null != animPlayerView){
            this.animPlayerView = animPlayerView;
        }
        isLoadingAnimShowing = false;
    }

    /**
     * 显示加载动画
     */
    public void showLoadingAnim(){
        Log.d(TAG,"showLoadingAnim");
        hideLoadingAnim();
        if(null != animPlayerView){
            animPlayerView.setImageResource(R.drawable.anim_liveroom_vedio_loading);
            Drawable tempDrawable = animPlayerView.getDrawable();
            if((tempDrawable != null) && (tempDrawable instanceof AnimationDrawable)){
                ((AnimationDrawable)tempDrawable).start();
            }
            isLoadingAnimShowing = true;
            animPlayerView.setVisibility(View.VISIBLE);
        }
    }

    /**
     * 隐藏加载动画
     */
    public void hideLoadingAnim(){
        Log.d(TAG,"hideLoadingAnim");
        if(null != animPlayerView && isLoadingAnimShowing){
            Drawable tempDrawable = animPlayerView.getDrawable();
            if((tempDrawable != null) && (tempDrawable instanceof AnimationDrawable)){
                ((AnimationDrawable)tempDrawable).stop();
            }
            animPlayerView.setVisibility(View.GONE);
            isLoadingAnimShowing = false;
        }
    }

    public boolean isLoadingAnimShowing(){
        return isLoadingAnimShowing;
    }

}
