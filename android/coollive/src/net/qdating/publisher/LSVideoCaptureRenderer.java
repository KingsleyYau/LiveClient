package net.qdating.publisher;

import net.qdating.LSConfig;
import net.qdating.LSConfig.FillMode;
import net.qdating.filter.LSImageCameraFilter;
import net.qdating.filter.LSImageFilter;
import net.qdating.filter.LSImageRawTextureFilter;
import net.qdating.filter.LSImageRecordFilter;
import net.qdating.filter.LSImageRecordFilterCallback;
import net.qdating.utils.Log;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import android.graphics.SurfaceTexture;
import android.graphics.SurfaceTexture.OnFrameAvailableListener;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView.Renderer;

/**
 * 视频输入裁剪
 * 魅族的GLES不支持GL_RGB
 * 
 * @author max
 */
public class LSVideoCaptureRenderer implements Renderer, LSImageRecordFilterCallback {
	/**
	 * 回调
	 */
	private ILSVideoPreviewCallback callback = null;
	/**
	 * 预览界面宽度
	 */
	int previewWidth = 0;
	/**
	 * 预览界面高度
	 */
	int previewHeight = 0;
	/**
	 * 原始视频宽度
	 */
	int originalWidth = 0;
	/**
	 * 原始视频高度
	 */
	int originalHeight = 0;
	/**
	 * 纹理坐标矩阵
	 */
	private float[] transformMatrix = new float[16];
	/**
	 * 预览纹理Id
	 */
	private int[] glCameraTextureId = null;
	/**
	 * 输入流Texture
	 */
	private SurfaceTexture surfaceTexture = null;
	
	/**
	 * 滤镜
	 */
	private LSImageCameraFilter cameraFilter = new LSImageCameraFilter();
	private LSImageRawTextureFilter previewFilter = new LSImageRawTextureFilter();
	private LSImageRecordFilter recordFilter = new LSImageRecordFilter(this);
	
	public LSVideoCaptureRenderer(ILSVideoPreviewCallback callback, FillMode fillMode) {
		this.callback = callback;
		
		cameraFilter.fillMode = fillMode;
		previewFilter.fillMode = fillMode;
		recordFilter.fillMode = fillMode;
	}
	
	public void init() {
		Log.d(LSConfig.TAG, String.format("LSVideoCaptureRenderer::init( this : 0x%x )", hashCode()));
		
		cameraFilter.setFilter(previewFilter);
		previewFilter.setFilter(recordFilter);
	}
	
	public void uninit() {
		Log.d(LSConfig.TAG, String.format("LSVideoCaptureRenderer::uninit( this : 0x%x )", hashCode()));
		
		cameraFilter.uninit();
		previewFilter.uninit();
		recordFilter.uninit();
	}
	
	public void setOriginalSize(int width, int height) {
		Log.d(LSConfig.TAG, String.format("LSVideoCaptureRenderer::setOriginalSize( this : 0x%x, originalWidth : %d, originalHeight : %d )", hashCode(), width, height));
		
		originalWidth = width;
		originalHeight = height;
	}
	
	public SurfaceTexture getSurfaceTexture() {
		return surfaceTexture;
	}
	
	private void createSurfaceTexture() {
		if( surfaceTexture == null ) {
			if( glCameraTextureId != null ) {
				Log.d(LSConfig.TAG, String.format("LSVideoCaptureRenderer::createSurfaceTexture( this : 0x%x )", hashCode()));
				
				// 绑定纹理到处理流
				surfaceTexture = new SurfaceTexture(glCameraTextureId[0]);
				surfaceTexture.setOnFrameAvailableListener(new OnFrameAvailableListener() {
					@Override
					public void onFrameAvailable(SurfaceTexture surfaceTexture) {
						// TODO Auto-generated method stub
						callback.onFrameAvailable(surfaceTexture);
					}
				});
				
				callback.onCreateTexture(surfaceTexture);
			}

		}
	}
	
	@Override
	public void onDrawFrame(GL10 gl) {
		// TODO Auto-generated method stub
        // 创建流输入, 只能在这里创建, 因为要保证GL的创建和渲染在同一个线程
		createSurfaceTexture();
		
        // 请求输入下一帧图像
		surfaceTexture.updateTexImage();
		// 获取旧的图像矩阵
		surfaceTexture.getTransformMatrix(transformMatrix);
		
		// 重绘背景
		gl.glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		gl.glClear(GL10.GL_COLOR_BUFFER_BIT);
				
		// 绘制
		if( glCameraTextureId != null ) {
			cameraFilter.updateMatrix(transformMatrix);
			cameraFilter.draw(glCameraTextureId[0], originalWidth, originalHeight);
		}
	}

	@Override
	public void onSurfaceChanged(GL10 gl, int width, int height) {
		// TODO Auto-generated method stub
        Log.i(LSConfig.TAG,
				String.format("LSVideoCaptureRenderer::onSurfaceChanged( " +
								"this : 0x%x, " +
								"width : %d, " +
								"height : %d " +
								")",
						hashCode(),
						width,
						height
				)
		);
        
        previewWidth = width;
        previewHeight = height;
        
		// 改变预览滤镜大小
		previewFilter.changeViewPointSize(previewWidth, previewHeight);
		// 改变录制滤镜大小
		recordFilter.changeViewPointSize(LSConfig.VIDEO_WIDTH, LSConfig.VIDEO_HEIGHT);
	}

	@Override
	public void onSurfaceCreated(GL10 gl, EGLConfig config) {
		// TODO Auto-generated method stub
        Log.d(LSConfig.TAG, String.format("LSVideoCaptureRenderer::onSurfaceCreated( this : 0x%x )", hashCode()));
        
        // 摄像头滤镜
		cameraFilter.init();
		// 录制
		recordFilter.init();
		// 预览滤镜
		previewFilter.init();
		
		// 创建摄像头纹理
        glCameraTextureId = LSImageFilter.genCameraTexture();
	}

	@Override
	public void onRecordFrame(byte[] data, int size, int width, int height) {
		// TODO Auto-generated method stub
		if( callback != null ) {
			callback.onRenderFrame(data, size, width, height);
		}
	}
}
