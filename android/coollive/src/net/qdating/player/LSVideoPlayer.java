/**
 * Copyright (c) 2016 The Camshare project authors. All Rights Reserved.
 */
package net.qdating.player;

import java.nio.ByteBuffer;

import android.graphics.Bitmap;
import android.opengl.GLSurfaceView;
import net.qdating.LSConfig;
import net.qdating.LSConfig.FillMode;
import net.qdating.utils.Log;

public class LSVideoPlayer implements ILSVideoRendererJni {
	/**
	 * 预览界面
	 */
	private GLSurfaceView playerSurfaceView;
	/**
	 * 预览渲染器
	 */
	private LSVideoPlayerRenderer playerRenderer = null;
	
	private int pixelBufferSize = 0;
    private Bitmap bitmap = null;
    private ByteBuffer pixelBuffer = null;
    
    private int width = 0;
    private int height = 0;
    
	public LSVideoPlayer() {
		
	}
	
	/**
	 * 绑定界面元素
	 * @param view
	 * @param viewWidth
	 * @param viewHeight
	 */
	public void init(GLSurfaceView surfaceView, FillMode fillMode) {
		// 创建预览渲染器
		this.playerRenderer = new LSVideoPlayerRenderer(fillMode);
		this.playerRenderer.init();
		
		// 设置GL预览界面, 按照顺序调用, 否则crash
		this.playerSurfaceView = surfaceView;
		this.playerSurfaceView.setEGLContextClientVersion(2);
		this.playerSurfaceView.setRenderer(playerRenderer);
		this.playerSurfaceView.setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);
		this.playerSurfaceView.setPreserveEGLContextOnPause(true);
	}
	
	/**
	 * 
	 */
	public void uninit() {
	}

	@Override
	public void renderVideoFrame(byte[] data, int size, int width, int height) {
		// TODO Auto-generated method stub
		// 刷新内存图像
		drawBitmap(data, size, width, height);
		// 更新滤镜输入
		playerRenderer.updateBmpFrame(bitmap);
		// 通知界面刷新
		playerSurfaceView.requestRender();
	}
	
    private void drawBitmap(byte[] data, int size, int width, int height) {
    	// 更新滤镜输入大小
    	if( this.width != width || this.height != height ) {
    		Log.d(LSConfig.TAG, String.format("LSVideoPlayer::drawBitmap( [Change image size], "
    				+ "oldWidth : %d, oldHeight : %d, "
    				+ "newWidth : %d, newHeight : %d "
    				+ ")", 
    				this.width, this.height,
    				width, height
    				));
    		
    		this.width = width;
    		this.height = height;
    		playerRenderer.setOriginalSize(width, height);
    		bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
    	}
    	
    	// 更新内存块大小
    	if( pixelBufferSize < size ) {
    		Log.d(LSConfig.TAG, String.format("LSVideoPlayer::drawBitmap( [Change buffer size], oldSize : %d, newSize : %d )", pixelBufferSize, size));
    		
    		pixelBufferSize = size;
        	if( pixelBuffer != null ) {
        		pixelBuffer.clear();
        	}
        	pixelBuffer = ByteBuffer.allocateDirect(pixelBufferSize);
    	}
    	
    	// 更新内存数据
    	pixelBuffer.clear();
    	pixelBuffer.put(data, 0, size);
    	pixelBuffer.rewind();
        bitmap.copyPixelsFromBuffer(pixelBuffer);
    }
}
