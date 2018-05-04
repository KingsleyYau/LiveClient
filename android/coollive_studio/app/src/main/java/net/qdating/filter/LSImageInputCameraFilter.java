package net.qdating.filter;

import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import net.qdating.utils.Log;

import net.qdating.LSConfig;

/**
 * 摄像头输出滤镜
 * @author max
 *
 */
public class LSImageInputCameraFilter extends LSImageBufferFilter {
	private static String vertexShaderString = ""
			+ "// 摄像头顶点着色器\n"
			+ "// 摄像头矩阵转换(输入)\n"
			+ "uniform mat4 uTextureMatrix;\n"
			+ "// 世界坐标,绘制区域(输入)\n"
			+ "attribute vec4 aPosition;\n"
			+ "// 纹理坐标,绘制图像(输入)\n"
			+ "attribute vec4 aTextureCoordinate;\n"
			+ "// 片段着色器(输出)\n"
			+ "varying vec2 vTextureCoordinate;\n"
			+ "void main() {\n"
			+ "vTextureCoordinate = (uTextureMatrix * aTextureCoordinate).xy;\n"
			+ "gl_Position = aPosition;\n"
			+ "}\n";
	private static String fragmentShaderString = ""
			+ "#extension GL_OES_EGL_image_external : require\n"
			+ "precision mediump float;\n"
			+ "// 摄像头颜色着色器\n"
			+ "uniform samplerExternalOES uInputTexture;\n"
			+ "// 片段着色器(输入)\n"
			+ "varying vec2 vTextureCoordinate;\n"
			+ "void main() {\n"
			+ "gl_FragColor = texture2D(uInputTexture, vTextureCoordinate);\n"
			+ "}\n";
	
	/**
	 * 纹理坐标矩阵
	 */
	private float[] transformMatrix = null;

	private int uTextureMatrix;
	private int aPosition;
	private int aTextureCoordinate;
	private int uInputTexture;

	private float width = 1f;
	private float height = 1f;

	public LSImageInputCameraFilter() {
		super(vertexShaderString, fragmentShaderString, LSImageVertex.filterVertex_0);
	}

	public void updateMatrix(float[] transformMatrix) {
		this.transformMatrix = transformMatrix;
	}
	
	@Override
	public void init() {
		super.init();
	}
	
	@Override
	protected void onDrawStart(int textureId) {
		super.onDrawStart(textureId);

		// 激活纹理单元GL_TEXTURE0
		GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
		// 绑定外部纹理到纹理单元GL_TEXTURE0
		GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textureId);
		
		uTextureMatrix = GLES20.glGetUniformLocation(getProgram(), "uTextureMatrix");
		aPosition = GLES20.glGetAttribLocation(getProgram(), "aPosition");
		aTextureCoordinate = GLES20.glGetAttribLocation(getProgram(), "aTextureCoordinate");
		uInputTexture = GLES20.glGetUniformLocation(getProgram(), "uInputTexture");
		
		// 填充着色器-纹理矩阵
		GLES20.glUniformMatrix4fv(uTextureMatrix, 1, false, transformMatrix, 0);
		
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
		
		// 填充着色器-纹理采样器, 将纹理单元GL_TEXTURE0绑元定到采样器
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
		GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, 0);
		
		super.onDrawFinish(textureId);
	}

}
