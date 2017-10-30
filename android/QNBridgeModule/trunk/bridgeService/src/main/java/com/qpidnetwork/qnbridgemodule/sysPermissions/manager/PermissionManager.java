package com.qpidnetwork.qnbridgemodule.sysPermissions.manager;

import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.util.Log;

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
                .permission(Permission.PHONE, Permission.STORAGE)
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
        void onSuccessful();

        void onFailure();
    }
}
