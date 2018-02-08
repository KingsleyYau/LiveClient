package net.qdating.player;

import java.nio.ByteBuffer;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.opengl.GLU;
import android.opengl.GLUtils;
import android.opengl.GLSurfaceView.Renderer;
import android.util.Log;

public class LSVideoGLRenderer implements Renderer {
	private final static String TAG = "coollive";
	
	
	// Our texture id
	private int yTexture[] = new int[1];
	private int uvTexture[] = new int[1];
	private ByteBuffer yBuffer = null;
	private ByteBuffer uvBuffer = null;
	
	private int frameWidth;
	private int frameHeight;
    
	private int viewWidth;
	private int viewHeight;
    
	public LSVideoGLRenderer() {
		// Tell OpenGL to generate textures.
	}

	private void createTexture(int width, int height, int format, int[] texture) {
		// 创建实例
	    GLES20.glGenTextures(1, texture, 0);
	    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, texture[0]);
	    
	    // 设定视觉
	    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
	    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
	    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST);
	    GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
	    GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, format, width, height, 0, format, GLES20.GL_UNSIGNED_BYTE, null);
	    
	}

	@Override
	public void onDrawFrame(GL10 gl) {
		// TODO Auto-generated method stub
		// 重画背景
		gl.glClear(GL10.GL_COLOR_BUFFER_BIT | GL10.GL_DEPTH_BUFFER_BIT);
		
		if( yBuffer != null && uvBuffer != null ) {
			// 绘制Y Buffer
			gl.glActiveTexture(GLES20.GL_TEXTURE0);
			GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, yTexture[0]);
			gl.glTexSubImage2D(GLES20.GL_TEXTURE_2D,
					0,
					0,
					0,
					frameWidth,
					frameHeight,
					GLES20.GL_LUMINANCE,
					GLES20.GL_UNSIGNED_BYTE,
					yBuffer
					);
			
			// 绘制UV Buffer
			gl.glActiveTexture(GLES20.GL_TEXTURE2);
			gl.glBindTexture(GLES20.GL_TEXTURE_2D, uvTexture[0]);
			gl.glTexSubImage2D(GLES20.GL_TEXTURE_2D,
	                0,
	                0,
	                0,
	                frameWidth >> 1,
	                frameHeight >> 1,
	                GLES20.GL_LUMINANCE_ALPHA,
	                GLES20.GL_UNSIGNED_BYTE,
	                uvBuffer
	                );
		}
		
	    // 绘制
	    gl.glViewport(0, 0, viewWidth, viewHeight);
	    gl.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);
	}

	@Override
	public void onSurfaceChanged(GL10 gl, int width, int height) {
		// TODO Auto-generated method stub
        Log.i(TAG, String.format("LSVideoGLRenderer::onSurfaceChanged( width : %d, height : %d ) ", width, height));
        
        viewWidth = width;
        viewHeight = height;
        
        gl.glViewport(0, 0, viewWidth, viewHeight);
	}

	@Override
	public void onSurfaceCreated(GL10 gl, EGLConfig config) {
		// TODO Auto-generated method stub
        Log.i(TAG, String.format("LSVideoGLRenderer::onSurfaceCreated() "));
        
		// Set the background color to black ( rgba ).
        // 设置背景色
		gl.glClearColor(0.0f, 0.0f, 0.0f, 0.5f);
		
        // 创建yuv纹理
        createTexture(frameWidth, frameHeight, GLES20.GL_LUMINANCE, yTexture);
        createTexture(frameWidth >> 1, frameHeight >> 1, GLES20.GL_LUMINANCE_ALPHA, uvTexture);
	}
	
	public void copyYUV(byte[] data, int size) {
    	if( yBuffer == null ) {
    		yBuffer = ByteBuffer.allocateDirect(size);
    	}
    	
    	if( uvBuffer == null ) {
    		uvBuffer = ByteBuffer.allocateDirect(size);
    	}
    	
    	yBuffer.clear();
    	uvBuffer.clear();
    	
	    int ySize = ( size << 1 ) / 3;
	    yBuffer.put(data, 0, ySize).position(0);
	    uvBuffer.put(data, ySize, ySize>>1).position(0);
	}
}
