package net.qdating.filter;

import android.opengl.GLES20;

/**
 * 原始渲染滤镜
 * @author max
 *
 */
public class LSImageRawTextureFilter extends LSImageFilter {
	private int aPosition;
	private int aTextureCoordinate;
	private int uInputTexture;
		
	public LSImageRawTextureFilter() {
		super(LSImageShader.defaultPixelVertexShaderString, LSImageShader.dafaultPixelFragmentShaderString, LSImageVertex.filterVertex_0);
	}
	
	@Override
	public void init() {
		super.init();
	}
	
	@Override
	protected void onDrawStart(int textureId) {
		// 激活纹理单元GL_TEXTURE0
		GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
		// 绑定外部纹理到纹理单元GL_TEXTURE0
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureId);
		
		aPosition = GLES20.glGetAttribLocation(getProgram(), "aPosition");
		aTextureCoordinate = GLES20.glGetAttribLocation(getProgram(), "aTextureCoordinate");
		uInputTexture = GLES20.glGetUniformLocation(getProgram(), "uInputTexture");
		
		// 填充着色器-顶点采样器
		if( getVertexBuffer() != null ) {
			// 顶点每次读取2个值, 每4个元素(4 * 4 = 16byte)为下一组顶点开始
			getVertexBuffer().position(0);
	        GLES20.glVertexAttribPointer(aPosition, 2, GLES20.GL_FLOAT, false, 16, getVertexBuffer());
	        GLES20.glEnableVertexAttribArray(aPosition);
	        
	        // 填充着色器-纹理坐标
	        // 纹理坐标每次读取2个值, 每4个元素(4 * 4 = 16byte)为下一组纹理坐标开始
	        getVertexBuffer().position(2);
	        GLES20.glVertexAttribPointer(aTextureCoordinate, 2, GLES20.GL_FLOAT, false, 16, getVertexBuffer());
	        GLES20.glEnableVertexAttribArray(aTextureCoordinate);
		}
		
		// 填充着色器-颜色采样器, 将纹理单元GL_TEXTURE0绑元定到采样器
		GLES20.glUniform1i(uInputTexture, 0);
	}
	
	@Override
	protected int onDrawFrame(int textureId) {
		// 绘制
		GLES20.glDrawArrays(GLES20.GL_TRIANGLES, 0, 6);
		
		return super.onDrawFrame(textureId);
	}
	
	@Override
	protected void onDrawFinish(int textureId) {
		// 取消着色器参数绑定
		GLES20.glDisableVertexAttribArray(aPosition);  
		GLES20.glDisableVertexAttribArray(aTextureCoordinate);
		
		// 解除纹理绑定
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);
	}
	
}
