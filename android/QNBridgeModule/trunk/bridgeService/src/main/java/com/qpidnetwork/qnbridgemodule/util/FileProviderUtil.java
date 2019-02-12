package com.qpidnetwork.qnbridgemodule.util;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Build;
import android.provider.MediaStore;
import android.support.v4.content.FileProvider;
import android.text.TextUtils;

import java.io.File;
import java.util.List;

/**
 * 拍照取照片路径
 * https://github.com/hongyangAndroid/FitAndroid7
 */
public class FileProviderUtil {

    public static Uri getUriForFile(Context context, File file) {
        Uri fileUri = null;
        if (Build.VERSION.SDK_INT >= 24) {
            fileUri = getUriForFile24(context, file);
        } else {
            fileUri = Uri.fromFile(file);
        }
        return fileUri;
    }

    private static Uri getUriForFile24(Context context, File file) {
        Uri fileUri = android.support.v4.content.FileProvider.getUriForFile(context,
                context.getPackageName() + ".provider",         //与Manifest.xml里的provider相同
                file);
        return fileUri;
    }

    public static void setIntentDataAndType(Context context,
                                            Intent intent,
                                            String type,
                                            File file,
                                            boolean writeAble) {
        if (Build.VERSION.SDK_INT >= 24) {
            intent.setDataAndType(getUriForFile(context, file), type);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            if (writeAble) {
                intent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
            }
        } else {
            intent.setDataAndType(Uri.fromFile(file), type);
        }
    }

    public static void setIntentData(Context context,
                                     Intent intent,
                                     File file,
                                     boolean writeAble) {
        if (Build.VERSION.SDK_INT >= 24) {
//            intent.setData(getUriForFile(context, file));
            intent.putExtra(
                    MediaStore.EXTRA_OUTPUT,
                    getUriForFile(context, file)
            );
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            if (writeAble) {
                intent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
            }
        } else {
//            intent.setData(Uri.fromFile(file));
            intent.putExtra(
                    MediaStore.EXTRA_OUTPUT,
                    Uri.fromFile(file)
            );
        }
    }

    public static void grantPermissions(Context context, Intent intent, Uri uri, boolean writeAble) {

        int flag = Intent.FLAG_GRANT_READ_URI_PERMISSION;
        if (writeAble) {
            flag |= Intent.FLAG_GRANT_WRITE_URI_PERMISSION;
        }
        intent.addFlags(flag);
        List<ResolveInfo> resInfoList = context.getPackageManager()
                .queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY);
        for (ResolveInfo resolveInfo : resInfoList) {
            String packageName = resolveInfo.activityInfo.packageName;
            context.grantUriPermission(packageName, uri, flag);
        }
    }

    /**
     * 系统相册intent组装
     * @param intent
     * @param htmlAcceptType
     */
    public static void setIntentData4SystemAlbum(Intent intent, String htmlAcceptType){
        try {
            intent.setType("image/*");
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
                intent.setAction(Intent.ACTION_OPEN_DOCUMENT);
            }else{
                intent.setAction(Intent.ACTION_GET_CONTENT);
            }
        } catch (Exception e) {
            intent.setType("image/*");
            intent.setAction(Intent.ACTION_GET_CONTENT);
        }
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType(!TextUtils.isEmpty(htmlAcceptType) ? htmlAcceptType : "image/*");
    }
}
