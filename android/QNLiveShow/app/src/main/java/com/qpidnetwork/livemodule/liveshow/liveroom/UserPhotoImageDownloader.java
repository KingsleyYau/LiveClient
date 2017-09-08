package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.widget.ImageView;

import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.squareup.picasso.Picasso;

/**
 * 用户头像下载器(仅限主线程调用，否则可能异常或无效)
 * Created by Hunter Mun on 2017/6/23.
 */

public class UserPhotoImageDownloader {

    private static final int EVENT_GET_USER_INFO = 1;

    private Context mContext;
    private Handler mHandler;

    private String mUserId;
    private int mDefaultImageResId;
    private ImageView mImageView;

    public UserPhotoImageDownloader(Context context){
        this.mContext = context;
        mHandler = new Handler(){
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                switch (msg.what){
                    case EVENT_GET_USER_INFO:{
                        HttpRespObject httpRespObject = (HttpRespObject)msg.obj;
                        if(httpRespObject.isSuccess){
                            String photoUrl = (String)httpRespObject.data;
                            if(!TextUtils.isEmpty(photoUrl) && mImageView != null){
                                Picasso.with(mContext).load(photoUrl).into(mImageView);
                            }
                        }
                    }break;
                    default:
                        break;

                }
            }
        };
    }

    public UserPhotoImageDownloader setDefaultResource(int resId){
        this.mDefaultImageResId = resId;
        return this;
    }

    public UserPhotoImageDownloader loadUserPhoto(String userId){
        this.mUserId = userId;
        if(mDefaultImageResId != -1 && mImageView != null){
            mImageView.setImageResource(mDefaultImageResId);
        }
        if(!TextUtils.isEmpty(mUserId)){
            IMManager imManager = IMManager.getInstance();
            IMUserBaseInfoItem userInfo = imManager.getUserInfo(mUserId);
            if(!TextUtils.isEmpty(userInfo.photoUrl)){
                if(mImageView != null) {
                    Picasso.with(mContext).load(userInfo.photoUrl).into(mImageView);
                }
            }else{
                //根据直播间是否已知所有用户PhotoUrl取消单独获取
//                imManager.getUserSmallPhoto(mUserId, new OnGetUserPhotoCallback() {
//                    @Override
//                    public void onGetUserPhoto(boolean isSuccess, int errCode, String errMsg, String photoUrl) {
//                        Message msg = Message.obtain();
//                        msg.what = EVENT_GET_USER_INFO;
//                        msg.obj = new HttpRespObject(isSuccess, errCode, errMsg, photoUrl);
//                        mHandler.sendMessage(msg);
//                    }
//                });
            }
        }
        return this;
    }

    public void into(ImageView view){
        this.mImageView = view;
    }

    public void reset(){
        this.mUserId = "";
        this.mDefaultImageResId = -1;
        this.mImageView.setImageBitmap(null);
    }

}
