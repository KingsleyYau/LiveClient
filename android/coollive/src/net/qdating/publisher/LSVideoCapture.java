package net.qdating.publisher;

import java.io.IOException;
import java.util.List;

import android.graphics.ImageFormat;
import android.graphics.PixelFormat;
import android.hardware.Camera;
import android.hardware.Camera.CameraInfo;
import android.hardware.Camera.PreviewCallback;
import android.hardware.Camera.Size;
import android.os.Handler;
import android.os.HandlerThread;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import android.view.SurfaceView;
import net.qdating.LSConfig;
import net.qdating.utils.Log;

public class LSVideoCapture implements PreviewCallback, Callback {
	private final int INVALID_FRAMERATE = -1;
	
	private SurfaceHolder surfaceHolder;
	private Camera mCamera;
	private ILSVideoCaptureCallback captureCallback;
	private int rotation;
	private int previewRotation;
	
	private CaptureThread captureThread;
	private boolean videoCaptureInit = false;
	
	private class CaptureThread extends HandlerThread {
		private Handler mHandler;
		private LSVideoCapture videoCapture;
		
	    public CaptureThread(String name, LSVideoCapture videoCapture) {
	        super(name);
	        
	        this.videoCapture = videoCapture;
	    }

	    @Override
	    public synchronized void start() {
	    	// TODO Auto-generated method stub
	    	super.start();
	    	
	        mHandler = new Handler(getLooper());
	    }
	    
	    void startCapture() {
	        mHandler.post(new Runnable() {
	            @Override
	            public void run() {
	            	videoCaptureInit = videoCapture.initCapture();
	    			synchronized (videoCapture) {
	    				videoCapture.notify();
	    			}
	            }
	        });
	    }
	}
	
	public LSVideoCapture() {
		captureThread = new CaptureThread("CaptureThread", this);
	}
	
