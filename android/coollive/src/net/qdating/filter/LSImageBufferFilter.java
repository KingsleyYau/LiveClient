package net.qdating.filter;

import android.opengl.GLES20;
import net.qdating.LSConfig;
import net.qdating.utils.Log;

public abstract class LSImageBufferFilter extends LSImageFilter {
	/**
	 * FBO纹理Id
	 */
	private int[] glFBOTextureId = null;
	/**
	 * FBOId
	 */
	private int[] glFBOId = null;
	
	public LSImageBufferFilter(String vertexShaderString, String fragmentShaderString, float[] filterVertex) {
		super(vertexShaderString, fragmentShaderString, filterVertex);
		// TODO Auto-generated constructor stub
	}

	@Override
	public void init() {
		super.init();
	}
	
	@Override
	public void uninit() {
		super.uninit();
		
		destroyGLFBO();
	}
	
	@Override
	protected ImageSize changeInputSize(int inputWidth, int inputHeight) {
		ImageSize imageSize = super.changeInputSize(inputWidth, inputHeight);
		if( imageSize.bChange ) {
			destroyGLFBO();
			createGLFBO();
		}
		return imageSize;
	}
	
	@Override
	protected void onDrawStart(int textureId) {
		// 绑定FBO
		GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, glFBOId[0]);
	}
	
	@Override
	protected int onDrawFrame(int textureId) {
		super.onDrawFrame(textureId);
		int newTextureId = textureId;
		newTextureId = glFBOTextureId[0];
		// 返回FBO的纹理
		return newTextureId;
	}
	
	@Override
	protected void onDrawFinish(int textureId) {
		// 解绑FBO
		GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);
	}
	
	protected int getFBOId() {
		int result = (glFBOId != null)?glFBOId[0]:0;
		return result;
	}
	
	/**
	 * 创建新FBO
	 */
	private void createGLFBO() {
		if( inputWidth > 0 && inputHeight > 0 ) {
			// 创建新FBO
			glFBOId = new int[1];
			GLES20.glGenFramebuffers(1, glFBOId, 0);
			// 创建FBO纹理
			glFBOTextureId = new int[1];
			GLES20.glGenTextures(1, glFBOTextureId, 0);
			
		    // 绑定纹理
		    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, glFBOTextureId[0]);
		    
	        // 创建空白纹理
		    GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGBA, inputWidth, inputHeight, 0, 
		    		GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, null);
		    
		    // 设置纹理参数
	        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
	                GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
	        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
	                GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
	        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
	                GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
	        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
	                GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
	        
	        // 将纹理关联到FBO
	        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, glFBOId[0]);
		    GLES20.glFramebufferTexture2D(GLES20.GL_FRAMEBUFFER, GLES20.GL_COLOR_ATTACHMENT0, GLES20.GL_TEXTURE_2D, glFBOTextureId[0], 0);
		    
		    // 解除纹理绑定
	        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);
	        // 解除绑定FBO
	        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);
		}
		
		Log.d(LSConfig.TAG, String.format("LSImageBufferFilter::createGLFBO( glFBOTextureId : %d, glFBOId : %d ) ", glFBOTextureId[0], glFBOId[0]));
	}
	
	/**
	 * 销毁FBO
	 */
	private void destroyGLFBO() {
		if( glFBOId != null ) {
			GLES20.glDeleteFramebuffers(1, glFBOId, 0);
			glFBOId = null;
		}
		
		if( glFBOTextureId != null ) {
			GLES20.glDeleteTextures(1, glFBOTextureId, 0);
			glFBOTextureId = null;
		}
	}
}
