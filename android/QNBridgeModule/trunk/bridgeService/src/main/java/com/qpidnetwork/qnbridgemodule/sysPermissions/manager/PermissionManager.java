package com.qpidnetwork.qnbridgemodule.sysPermissions.manager;

import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.support.v7.app.AlertDialog;

import com.qpidnetwork.qnbridgemodule.R;
import com.qpidnetwork.qnbridgemodule.sysPermissions.AndPermission;
import com.qpidnetwork.qnbridgemodule.sysPermissions.Permission;
import com.qpidnetwork.qnbridgemodule.sysPermissions.PermissionNo;
import com.qpidnetwork.qnbridgemodule.sysPermissions.PermissionYes;
import com.qpidnetwork.qnbridgemodule.sysPermissions.Rationale;
import com.qpidnetwork.qnbridgemodule.sysPermissions.RationaleListener;

import java.util.List;

/**
 * Created by Jagger on 2017/10/23.
 * 权限管理工具
 * Gradle:targetSdkVersion 23 //权限API要求23+
 */

public class PermissionManager {
    private static final int REQUEST_CODE_PERMISSION = 99;
    public static final int REQUEST_CODE_SYSSETTING = 300;


    private Context mContext;
    private PermissionCallback mCallback;

    public PermissionManager(Context context, PermissionCallback callback) {
        this.mContext = context;
        this.mCallback = callback;
    }

    public void requestBase() {
        AndPermission.with(mContext)
                .requestCode(REQUEST_CODE_PERMISSION)
                .permission(Permission.PHONE , Permission.STORAGE)
                .callback(this)
                // rationale作用是：用户拒绝一次权限，再次申请时先征求用户同意，再打开授权对话框；
                // 这样避免用户勾选不再提示，导致以后无法申请权限。
                // 你也可以不设置。
                .rationale(new RationaleListener() {
                    @Override
                    public void showRequestPermissionRationale(int requestCode, Rationale rationale) {
                        // 这里的对话框可以自定义，只要调用rationale.resume()就可以继续申请。
                        AndPermission.rationaleDialog(mContext, rationale).show();
                    }
                })
                .start();
    }

    public void requestPhoto() {
        AndPermission.with(mContext)
                .requestCode(REQUEST_CODE_PERMISSION)
                .permission(Permission.STORAGE, Permission.CAMERA)
                .callback(this)
                // rationale作用是：用户拒绝一次权限，再次申请时先征求用户同意，再打开授权对话框；
                // 这样避免用户勾选不再提示，导致以后无法申请权限。
                // 你也可以不设置。
                .rationale(new RationaleListener() {
                    @Override
                    public void showRequestPermissionRationale(int requestCode, Rationale rationale) {
                        // 这里的对话框可以自定义，只要调用rationale.resume()就可以继续申请。
                        AndPermission.rationaleDialog(mContext, rationale).show();
                    }
                })
                .start();
    }

    public void requestVideo() {
        AndPermission.with(mContext)
                .requestCode(REQUEST_CODE_PERMISSION)
                .permission(Permission.STORAGE, Permission.AUDIO, Permission.CAMERA)
                .callback(this)
                // rationale作用是：用户拒绝一次权限，再次申请时先征求用户同意，再打开授权对话框；
                // 这样避免用户勾选不再提示，导致以后无法申请权限。
                // 你也可以不设置。
                .rationale(new RationaleListener() {
                    @Override
                    public void showRequestPermissionRationale(int requestCode, Rationale rationale) {
                        // 这里的对话框可以自定义，只要调用rationale.resume()就可以继续申请。
                        AndPermission.rationaleDialog(mContext, rationale).show();
                    }
                })
                .start();
    }

    public void requestAudio() {
        AndPermission.with(mContext)
                .requestCode(REQUEST_CODE_PERMISSION)
                .permission(Permission.STORAGE, Permission.AUDIO)
                .callback(this)
                // rationale作用是：用户拒绝一次权限，再次申请时先征求用户同意，再打开授权对话框；
                // 这样避免用户勾选不再提示，导致以后无法申请权限。
                // 你也可以不设置。
                .rationale(new RationaleListener() {
                    @Override
                    public void showRequestPermissionRationale(int requestCode, Rationale rationale) {
                        // 这里的对话框可以自定义，只要调用rationale.resume()就可以继续申请。
                        AndPermission.rationaleDialog(mContext, rationale).show();
                    }
                })
                .start();
    }

    /**
     * 注:一定要在onActivityResult处理REQUEST_CODE_SYSSETTING事件
     * @return
     */
    public void requestFloatWindow() {
        DialogInterface.OnClickListener clickListener = new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                switch (which) {
                    case DialogInterface.BUTTON_POSITIVE:
                        //启动Activity让用户授权
                        Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:" + mContext.getPackageName()));
                        ((Activity)mContext).startActivityForResult(intent,REQUEST_CODE_SYSSETTING);

                        //一定要在onActivityResult处理REQUEST_CODE_SYSSETTING事件

                        break;
                    case DialogInterface.BUTTON_NEGATIVE:
                        mCallback.onFailure();
                        break;
                }
            }
        };

        if(!AndPermission.hasPermission(mContext , Permission.OVERLAYWINDOW)) {
            AlertDialog.Builder builder = new AlertDialog.Builder(mContext)
                    .setCancelable(false)
                    .setTitle(R.string.permission_title_float_window)
                    .setMessage(R.string.permission_message_float_window)
                    .setPositiveButton(R.string.permission_setting, clickListener)
                    .setNegativeButton(R.string.permission_cancel, clickListener);
            builder.show();
        }else{
            mCallback.onSuccessful();
        }
    }

    @PermissionYes(REQUEST_CODE_PERMISSION)
    public void yes(List<String> permissions) {
        this.mCallback.onSuccessful();
    }

    @PermissionNo(REQUEST_CODE_PERMISSION)
    public void no(List<String> permissions) {
        // 用户否勾选了不再提示并且拒绝了权限，那么提示用户到设置中授权。
        if (AndPermission.hasAlwaysDeniedPermission(mContext, permissions)) {
            AndPermission.defaultSettingDialog((Activity)mContext, REQUEST_CODE_SYSSETTING)
                    .setTitle(R.string.title_dialog)
                    .setMessage(R.string.message_permission_failed)
                    .setPositiveButton(R.string.ok)
                    .setNegativeButton(R.string.no, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            mCallback.onFailure();
                        }
                    })
                    .show();

            // 更多自定dialog，请看上面。
        }else{
            this.mCallback.onFailure();
        }
    }

    public interface PermissionCallback {
        /**
         * 所有权限都允许了，才返回成功
         */
        void onSuccessful();

        /**
         * 只要拒绝其中一个权限就回调失败
         */
        void onFailure();
    }
}
