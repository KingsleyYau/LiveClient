package net.qdating.player;

import android.opengl.GLSurfaceView;
import net.qdating.LSConfig;
import net.qdating.LSConfig.FillMode;
import net.qdating.filter.LSImageFilter;
import net.qdating.utils.Log;

/**
 * 视频硬渲染器
 * @author max
 *
 */
public class LSVideoHardPlayer implements ILSVideoHardRendererJni {
	/**
	 * 渲染绑定器
	 */
	private LSPlayerRendererBinder rendererBinder = null;
	
    private int width = 0;
    private int height = 0;
	
	public LSVideoHardPlayer() {
		
	}
	
	/**
	 * 设置渲染绑定器
	 * @param rendererBinder 界面
	 */
	public void setRendererBinder(LSPlayerRendererBinder rendererBinder) {
		synchronized (this) {
			this.rendererBinder = rendererBinder;
		}
	}

	@Override
	public void renderVideoFrame(LSVideoHardDecoderFrame videoFrame) {
		// TODO Auto-generated method stub
		synchronized (this) {
			// 更新滤镜输入大小
			if (width != videoFrame.width || height != videoFrame.height) {
				Log.d(LSConfig.TAG,
						String.format("LSVideoHardPlayer::renderVideoFrame( "
										+ "this : 0x%x, "
										+ "[Change image size], "
										+ "oldWidth : %d, oldHeight : %d, "
										+ "newWidth : %d, newHeight : %d "
										+ ")",
								hashCode(),
								width, height,
								videoFrame.width, videoFrame.height
						));

				width = videoFrame.width;
				height = videoFrame.height;
			}

			if( rendererBinder != null && rendererBinder.playerHardRenderer != null ) {
				// 更新滤镜大小
				rendererBinder.playerHardRenderer.setOriginalSize(videoFrame.width, videoFrame.height);
			}

			if( rendererBinder != null && rendererBinder.playerHardRenderer != null ) {
				// 更新滤镜输入
				rendererBinder.playerHardRenderer.updateDecodeFrame(videoFrame);
			}

			if( rendererBinder != null && rendererBinder.playerSurfaceView != null ) {
				// 通知界面刷新
				rendererBinder.playerSurfaceView.requestRender();
			}
		}
	}
}
