package com.qpidnetwork.livemodule.liveshow.authorization;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Base64;
import android.util.Log;

import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookRequestError;
import com.facebook.FacebookSdk;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.LoggingBehavior;
import com.facebook.appevents.AppEventsLogger;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.share.Sharer;
import com.facebook.share.model.ShareContent;
import com.facebook.share.model.ShareHashtag;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.model.SharePhoto;
import com.facebook.share.model.SharePhotoContent;
import com.facebook.share.model.ShareVideo;
import com.facebook.share.model.ShareVideoContent;
import com.facebook.share.widget.ShareDialog;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.ShareType;
import com.qpidnetwork.livemodule.liveshow.share.ShareContentInfo;

import org.json.JSONException;
import org.json.JSONObject;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Description:facebook sdk登录管理器
 * <p>使用方式:
 *     0.Application的onCreate里面调用FackbookSDKManager.getInstance().init(context);
 *     1.在facebook登录或者分享的activity/fragment中,onActivityResult里面调用
 *     FacebookSDKManager.getInstance().getFacebookCallbackManager().onActivityResult()
 *     2.登录业务管理器LoginManager里面在需要facebook login的地方，调用FackbookSDKManager.login(context,callback)
 *     3.在需要分享的地方，调用FackbookSDKManager.share(context,callback)
 *     4.使用方式可以参考FacebookSdkTestActivity
 * Created by Harry on 2017/12/19.
 */

public class FacebookSDKManager {

    private final static String TAG = FacebookSDKManager.class.getSimpleName();

    private CallbackManager callbackManager = CallbackManager.Factory.create();

    public CallbackManager getCallbackManager(){
        return callbackManager;
    }

    private FacebookSDKManager(){
        facebookSdkLoginCallbackList = new ArrayList<>();
    }

    private static FacebookSDKManager instance = null;

    public static FacebookSDKManager getInstance(){
        if(null == instance){
            instance = new FacebookSDKManager();
        }
        return instance;
    }

    public void init(Context context){
        //facebook sdk的初始化
        FacebookSdk.sdkInitialize(context.getApplicationContext());
        FacebookSdk.addLoggingBehavior(LoggingBehavior.REQUESTS);
        boolean isDebug = context.getResources().getBoolean(R.bool.demo);
        Log.d(TAG,"init-isDebug:"+isDebug);
        FacebookSdk.setIsDebugEnabled(isDebug);
        FacebookSdk.addLoggingBehavior(LoggingBehavior.GRAPH_API_DEBUG_INFO);
        //应用事件记录
        AppEventsLogger.activateApp(context.getApplicationContext());
        LoginManager.getInstance().registerCallback(callbackManager, loginFacebookCallback);
        logKeyHash(context);
    }

