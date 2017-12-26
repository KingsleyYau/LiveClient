package com.qpidnetwork.livemodule.liveshow.liveroom.vedio;

import android.content.Context;
import android.graphics.drawable.Animatable;
import android.net.Uri;
import android.support.annotation.Nullable;
import android.view.View;

import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.controller.BaseControllerListener;
import com.facebook.drawee.controller.ControllerListener;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.imagepipeline.image.ImageInfo;
import com.qpidnetwork.livemodule.utils.Log;

/**
 * Description:直播间视频loading动画管理器
 * <p>
 * Created by Harry on 2017/12/6.
 */

public class VedioLoadingAnimManager {
    private final String TAG = VedioLoadingAnimManager.class.getSimpleName();
    private SimpleDraweeView animPlayerView;
    private static Uri vedioLoadingGifUri;
    private Context mContext;

    public VedioLoadingAnimManager(Context context, SimpleDraweeView animPlayerView){
        if(null != animPlayerView){
            this.animPlayerView = animPlayerView;
        }
        if(null == vedioLoadingGifUri){
            vedioLoadingGifUri = Uri.parse("asset://"+context.getPackageName()+"/liveroom_vedio_loading.gif");
        }
        mContext = context.getApplicationContext();
        Log.logD(TAG,"VedioLoadingAnimManager-vedioLoadingGifUri:"+vedioLoadingGifUri);
    }

    /**
     * 显示加载动画
     */
    public void showLoadingAnim(){
        Log.d(TAG,"showLoadingAnim");
        if(null != animPlayerView){
            ControllerListener controllerListener = new BaseControllerListener<ImageInfo>() {
                @Override
                public void onFinalImageSet(String id,
                        @Nullable ImageInfo imageInfo,
                        @Nullable Animatable anim) {
                    if (anim != null) {
                        anim.start();
                    }
                }

                @Override
                public void onFailure(String id, Throwable throwable) {
                    super.onFailure(id, throwable);
                    if(null != throwable){
                        Log.d(TAG,"showLoadingAnim-onFailure:"+throwable.getMessage());
                        throwable.printStackTrace();
                    }
                }
            };

            DraweeController controller = Fresco.newDraweeControllerBuilder()
                    .setUri(vedioLoadingGifUri)
                    .setCallerContext(mContext)
                    .setOldController(animPlayerView.getController())
                    .setControllerListener(controllerListener)
                    .setAutoPlayAnimations(true)
                    .build();

            animPlayerView.setVisibility(View.VISIBLE);
            animPlayerView.setController(controller);
        }
    }

    /**
     * 隐藏加载动画
     */
    public void hideLoadingAnim(){
        Log.d(TAG,"hideLoadingAnim");
        if(null != animPlayerView){
            animPlayerView.setVisibility(View.GONE);
        }
    }



}
