package com.qpidnetwork.livemodule.utils;

import android.app.Activity;
import android.content.ContentValues;
import android.content.Intent;
import android.net.Uri;
import android.provider.MediaStore;
import android.support.v4.app.Fragment;

import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;

import java.io.File;
import java.io.IOException;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/6/1.
 */

public class ActivityUtil {

    /**
     * 调用系统选择照片的意图
     */
    public static void chooseImage(Activity activity, int reqCode, boolean isClip){
        Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
        activity.startActivityForResult(intent,reqCode);
    }

    /**
     * 调用系统选择照片的意图
     */
    public static void chooseImage(Fragment fragment, int reqCode){
        Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
        fragment.startActivityForResult(intent,reqCode);
    }

    /**
     * 调用系统选择照片的意图
     */
    public static void chooseImage(Activity activity, int reqCode){
//        Intent intent = new Intent(Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT ? Intent.ACTION_PICK : Intent.ACTION_GET_CONTENT, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
        Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
        //如果直接写intent.setDataAndType("image/*");那么调用的就是系统图库
        intent.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*");
        activity.startActivityForResult(intent,reqCode);
    }


    /**
     * 调用系统选择图片的意图
     * 该方式获取的Uri传递给cropImage，会出现系统提示无法加载图片的情况
     * @param fragment
     * @param reqCode
     */
    public static void chooseImage(Fragment fragment, int reqCode, String desc){
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT,null);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("image/*");
        fragment.startActivityForResult(Intent.createChooser(intent, desc),reqCode);
    }

    /**
     * 调用系统裁剪图片的意图
     * 参考http://www.2cto.com/kf/201410/347861.html
     * @param fragment
     * @param reqCode
     * @param inputUri
     * @param crop 是否裁剪
     * @param scale 是否去黑边
     * @param scaleUpIfNeeded 去黑边
     * @param aspectX 宽比例
     * @param aspectY 高比例
     * @param outputX 输出X方向的比例
     * @param outputY 输出Y方向的比例
     * @param outputFormat
     * @param noFaceDetection
     * @param isReturnData
     */
    public static void cropImage(Fragment fragment, int reqCode,
                                 Uri inputUri,Uri outputUri, boolean crop,boolean scale,boolean scaleUpIfNeeded
                                ,int aspectX, int aspectY, int outputX, int outputY, String outputFormat
                                ,boolean noFaceDetection,boolean isReturnData){

        Intent intent = new Intent("com.android.camera.action.CROP");
//        if(Build.VERSION.SDK_INT <= Build.VERSION_CODES.KITKAT){
//
//        }
        intent.setDataAndType(inputUri, "image/*");
        // 下面这个crop=true是设置在开启的Intent中设置显示的VIEW可裁剪
        intent.putExtra("crop", String.valueOf(crop));
        intent.putExtra("scale", true);// 去黑边
        intent.putExtra("scaleUpIfNeeded", true);// 去黑边
        // aspectX aspectY 是宽高的比例
        intent.putExtra("aspectX", aspectX);//输出是X方向的比例
        intent.putExtra("aspectY", aspectY);
        intent.putExtra("outputX", outputX);//输出X方向的像素
        intent.putExtra("outputY", outputY);
        intent.putExtra("outputFormat", outputFormat);
        intent.putExtra("noFaceDetection", noFaceDetection);
        if(null != outputUri){
            intent.putExtra(MediaStore.EXTRA_OUTPUT, outputUri);
        }
        //Return the bitmap with Action=inline-data by using the data
        intent.putExtra("return-data", isReturnData);
        fragment.startActivityForResult(intent,reqCode);
    }

    /**
     * 调用系统裁剪图片的意图
     * @param Activity
     * @param reqCode
     * @param inputUri
     * @param crop 是否裁剪
     * @param scale 是否去黑边
     * @param scaleUpIfNeeded 去黑边
     * @param aspectX 宽比例
     * @param aspectY 高比例
     * @param outputX 输出X方向的比例
     * @param outputY 输出Y方向的比例
     * @param outputFormat
     * @param noFaceDetection
     * @param isReturnData
     */
    public static void cropImage(Activity Activity, int reqCode,
                                 Uri inputUri, Uri outputUri, boolean crop, boolean scale, boolean scaleUpIfNeeded
            , int aspectX, int aspectY, int outputX, int outputY, String outputFormat
            , boolean noFaceDetection, boolean isReturnData){
        Log.d(TAG,"cropImage-inputUri:"+inputUri+" outputUri:"+outputUri+" outputFormat:"+outputFormat);
        Intent intent = new Intent("com.android.camera.action.CROP");
        intent.setDataAndType(inputUri, "image/*");
        // 下面这个crop=true是设置在开启的Intent中设置显示的VIEW可裁剪
        intent.putExtra("crop", String.valueOf(crop));
        intent.putExtra("scale", true);// 去黑边
        intent.putExtra("scaleUpIfNeeded", true);// 去黑边
        // aspectX aspectY 是宽高的比例
        intent.putExtra("aspectX", aspectX);//输出是X方向的比例
        intent.putExtra("aspectY", aspectY);
        intent.putExtra("outputX", outputX);//输出X方向的像素
        intent.putExtra("outputY", outputY);
        intent.putExtra("outputFormat", outputFormat);
        intent.putExtra("noFaceDetection", noFaceDetection);
        if(null != outputUri){
            intent.putExtra(MediaStore.EXTRA_OUTPUT, outputUri);
        }
        //Return the bitmap with Action=inline-data by using the data
        intent.putExtra("return-data", isReturnData);
        Activity.startActivityForResult(intent,reqCode);
    }

    /**
     * 相机拍照
     * @param baseActivity
     * @param reqCode
     * @return
     */
    public static String startSystemCameraByContentUri(Activity baseActivity, int reqCode){
        ContentValues values = new ContentValues(1);
        values.put(MediaStore.Images.Media.MIME_TYPE, "image/jpg");
        Uri mCameraTempUri = baseActivity.getContentResolver()
                .insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
        android.util.Log.d(TAG,"startSystemCameraByFileUri-reqCode:"+reqCode+" mCameraTempUri:"+mCameraTempUri);
        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        intent.putExtra(MediaStore.EXTRA_OUTPUT, mCameraTempUri);
        baseActivity.startActivityForResult(intent, reqCode);
        String imagePath = ImageUtil.getFilePathFromUri(baseActivity,mCameraTempUri);
        android.util.Log.d(TAG,"startSystemCameraByFileUri-imagePath:"+imagePath);
        return imagePath;
    }

    /**
     * 相机拍照,较新的Android系统上有bug
     */
    public static String startSystemCameraByFileUri(Activity baseActivity, int reqCode){
        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        String imagePath = FileCacheManager.getInstance().getImagePath()+System.currentTimeMillis()+".jpg";
        File imageFile = new File(imagePath);
        //unrecognized token: "1434047218471.jpg" (code 1): , while compiling: SELECT * FROM images WHERE (_display_name=1434047218471.jpg)
        if(!imageFile.exists()){
            try {
                imageFile.createNewFile();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        //file:// Uri exposed through ClipData.Item.getUri()
        Uri fileUri = Uri.fromFile(imageFile);
        android.util.Log.d(TAG,"startSystemCameraByContentUri-reqCode:"+reqCode+" imagePath:"+imagePath);
        intent.putExtra(MediaStore.EXTRA_OUTPUT, fileUri);
        baseActivity.startActivityForResult(intent, reqCode);
        return imagePath;
    }

    public static final String TAG = ActivityUtil.class.getSimpleName();
}
