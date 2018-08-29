package com.qpidnetwork.livemodule.liveshow.authorization;

import com.qpidnetwork.livemodule.httprequest.OnRequestLSGetManBaseInfoCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestLSSetManBaseInfoCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestUploadPhotoCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniAuthorization;
import com.qpidnetwork.livemodule.httprequest.RequestJniOther;
import com.qpidnetwork.livemodule.httprequest.item.ManBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.utils.Log;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/12/26.
 */

public class MainBaseInfoManager {

    private final String TAG = MainBaseInfoManager.class.getSimpleName();

    private MainBaseInfoManager(){

    }

    private static MainBaseInfoManager instance = null;

    public static MainBaseInfoManager getInstance(){
        if(null == instance){
            instance = new MainBaseInfoManager();
        }
        return instance;
    }

    private ManBaseInfoItem manBaseInfoItem;


    public interface OnGetMainBaseInfoListener{
        void onGetMainBaseInfo(boolean isSuccess, int errCode, String errMsg);
    }

    /**
     * 获取用户个人信息
     * @param listener
     */
    public void getMainBaseInfoFromServ(final OnGetMainBaseInfoListener listener){

        RequestJniOther.GetManBaseInfo(new OnRequestLSGetManBaseInfoCallback() {
            @Override
            public void onGetManBaseInfo(boolean isSuccess, int errCode, String errMsg, ManBaseInfoItem item) {
                Log.d(TAG,"onGetManBaseInfo-isSuccess:"+isSuccess+" errCode:"+errCode
                        +" errMsg:"+errMsg+" item:"+item);
                if(isSuccess){
                    // Samson:用户头像文件应该会在本地缓存，每次登录成功或上传头像成功就清一下缓存，使其被使用时会自动重新下载,
                    // 若头像不存在就给本地默认图并开始下载，下载成功就回调界面刷新
                    // 这里由于我们是通过url唯一索引本地文件缓存的，头像更改前后url会不一样，所以基本上不需要清理
                    manBaseInfoItem = item;
                }
                if(null != listener){
                    listener.onGetMainBaseInfo(isSuccess,errCode,errMsg);
                }
            }
        });
    }

    /**
     * 更新用户个人信息
     * @param nickname
     * @param listener
     */
    public void updateMainBaseInfo(final String nickname, final OnUpdateMainBaseInfoListener listener){
        RequestJniOther.SetManBaseInfo(nickname, new OnRequestLSSetManBaseInfoCallback() {
            @Override
            public void onSetManBaseInfo(boolean isSuccess, int errCode, String errMsg) {
                Log.d(TAG,"onSetManBaseInfo-isSuccess:"+isSuccess+" errCode:"+errCode+"errMsg:"+errMsg);
                if(isSuccess && null != manBaseInfoItem){
                    manBaseInfoItem.nickName = nickname;
                }
                //暂不同步LoginItem，同直播间接口数据展示区分开
                if(null != listener){
                    listener.onUpdateMainBaseInfo(isSuccess,errCode,errMsg);
                }
            }
        });
    }

    public interface OnUpdateMainBaseInfoListener{
        void onUpdateMainBaseInfo(boolean isSuccess, int errCode, String errMsg);
    }

    public void updateUserPhoto(String localImgPath,final OnUpdateUserPhotoListener listener){
        RequestJniAuthorization.LSUploadPhoto(FileCacheManager.getInstance().getTempImageUrl(),
                new OnRequestUploadPhotoCallback() {
                    @Override
                    public void onUploadPhoto(boolean isSuccess, int errCode, String errMsg, String photoUrl) {
                        Log.d(TAG,"onUploadPhoto-isSuccess:"+isSuccess+" errCode:"+errCode
                                +" errMsg:"+errMsg+" photoUrl:"+photoUrl);
                        if(isSuccess && null != manBaseInfoItem){
                            manBaseInfoItem.photoUrl = photoUrl;
                        }
                        if(null != listener){
                            listener.onUpdateUserPhoto(isSuccess,errCode,errMsg);
                        }
                    }
                });
    }

    public interface OnUpdateUserPhotoListener{
        void onUpdateUserPhoto(boolean isSuccess, int errCode, String errMsg);
    }

    public ManBaseInfoItem getLocalMainBaseInfo(){
        return manBaseInfoItem;
    }




}
