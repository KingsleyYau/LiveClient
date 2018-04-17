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
	public void uninit() {
		super.uninit();

		destroyGLFBO();
	}

	@Override
	public boolean changeViewPointSize(int viewPointWidth, int viewPointHeight) {
		boolean bChange = super.changeViewPointSize(viewPointWidth, viewPointHeight);
		if( bChange ) {
			destroyGLFBO();
			createGLFBO();
		}
		return bChange;
	}

	@Override
	protected void onDrawStart(int textureId) {
		// 绑定FBO
		if( glFBOId != null ) {
			GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, glFBOId[0]);
			String method = String.format("LSImageBufferFilter::onDrawStart( glBindFramebuffer( glFBOId : %d) )", glFBOId[0]);
			checkGLError(method, null);
		}
	}
	
	@Override
	protected int onDrawFrame(int textureId) {
		super.onDrawFrame(textureId);
		int newTextureId = (glFBOTextureId != null)?glFBOTextureId[0]:textureId;
		// 返回FBO的纹理
		return newTextureId;
	}
	
	@Override
	protected void onDrawFinish(int textureId) {
		// 解绑FBO
		GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);
		String method = String.format("LSImageBufferFilter::onDrawFinish( glBindFramebuffer(Unbind) )");
		checkGLError(method, null);
	}

	protected int getFBOId() {
		int result = (glFBOId != null)?glFBOId[0]:0;
		return result;
	}
	
	/**
	 * 创建新FBO
	 */
	private void createGLFBO() {
		if( viewPointWidth > 0 && viewPointHeight > 0 ) {
			// 创建新FBO
			glFBOId = new int[1];
			GLES20.glGenFramebuffers(1, glFBOId, 0);
			// 创建FBO纹理
			glFBOTextureId = LSImageFilter.genPixelTexture();
			
		    // 绑定纹理
		    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, glFBOTextureId[0]);
		    
	        // 创建空白纹理
		    GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGBA, viewPointWidth, viewPointHeight, 0,
		    		GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, null);

	        // 将纹理关联到FBO
	        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, glFBOId[0]);
		    GLES20.glFramebufferTexture2D(GLES20.GL_FRAMEBUFFER, GLES20.GL_COLOR_ATTACHMENT0, GLES20.GL_TEXTURE_2D, glFBOTextureId[0], 0);

			// 解除绑定FBO
			GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);

		    // 解除纹理绑定
	        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);

			Log.d(LSConfig.TAG,
					String.format("LSImageBufferFilter::createGLFBO( " +
									"this : 0x%x, " +
									"glFBOTextureId : %d, " +
									"glFBOId : %d, " +
									"width : %d, " +
									"height : %d, " +
									"className : [%s] " +
									") ",
							hashCode(),
							glFBOTextureId[0],
							glFBOId[0],
							viewPointWidth,
							viewPointHeight,
							getClass().getName()
					)
			);
		}
	}
	
	/**
	 * 销毁FBO
	 */
	private void destroyGLFBO() {
		Log.d(LSConfig.TAG,
				String.format("LSImageBufferFilter::destroyGLFBO( " +
								"this : 0x%x, " +
								"glFBOTextureId : %d, " +
								"glFBOId : %d, " +
								"className : [%s] " +
								") ",
						hashCode(),
						(glFBOTextureId != null)?glFBOTextureId[0]:0,
						(glFBOId != null)?glFBOId[0]:0,
						getClass().getName()
				)
		);

		if( glFBOId != null ) {
			GLES20.glDeleteFramebuffers(1, glFBOId, 0);
            String method = String.format("LSImageBufferFilter::destroyGLFBO( glDeleteFramebuffers( textureId : %d ) )", glFBOId[0]);
            checkGLError(method, null);
			glFBOId = null;
		}
		
		if( glFBOTextureId != null ) {
		    LSImageFilter.deleteTexture(glFBOTextureId);
			glFBOTextureId = null;
		}
	}
}
