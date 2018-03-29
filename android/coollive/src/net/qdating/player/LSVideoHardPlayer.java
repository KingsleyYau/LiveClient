package net.qdating.player;

import android.opengl.GLSurfaceView;
import net.qdating.LSConfig;
import net.qdating.LSConfig.FillMode;
import net.qdating.utils.Log;

public class LSVideoHardPlayer implements ILSVideoHardRendererJni {
	/**
	 * 预览界面
	 */
	private GLSurfaceView playerSurfaceView;
	/**
	 * 预览渲染器
	 */
	private LSVideoHardPlayerRenderer playerHardRenderer = null;
	
    private int width = 0;
    private int height = 0;
	
	public LSVideoHardPlayer() {
		
	}
	
	/**
	 * 绑定界面元素
	 * @param view
	 * @param viewWidth
	 * @param viewHeight
	 */
	public void init(GLSurfaceView surfaceView, FillMode fillMode) {
		// 创建预览渲染器
		this.playerHardRenderer = new LSVideoHardPlayerRenderer(fillMode);
		this.playerHardRenderer.init();
		
		// 设置GL预览界面, 按照顺序调用, 否则crash
		this.playerSurfaceView = surfaceView;
		this.playerSurfaceView.setEGLContextClientVersion(2);
		this.playerSurfaceView.setRenderer(playerHardRenderer);
		this.playerSurfaceView.setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);
		this.playerSurfaceView.setPreserveEGLContextOnPause(true);
	}
	
	/**
	 * 反初始化
	 */
	public void uninit() {
		playerHardRenderer.uninit();
	}

	@Override
	public void renderVideoFrame(LSVideoHardDecoderFrame videoFrame) {
		// TODO Auto-generated method stub
    	// 更新滤镜输入大小
    	if( width != videoFrame.width || height != videoFrame.height ) {
    		Log.d(LSConfig.TAG, 
    				String.format("LSVideoHardPlayer::renderVideoFrame( [Change image size], "
    				+ "oldWidth : %d, oldHeight : %d, "
    				+ "newWidth : %d, newHeight : %d "
    				+ ")", 
    				width, height,
    				videoFrame.width, videoFrame.height
    				));
    		
    		width = videoFrame.height;
    		height = videoFrame.height;
    		
    		playerHardRenderer.setOriginalSize(videoFrame.width, videoFrame.height);
    	}
		
		// 更新滤镜输入
		playerHardRenderer.updateYuvFrame(
				videoFrame.byteBufferY, videoFrame.byteSizeY, 
				videoFrame.byteBufferU, videoFrame.byteSizeU, 
				videoFrame.byteBufferV, videoFrame.byteSizeV
				);
		
		// 通知界面刷新
		playerSurfaceView.requestRender();
	}
}
