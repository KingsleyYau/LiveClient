package net.qdating.publisher;

import java.io.IOException;
import java.util.List;

import android.graphics.ImageFormat;
import android.graphics.PixelFormat;
import android.hardware.Camera;
import android.hardware.Camera.CameraInfo;
import android.hardware.Camera.PreviewCallback;
import android.hardware.Camera.Size;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import android.view.SurfaceView;
import net.qdating.LSConfig;
import net.qdating.utils.Log;

public class LSVideoCapture implements PreviewCallback, Callback {
	private SurfaceHolder surfaceHolder;
	private Camera mCamera;
	private ILSVideoCaptureCallback captureCallback;
	
	public LSVideoCapture() {

	}
	
	public boolean init(SurfaceHolder holder, ILSVideoCaptureCallback callback) {
		Log.i(LSConfig.TAG, String.format("LSVideoCapture::init()"));
		
		boolean bFlag = false;
		
		surfaceHolder = holder;
		surfaceHolder.setKeepScreenOn(true);
		surfaceHolder.setFormat(PixelFormat.TRANSPARENT);
		surfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
		surfaceHolder.addCallback(this);
		
		captureCallback = callback;
		
		bFlag = initCapture();
		
		Log.i(LSConfig.TAG, String.format("LSVideoCapture::init( [%s] )", bFlag?"Success":"Fail"));
		
		return bFlag;
	}
	
	public void uninit() {
		Log.i(LSConfig.TAG, String.format("LSVideoCapture::uninit()"));
		
		stop();
		
		if( mCamera != null ) {
			mCamera.setPreviewCallbackWithBuffer(null);
			mCamera.release();
			mCamera = null;
		}
		
		if( surfaceHolder != null ) {
			surfaceHolder.removeCallback(this);
		}

	}
	
	public boolean start() {
		Log.i(LSConfig.TAG, String.format("LSVideoCapture::start()"));
		
		boolean bFlag = true;
		
		if( mCamera != null ) {
			// 开启预览
			mCamera.startPreview();
			bFlag = true;
		}
		
		return bFlag;
	}
	
	public void stop() {
		Log.i(LSConfig.TAG, String.format("LSVideoCapture::stop()"));
		
		if( mCamera != null ) {
			// 停止预览
			mCamera.stopPreview();
		}
	}
	
	private boolean initCapture() {
		Log.i(LSConfig.TAG, String.format("LSVideoCapture::initCapture()"));
		
		boolean bFlag = false;
		
		if( mCamera == null ) {
			int cameraIndex = getCamera(true);
			if( cameraIndex != -1 ) {
				// 打开摄像头
				mCamera = Camera.open(cameraIndex);
				
				// 获取采集参数
				Camera.Parameters parameters = mCamera.getParameters();
				
				// 设置采集的格式
				parameters.setPreviewFormat(ImageFormat.NV21);
				// 设置采集分辨率
				Size bestSize = getBestSuppportPreviewSize(mCamera);
				parameters.setPreviewSize(bestSize.width, bestSize.height);
				// 设置采集帧率
				parameters.setPreviewFrameRate(getBestCameraPreviewFrameRate(mCamera));
				// 设置采集后图像旋转
//				parameters.setRotation(90);
				
				// 设置采集参数
				mCamera.setParameters(parameters);
				mCamera.setDisplayOrientation(90);
				
				// 设置采集缓存Buffer
				PixelFormat pixelFormat = new PixelFormat();
				PixelFormat.getPixelFormatInfo(parameters.getPreviewFormat(), pixelFormat);
				
				int bufSize = bestSize.width * bestSize.height * pixelFormat.bitsPerPixel / 8;
				byte[] buffer = null;
				for (int i = 0; i < LSConfig.VIDEO_FPS; i++) {
					buffer = new byte[bufSize];
					mCamera.addCallbackBuffer(buffer);
				}
				mCamera.setPreviewCallbackWithBuffer(this);
				
				bFlag = true;
			}
		}
		
		return bFlag;
	}
	
	/**
	 * 开启实时预览
	 * @param holder
	 */
	private void startPreview(SurfaceHolder holder) {
//		if( mCamera != null ) {
//			try {
//				 mCamera.setPreviewDisplay(holder);
//				 mCamera.setDisplayOrientation(90);
//			} catch (RuntimeException e) {
//				 Log.i(LSConfig.TAG, String.format("LSVideoCapture::startPreview( error : %s )", e.toString()));
//				 e.printStackTrace();
//				 
//			} catch (IOException e) {
//				// TODO Auto-generated catch block
//				Log.i(LSConfig.TAG, String.format("LSVideoCapture::startPreview( error : %s )", e.toString()));
//				e.printStackTrace();
//			}
//		}
	}
	
