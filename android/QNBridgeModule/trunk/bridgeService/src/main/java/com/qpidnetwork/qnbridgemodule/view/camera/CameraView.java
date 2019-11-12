/**
 * Author: Martin Shum
 * This is the camera view which used below api 21.
 */

package com.qpidnetwork.qnbridgemodule.view.camera;

import android.app.Activity;
import android.content.Context;
import android.graphics.Point;
import android.hardware.Camera;
import android.hardware.Camera.PictureCallback;
import android.hardware.Camera.Size;
import android.os.Build;
import android.util.AttributeSet;
import android.view.SurfaceHolder;
import android.view.SurfaceView;

import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.List;

public class CameraView extends SurfaceView implements SurfaceHolder.Callback, PictureCallback {

    private static final String TAG = "CameraView";

    private Camera camera;
    private List<Size> supportedPreviewSizes;
    private Size optimalPreviewSize;
    private int viewHeight = 0;

    //private String capturedFileUrl;
    private PhotoCaptureCallback photoCaptureCallback;
    private OnCameraChangedListener onCameraChangedListener;

    private Point screenSize;
    private int frontCamera = -1;
    private int backCamera = -1;
    private static int currentCamera = -1;

    // 2019/4/23 Hardy
    private Size pictureSize;       // 后置摄像头的输出图片大小
    private Size frontPictureSize;  // 前置摄像头的输出图片大小

    // 2019/5/22 Hardy  相机的旋转方向
    private static final int DISPLAY_ORIENTATION_FAILED = -1;
    private int mBackDisplayOrientation = DISPLAY_ORIENTATION_FAILED;
    private int mFrontDisplayOrientation = DISPLAY_ORIENTATION_FAILED;


    public static interface OnCameraChangedListener {
        public void onCameraChanged(int cameraIndex);
    }

    public static interface PhotoCaptureCallback {
        public void onPhotoCaptured(byte[] data);
    }

    public CameraView(Context context) {
        this(context, null);
    }

