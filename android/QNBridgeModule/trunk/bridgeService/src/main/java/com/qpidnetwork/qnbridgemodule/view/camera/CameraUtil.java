package com.qpidnetwork.qnbridgemodule.view.camera;

import android.app.Activity;
import android.hardware.Camera;
import android.os.Build;
import android.view.Surface;

/**
 * Created by Hardy on 2019/5/22.
 * https://blog.csdn.net/figo0423/article/details/52699979
 * 相机工具类
 */
public class CameraUtil {

    private CameraUtil() {

    }

    /**
     * 获取相机方向
     *
     * @param activity
     * @param cameraId
     * @return
     */
    //If you want to make the camera image show in the same orientation as the display, you can use the following code.
    public static int getCameraDisplayOrientation(Activity activity, int cameraId) {
        int result = 90;    // 后置摄像头，默认是 90

        try {
            android.hardware.Camera.CameraInfo info = new android.hardware.Camera.CameraInfo();
            android.hardware.Camera.getCameraInfo(cameraId, info);

            int rotation = activity.getWindowManager().getDefaultDisplay().getRotation();
            int degrees = 0;
            switch (rotation) {
                case Surface.ROTATION_0:
                    degrees = 0;
                    break;
                case Surface.ROTATION_90:
                    degrees = 90;
                    break;
                case Surface.ROTATION_180:
                    degrees = 180;
                    break;
                case Surface.ROTATION_270:
                    degrees = 270;
                    break;
            }

            if (info.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
                result = (info.orientation + degrees) % 360;
                result = (360 - result) % 360;  // compensate the mirror
            } else {  // back-facing
                result = (info.orientation - degrees + 360) % 360;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return result;
    }


    public static int getSdkVersion() {
        return android.os.Build.VERSION.SDK_INT;
    }

    private static boolean checkCameraFacing(final int facing) {
        if (getSdkVersion() < Build.VERSION_CODES.GINGERBREAD) {
            return false;
        }
        final int cameraCount = Camera.getNumberOfCameras();
        Camera.CameraInfo info = new Camera.CameraInfo();
        for (int i = 0; i < cameraCount; i++) {
            Camera.getCameraInfo(i, info);
            if (facing == info.facing) {
                return true;
            }
        }
        return false;
    }

    /** 
      * 检查设备是否有摄像头 
      * @return true,有相机；false,无相机
      */
    public static boolean hasCamera() {
        return hasBackFacingCamera() || hasFrontFacingCamera();
    }

    /**
     * 检查设备是否有后置摄像头 
      * @return true,有后置摄像头；false,后置摄像头
      */
    public static boolean hasBackFacingCamera() {
        final int CAMERA_FACING_BACK = 0;
        return checkCameraFacing(CAMERA_FACING_BACK);
    }

    /**
     * 检查设备是否有前置摄像头 
      * @return true,有前置摄像头；false,前置摄像头
      */
    public static boolean hasFrontFacingCamera() {
        final int CAMERA_FACING_BACK = 1;
        return checkCameraFacing(CAMERA_FACING_BACK);
    }

    /**
      * 判断相机是否可用
      * @return true,相机驱动可用，false,相机驱动不可用
      */
    public static boolean isCameraCanUse() {
        boolean canUse = true;
        Camera mCamera = null;
        try {
            mCamera = Camera.open();
        } catch (Exception e) {
            canUse = false;
        }
        if (canUse) {
            mCamera.release();
            mCamera = null;
        }
        return canUse;
    }

    /**
     * 是否所有摄像头都可用
     * @return
     */
    public static boolean isAllCameraCanUse() {
        boolean canUse = true;
        Camera mCamera = null;
        for(int i = 0 ; i < Camera.getNumberOfCameras(); i ++) {
            try {
                mCamera = Camera.open(i);
            } catch (Exception e) {
                canUse = false;
            }finally {
                if(mCamera != null){
                    mCamera.release();
                }
                mCamera = null;
            }

            if (!canUse) {
                break;
            }

//            if (canUse) {
//                mCamera.release();
//                mCamera = null;
//            }else {
//                break;
//            }
        }
        return canUse;
    }
}
