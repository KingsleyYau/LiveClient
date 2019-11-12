package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.os.Message;
import android.provider.MediaStore;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.View;

import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.LiveDomainRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.item.LSProfileItem;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.view.dialog.UserIconUploadDialog;
import com.qpidnetwork.qnbridgemodule.bean.CommonConstant;
import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;
import com.qpidnetwork.qnbridgemodule.sysPermissions.manager.PermissionManager;
import com.qpidnetwork.qnbridgemodule.util.BroadcastManager;
import com.qpidnetwork.qnbridgemodule.util.CompatUtil;
import com.qpidnetwork.qnbridgemodule.util.FileProviderUtil;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;

import java.io.File;

/**
 * Created by zy2 on 2019/8/13.
 * 用户头像上传的基类
 * ——个人中心
 * ——个人资料编辑
 * ——个人头像大图详情
 */
public abstract class BaseUserIconUploadActivity extends BaseFragmentActivity implements UserIconUploadDialog.OnClickCallback {

    /**
     * 拍照
     */
    private static final int RESULT_LOAD_IMAGE_CAPTURE = 3;
    /**
     * 相册
     */
    private static final int RESULT_LOAD_IMAGE_ALBUMN = 4;
    /**
     * 裁剪图片
     */
    private static final int RESULT_LOAD_IMAGE_CUT = 5;

    private static final int REQUEST_UPDATE_PROFILE_IMAGE_SUCCESS = 21;
    private static final int REQUEST_UPDATE_PROFILE_IMAGE_FAIL = 22;

    protected LSProfileItem lsProfileItem;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (isRegisterGetUserInfoBroadcast()) {
            initGetUserInfoBroadcast();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        if (getUserInfoBroadcast != null) {
            BroadcastManager.unregisterReceiver(mContext, getUserInfoBroadcast);
        }
    }

    private void initGetUserInfoBroadcast() {
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(CommonConstant.ACTION_USER_UPLOAD_PHOTO_SUCCESS_LIVE);
        BroadcastManager.registerReceiver(mContext, getUserInfoBroadcast, intentFilter);
    }

