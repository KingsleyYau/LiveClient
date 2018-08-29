package com.qpidnetwork.livemodule.liveshow.share;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.OnGetShareLinkCallback;
import com.qpidnetwork.livemodule.httprequest.OnSetShareSucCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniOther;
import com.qpidnetwork.livemodule.httprequest.item.SharePageType;
import com.qpidnetwork.livemodule.httprequest.item.ShareType;
import com.qpidnetwork.livemodule.liveshow.authorization.FacebookSDKManager;
import com.qpidnetwork.livemodule.utils.Log;

import java.lang.ref.WeakReference;

/**
 * Description:直播分享管理器
 * <p>
 * Created by Harry on 2017/12/26.
 */

public class LiveShareManager {

    public LiveShareManager(Activity activity){
        mActivity = new WeakReference<Activity>(activity);
    }

    private final String TAG = LiveShareManager.class.getSimpleName();
    private WeakReference<Activity> mActivity;

    private ShareType lastShareType;
    private String lastShareLink;
    private String lastShareId;
    private OnShareResultListener lastShareResultListener;

    private Handler handler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            notyServShareSuc();
        }
    };


    /**
     * 第三方平台链接分享
     * @param userId 用户ID
     * @param anchorId 被分享的主播ID
     * @param shareType 分享类型
     * @param sharePageType 分享页面类型
     * @param defaultShareLink 默认分享链接
     */
    public void share2ThirdPlatform(String userId, String anchorId, ShareType shareType,
                                    SharePageType sharePageType, String defaultShareLink,
                                    OnShareResultListener listener){
        Log.d(TAG,"share2ThirdPlatform-userId:"+userId+" anchorId:"+anchorId+" shareType:"+shareType
                +" sharePageType:"+sharePageType+" defaultShareLink:"+defaultShareLink);
        lastShareType = shareType;
        lastShareLink = defaultShareLink;
        lastShareId = null;
        lastShareResultListener = listener;
        RequestJniOther.GetShareLink(userId, anchorId, shareType, sharePageType, new OnGetShareLinkCallback() {
            @Override
            public void onGetShareLink(final boolean isSuccess, int errCode, String errMsg,
                                       final String shareId, final String shareLink) {
                Log.d(TAG,"onGetShareLink-isSuccess:"+isSuccess+" errCode:"+errCode
                        +" errMsg:"+errMsg+" shareId:"+shareId+" shareLink:"+shareLink);
                if(isSuccess){
                    lastShareLink = shareLink;
                    lastShareId = shareId;
                }
                share2ThirdPlatform();
            }
        });
    }

    /**
     * 分享到第三方平台
     */
    private void share2ThirdPlatform(){
        if(null != mActivity && mActivity.get() != null ){
            mActivity.get().runOnUiThread(new Thread(){
                @Override
                public void run() {
                    ShareContentInfo shareContentInfo = new ShareContentInfo();
                    shareContentInfo.shareContentType = ShareContentInfo.ShareContentType.Link;
                    shareContentInfo.contentUrl = lastShareLink;
                    if(lastShareType == ShareType.faceBook){
                        FacebookSDKManager.getInstance().share(mActivity.get(), ShareType.faceBook,
                                shareContentInfo, new FacebookSDKManager.FacebookSDKShareCallBack() {
                                    @Override
                                    public void onShare(FacebookSDKManager.OpearResultCode opearResultCode, String message) {
                                        Log.d(TAG,"share2ThirdPlatform-onShare opearResultCode:"+opearResultCode
                                                +" message:"+message+" lastShareId:"+lastShareId);
                                        if(opearResultCode == FacebookSDKManager.OpearResultCode.SUCCESS){
                                            //分享成功，且shareid不为空，则通知服务器
                                            if(!TextUtils.isEmpty(lastShareId)){
                                                handler.sendEmptyMessage(0);
                                            }else{//否则回调界面
                                                if(null != lastShareResultListener){
                                                    lastShareResultListener.onShareReesult(ShareResult.Success, message);
                                                }
                                            }
                                        }else{//分享不成功,回调界面
                                            if(null != lastShareResultListener){
                                                lastShareResultListener.onShareReesult(
                                                        opearResultCode == FacebookSDKManager.OpearResultCode.FAILED ?
                                                                ShareResult.Failed : ShareResult.Cancel,
                                                        message);
                                            }
                                        }
                                    }
                                });
                    }
                }
            });
        }
    }

    /**
     * 通知服务器分享结果
     */
    private void notyServShareSuc(){

        RequestJniOther.SetShareSuc(lastShareId, new OnSetShareSucCallback() {
            @Override
            public void onSetShareSuc(boolean isSuccess, int errCode, String errMsg) {
                Log.d(TAG,"onSetShareSuc-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg");
                //上传shareid到服务器成功与否暂时不用理会
                if(null != lastShareResultListener){
                    lastShareResultListener.onShareReesult(ShareResult.Success,null);
                }

            }
        });
    }

    /**
     * 分享回调
     */
    public interface OnShareResultListener{
        void onShareReesult(ShareResult shareResult, String message);
    }

    /**
     * 分享结果
     */
    public enum ShareResult{
        Success,
        Failed,
        Cancel
    }

    /**
     * 分享文字,调用系统分享意图
     * @param context
     * @param shareContent
     */
    public void getShareIntent(Context context, String shareContent) {
        Log.d(TAG,"getShareIntent-shareContent:"+shareContent);
        Intent shareIntent = new Intent();
        shareIntent.setAction(Intent.ACTION_SEND);
        shareIntent.putExtra(Intent.EXTRA_TEXT, shareContent);
        shareIntent.setType("text/plain");
        //设置分享列表的标题，并且每次都显示分享列表
        context.startActivity(Intent.createChooser(shareIntent, context.getResources().getString(R.string.shareto)));
    }

    /**
     * 分享图文,调用系统分享意图
     * @param context
     * @param imageUri
     * @param shareTitle
     * @param shareContent
     */
    public  void getShareIntent(Context context, Uri imageUri, String shareTitle, String shareContent) {
        Log.d(TAG, "getShareIntent-imageUri:" + imageUri
                +" shareTitle:"+shareTitle+" shareContent:"+shareContent);
        Intent shareIntent = new Intent();
        shareIntent.setAction(Intent.ACTION_SEND);
        shareIntent.putExtra(Intent.EXTRA_STREAM, imageUri);
        shareIntent.putExtra(Intent.EXTRA_SUBJECT, shareTitle);
        shareIntent.putExtra(Intent.EXTRA_TEXT, shareContent);
        shareIntent.putExtra(Intent.EXTRA_HTML_TEXT, shareContent);
        shareIntent.setType("image/*");
//        shareIntent.setType("text/plain");
        shareIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_GRANT_READ_URI_PERMISSION);
        context.startActivity(Intent.createChooser(shareIntent,
                context.getResources().getString(R.string.shareto)));
    }

    /**
     * 复制信息到粘贴板上
     *
     * @param context
     * @param message
     */
    @SuppressLint("NewApi")
    public void copyMessageToClipboard(Context context, String message) {
        Log.d(TAG,"getShareIntent-message:"+message);
        ClipboardManager cmb = (ClipboardManager) context
                .getSystemService(Context.CLIPBOARD_SERVICE);
        cmb.setPrimaryClip(ClipData.newPlainText(null, message));
    }
}