	private void stopPreview() {
//		if( mCamera != null ) {
//			// 停止预览
//			mCamera.setPreviewCallback(null);
//			mCamera.stopPreview();
//		}
	}
	
	/**
	 * 查找摄像头
	 * @return
	 */
	private int getCamera(boolean isFront) {
		CameraInfo cameraInfo = new Camera.CameraInfo();
		int cameraCount = Camera.getNumberOfCameras();
		int cameraIndex = -1;
		
		for (int camIdx = 0; camIdx < cameraCount; camIdx++) {
			Camera.getCameraInfo(camIdx, cameraInfo);
			if (cameraInfo.facing == (isFront?CameraInfo.CAMERA_FACING_FRONT:CameraInfo.CAMERA_FACING_BACK)) {
				cameraIndex = camIdx;
				break;
			}
		}

		Log.i(LSConfig.TAG, String.format("LSVideoCapture::getCamera( cameraIndex : %d )", cameraIndex));
		
		return cameraIndex;
	}
	
	/**
	 * 获取最合适的Preview size(大于设定大小，且最小buffer)
	 * @param camera
	 * @return
	 */
	private Size getBestSuppportPreviewSize(Camera camera) {
		Size bestSize = null;
		int minLenght = LSConfig.VIDEO_WIDTH > LSConfig.VIDEO_HEIGHT ? LSConfig.VIDEO_WIDTH : LSConfig.VIDEO_HEIGHT;
		Camera.Parameters parameters = mCamera.getParameters();
		List<Size> previewSizes = parameters.getSupportedPreviewSizes();
		if( previewSizes != null ) {
			for (Size size : previewSizes) {
				if( bestSize == null ) {
					bestSize = size;
				} else {
					if (bestSize.width < size.width || bestSize.height < size.height ) {
						bestSize = size;
					}
				}
				
				if (bestSize.width >= minLenght && bestSize.height >= minLenght) {
					break;
				}
			}
		}
		
		if( bestSize != null ) {
			Log.i(LSConfig.TAG, String.format("LSVideoCapture::getBestSuppportPreviewSize( bestWidth : %d, bestHeight : %d )", bestSize.width, bestSize.height));
		} else {
			Log.i(LSConfig.TAG, String.format("LSVideoCapture::getBestSuppportPreviewSize( [Fail] )"));
		}
		
		return bestSize;
	}
	
	/**
	 * 获取最合适的帧采集率
	 * @return
	 */
	private int getBestCameraPreviewFrameRate(Camera camera) {
		int bestFrameRate = 0;
		List<Integer> previewFrameRate = camera.getParameters().getSupportedPreviewFrameRates();
		for(Integer frameRate : previewFrameRate) {
			if( frameRate > bestFrameRate ) {
				bestFrameRate = frameRate;
			}
			
			if( frameRate == LSConfig.VIDEO_FPS ) {
				bestFrameRate = LSConfig.VIDEO_FPS;
				break;
			}
		}
		
		Log.i(LSConfig.TAG, String.format("LSVideoCapture::getBestCameraPreviewFrameRate( bestFrameRate : %d )", bestFrameRate));
		
		return bestFrameRate;
	}
	
	@Override
	public void onPreviewFrame(byte[] data, Camera camera) {
		// TODO Auto-generated method stub
		int width = camera.getParameters().getPreviewSize().width;
		int height = camera.getParameters().getPreviewSize().height;
		
//		Log.i(LSConfig.TAG, String.format("LSVideoCapture::onPreviewFrame( width : %d, height : %d )", width, height));
		
		if( captureCallback != null ) {
			captureCallback.onVideoCapture(data, width, height);
		}
		
		camera.addCallbackBuffer(data);
	}
	
	@Override
	public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
		// TODO Auto-generated method stub
        Log.i(LSConfig.TAG, String.format("LSVideoCapture::surfaceChanged( width : %d, height : %d )", width, height));

        startPreview(holder);
	}

	@Override
	public void surfaceCreated(SurfaceHolder holder) {
		// TODO Auto-generated method stub
    	Log.i(LSConfig.TAG, String.format("LSVideoCapture::surfaceCreated()"));
    	
    	startPreview(holder);
	}

	@Override
	public void surfaceDestroyed(SurfaceHolder holder) {
		// TODO Auto-generated method stub
		Log.i(LSConfig.TAG, String.format("LSVideoCapture::surfaceDestroyed()"));
		
		stopPreview();
	}
}
