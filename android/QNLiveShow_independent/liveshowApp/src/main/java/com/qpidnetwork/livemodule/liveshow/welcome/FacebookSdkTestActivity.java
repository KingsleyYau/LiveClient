package com.qpidnetwork.livemodule.liveshow.welcome;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.Intent;
import android.graphics.drawable.BitmapDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.facebook.AccessToken;
import com.facebook.AccessTokenTracker;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.login.widget.LoginButton;
import com.facebook.share.widget.ShareButton;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.ShareType;
import com.qpidnetwork.livemodule.liveshow.authorization.FacebookSDKManager;
import com.qpidnetwork.livemodule.liveshow.authorization.ThirdPlatformUserInfo;
import com.qpidnetwork.livemodule.liveshow.share.LiveShareManager;
import com.qpidnetwork.livemodule.liveshow.share.ShareContentInfo;

import java.io.File;


public class FacebookSdkTestActivity extends Activity implements FacebookSDKManager.FacebookSDKLoginCallback {

    private final String TAG = FacebookSdkTestActivity.class.getSimpleName();
    private CallbackManager callbackManager;
    //可以使用accessTokenTracker跟踪token的变化
    private AccessTokenTracker accessTokenTracker;
    private FacebookCallback facebookCallback;
    private final int MSG_WHAT_FBLOGIN_SUC = 1;
    private final int MSG_WHAT_FBLOGIN_CANCEL = 2;
    private final int MSG_WHAT_FBLOGIN_ERROR = 3;
    private final int MSG_WHAT_FBLOGIN_TOKEN_CHANGED = 4;
    private final int MSG_WHAT_FBSHARE_SUC = 5;
    private final int MSG_WHAT_FBSHARE_CANCEL = 6;
    private final int MSG_WHAT_FBSHARE_ERROR = 7;
    private Handler handler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            switch (msg.what){
                case MSG_WHAT_FBSHARE_SUC:
                    sbLog.append("---------------------------------\n");
                    sbLog.append("Facebook 分享成功\n");
                    sbLog.append("postId:"+msg.obj+"\n");
                    break;
                case MSG_WHAT_FBSHARE_CANCEL:
                    sbLog.append("---------------------------------\n");
                    sbLog.append("Facebook 分享取消\n");
                    break;
                case MSG_WHAT_FBSHARE_ERROR:
                    sbLog.append("---------------------------------\n");
                    sbLog.append("Facebook 分享失败\n");
                    break;
                case MSG_WHAT_FBLOGIN_SUC:
                    sbLog.append("---------------------------------\n");
                    sbLog.append("Facebook 登录成功\n");
                    sbLog.append("accessToken:"+msg.obj+"\n");
                    break;

                case MSG_WHAT_FBLOGIN_ERROR:
                    sbLog.append("---------------------------------\n");
                    sbLog.append("Facebook 登录失败\n");
                    break;
                case MSG_WHAT_FBLOGIN_TOKEN_CHANGED:
                    sbLog.append("---------------------------------\n");
                    sbLog.append("Facebook accessToken发生了更改\n");
                    Bundle bundle = msg.getData();
                    if(null != bundle){
                        sbLog.append("accessToken:"+bundle.getString("accessToken")+"\n");
                        sbLog.append("accessToken1:"+bundle.getString("accessToken1")+"\n");
                    }
                    break;
            }
            if(null != tv_fbLog){
                tv_fbLog.setText(sbLog.toString());
            }
        }
    };
    private LoginButton lb_fbLogin;
    private StringBuilder sbLog;
    private TextView tv_fbLog;

    private ShareButton sb_fbShare;

    private LiveShareManager liveShareManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_facebook_sdk_test);
        init();
        initFBLoginButton();
        initFBShareButton();
    }

    private void init(){
        tv_fbLog = (TextView)findViewById(R.id.tv_fbLog);
        callbackManager = FacebookSDKManager.getInstance().getCallbackManager();
        accessTokenTracker = new AccessTokenTracker() {
            @Override
            protected void onCurrentAccessTokenChanged(AccessToken accessToken, AccessToken accessToken1) {
                Log.d(TAG,"onCurrentAccessTokenChanged-accessToken:"+accessToken+" accessToken1:"+accessToken1);
                if(null != handler){
                    Message msg = handler.obtainMessage(MSG_WHAT_FBLOGIN_TOKEN_CHANGED);
                    Bundle bundle = new Bundle();
                    if(null != accessToken){
                        bundle.putString("accessToken",accessToken.toString());
                    }
                    if(null != accessToken1){
                        bundle.putString("accessToken1",accessToken1.toString());
                    }
                    msg.setData(bundle);
                    handler.sendMessage(msg);
                }
            }
        };

        sbLog = new StringBuilder();
        liveShareManager = new LiveShareManager(this);
    }

    public void initFBLoginButton(){
        lb_fbLogin = (LoginButton) findViewById(R.id.lb_fbLogin);
        lb_fbLogin.setReadPermissions("public_profile","email","user_birthday");
        // If using in a fragment
//        lb_fbLogin.setFragment(this);
        facebookCallback = FacebookSDKManager.getInstance().getLoginFacebookCallback();
        //registerLoginCallBack权限设置为public仅仅是为了在该界面测试LoginButton的回调
        FacebookSDKManager.getInstance().registerLoginCallBack(this);
        lb_fbLogin.registerCallback(callbackManager, facebookCallback);
    }

    public void initFBShareButton(){
        sb_fbShare = (ShareButton) findViewById(R.id.sb_fbShare);
        ShareContentInfo shareContentInfo = new ShareContentInfo();
        shareContentInfo.shareContentType = ShareContentInfo.ShareContentType.Link;
        shareContentInfo.contentUrl = "https://live.charmdate.com:443/uploadfiles/cover_photo/big/201711/a63db7024fc6b8664a41ef1fed9e0abf.jpg";
        shareContentInfo.hashTag = "#share4Test";
        shareContentInfo.quote="Dev by hkercn";
        sb_fbShare.setShareContent(FacebookSDKManager.getInstance().genShareContent(shareContentInfo));
    }

    public void onFacebookLoginClick(View view){
        Log.d(TAG,"onFacebookLoginClick");
//        loginManager.logInWithReadPermissions(this,Arrays.asList(new String[]{"email","public_profile"}));
        FacebookSDKManager.getInstance().login(this,this);
    }

    private FacebookSDKManager.FacebookSDKShareCallBack shareCallBack = new FacebookSDKManager.FacebookSDKShareCallBack() {
        @Override
        public void onShare(FacebookSDKManager.OpearResultCode opearResultCode, String message) {
            Log.d(TAG,"onShare-opearResultCode:" +opearResultCode.name()+" message:"+message);
            switch (opearResultCode){
                case SUCCESS:
                    Message msg = handler.obtainMessage(MSG_WHAT_FBSHARE_SUC);
                    msg.obj = message;
                    handler.sendMessage(msg);
                    break;
                case CANCEL:
                    handler.sendEmptyMessage(MSG_WHAT_FBSHARE_CANCEL);
                    break;
                case FAILED:
                    handler.sendEmptyMessage(MSG_WHAT_FBSHARE_ERROR);
                    break;
            }
        }
    };

    public void onFacebookShareLinkClick(View view){
        Log.d(TAG,"onFacebookShareLinkClick");
        ShareContentInfo shareContentInfo = new ShareContentInfo();
        shareContentInfo.shareContentType = ShareContentInfo.ShareContentType.Link;
        shareContentInfo.contentUrl = "https://live.charmdate.com:443/uploadfiles/cover_photo/big/201711/a63db7024fc6b8664a41ef1fed9e0abf.jpg";
        shareContentInfo.hashTag = "#share4Test";
        shareContentInfo.quote="Dev by hkercn";
        FacebookSDKManager.getInstance().share(this, ShareType.faceBook, shareContentInfo, shareCallBack);
    }

    public void onFacebookShareImgClick(View view){
        Log.d(TAG,"onFacebookShareImgClick");
        ShareContentInfo shareContentInfo = new ShareContentInfo();
        shareContentInfo.shareContentType = ShareContentInfo.ShareContentType.Img;
        shareContentInfo.bitmap = ((BitmapDrawable)getResources().getDrawable(R.drawable.live_guide_a_1)).getBitmap();
        FacebookSDKManager.getInstance().share(this, ShareType.faceBook, shareContentInfo, shareCallBack);
    }

    public void onFacebookShareVedioClick(View view){
        Log.d(TAG,"onFacebookShareVedioClick");
        Uri videoFileUri = Uri.fromFile(new File("/storage/emulated/0/DCIM/Camera/20171220_191204.mp4"));
        ShareContentInfo shareContentInfo = new ShareContentInfo();
        shareContentInfo.shareContentType = ShareContentInfo.ShareContentType.Vedio;
        shareContentInfo.vedioUrl = videoFileUri.toString();
        FacebookSDKManager.getInstance().share(this, ShareType.faceBook, shareContentInfo, shareCallBack);
    }

    public void onFacebookShareMediaClick(View view){
        Log.d(TAG,"onFacebookShareMediaClick");
    }

    public void onFacebookLogoutClick(View view){
        Log.d(TAG,"onFacebookLogoutClick");
        FacebookSDKManager.getInstance().logout();
    }

    /**
     * 拷贝文本链接到系统黏贴板
     * @param view
     */
    public void onShareTxtLink(View view){
        Log.d(TAG,"onShareTxtLink");
        liveShareManager.getShareIntent(this,"Share coollive to u");
    }

    /**
     * 调用系统分享意图分享单张图片
     * @param view
     */
    public void onShareImg(View view){
        Log.d(TAG,"onShareImg");
        Uri imageUri = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE +
                "://" + getResources().getResourcePackageName(R.drawable.ic_launcher)
                + '/' + getResources().getResourceTypeName(R.drawable.ic_launcher)
                + '/' + getResources().getResourceEntryName(R.drawable.ic_launcher) );
        liveShareManager.getShareIntent(this,imageUri,"share u","Share coollive to u");
    }

    public void onCopyLink(View view){
        Log.d(TAG,"onCopyLink");
        liveShareManager.copyMessageToClipboard(this,"www.baidu.com");
        Toast.makeText(this,"has copy www.baidu.com to clipboard",Toast.LENGTH_SHORT).show();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        lb_fbLogin.unregisterCallback(callbackManager);
        handler.removeCallbacksAndMessages(null);
        FacebookSDKManager.getInstance().clean();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if(null != callbackManager){
            //不论通过callbackManager跟踪登陆结果，还是通过accessTokenTracker监听token变化，两种方式都需要调用
            //callbackManager.onActivityResult(requestCode,resultCode,data);以便将登录结果传递到callbackManager中
            //集成到facebook sdk登录或者分享功能的所有activity和fragment都应将onActivityResult转发到callbackManager
            callbackManager.onActivityResult(requestCode,resultCode,data);
        }
    }

    @Override
    public void onLogin(FacebookSDKManager.OpearResultCode opearResultCode,
                        String message, ThirdPlatformUserInfo userInfo) {
        Log.d(TAG,"onLoginResult-opearResultCode:"+opearResultCode.name()+" message:"+message);
        switch (opearResultCode){
            case SUCCESS:
                if(null != handler){
                    Message msg = handler.obtainMessage(MSG_WHAT_FBLOGIN_SUC);
                    msg.obj = userInfo;
                    handler.sendMessage(msg);
                }
                break;
            case CANCEL:
                if(null != handler){
                    handler.sendEmptyMessage(MSG_WHAT_FBLOGIN_CANCEL);
                }
                break;
            case FAILED:
                if(null != handler){
                    handler.sendEmptyMessage(MSG_WHAT_FBLOGIN_ERROR);
                }
                break;
        }

    }
}
