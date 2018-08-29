package com.qpidnetwork.anchor.liveshow.manager;

import android.hardware.Camera;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;

import com.qpidnetwork.anchor.liveshow.liveroom.LiveRoomTransitionActivity;
import com.qpidnetwork.anchor.utils.Log;

/**
 * 检测camera和AudioRecord可用性
 * Created by Hunter Mun on 2018/3/30.
 */

public class CameraMicroPhoneCheckManager {

    private static final String TAG = CameraMicroPhoneCheckManager.class.getName();

    private static final int STATE_SUCCESS = 0;                 //设备可用
    private static final int STATE_USING = 1;                   //设备使用中
    private static final int STATE_NO_PERMISSION = 2;           //设备缺少权限

    private OnCameraAndRecordAudioCheckListener mOnCameraAndRecordAudioCheckListener;

    public enum CheckPermissionStatus{
        Default,
        Checking,
        CheckSuccess
    }

    private CheckPermissionStatus mCheckPermissionStatus = CheckPermissionStatus.Default;

    public CameraMicroPhoneCheckManager(){

    }

    /**
     * 设置时间监听器
     * @param listener
     */
    public void setOnCameraAndRecordAudioCheckListener(OnCameraAndRecordAudioCheckListener listener){
        mOnCameraAndRecordAudioCheckListener = listener;
    }

    /**
     * 开始检测
     */
    public void checkStart(){
        mCheckPermissionStatus = CheckPermissionStatus.Checking;
        //开线程检测，解决异步卡死问题
        new Thread(new Runnable() {
            @Override
            public void run() {
                Log.i(TAG, "checkStart start");
                if(CheckFrontCameraUsable() == STATE_SUCCESS){
                    Log.i(TAG, "CheckFrontCameraUsable success");
                    if(getRecordState() == STATE_SUCCESS){
                        Log.i(TAG, "getRecordState success");
                        mCheckPermissionStatus = CheckPermissionStatus.CheckSuccess;
                        if(mOnCameraAndRecordAudioCheckListener != null){
                            mOnCameraAndRecordAudioCheckListener.onCheckPermissionSuccess();
                        }
                    }else{
                        Log.i(TAG, "getRecordState permission deny");
                        mCheckPermissionStatus = CheckPermissionStatus.Default;
                        if(mOnCameraAndRecordAudioCheckListener != null){
                            mOnCameraAndRecordAudioCheckListener.onCheckRecordAudioPermissionDeny();
                        }
                    }
                }else{
                    Log.i(TAG, "CheckFrontCameraUsable permission deny");
                    mCheckPermissionStatus = CheckPermissionStatus.Default;
                    if(mOnCameraAndRecordAudioCheckListener != null){
                        mOnCameraAndRecordAudioCheckListener.onCheckCameraPermissionDeny();
                    }
                }
                Log.i(TAG, "checkStart finish");
            }
        }).start();
    }

    /**
     * 获取权限检测状态
     * @return
     */
    public CheckPermissionStatus getCheckPermissionStatus(){
        return mCheckPermissionStatus;
    }

    /**
     * 检测Mircophone RECORD_AUDIO permission是否可用
     * @return
     */
    private int getRecordState() {
        int minBuffer = AudioRecord.getMinBufferSize(44100, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT);
        AudioRecord audioRecord = new AudioRecord(MediaRecorder.AudioSource.DEFAULT, 44100, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT, (minBuffer * 100));
        short[] point = new short[minBuffer];
        int readSize = 0;
        try {
            audioRecord.startRecording();//检测是否可以进入初始化状态
        } catch (Exception e) {
            if (audioRecord != null) {
                audioRecord.release();
                audioRecord = null;
                Log.d("CheckAudioPermission", "无法进入录音初始状态");
            }
            return STATE_NO_PERMISSION;
        }
        if (audioRecord.getRecordingState() != AudioRecord.RECORDSTATE_RECORDING) {
            //6.0以下机型都会返回此状态，故使用时需要判断bulid版本
            //检测是否在录音中
            try {
                if (audioRecord != null) {
                    audioRecord.stop();
                    audioRecord.release();
                    audioRecord = null;
                    Log.d("CheckAudioPermission", "录音机被占用");
                }
            }catch (Exception e){
                e.printStackTrace();
            }
            return STATE_USING;
        } else {
            //检测是否可以获取录音结果

            readSize = audioRecord.read(point, 0, point.length);
            if (readSize <= 0) {
                if (audioRecord != null) {
                    audioRecord.stop();
                    audioRecord.release();
                    audioRecord = null;

                }
                Log.d("CheckAudioPermission", "录音的结果为空");
                return STATE_NO_PERMISSION;

            } else {
                if (audioRecord != null) {
                    audioRecord.stop();
                    audioRecord.release();
                    audioRecord = null;

                }

                return STATE_SUCCESS;
            }
        }
    }

    /**
     * 检测前置摄像头是否可用
     * @return
     */
    private int CheckFrontCameraUsable(){
        boolean isCanUse = false;
        int camIndex = GetFrontCameraIndex();
        if(camIndex != -1){
            try{
                Camera camera = Camera.open(camIndex);
                camera.release();
                camera = null;
                isCanUse = true;
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return isCanUse?STATE_SUCCESS:STATE_NO_PERMISSION;
    }

    /**
     * 获取前置摄像头Index
     * @return
     */
    private int GetFrontCameraIndex(){
        int cameraIndex = -1;
        Camera.CameraInfo cameraInfo = new Camera.CameraInfo();
        int cameraCount = Camera.getNumberOfCameras();
        for(int camIdx = 0; camIdx < cameraCount; camIdx++){
            Camera.getCameraInfo(camIdx, cameraInfo);
            if (cameraInfo.facing == Camera.CameraInfo.CAMERA_FACING_FRONT){
                cameraIndex = camIdx;
                break;
            }
        }
        return cameraIndex;
    }

    public interface OnCameraAndRecordAudioCheckListener{
        //检测权限成功
        public void onCheckPermissionSuccess();
        //Camera权限不可用回调
        public void onCheckCameraPermissionDeny();
        //RecordAudio权限不可用
        public void onCheckRecordAudioPermissionDeny();
    }
}
