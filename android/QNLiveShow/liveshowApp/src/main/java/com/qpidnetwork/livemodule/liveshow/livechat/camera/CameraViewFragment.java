package com.qpidnetwork.livemodule.liveshow.livechat.camera;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.RelativeLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragment;
import com.qpidnetwork.livemodule.liveshow.livechat.LiveChatTalkActivity;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.livemodule.view.MaterialProgressBar;
import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;
import com.qpidnetwork.qnbridgemodule.util.FileProviderUtil;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.view.camera.CameraView;
import com.qpidnetwork.qnbridgemodule.view.camera.PictureHelper;

import java.io.File;

/**
 * 2019/5/6 Hardy
 * <p>
 * 自定义拍照界面
 * <p>
 * 拷贝自 QN 的 com.qpidnetwork.dating.livechat.CameraViewFragment
 */
public class CameraViewFragment extends BaseFragment implements CameraView.PhotoCaptureCallback, CameraView.OnCameraChangedListener {

    private static String KEY_FRAGMENT_HEIGHT = "KEY_FRAGMENT_HEIGHT";

    private RelativeLayout cameraViewHolder;
    private CameraView cameraView;
    private ImageButton sendPhotoButton;
    private ImageButton swapCameraButton;
    private ImageButton expandCameraButton;
    private MaterialProgressBar progressBar;

//	private int fragmentHeight;

    // 2018/12/14 Hardy
    private ImageButton cancelSendImageButton;
    private ImageButton ensureSendImageButton;
    private String mSendFilePath;

    //    public static CameraViewFragment newInstance(int fregamntHeight) {
    public static CameraViewFragment newInstance() {
        CameraViewFragment newInstance = new CameraViewFragment();

//        Bundle args = new Bundle();
//        args.putInt(KEY_FRAGMENT_HEIGHT, fregamntHeight);
//        newInstance.setArguments(args);

        return newInstance;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

//        Bundle bundle = this.getArguments();
//        if (bundle == null || !bundle.containsKey(KEY_FRAGMENT_HEIGHT))
//            throw new NullPointerException("Null argument.");
//		fragmentHeight = bundle.getInt(KEY_FRAGMENT_HEIGHT);

        View view = inflater.inflate(R.layout.fragment_livechat_camera_layout_live, container, false);

        cameraViewHolder = (RelativeLayout) view.findViewById(R.id.cameraViewHolder);
        cameraView = (CameraView) view.findViewById(R.id.cameraView);
        sendPhotoButton = (ImageButton) view.findViewById(R.id.sendButton);
        swapCameraButton = (ImageButton) view.findViewById(R.id.swapCameraButton);
        expandCameraButton = (ImageButton) view.findViewById(R.id.expandCameraButton);
        progressBar = (MaterialProgressBar) view.findViewById(R.id.progressBar);
        // 2018/12/14 Hardy
        cancelSendImageButton = (ImageButton) view.findViewById(R.id.cancelSendImageButton);
        ensureSendImageButton = (ImageButton) view.findViewById(R.id.ensureSendImageButton);
        cancelSendImageButton.setOnClickListener(this);
        ensureSendImageButton.setOnClickListener(this);

        expandCameraButton.setOnClickListener(this);
        swapCameraButton.setOnClickListener(this);
        sendPhotoButton.setOnClickListener(this);
        //del by Jagger 2018-10-29 因在BlackBerry BBB100-4 上显示只有一条很窄的范围(105px),同时布局文件也修改了
//		cameraViewHolder.getLayoutParams().height = fragmentHeight;
        cameraView.setPhotoCaptureCallback(this);
        cameraView.setOnCameraChangedListener(this);

        return view;
    }

    @Override
    public void onPhotoCaptured(byte[] data) {
        processPhoto(data);
    }

