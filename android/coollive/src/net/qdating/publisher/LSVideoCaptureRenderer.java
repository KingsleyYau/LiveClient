package net.qdating.publisher;

import net.qdating.LSConfig;
import net.qdating.LSConfig.FillMode;
import net.qdating.filter.LSImageInputCameraFilter;
import net.qdating.filter.LSImageCropFilter;
import net.qdating.filter.LSImageFilter;
import net.qdating.filter.LSImageFlipFilter;
import net.qdating.filter.LSImageOutputFilter;
import net.qdating.filter.LSImageRecordFilter;
import net.qdating.filter.LSImageRecordFilterCallback;
import net.qdating.filter.LSImageRecordYuvFilter;
import net.qdating.filter.LSImageUtil;
import net.qdating.utils.Log;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import android.graphics.SurfaceTexture;
import android.graphics.SurfaceTexture.OnFrameAvailableListener;
import android.media.MediaCodecInfo;
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
	private LSImageInputCameraFilter cameraFilter = null;
	private LSImageCropFilter cropFilter = null;
	private LSImageOutputFilter outputFilter = null;
	private LSImageFlipFilter flipFilter = null;
	private LSImageFilter recordFilter = null;

	public LSVideoCaptureRenderer(ILSVideoPreviewCallback callback, FillMode fillMode, boolean useHardEncoder) {
		this.callback = callback;

		cameraFilter = new LSImageInputCameraFilter();
		cropFilter = new LSImageCropFilter();
		outputFilter = new LSImageOutputFilter();
		flipFilter = new LSImageFlipFilter(LSImageFlipFilter.FlipType.FlipType_Vertical);

		if( useHardEncoder ) {
			// 硬编码录制滤镜
			if( LSVideoHardEncoder.supportHardEncoderFormat() == MediaCodecInfo.CodecCapabilities.COLOR_Format32bitARGB8888 ) {
				recordFilter = new LSImageRecordFilter(this);
			} else if( LSVideoHardEncoder.supportHardEncoderFormat() == MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Planar ) {
				recordFilter = new LSImageRecordYuvFilter(this, LSImageUtil.ColorFormat.ColorFormat_YUV420P);
			} else if( LSVideoHardEncoder.supportHardEncoderFormat() == MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420SemiPlanar ) {
				recordFilter = new LSImageRecordYuvFilter(this, LSImageUtil.ColorFormat.ColorFormat_YUV420SP);
			} else {
				Log.e(LSConfig.TAG, String.format("LSVideoCaptureRenderer::LSVideoCaptureRenderer( this : 0x%x, [Not supported color format] )", hashCode()));
			}
		} else {
			// 软编码录制滤镜
			recordFilter = new LSImageRecordFilter(this);
		}

		// 设置渲染模式
		outputFilter.fillMode = fillMode;
	}

	public void init() {
		Log.d(LSConfig.TAG, String.format("LSVideoCaptureRenderer::init( this : 0x%x )", hashCode()));

		cameraFilter.setFilter(cropFilter);
		cropFilter.setFilter(outputFilter);
		outputFilter.setFilter(flipFilter);
		flipFilter.setFilter(recordFilter);
	}

	public void uninit() {
		Log.d(LSConfig.TAG, String.format("LSVideoCaptureRenderer::uninit( this : 0x%x )", hashCode()));
	}
	
	public void setOriginalSize(int width, int height) {
		originalWidth = width;
		originalHeight = height;

		// 目标比例
		float radioPreview = 1.0f * LSConfig.VIDEO_WIDTH / LSConfig.VIDEO_HEIGHT;
		// 源比例
		float radioImage = 1.0f * originalWidth / originalHeight;

		Log.d(LSConfig.TAG,
				String.format("LSVideoCaptureRenderer::setOriginalSize( "
						+ "this : 0x%x, "
						+ "originalWidth : %d, "
						+ "originalHeight : %d, "
						+ "radioPreview : %f, "
						+ "radioImage : %f "
						+ " )",
						hashCode(),
						originalWidth,
						originalHeight,
						radioPreview,
						radioImage
				)
		);

		if( radioPreview < radioImage ) {
			// 剪裁左右
			cropFilter.setCropRect((1 - radioImage) / 2, 0, radioImage, 1);
		} else {
			// 剪裁上下
			cropFilter.setCropRect(0, (1 - radioImage) / 2, 1, radioImage);
		}
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
		GLES20.glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT | GLES20.GL_DEPTH_BUFFER_BIT);

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
		outputFilter.changeViewPointSize(previewWidth, previewHeight);

		// 改变录制滤镜大小
		if( recordFilter != null ) {
			recordFilter.changeViewPointSize(LSConfig.VIDEO_WIDTH, LSConfig.VIDEO_HEIGHT);
		}
	}

	@Override
	public void onSurfaceCreated(GL10 gl, EGLConfig config) {
		// TODO Auto-generated method stub
        Log.d(LSConfig.TAG, String.format("LSVideoCaptureRenderer::onSurfaceCreated( this : 0x%x )", hashCode()));

		// 创建摄像头纹理
		glCameraTextureId = LSImageFilter.genCameraTexture();

        // 摄像头
		cameraFilter.init();
		// 裁剪
		cropFilter.init();
		// 预览
		outputFilter.init();
		// 垂直翻转
		flipFilter.init();
		// 录制
		if( recordFilter != null ) {
			recordFilter.init();
		}
	}

	@Override
	public void onRecordFrame(byte[] data, int size, int width, int height) {
		// TODO Auto-generated method stub
		if( callback != null ) {
			callback.onRenderFrame(data, size, width, height);
		}
	}
}