    BroadcastReceiver getUserInfoBroadcast = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent != null && !TextUtils.isEmpty(intent.getAction()) &&
                    CommonConstant.ACTION_USER_UPLOAD_PHOTO_SUCCESS_LIVE.equals(intent.getAction())) {
                onLoadUserInfo();
            }
        }
    };

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        HttpRespObject obj = (HttpRespObject) msg.obj;
        switch (msg.what) {
            case REQUEST_UPDATE_PROFILE_IMAGE_SUCCESS:
                hideProgressDialog();

                // 通知其他监听页面，重新获取个人资料，刷新头像.
                BroadcastManager.sendBroadcast(this, new Intent(CommonConstant.ACTION_USER_UPLOAD_PHOTO_SUCCESS_LIVE));

                // 上传头像成功
                // 重新获取个人信息
                onUploadIconSuccess();
                break;

            case REQUEST_UPDATE_PROFILE_IMAGE_FAIL:
                hideProgressDialog();
                cancelToastImmediately();
                ToastUtil.showToast(mContext, obj.errMsg);
                break;

            default:
                break;
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        switch (requestCode) {
            case RESULT_LOAD_IMAGE_CAPTURE: {
                if (resultCode == RESULT_OK) {
                    File tempCameraImager = new File(FileCacheManager.getInstance().GetTempCameraImageUrl());
                    File tempImager = new File(FileCacheManager.getInstance().GetTempImageUrl());

                    doStartPhotoZoom(
                            FileProviderUtil.getUriForFile(this, tempCameraImager),
                            Uri.fromFile(tempImager));
                }
            }
            break;

            case RESULT_LOAD_IMAGE_ALBUMN: {
                if (resultCode == RESULT_OK && null != data) {
                    Uri selectedImage = data.getData();
                    String picturePath = CompatUtil.getSelectedPhotoPath(this, selectedImage);

                    if (isValidImage(picturePath)) {
                        File pic = new File(picturePath);
                        File picCut = new File(FileCacheManager.getInstance().GetTempImageUrl());

                        doStartPhotoZoom(
                                FileProviderUtil.getUriForFile(this, pic),
                                Uri.fromFile(picCut));
                    }
                }
            }
            break;

            case RESULT_LOAD_IMAGE_CUT: {
                if (resultCode == RESULT_OK) {
                    // 上传头像
                    showProgressDialogNoCheckActivityVisible("Uploading...");

                    LiveDomainRequestOperator.getInstance().UploadUserPhoto(
                            FileCacheManager.getInstance().GetTempImageUrl(),
                            new OnRequestCallback() {
                                @Override
                                public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                                    Message msg = Message.obtain();

                                    HttpRespObject obj = new HttpRespObject(isSuccess, errCode, errMsg, null);
                                    if (isSuccess) {
                                        // 上传头像成功
                                        msg.what = REQUEST_UPDATE_PROFILE_IMAGE_SUCCESS;
                                    } else {
                                        // 上传头像失败
                                        msg.what = REQUEST_UPDATE_PROFILE_IMAGE_FAIL;
                                    }
                                    msg.obj = obj;

                                    sendUiMessage(msg);
                                }
                            });
                }
            }
            break;

            default:
                break;
        }
    }

    @Override
    public void OnFirstButtonClick(View v) {
        File tempFile = new File(FileCacheManager.getInstance().GetTempCameraImageUrl());

        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        //7。0＋拍照图片存取兼容 使用：FileProvider.getUriForFile
        FileProviderUtil.setIntentData(mContext, intent, tempFile, true);
        startActivityForResult(intent, RESULT_LOAD_IMAGE_CAPTURE);
    }

    @Override
    public void OnSecondButtonClick(View v) {
        Intent intent = new Intent();
        FileProviderUtil.setIntentData4SystemAlbum(intent, "");
        startActivityForResult(intent, RESULT_LOAD_IMAGE_ALBUMN);
    }

    @Override
    public void OnCancelButtonClick(View v) {
        // 2019/8/13 没事做
    }

    /**
     * 裁剪图片方法实现
     */
    protected void doStartPhotoZoom(Uri src, Uri dest) {
        Intent intent = new Intent("com.android.camera.action.CROP");
        // 给目标应用一个临时授权
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION
                | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
        intent.setDataAndType(src, "image/*");
        // 下面这个crop=true是设置在开启的Intent中设置显示的VIEW可裁剪
        intent.putExtra("crop", "true");

        // aspectX aspectY 是宽高(x y方向上)的比例，其小于1的时候可以操作截图框,若不设定，则可以任意宽度和高度
        intent.putExtra("aspectX", 1);
        intent.putExtra("aspectY", 1);
        intent.putExtra("scale", true);

        intent.putExtra("output", dest);// 指定裁剪后的图片存储路径
        intent.putExtra("outputX", 600);// outputX outputY裁剪保存的宽高(使各手机截取的图片质量一致)
        intent.putExtra("outputY", 600);

        intent.putExtra("noFaceDetection", true);// 取消人脸识别功能(系统的裁剪图片默认对图片进行人脸识别,当识别到有人脸时，会按aspectX和aspectY为1来处理)
        intent.putExtra("return-data", false);// 将相应的数据与URI关联起来，返回裁剪后的图片URI,true返回bitmap
        intent.putExtra("outputFormat", Bitmap.CompressFormat.JPEG.toString());
        startActivityForResult(intent, RESULT_LOAD_IMAGE_CUT);
    }

    public void setLsProfileItem(LSProfileItem lsProfileItem) {
        this.lsProfileItem = lsProfileItem;
    }

    protected void showIconUploadDialog() {
        //先进行权限检测
        PermissionManager permissionManager = new PermissionManager(mContext, new PermissionManager.PermissionCallback() {
            @Override
            public void onSuccessful() {
                UserIconUploadDialog dialog = new UserIconUploadDialog(mContext, BaseUserIconUploadActivity.this);
                dialog.show();
            }

            @Override
            public void onFailure() {
            }
        });

        permissionManager.requestPhoto();
    }

    protected void openIconAct() {
        // TODO: 2019/8/13
        if (lsProfileItem == null || !lsProfileItem.showPhoto()) {
            // 显示默认图，所以点击无响应

        } else {
            // 跳转去头像详情
            MyProfilePhotoActivity.startAct(mContext, lsProfileItem.photoURL);
        }
    }

    protected boolean isValidImage(String imagePath) {
        if (TextUtils.isEmpty(imagePath)) {
            return false;
        }

        String lowCasePath = imagePath.toLowerCase();
        if (lowCasePath.endsWith(".jpg") || lowCasePath.endsWith(".jpeg")) {
            return true;
        }

        ToastUtil.showToast(mContext, "Upload failed. Your photo should be in JPEG format.");

        return false;
    }

    /**
     * 上传头像图片成功
     */
    protected abstract void onUploadIconSuccess();

    /**
     * 获取用户资料
     */
    protected abstract void onLoadUserInfo();

    /**
     * 是否注册获取用户资料的广播
     *
     * @return
     */
    protected abstract boolean isRegisterGetUserInfoBroadcast();
}