    private void processPhoto(byte[] data) {
        if (data == null) {
            // 2018/12/14 Hardy
            resetCameraView();

//            enableButtons();
            return;
        }

        @SuppressLint("StaticFieldLeak")
        AsyncTask<Object, Void, Object> task = new AsyncTask<Object, Void, Object>() {

            @Override
            protected Object doInBackground(Object... params) {
                Bitmap bitmap = (Bitmap) params[0];
                if (bitmap == null)
                    return null;

                float ratio = (float) bitmap.getHeight() / (float) cameraViewHolder.getWidth();
                int heightDifference = bitmap.getWidth() - (int) ((float) cameraViewHolder.getHeight() * ratio);

                Bitmap rotateBitmap = null;
                if (heightDifference > 2) {
                    float offset = (float) heightDifference / 2.0f;
                    Bitmap tempBitmap = Bitmap.createBitmap(bitmap, (int) offset, 0, (int) ((float) cameraViewHolder.getHeight() * ratio), bitmap.getHeight());
                    if (bitmap != null) {
                        bitmap.recycle();
                        bitmap = null;
                    }
//                    rotateBitmap = ImageUtil.createRotatedBitmap(getActivity(), tempBitmap, (cameraView.getCurrentCamera() == cameraView.getFrontCamera()) ? -90 : 90);

                    // 2019/5/22  Hardy
                    rotateBitmap = ImageUtil.createRotatedBitmap(getActivity(), tempBitmap, cameraView.getImageOrientation());

                    tempBitmap.recycle();
                } else {
                    rotateBitmap = bitmap;
                }

                String fileUrl = FileCacheManager.getInstance().getPrivatePhotoTempSavePath() + PictureHelper.getPhotoFileName();
                boolean written = ImageUtil.writeBitmapToFile(rotateBitmap, fileUrl);
                rotateBitmap.recycle();

                return (written) ? fileUrl : null;

            }

            @Override
            protected void onPostExecute(Object fileUrl) {
                super.onPostExecute(fileUrl);
//                enableButtons();
//                if (fileUrl == null) {
//                    return;
//                }
//                if (getActivity() != null) {
//                    ((ChatActivity) getActivity()).sendPrivatePhoto((String) fileUrl);
//                }

                // 2018/12/14 Hardy
                if (fileUrl == null) {
                    resetCameraView();
                    return;
                }
                mSendFilePath = (String) fileUrl;
                progressBar.setVisibility(View.GONE);
                showCaptureView(true);
            }

        };

        Bitmap bitmap = BitmapFactory.decodeByteArray(data, 0, data.length);
        if (Build.VERSION.SDK_INT >= 11) {
            task.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, bitmap);
        } else {
            task.execute(bitmap);
        }
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);

        int id = v.getId();
        if (id == R.id.cancelSendImageButton) { // 重拍
            resetCameraView();

        } else if (id == R.id.ensureSendImageButton) {  // 真正的发送事件
            if (getActivity() != null) {
                // 不需要发送的二次确认
                ((LiveChatTalkActivity) getActivity()).sendPrivatePhotoNoTips(mSendFilePath);
            }
            resetCameraView();

        } else if (id == R.id.sendButton) {
            dissableButtons();
            cameraView.capture();

        } else if (id == R.id.swapCameraButton) {
            cameraView.swapCamera();

        } else if (id == R.id.expandCameraButton) {
            try {
                cameraView.releaseCamera();

                Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
                String takePhotoTempPath = FileCacheManager.getInstance().getPrivatePhotoTempSavePath() + PictureHelper.getPhotoFileName();

                ((LiveChatTalkActivity) getActivity()).setTempPicturePath(takePhotoTempPath);

                //			intent.putExtra(android.provider.MediaStore.EXTRA_OUTPUT, Uri.fromFile(new File(takePhotoTempPath)));
                if (cameraView.getCurrentCamera() != -1) {
                    //this is supposed to set which camera to use (front camera or back camera)
                    //It works only on some devices, not all devices work with this.
                    intent.putExtra("android.intent.extras.CAMERA_FACING", cameraView.getCurrentCamera());
                }
                FileProviderUtil.setIntentData(mContext, intent, new File(takePhotoTempPath), true);

                getActivity().startActivityForResult(intent, LiveChatTalkActivity.RESULT_LOAD_IMAGE_CAPTURE);

            } catch (Exception e) {
                Log.w("info", "-=---------------- expandCameraButton -----------------------");
                e.printStackTrace();
            }
        }
    }

    //===================   2018/12/14 Hardy    ===============================
    private void resetCameraView() {
        showCaptureView(false);
        enableButtons();
    }

    private void showCaptureView(boolean isShow) {
        if (isShow) {
            sendPhotoButton.setVisibility(View.GONE);
            expandCameraButton.setVisibility(View.GONE);
            swapCameraButton.setVisibility(View.GONE);

            cancelSendImageButton.setVisibility(View.VISIBLE);
            ensureSendImageButton.setVisibility(View.VISIBLE);
        } else {
            sendPhotoButton.setVisibility(View.VISIBLE);
            expandCameraButton.setVisibility(View.VISIBLE);
            swapCameraButton.setVisibility(View.VISIBLE);

            cancelSendImageButton.setVisibility(View.GONE);
            ensureSendImageButton.setVisibility(View.GONE);
        }
    }
    //===================   2018/12/14 Hardy    ===============================

    private void enableButtons() {
        cameraView.startCameraPreview();
        this.progressBar.setVisibility(View.GONE);
        this.sendPhotoButton.setEnabled(true);
        this.expandCameraButton.setEnabled(true);
        this.swapCameraButton.setEnabled(true);
    }

    private void dissableButtons() {
        this.progressBar.setVisibility(View.VISIBLE);
        this.sendPhotoButton.setEnabled(false);
        this.expandCameraButton.setEnabled(false);
        this.swapCameraButton.setEnabled(false);
    }

    @Override
    public void onResume() {
        super.onResume();
//        cameraView.reconnectCamera();

        /*
            2019/5/21 Hardy
            解决在黑莓手机上，跳转去系统相机，再返回这里时，
            由于系统的 camera 对象同一时间只能存在一个，但系统相机还没及时释放，则这里获取不到 camera ，导致画面一直黑屏的问题
        */
        cameraView.postDelayed(new Runnable() {
            @Override
            public void run() {
                openCamera();
            }
        },500);

    }

    /**
     * 2018/12/14 Hardy
     * 外层下次调用 replace 添加视图时，会销毁视图，重新加载。故在这里要释放 camera
     */
    @Override
    public void onDestroy() {
        super.onDestroy();
        releaseCamera();
    }

    @Override
    public void onCameraChanged(int cameraIndex) {
        if (cameraIndex == cameraView.getFrontCamera()) {
            swapCameraButton.setImageResource(R.drawable.ic_camera_front_white_24dp);
        }

        if (cameraIndex == cameraView.getBackCamera()) {
            swapCameraButton.setImageResource(R.drawable.ic_camera_rear_white_24dp);
        }
    }

    /**
     * 打开相机
     */
    public void openCamera(){
        if (cameraView != null) {
            cameraView.reconnectCamera();
        }
    }

    /**
     * 释放相机
     */
    public void releaseCamera(){
        if (cameraView != null) {
            cameraView.releaseCamera();
        }
    }
}
