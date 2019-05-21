/**
 * Copyright (c) 2016 The Camshare project authors. All Rights Reserved.
 */
package net.qdating.player;

import java.nio.ByteBuffer;

import android.graphics.Bitmap;
import android.opengl.GLSurfaceView;
import net.qdating.LSConfig;
import net.qdating.LSConfig.FillMode;
import net.qdating.filter.LSImageFilter;
import net.qdating.utils.Log;

/**
 * 视频软渲染器
 * @author max
 *
 */
public class LSVideoPlayer implements ILSVideoRendererJni {
	/**
	 * 渲染绑定器
	 */
	private LSPlayerRendererBinder rendererBinder = null;
	
	private int pixelBufferSize = 0;
    private Bitmap bitmap = null;
    private ByteBuffer pixelBuffer = null;
    
    private int width = 0;
    private int height = 0;
    
	public LSVideoPlayer() {
		
	}
	
	/**
	 * 设置渲染绑定器
	 * @param rendererBinder 渲染绑定器
	 */
	public void setRendererBinder(LSPlayerRendererBinder rendererBinder) {
		synchronized (this) {
			this.rendererBinder = rendererBinder;
		}
	}

	@Override
	public void renderVideoFrame(byte[] data, int size, int width, int height) {
		// TODO Auto-generated method stub
		// 刷新内存图像
		drawBitmap(data, size, width, height);

		synchronized (this) {
			if( rendererBinder != null && rendererBinder.playerRenderer != null && rendererBinder.playerSurfaceView != null ) {
				// 更新滤镜输入
				rendererBinder.playerRenderer.updateBmpFrame(bitmap);
				// 通知界面刷新
				rendererBinder.playerSurfaceView.requestRender();
			}
		}
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

    		bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
    	}

		synchronized (this) {
			if( rendererBinder != null && rendererBinder.playerRenderer != null ) {
				rendererBinder.playerRenderer.setOriginalSize(width, height);
			}
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