    public CameraView(Context context, AttributeSet attrs) {
        super(context, attrs);
        screenSize = new Point();

//        screenSize.x = SystemUtil.getDisplayMetrics(this.getContext()).widthPixels;
//        screenSize.y = SystemUtil.getDisplayMetrics(this.getContext()).heightPixels;
        // 2019/5/6 Hardy
//        DisplayMetrics dm = new DisplayMetrics();
//        WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
//        if (wm != null && wm.getDefaultDisplay() != null) {
//            wm.getDefaultDisplay().getMetrics(dm);
//        }
        screenSize.x = DisplayUtil.getScreenWidth(context);
        screenSize.y = DisplayUtil.getScreenHeight(context);

        this.getKeepScreenOn();
        this.getHolder().addCallback(this);

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.HONEYCOMB)
            this.getHolder().setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);

        assignCamera();
        currentCamera = backCamera;

        try {
            if (currentCamera == -1) {
                camera = Camera.open();
            } else {
                camera = Camera.open(currentCamera);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        calculateOptimalPreviewSize();

    }

    public void setPhotoCaptureCallback(PhotoCaptureCallback photoCaptureCallback) {
        this.photoCaptureCallback = photoCaptureCallback;
    }

    public void setOnCameraChangedListener(OnCameraChangedListener onCameraChangedListener) {
        this.onCameraChangedListener = onCameraChangedListener;
    }

    public int getCurrentCamera() {
        return currentCamera;
    }

    public int getBackCamera() {
        return backCamera;
    }

    public int getFrontCamera() {
        return frontCamera;
    }

    private void setCamera(int cameraIndex) {
        if (cameraIndex == -1 ||
                (cameraIndex != backCamera &&
                        cameraIndex != frontCamera)) return;
        currentCamera = cameraIndex;
        releaseCamera();
        reconnectCamera();

        if (onCameraChangedListener != null) onCameraChangedListener.onCameraChanged(currentCamera);

    }

    public void swapCamera() {
        if (currentCamera == backCamera) {
            setCamera(frontCamera);
        } else {
            setCamera(backCamera);
        }
    }


    public void startCameraPreview() {

        if (camera == null) return;

        Camera.Parameters param = camera.getParameters();
        param.setPreviewFrameRate(20);

        List<Integer> supportPreviewFrameRates = param.getSupportedPreviewFrameRates();
        if (supportPreviewFrameRates != null)
            param.setPreviewFrameRate(supportPreviewFrameRates.get(supportPreviewFrameRates.size() - 1));

        if (param.getSupportedFocusModes().size() != 0) {
            for (int i = 0; i < param.getSupportedFocusModes().size(); i++) {
                if (param.getSupportedFocusModes().get(i).equals(Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE)) {
                    param.setFocusMode(Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE);
                }
            }
        }

        param.setPreviewSize(optimalPreviewSize.width, optimalPreviewSize.height);

        // 2019/4/22 Hardy	设置图片宽高大小，避免在某些机器上，拍照出来的宽高大小是最小的，导致图片小并且模糊的不好体验
        List<Size> list = param.getSupportedPictureSizes();
        Size curSize = null;
        // 需要区分前/后置摄像头
        if (currentCamera == backCamera) {
            if (pictureSize == null) {
                pictureSize = getCurPictureSize(list);
            }
            curSize = pictureSize;

        } else {
            if (frontPictureSize == null) {
                frontPictureSize = getCurPictureSize(list);
            }
            curSize = frontPictureSize;
        }

        if (curSize != null) {
            param.setPictureSize(curSize.width, curSize.height);
        }


        try {
//            camera.setDisplayOrientation(90);
            // 2019/5/22 Hardy
            // 解决华为 6p 前置摄像头上下翻转的问题
            setCameraDisplayOrientation(currentCamera, camera);

            camera.setParameters(param);
            camera.setPreviewDisplay(getHolder());
            camera.startPreview();
        } catch (Exception e) {
            Log.v("error", e.toString());
            e.printStackTrace();
        }
    }

    /**
     * 获取照片的输出大小
     *
     * @param list
     * @return
     */
    private Size getCurPictureSize(List<Size> list) {
        // 获取需求自定义的宽高比例
        Size pictureSize = CameraSizeUtil.getInstance().getPictureSizeForSpecifiedPx(list, 1920);

        // 如果没有，则获取自定义的宽高比例
        if (pictureSize == null) {
            pictureSize = CameraSizeUtil.getInstance().getPictureSize(list, 800);
        }

        return pictureSize;
    }

    public void capture() {
        try {
            camera.takePicture(null, null, this);
        } catch (Exception e) {
            e.printStackTrace();

            if (photoCaptureCallback != null) photoCaptureCallback.onPhotoCaptured(null);
        }
    }

    public void reconnectCamera() {
        Log.i("info", "-------------- reconnectCamera -----------------------");
        try {
            if (currentCamera == -1) {
                camera = Camera.open();
            } else {
                camera = Camera.open(currentCamera);
            }

            calculateOptimalPreviewSize();
            startCameraPreview();
            this.setKeepScreenOn(false);
        } catch (Exception e) {
            e.printStackTrace();
            Log.v("exception", e.toString());
        }
    }

    public void releaseCamera() {
        if (camera == null) return;

        Log.i("info", "-------------- releaseCamera -----------------------");

        try {
            camera.stopPreview();
            camera.release();

            camera = null;
        } catch (Exception e) {
            Log.w("info", "-=---------------- releaseCamera -----------------------");
            e.printStackTrace();
        }

        this.setKeepScreenOn(false);
    }

    private void calculateOptimalPreviewSize() {
        if (camera != null) {
            supportedPreviewSizes = camera.getParameters().getSupportedPreviewSizes();
            optimalPreviewSize = getOptimalPreviewSize(supportedPreviewSizes, 600, 600);
            float sizePercentage = (float) screenSize.x / (float) optimalPreviewSize.height;
            viewHeight = (int) ((float) optimalPreviewSize.width * sizePercentage);
        }

        this.invalidate();
    }

    private void assignCamera() {
        Camera.CameraInfo cameraInfo = new Camera.CameraInfo();
        for (int i = 0; i < Camera.getNumberOfCameras(); i++) {
            Camera.getCameraInfo(i, cameraInfo);
            if (cameraInfo.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
                frontCamera = i;
            }

            if (cameraInfo.facing == Camera.CameraInfo.CAMERA_FACING_BACK) {
                backCamera = i;
            }
        }
    }

    @Override
    public void onPictureTaken(byte[] data, Camera camera) {
        if (photoCaptureCallback != null) photoCaptureCallback.onPhotoCaptured(data);
        //camera.startPreview();
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {

    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        Log.i("info", "----------surfaceCreated");
        try {
            startCameraPreview();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        Log.i("info", "----------surfaceDestroyed");
        releaseCamera();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        this.setMeasuredDimension(screenSize.x, viewHeight);
    }


    private Camera.Size getOptimalPreviewSize(List<Camera.Size> sizes, int w, int h) {
        final double ASPECT_TOLERANCE = 0.1;
        double targetRatio = (double) h / w;

        if (sizes == null) return null;

        Camera.Size optimalSize = null;
        double minDiff = Double.MAX_VALUE;

        int targetHeight = h;

        for (Camera.Size size : sizes) {
            double ratio = (double) size.width / size.height;
            if (Math.abs(ratio - targetRatio) > ASPECT_TOLERANCE) continue;
            if (Math.abs(size.height - targetHeight) < minDiff) {
                optimalSize = size;
                minDiff = Math.abs(size.height - targetHeight);
            }
        }

        if (optimalSize == null) {
            minDiff = Double.MAX_VALUE;
            for (Camera.Size size : sizes) {
                if (Math.abs(size.height - targetHeight) < minDiff) {
                    optimalSize = size;
                    minDiff = Math.abs(size.height - targetHeight);
                }
            }
        }
        return optimalSize;
    }


    //===============   2019/05/22  Hardy   解决摄像头翻转问题=========================================
    private void setCameraDisplayOrientation(int cameraId, android.hardware.Camera camera) {
        int result;

        if (cameraId == backCamera) {
            if (mBackDisplayOrientation == DISPLAY_ORIENTATION_FAILED) {
                mBackDisplayOrientation = CameraUtil.getCameraDisplayOrientation(((Activity) getContext()), cameraId);
            }

            result = mBackDisplayOrientation;
        } else {
            if (mFrontDisplayOrientation == DISPLAY_ORIENTATION_FAILED) {
                mFrontDisplayOrientation = CameraUtil.getCameraDisplayOrientation(((Activity) getContext()), cameraId);
            }

            result = mFrontDisplayOrientation;
        }

        camera.setDisplayOrientation(result);
    }

    public int getImageOrientation() {
        int result;

        if (currentCamera == backCamera) {
            if (mBackDisplayOrientation == DISPLAY_ORIENTATION_FAILED) {
                mBackDisplayOrientation = CameraUtil.getCameraDisplayOrientation(((Activity) getContext()), currentCamera);
            }

            result = mBackDisplayOrientation;
        } else {
            if (mFrontDisplayOrientation == DISPLAY_ORIENTATION_FAILED) {
                mFrontDisplayOrientation = CameraUtil.getCameraDisplayOrientation(((Activity) getContext()), currentCamera);
            }

            result = -mFrontDisplayOrientation;     // 前置摄像头，为负数
        }

        return result;
    }
    //===============   2019/05/22  Hardy   解决摄像头翻转问题=========================================


}