	public boolean init(SurfaceHolder holder, ILSVideoCaptureCallback callback, int rotation) {
		boolean bFlag = false;
		
		surfaceHolder = holder;
		surfaceHolder.setKeepScreenOn(true);
		surfaceHolder.setFormat(PixelFormat.TRANSPARENT);
		surfaceHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
		surfaceHolder.addCallback(this);
		surfaceHolder.setFixedSize(LSConfig.VIDEO_WIDTH, LSConfig.VIDEO_HEIGHT);
		
		captureCallback = callback;
		this.rotation = rotation;
		
		captureThread.start();
		
		// 异步开启摄像头
		captureThread.startCapture();
		try {
			synchronized (this) {
				this.wait();
			}
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		bFlag = videoCaptureInit;
		
//		bFlag = initCapture();
		
		Log.d(LSConfig.TAG, String.format("LSVideoCapture::init( [%s] )", bFlag?"Success":"Fail"));
		
		return bFlag;
	}
	
	public void uninit() {
		Log.d(LSConfig.TAG, String.format("LSVideoCapture::uninit()"));
		
		stop();
		
		captureThread.quit();
		
		if( mCamera != null ) {
			mCamera.setPreviewCallbackWithBuffer(null);
			mCamera.release();
			mCamera = null;
		}
		
		if( surfaceHolder != null ) {
			surfaceHolder.removeCallback(this);
		}

		videoCaptureInit = false;
	}
	
	public boolean start() {
		boolean bFlag = true;
		
		if( mCamera != null ) {
			// 设置采集缓存Buffer
			Size bestSize = mCamera.getParameters().getPreviewSize();
			PixelFormat pixelFormat = new PixelFormat();
			PixelFormat.getPixelFormatInfo(ImageFormat.NV21, pixelFormat);
			
			int bufSize = bestSize.width * bestSize.height * pixelFormat.bitsPerPixel / 8;
			byte[] buffer = null;
			for (int i = 0; i < LSConfig.VIDEO_CAPTURE_BUFFER_COUNT; i++) {
				buffer = new byte[bufSize];
				mCamera.addCallbackBuffer(buffer);
			}
			mCamera.setPreviewCallbackWithBuffer(this);
//			mCamera.setPreviewTexture();
			
			// 开启预览
			mCamera.startPreview();
			
			bFlag = true;
		}

		Log.d(LSConfig.TAG, String.format("LSVideoCapture::start( [%s] )", bFlag?"Success":"Fail"));
		
		return bFlag;
	}
	
	public void stop() {
		Log.d(LSConfig.TAG, String.format("LSVideoCapture::stop()"));
		
		if( mCamera != null ) {
			// 停止预览
			mCamera.stopPreview();
			mCamera.setPreviewCallbackWithBuffer(null);
		}
	}
	
	private boolean initCapture() {
		boolean bFlag = false;
		
		if( mCamera == null ) {
			int cameraIndex = getCamera(true);
			if( cameraIndex != -1 ) {
				// 打开摄像头
				mCamera = Camera.open(cameraIndex);
				if( mCamera != null ) {
					bFlag = true;
					
					// 获取采集参数
					Camera.Parameters parameters = mCamera.getParameters();
					
					// 设置采集的格式
					int[] formats = getCameraPreviewFormats(mCamera);
//					parameters.setPreviewFormat(formats[0]);
					parameters.setPreviewFormat(ImageFormat.NV21);
					
					// 设置采集分辨率
					Size bestSize = getBestSuppportPreviewSize(mCamera);
					if( bestSize != null ) {
						parameters.setPreviewSize(bestSize.width, bestSize.height);
					} else {
						bFlag = false;
					}
					
					// 设置采集帧率
					int fps = getBestCameraPreviewFrameRate(mCamera);
					if( fps != INVALID_FRAMERATE ) {
						parameters.setPreviewFrameRate(fps);
//						parameters.setPreviewFpsRange(fps, fps);
					} else {
						bFlag = false;
					}
					
					// 设置采集参数
					mCamera.setParameters(parameters);
					
					int degrees = 0;
					switch (rotation) {
					case Surface.ROTATION_0: degrees = 0; break;
					case Surface.ROTATION_90: degrees = 90; break;
					case Surface.ROTATION_180: degrees = 180; break;
					case Surface.ROTATION_270: degrees = 270; break;
					}
					
					int result;
					Camera.CameraInfo info = new Camera.CameraInfo();
				    Camera.getCameraInfo(cameraIndex, info);
				    if (info.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
				    	result = (info.orientation + degrees) % 360;
				    	result = (360 - result) % 360;  // compensate the mirror
				    } else {  // back-facing
				    	result = (info.orientation - degrees + 360) % 360;
				    }
				    
				    previewRotation = result;
					if( captureCallback != null ) {
						captureCallback.onChangeRotation(previewRotation);
					}
				}
			}
		}
		
		Log.d(LSConfig.TAG, String.format("LSVideoCapture::initCapture( [%s] )", bFlag?"Success":"Fail"));
		
		return bFlag;
	}
	
	/**
	 * 开启实时预览
	 * @param holder
	 */
	private void startPreview(SurfaceHolder holder) {
		if( mCamera != null ) {
			try {
				mCamera.setPreviewDisplay(holder);
				mCamera.setDisplayOrientation(previewRotation);
				
			} catch (RuntimeException e) {
				 Log.d(LSConfig.TAG, String.format("LSVideoCapture::startPreview( error : %s )", e.toString()));
				 e.printStackTrace();
				 
			} catch (IOException e) {
				// TODO Auto-generated catch block
				Log.d(LSConfig.TAG, String.format("LSVideoCapture::startPreview( error : %s )", e.toString()));
				e.printStackTrace();
			}
		}
	}
	
	private void stopPreview() {
		if( mCamera != null ) {
			// 停止预览
			mCamera.setPreviewCallback(null);
			mCamera.stopPreview();
		}
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

		Log.d(LSConfig.TAG, String.format("LSVideoCapture::getCamera( cameraIndex : %d )", cameraIndex));
		
		return cameraIndex;
	}
	
	/**
	 * 获取最合适的Preview size(大于设定大小，且最小buffer)
	 * @param camera
	 * @return
	 */
	private Size getBestSuppportPreviewSize(Camera camera) {
		Size bestSize = null;
//		int minLenght = LSConfig.VIDEO_WIDTH > LSConfig.VIDEO_HEIGHT ? LSConfig.VIDEO_WIDTH : LSConfig.VIDEO_HEIGHT;
		Camera.Parameters parameters = mCamera.getParameters();
		List<Size> previewSizes = parameters.getSupportedPreviewSizes();
		if( previewSizes != null ) {
			for (Size size : previewSizes) {
//				if( bestSize == null ) {
//					bestSize = size;
//				} else {
//					if (bestSize.width < size.width || bestSize.height < size.height ) {
//						bestSize = size;
//					}
//				}
				
				// 因为采集逆时针旋转90度, 宽高互换
				if (size.width == LSConfig.VIDEO_HEIGHT && size.height == LSConfig.VIDEO_WIDTH) {
					bestSize = size;
					break;
				}
			}
		}
		
		if( bestSize != null ) {
			Log.d(LSConfig.TAG, String.format("LSVideoCapture::getBestSuppportPreviewSize( bestWidth : %d, bestHeight : %d )", bestSize.width, bestSize.height));
		} else {
			Log.d(LSConfig.TAG, String.format("LSVideoCapture::getBestSuppportPreviewSize( [Fail] )"));
		}
		
		return bestSize;
	}
	
	/**
	 * 获取最合适的帧采集率
	 * @return
	 */
	private int getBestCameraPreviewFrameRate(Camera camera) {
		int bestFrameRate = INVALID_FRAMERATE;
		List<Integer> previewFrameRate = camera.getParameters().getSupportedPreviewFrameRates();
		for(Integer frameRate : previewFrameRate) {
			if( frameRate > bestFrameRate ) {
				bestFrameRate = frameRate;
			}
//			if( frameRate == LSConfig.VIDEO_FPS ) {
//				bestFrameRate = LSConfig.VIDEO_FPS;
//				break;
//			}
		}
		
		Log.d(LSConfig.TAG, String.format("LSVideoCapture::getBestCameraPreviewFrameRate( bestFrameRate : %d )", bestFrameRate));
		
		return bestFrameRate;
	}
	
	/**
	 * 获取当前手机支持的预览格式列表
	 * @param camera
	 * @return
	 */
	private int[] getCameraPreviewFormats(Camera camera){
		List<Integer> previewForamts = camera.getParameters().getSupportedPreviewFormats();
		int[] previewFormatArray = new int[previewForamts.size()];
		for(int i = 0; i < previewForamts.size(); i++){
			previewFormatArray[i] = previewForamts.get(i);
		}
		return previewFormatArray;
	}
	
	@Override
	public void onPreviewFrame(byte[] data, Camera camera) {
		// TODO Auto-generated method stub
		int width = camera.getParameters().getPreviewSize().width;
		int height = camera.getParameters().getPreviewSize().height;
		
//		Log.d(LSConfig.TAG, String.format("LSVideoCapture::onPreviewFrame( width : %d, height : %d, size : %d, data : %d )", width, height, data.length, data.hashCode()));
		
		if( captureCallback != null ) {
			captureCallback.onVideoCapture(data, data.length, width, height);
		}
		
		camera.addCallbackBuffer(data);
	}
	
	@Override
	public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
		// TODO Auto-generated method stub
        Log.d(LSConfig.TAG, String.format("LSVideoCapture::surfaceChanged( width : %d, height : %d )", width, height));

        startPreview(holder);
	}

	@Override
	public void surfaceCreated(SurfaceHolder holder) {
		// TODO Auto-generated method stub
    	Log.d(LSConfig.TAG, String.format("LSVideoCapture::surfaceCreated()"));
    	
    	startPreview(holder);
	}

	@Override
	public void surfaceDestroyed(SurfaceHolder holder) {
		// TODO Auto-generated method stub
		Log.d(LSConfig.TAG, String.format("LSVideoCapture::surfaceDestroyed()"));
		
		stopPreview();
	}
}
