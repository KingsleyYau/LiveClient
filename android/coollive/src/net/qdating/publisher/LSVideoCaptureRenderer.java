package net.qdating.publisher;

import net.qdating.LSConfig;
import net.qdating.LSConfig.FillMode;
import net.qdating.filter.LSImageBeautyFilter;
import net.qdating.filter.LSImageBmpFilter;
import net.qdating.filter.LSImageInputCameraFilter;
import net.qdating.filter.LSImageCropFilter;
import net.qdating.filter.LSImageFilter;
import net.qdating.filter.LSImageFlipFilter;
import net.qdating.filter.LSImageOutputFilter;
import net.qdating.filter.LSImageRecordFilter;
import net.qdating.filter.LSImageRecordFilterCallback;
import net.qdating.filter.LSImageRecordYuvFilter;
import net.qdating.filter.LSImageUtil;
import net.qdating.filter.LSImageWaterMarkFilter;
import net.qdating.utils.Log;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.SurfaceTexture;
import android.graphics.SurfaceTexture.OnFrameAvailableListener;
import android.media.MediaCodecInfo;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView.Renderer;

import java.io.File;

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
	private LSPublishConfig publishConfig;
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
	private LSImageBmpFilter bmpFilter = null;
	private LSImageCropFilter cropFilter = null;
	private LSImageOutputFilter outputFilter = null;
	private LSImageFlipFilter recordFlipFilter = null;
	private LSImageFlipFilter outputFlipFilter = null;
	private LSImageFilter recordFilter = null;

	private boolean bCustomFilterChange = false;
	private LSImageFilter customFilter = null;

	public LSVideoCaptureRenderer(ILSVideoPreviewCallback callback, FillMode fillMode, boolean useHardEncoder, LSPublishConfig publishConfig) {
		this.callback = callback;
		this.publishConfig = publishConfig;

		cameraFilter = new LSImageInputCameraFilter();
		bmpFilter = new LSImageBmpFilter();
		cropFilter = new LSImageCropFilter();
		recordFlipFilter = new LSImageFlipFilter(LSImageFlipFilter.FlipType.FlipType_Vertical);
		outputFlipFilter = new LSImageFlipFilter(LSImageFlipFilter.FlipType.FlipType_Vertical);
		outputFilter = new LSImageOutputFilter();

		if( useHardEncoder ) {
			// 硬编码录制滤镜
			if( LSVideoHardEncoder.supportHardEncoderFormat(publishConfig) == MediaCodecInfo.CodecCapabilities.COLOR_Format32bitARGB8888 ) {
				recordFilter = new LSImageRecordFilter(this);
			} else if( LSVideoHardEncoder.supportHardEncoderFormat(publishConfig) == MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Planar ) {
				recordFilter = new LSImageRecordYuvFilter(this, LSImageUtil.ColorFormat.ColorFormat_YUV420P);
			} else if( LSVideoHardEncoder.supportHardEncoderFormat(publishConfig) == MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420SemiPlanar ) {
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
		cropFilter.setFilter(recordFlipFilter);
		recordFlipFilter.setFilter(recordFilter);
		recordFilter.setFilter(outputFlipFilter);
		outputFlipFilter.setFilter(outputFilter);
	}

	public void uninit() {
		Log.d(LSConfig.TAG, String.format("LSVideoCaptureRenderer::uninit( this : 0x%x )", hashCode()));
	}

	/**
	 * 设置自定义滤镜
	 * @param customFilter 自定义滤镜
	 */
	public void setCustomFilter(LSImageFilter customFilter) {
		Log.d(LSConfig.TAG, String.format("LSVideoCaptureRenderer::setCustomFilter( this : 0x%x )", hashCode()));
		synchronized (this) {
			if( this.customFilter != customFilter ) {
				this.customFilter = customFilter;
				bCustomFilterChange = true;

				if (this.customFilter != null) {
					cropFilter.setFilter(this.customFilter);
					this.customFilter.setFilter(recordFlipFilter);
				} else {
					cropFilter.setFilter(recordFlipFilter);
				}
			}
		}
	}

	/**
	 * 获取自定义滤镜
	 * @return 自定义滤镜
	 */
	public LSImageFilter getCustomFilter() {
		return this.customFilter;
	}

	/**
	 * 设置自定义上传图片
	 * @param bitmap 图片
	 */
	public void setCaptureBitmap(Bitmap bitmap) {
		bmpFilter.updateBmpFrame(bitmap);

		if ( bmpFilter.getBitmap() != null ) {
			Log.i(LSConfig.TAG,
					String.format("LSVideoCaptureRenderer::setCaptureBitmap( "
									+ "this : 0x%x, "
									+ "[Set Capture Bitmap], "
									+ "bitmap : 0x%x, "
									+ "width : %d, "
									+ "height : %d "
									+ " )",
							hashCode(),
							bitmap.hashCode(),
							bmpFilter.getBitmap().getWidth(),
							bmpFilter.getBitmap().getHeight()
					)
			);

			changeCropFilterSize(bmpFilter.getBitmap().getWidth(), bmpFilter.getBitmap().getHeight());
			cameraFilter.setFilter(bmpFilter);
			bmpFilter.setFilter(cropFilter);
		} else {
			Log.i(LSConfig.TAG,
					String.format("LSVideoCaptureRenderer::setCaptureBitmap( "
									+ "this : 0x%x, "
									+ "[Clear Capture Bitmap], "
									+ "width : %d, "
									+ "height : %d "
									+ " )",
							hashCode(),
							originalWidth,
							originalHeight
					)
			);

			changeCropFilterSize(originalWidth, originalHeight);
			cameraFilter.setFilter(cropFilter);
		}
	}

	public void changeCropFilterSize(int inputWidth, int inputHeight) {
		// 目标比例
		float radioPreview = 1.0f * publishConfig.videoWidth / publishConfig.videoHeight;
		// 源比例
		float radioImage = 1.0f * inputWidth / inputHeight;

		Log.i(LSConfig.TAG,
				String.format("LSVideoCaptureRenderer::changeCropFilterSize( "
								+ "this : 0x%x, "
								+ "inputWidth : %d, "
								+ "inputHeight : %d, "
								+ "radioPreview : %f, "
								+ "videoWidth : %d, "
								+ "videoHeight : %d, "
								+ "radioImage : %f "
								+ " )",
						hashCode(),
						inputWidth,
						inputHeight,
						radioPreview,
						publishConfig.videoWidth,
						publishConfig.videoHeight,
						radioImage
				)
		);

		if ( inputHeight == 0 || publishConfig.videoHeight == 0 || radioPreview == radioImage ) {
			// 不裁剪
		} else if( radioPreview < radioImage ) {
			// 剪裁左右
			float radio = 1.0f * inputHeight / publishConfig.videoHeight * publishConfig.videoWidth / inputWidth;
			cropFilter.setCropRect((1 - radio) / 2, 0, radio, 1);
		} else {
			// 剪裁上下
			float radio = 1.0f * inputWidth / publishConfig.videoWidth * publishConfig.videoHeight / inputHeight;
			cropFilter.setCropRect(0, (1 - radio) / 2, 1, radio);
		}
	}

	/**
	 * 设置输入图像大小
	 * @param width 宽
	 * @param height 高
	 */
	public void setOriginalSize(int width, int height) {
		this.originalWidth = width;
		this.originalHeight = height;

		changeCropFilterSize(originalWidth, originalHeight);
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
		// 重绘背景
		GLES20.glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT | GLES20.GL_DEPTH_BUFFER_BIT);

		synchronized (this) {
			if( bCustomFilterChange ) {
				if( customFilter != null ) {
					customFilter.init();
				}
				bCustomFilterChange = false;
			}

			// 创建流输入, 只能在这里创建, 因为要保证GL的创建和渲染在同一个线程
			createSurfaceTexture();

			// 请求输入下一帧图像
			surfaceTexture.updateTexImage();
			// 获取旧的图像矩阵
			surfaceTexture.getTransformMatrix(transformMatrix);

			// 绘制
			if( glCameraTextureId != null ) {
				cameraFilter.updateMatrix(transformMatrix);
				cameraFilter.draw(glCameraTextureId[0], originalWidth, originalHeight);
			}
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
			recordFilter.changeViewPointSize(publishConfig.videoWidth, publishConfig.videoHeight);
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
		// 自定义图片
		bmpFilter.init();
		// 裁剪
		cropFilter.init();
		// 预览
		outputFilter.init();
		// 录制前垂直翻转
		recordFlipFilter.init();
		// 录制后再垂直翻转
		outputFlipFilter.init();
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