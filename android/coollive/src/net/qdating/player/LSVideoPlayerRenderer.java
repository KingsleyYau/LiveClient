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
		Log.d(LSConfig.TAG, String.format("LSVideoPlayerRenderer::init()"));
	}
	
	public void uninit() {
		Log.d(LSConfig.TAG, String.format("LSVideoPlayerRenderer::uninit()"));
	}
	
	public void updateBmpFrame(Bitmap bitmap) {
		synchronized (this) {
			bmpFilter.updateBmpFrame(bitmap);
		}
	}
	
	public void setOriginalSize(int width, int height) {
		Log.d(LSConfig.TAG, String.format("LSVideoPlayerRenderer::setOriginalSize( originalWidth : %d, originalHeight : %d )", width, height));
		
		originalWidth = width;
		originalHeight = height;
	}
	
	@Override
	public void onDrawFrame(GL10 gl) {
		// TODO Auto-generated method stub
//		Log.d(LSConfig.TAG, String.format("LSVideoPlayerRenderer::onDrawFrame()"));
		
		// 重绘背景
		gl.glClearColor(1.0f, 0.0f, 0.0f, 0.0f);

		synchronized (this) {
			bmpFilter.draw(glTextureId[0], originalWidth, originalHeight);
		}
	}

	@Override
	public void onSurfaceChanged(GL10 gl, int width, int height) {
		// TODO Auto-generated method stub
        Log.i(LSConfig.TAG, String.format("LSVideoPlayerRenderer::onSurfaceChanged( width : %d, height : %d ) ", 
        		width, height, originalWidth, originalHeight));
        
        previewWidth = width;
        previewHeight = height;
        
        bmpFilter.changeViewPointSize(previewWidth, previewHeight);
	}

	@Override
	public void onSurfaceCreated(GL10 gl, EGLConfig config) {
		// TODO Auto-generated method stub
        Log.i(LSConfig.TAG, String.format("LSVideoPlayerRenderer::onSurfaceCreated()"));
		
		// 创建纹理
		glTextureId = LSImageFilter.genPixelTexture();
        
		bmpFilter.init();
	}

}
