package com.qpidnetwork.livemodule.framework.widget;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebView;

import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;
import com.qpidnetwork.qnbridgemodule.sysPermissions.manager.PermissionManager;
import com.qpidnetwork.qnbridgemodule.util.FileProviderUtil;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.io.File;

/**
 * Description:Webview之H5页面调用android的图库或拍照
 * Android WebView并不支持h5点input type属性
 * https://blog.csdn.net/hvkCoder/article/details/51365191
    // <input type="file" accept="image/*" capture="camera|photo">
    // <input type="file" accept="video/*" capture="camcorder">
    // <input type="file" accept="audio/*" capture="microphone">
     参考:http://teachcourse.cn/2224.html
     http://reezy.me/p/20170515/android-webview/
     https://jiandanxinli.github.io/2016-08-31.html
======================================================
 <input type="file" accept="image/*" capture/><br>
 <input type="file" name="image" accept="image/*"/>

 07-25 15:54:02.560 11395-11395/com.qpidnetwork.dating D/OpenFileWebChromeClient: openFileChooser-acceptType:image/* capture:filesystem
 takeAPicture-isCamera:false
 07-25 15:54:08.710 11395-11395/com.qpidnetwork.dating D/OpenFileWebChromeClient: openFileChooser-acceptType:image/* capture:filesystem
 takeAPicture-isCamera:false
======================================================

 * <p>
 * Created by Harry on 2018/7/24.
 */
public class OpenFileWebChromeClient  extends WebChromeClient {

    private final String TAG = OpenFileWebChromeClient.class.getSimpleName();

    public static final int REQUEST_FILE_PICKER = 1;
    public static final int REQUEST_CAPTURE_PHOTO = 2;
    public ValueCallback<Uri> mFilePathCallback;
    public ValueCallback<Uri[]> mFilePathCallbacks;
    private Activity mContext;
    public OpenFileWebChromeClient(Activity mContext){
        super();
        this.mContext = mContext;
    }
    // Android < 3.0 调用这个方法 api level 11
    public void openFileChooser(ValueCallback<Uri> filePathCallback) {
        mFilePathCallback = filePathCallback;
        takeAPicture("image/*",false);
    }
    //  For 3.0+ Devices (Start) 调用这个方法
    public void openFileChooser(ValueCallback filePathCallback, String acceptType) {
        Log.d(TAG,"openFileChooser-acceptType:"+acceptType);
        mFilePathCallback = filePathCallback;
        takeAPicture(acceptType,false);
    }

    // For Android >= 4.1 调用这个方法
    public void openFileChooser(ValueCallback<Uri> filePathCallback, String acceptType, String capture) {
        Log.d(TAG,"openFileChooser-acceptType:"+acceptType+" capture:"+capture);
        mFilePathCallback = filePathCallback;
        takeAPicture(acceptType,!TextUtils.isEmpty(capture)); //&& capture.equals("camera") 解决红米note白色回调时*
    }

    //  Lollipop 5.0+ 调用这个方法
    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    @Override
    public boolean onShowFileChooser(WebView webView, ValueCallback<Uri[]> filePathCallback,
                                     WebChromeClient.FileChooserParams fileChooserParams) {
        Log.d(TAG,"onShowFileChooser-fileChooserParams:"+fileChooserParams);
        mFilePathCallbacks = filePathCallback;
        if(null != fileChooserParams && null != fileChooserParams.getAcceptTypes() && fileChooserParams.getAcceptTypes().length>0){
            Log.d(TAG,"onShowFileChooser-fileChooserParams.isCaptureEnabled:"+fileChooserParams.isCaptureEnabled());
            takeAPicture("image/*",fileChooserParams.isCaptureEnabled());
        }
        return true;
    }

    private void takeAPicture(final String acceptType, final boolean isCamera) {

        //edit by Jagger 2018-8-21 增加权限检测
        PermissionManager permissionManager = new PermissionManager(mContext, new PermissionManager.PermissionCallback() {
            @Override
            public void onSuccessful() {
                Intent intent = new Intent();
                Log.d(TAG,"takeAPicture-acceptType:"+acceptType+" isCamera:"+isCamera);
                if(isCamera){
                    //调用系统摄像头拍照
                    intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
                    if (intent.resolveActivity(mContext.getPackageManager()) != null) {
                        File file = new File(FileCacheManager.getInstance().GetTempCameraImageUrl());

                        //
                        FileProviderUtil.setIntentData(mContext, intent, file , true);

                        mContext.startActivityForResult(intent, REQUEST_CAPTURE_PHOTO);
                    }
                }else{
                    //默认打开文件管理器
                    FileProviderUtil.setIntentData4SystemAlbum(intent, acceptType);
//                    mContext.startActivityForResult(Intent.createChooser(intent, "File Chooser"), REQUEST_FILE_PICKER);
                    // 2018/11/27 Hardy 去除多个 app 系统选择弹窗
                    mContext.startActivityForResult(intent, REQUEST_FILE_PICKER);
                }
            }
            @Override
            public void onFailure() { }
        });

        permissionManager.requestPhoto();

    }
}
