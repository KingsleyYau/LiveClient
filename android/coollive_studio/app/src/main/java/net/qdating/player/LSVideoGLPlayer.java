package net.qdating.player;

import android.opengl.GLSurfaceView;

public class LSVideoGLPlayer implements ILSVideoRendererJni {
	private LSVideoGLRenderer videoRenderer = new LSVideoGLRenderer();
	private GLSurfaceView surfaceView;
	
	public LSVideoGLPlayer() {
		// Create an OpenGL ES 2.0 context.
		surfaceView.setEGLContextClientVersion(2);
		// Set the Renderer for drawing on the GLSurfaceView
		surfaceView.setRenderer(videoRenderer);
        // Render the view only when there is a change in the drawing data
		surfaceView.setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);
	}
	
	public boolean init(GLSurfaceView surfaceView) {
		this.surfaceView = surfaceView;
		return true;
	}
	
	@Override
	public void renderVideoFrame(byte[] data, int width, int height) {
		// TODO Auto-generated method stub
		videoRenderer.copyYUV(data, data.length);
		
		// 刷新界面
		if( surfaceView != null ) {
			surfaceView.requestRender();
		}
	}

}
