package net.qdating.player;

import net.qdating.LSConfig;
import net.qdating.LSConfig.FillMode;
import net.qdating.filter.LSImageFilter;
import net.qdating.filter.LSImageRawBmpFilter;
import net.qdating.utils.Log;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import android.graphics.Bitmap;
import android.opengl.GLSurfaceView.Renderer;

/**
 * 视频输入裁剪
 * 魅族的GLES不支持GL_RGB
 * 
 * @author max
 */
public class LSVideoPlayerRenderer implements Renderer {
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
	 * 预览纹理Id
	 */
	private int[] glTextureId = null;
	/**
	 * 显示原始图片滤镜
	 */
	private LSImageRawBmpFilter bmpFilter = new LSImageRawBmpFilter();
	
	public LSVideoPlayerRenderer(FillMode fillMode) {
		bmpFilter.fillMode = fillMode;
	}
	
	public void init() {
		Log.d(LSConfig.TAG, String.format("LSVideoPlayerRenderer::init( this : 0x%x )", hashCode()));
	}
	
	public void uninit() {
		Log.d(LSConfig.TAG, String.format("LSVideoPlayerRenderer::uninit( this : 0x%x )",  hashCode()));
	}
	
	public void updateBmpFrame(Bitmap bitmap) {
		synchronized (this) {
			bmpFilter.updateBmpFrame(bitmap);
		}
	}
	
	public void setOriginalSize(int width, int height) {
		Log.d(LSConfig.TAG, String.format("LSVideoPlayerRenderer::setOriginalSize( this : 0x%x, originalWidth : %d, originalHeight : %d )", hashCode(), width, height));
		
		originalWidth = width;
		originalHeight = height;
	}
	
	@Override
	public void onDrawFrame(GL10 gl) {
		// TODO Auto-generated method stub
//		Log.d(LSConfig.TAG, String.format("LSVideoPlayerRenderer::onDrawFrame()"));
		
		// 重绘背景
		gl.glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		gl.glClear(GL10.GL_COLOR_BUFFER_BIT);

		synchronized (this) {
			bmpFilter.draw(glTextureId[0], originalWidth, originalHeight);
		}
	}

	@Override
	public void onSurfaceChanged(GL10 gl, int width, int height) {
		// TODO Auto-generated method stub
        Log.i(LSConfig.TAG,
				String.format("LSVideoPlayerRenderer::onSurfaceChanged( "
								+ "this : 0x%x, "
								+ "width : %d, "
								+ "height : %d "
								+ ")",
						hashCode(),
						width,
						height
				)
		);
        
        previewWidth = width;
        previewHeight = height;
        
        bmpFilter.changeViewPointSize(previewWidth, previewHeight);
	}

	@Override
	public void onSurfaceCreated(GL10 gl, EGLConfig config) {
		// TODO Auto-generated method stub
        Log.d(LSConfig.TAG, String.format("LSVideoPlayerRenderer::onSurfaceCreated( this : 0x%x )", hashCode()));
		
		// 创建纹理
		glTextureId = LSImageFilter.genPixelTexture();
        
		bmpFilter.init();
	}

}