    @SuppressLint("HandlerLeak")
    private Handler handler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            getFacebookUserInfo();
        }
    };

    /**
     * 打印facebook需要的keyHash
     * @param context
     */
    private void logKeyHash(Context context) {
        try {
            PackageInfo packageInfo = context.getPackageManager().getPackageInfo(
                    context.getPackageName(), PackageManager.GET_SIGNATURES);
            for(android.content.pm.Signature signature : packageInfo.signatures){
                MessageDigest messageDigest = MessageDigest.getInstance("SHA");
                messageDigest.update(signature.toByteArray());
                Log.d(TAG,"logKeyHash-keyhash:"+ Base64.encodeToString(messageDigest.digest(),Base64.DEFAULT));
            }
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
    }

    public void clean(){
        if(null != callbackManager){
            LoginManager.getInstance().unregisterCallback(callbackManager);
        }

        if(null != shareDialog){
            shareDialog = null;
        }
    }

    private List<FacebookSDKLoginCallback> facebookSdkLoginCallbackList;

    private FacebookCallback loginFacebookCallback = new FacebookCallback<LoginResult>() {
        @Override
        public void onSuccess(LoginResult loginResult) {
            if(null != loginResult){
                accessToken = loginResult.getAccessToken();
                Log.d(TAG,"loginFacebookCallback-onSuccess-loginResult.accessToken:" +accessToken.getToken());
                handler.sendEmptyMessage(0);
            }else{
                Log.d(TAG,"loginFacebookCallback-onSuccess");
            }
        }

        @Override
        public void onCancel() {
            Log.d(TAG,"loginFacebookCallback-onCancel");
            if(null != facebookSdkLoginCallbackList){
                for(FacebookSDKLoginCallback callBack : facebookSdkLoginCallbackList){
                    callBack.onLogin(OpearResultCode.FAILED,null,null);
                    facebookSdkLoginCallbackList.remove(callBack);
                }
            }
        }

        @Override
        public void onError(FacebookException e) {
            Log.d(TAG,"loginFacebookCallback-onError");
            if(null != e){
                e.printStackTrace();
            }
            if(null != facebookSdkLoginCallbackList){
                for(FacebookSDKLoginCallback callBack : facebookSdkLoginCallbackList){
                    callBack.onLogin(OpearResultCode.FAILED,e.getMessage(),null);
                    facebookSdkLoginCallbackList.remove(callBack);
                }
            }
        }
    };

    private GraphRequest request;

    /**
     * 获取facebook登录帐号的用户信息
     */
    private void getFacebookUserInfo(){
        Log.d(TAG,"getFacebookUserInfo");
        if(null != accessToken){
            request = GraphRequest.newMeRequest(accessToken,
                    new GraphRequest.GraphJSONObjectCallback() {
                        @Override
                        public void onCompleted(JSONObject object, GraphResponse response) {
                            Log.d(TAG,"getFacebookUserInfo-onCompleted object:"+object);
                            FacebookRequestError error = response.getError();
                            if(null != error){
                                int errorCode = error.getErrorCode();
                                int requestStatusCode = error.getRequestStatusCode();
                                int subErrorCode = error.getSubErrorCode();
                                String errorType = error.getErrorType();
                                String errorMessage = error.getErrorMessage();
                                Log.d(TAG,"getFacebookUserInfo-onCompleted errorCode:"+errorCode
                                        +" requestStatusCode:"+requestStatusCode
                                        +" subErrorCode:"+subErrorCode
                                        +" errorMessage:"+errorMessage
                                        +" errorType:"+errorType);
                                ThirdPlatformUserInfo userInfo = new ThirdPlatformUserInfo();
                                userInfo.token = accessToken.getToken();
                                if(null != facebookSdkLoginCallbackList){
                                    for(FacebookSDKLoginCallback callBack : facebookSdkLoginCallbackList){
                                        callBack.onLogin(OpearResultCode.SUCCESS, errorMessage,userInfo);
                                        facebookSdkLoginCallbackList.remove(callBack);
                                    }
                                }
                            }else{
                                //graphObject等同object
//                            JSONObject graphObject = response.getJSONObject();
//                            JSONArray graphObjectArray = response.getJSONArray();
//                            Log.d(TAG,"getFacebookUserInfo-onCompleted graphObject:"+graphObject);
//                            Log.d(TAG,"getFacebookUserInfo-onCompleted graphObjectArray:"+graphObjectArray);
                                Log.d(TAG,"getFacebookUserInfo-onCompleted request.accessToken:"
                                        +request.getAccessToken().getToken());
                                //解析jsonobject封装ThirdPlatformUserInfo
                                /*{
                                    "id": "343007902773655",
                                    "name": "胡克",
                                    "picture": {
                                        "data": {
                                            "height": 50,
                                            "is_silhouette": false,
                                            "url": "https://scontent.xx.fbcdn.net/v/t1.0-1/p50x50/16195821_226931217714658_2923792466498886168_n.jpg?oh=31ee5e2f1deb18806d99cd640dfe482a&oe=5AF9B686",
                                            "width": 50
                                        }
                                    },
                                    "gender": "male",
                                    "locale": "zh_CN"
                                }*/
                                ThirdPlatformUserInfo userInfo = new ThirdPlatformUserInfo();
                                try {
                                    userInfo.id = object.getString("id");
                                    JSONObject pictureObj = object.getJSONObject("picture");
                                    JSONObject pictureDataObj = null;
                                    if(null != pictureObj){
                                        pictureDataObj = pictureObj.getJSONObject("data");
                                    }
                                    if(null != pictureDataObj){
                                        userInfo.picture = pictureDataObj.getString("url");
                                    }
                                    userInfo.name = object.getString("name");
                                    userInfo.token = accessToken.getToken();
                                    userInfo.gender = object.getString("gender");
                                    userInfo.locale = object.getString("locale");
                                    userInfo.email = object.getString("email");

                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                                if(null != facebookSdkLoginCallbackList){
                                    for(FacebookSDKLoginCallback callBack : facebookSdkLoginCallbackList){
                                        callBack.onLogin(OpearResultCode.SUCCESS,"",userInfo);
                                        facebookSdkLoginCallbackList.remove(callBack);
                                    }
                                }
                            }

                        }
                    });
            Bundle parameters = new Bundle();
            //link主页链接,email写了也不一定能拿到
            //user_birthday,需要应用审核通过后才能获取，否则测试阶段会直接抛errorCode:100 -
            // requestStatusCode:400 subErrorCode:-1 errorType:OAuthException
            parameters.putString("fields", "id,name,email,picture,gender,locale");
            request.setParameters(parameters);
            request.executeAsync();
        }
    }

    public FacebookCallback getLoginFacebookCallback(){
        return loginFacebookCallback;
    }

    private AccessToken accessToken = null;

    /**
     * FACEBOOK SDK登录
     * @param context
     */
    public void login(Activity context, FacebookSDKLoginCallback facebookSdkLoginCallback){
        registerLoginCallBack(facebookSdkLoginCallback);
        LoginManager.getInstance().logInWithReadPermissions(context,
                Arrays.asList(new String[]{"public_profile","email","user_birthday"}));
    }

    /**
     * 登出Facebook平台
     */
    public void logout(){
        LoginManager.getInstance().logOut();
    }

    /**
     * 注册登录监听器
     * @param facebookSdkLoginCallback
     * @return
     */
    public boolean registerLoginCallBack(FacebookSDKLoginCallback facebookSdkLoginCallback){
        boolean registerResult = false;
        if(null != facebookSdkLoginCallbackList){
            synchronized (facebookSdkLoginCallbackList){
                for(FacebookSDKLoginCallback callBack : facebookSdkLoginCallbackList){
                    if(callBack == facebookSdkLoginCallback){
                        Log.w(TAG,"registerLoginCallBack-callback registe failed, it has been existed");
                        registerResult = true;
                        break;
                    }
                }
                if(!registerResult){
                    facebookSdkLoginCallbackList.add(facebookSdkLoginCallback);
                    Log.d(TAG,"registerLoginCallBack-callback registe success");
                    registerResult = true;
                }
            }
        }
        return registerResult;
    }

    /**
     * 登录回调
     */
    public interface FacebookSDKLoginCallback {
        /**
         * 登录结果回调
         * @param opearResultCode 登录操作结果码
         * @param message 错误消息
         * @param userInfo
         */
        void onLogin(FacebookSDKManager.OpearResultCode opearResultCode,
                     String message,ThirdPlatformUserInfo userInfo);
    }

    private ShareDialog shareDialog;

    /**
     * 对外分享接口
     * @param activity
     * @param shareType
     * @param shareContentInfo
     * @param facebookSDKShareCallBack
     */
    public void share(Activity activity, ShareType shareType,
                      ShareContentInfo shareContentInfo, FacebookSDKShareCallBack facebookSDKShareCallBack){
        switch (shareType){
            case faceBook:
                share2FaceBook(activity,shareContentInfo, facebookSDKShareCallBack);
                break;
        }
    }

    /**
     * 分享到facebook
     * 考虑到分享过程基本同界面展示绑定，故暂时不写callbase list
     * @param activity
     * @param shareContentInfo
     * @param facebookSDKShareCallBack
     */
    private void share2FaceBook(Activity activity,ShareContentInfo shareContentInfo, final FacebookSDKShareCallBack facebookSDKShareCallBack){
        if(null == shareDialog){
            shareDialog = new ShareDialog(activity);
            shareDialog.registerCallback(callbackManager,new FacebookCallback<Sharer.Result>() {
                @Override
                public void onSuccess(Sharer.Result result) {
                    Log.d(TAG,"onSuccess-postId:"+result.getPostId());
                    if(null != facebookSDKShareCallBack){
                        facebookSDKShareCallBack.onShare(OpearResultCode.SUCCESS,result.getPostId());
                    }
                }

                @Override
                public void onCancel() {
                    Log.d(TAG,"onCancel");
                    if(null != facebookSDKShareCallBack){
                        facebookSDKShareCallBack.onShare(OpearResultCode.CANCEL,"");
                    }
                }

                @Override
                public void onError(FacebookException e) {
                    Log.d(TAG,"onError");
                    e.printStackTrace();
                    if(null != facebookSDKShareCallBack){
                        facebookSDKShareCallBack.onShare(OpearResultCode.FAILED,"");
                    }
                }
            });
        }
        if(null != shareDialog){
            shareDialog.show(genShareContent(shareContentInfo));
        }

    }

    /**
     * 生成分享内容
     * @param shareContentInfo
     * @return
     */
    public ShareContent genShareContent(ShareContentInfo shareContentInfo){
        ShareContent shareContent = null;
        switch (shareContentInfo.shareContentType){
            case Link:
                ShareLinkContent.Builder builder = new ShareLinkContent.Builder();
                builder = builder.setContentUrl(Uri.parse(shareContentInfo.contentUrl));
                if(!TextUtils.isEmpty(shareContentInfo.hashTag)){
                    builder = builder.setShareHashtag(new ShareHashtag.Builder().setHashtag(shareContentInfo.hashTag).build());
                }
                if(!TextUtils.isEmpty(shareContentInfo.quote)){
                    builder = builder.setQuote(shareContentInfo.quote);
                }
                shareContent = builder.build();
                break;
            case Img:
                shareContent = new SharePhotoContent.Builder().addPhoto(
                        new SharePhoto.Builder().setBitmap(shareContentInfo.bitmap).build()).build();
                break;
            case Vedio:
                shareContent = new ShareVideoContent.Builder().setVideo(
                        new ShareVideo.Builder().setLocalUrl(
                                Uri.parse(shareContentInfo.vedioUrl)).build())
                        .build();
                break;
            case Media:
                //......
                break;
            default:
                break;
        }

        return shareContent;
    }

    /**
     * 分享回调
     */
    public interface FacebookSDKShareCallBack {
        void onShare(OpearResultCode opearResultCode, String message);
    }

    /**
     * 操作结果返回码
     */
    public enum OpearResultCode{
        SUCCESS,         //成功
        CANCEL,          //取消
        FAILED           //失败
    }

}
