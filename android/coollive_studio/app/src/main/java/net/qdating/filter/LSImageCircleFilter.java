package net.qdating.filter;

import android.opengl.GLES20;

import java.util.Random;

/**
 * 颜色闪烁滤镜
 * @author max
 *
 */
public class LSImageCircleFilter extends LSImageBufferFilter {
	private static String vertexShaderString = ""
			+ "// 图像顶点着色器 \n"
			+ "// 纹理坐标(输入) \n"
			+ "attribute vec4 aPosition; \n"
			+ "// 自定义屏幕坐标(输入) \n"
			+ "attribute vec4 aTextureCoordinate; \n"
			+ "// 片段着色器(输出) \n"
			+ "varying vec2 vTextureCoordinate; \n"
			+ "void main() { \n"
			+ "		vTextureCoordinate = aTextureCoordinate.xy; \n"
			+ "		gl_Position = aPosition; \n"
			+ "} \n";

	private static String fragmentShaderString = ""
			+ "// 图像颜色着色器 \n"
            + "precision mediump float; \n"
			+ "uniform sampler2D uInputTexture; \n"
			+ "uniform lowp int uColor; \n"
			+ "// 片段着色器(输入) \n"
			+ "varying highp vec2 vTextureCoordinate; \n"
			+ "void main() { \n"
			+ "		vec3 color = texture2D(uInputTexture, vTextureCoordinate).rgb; \n "
			+ "		vec2 xy = vTextureCoordinate.xy; \n "
			+ "		if( pow(xy.x, 2.) == xy.y ) { \n"
			+ "			gl_FragColor = vec4(0, 1, 0, 1); \n"
			+ "		} else { \n"
			+ "			gl_FragColor = vec4(color.r, color.g, color.b, 1.0); \n"
			+ "		} \n"
			+ "} \n";

	private int aPosition;
	private int aTextureCoordinate;
	private int uInputTexture;
	private int uColor;

	private Random rnd = new Random();
	private int index = 0;
	private int rndNum = 0;
	private int step = 3;

	public LSImageCircleFilter() {
		super(vertexShaderString, fragmentShaderString, LSImageVertex.filterVertex_0);
		// TODO Auto-generated constructor stub
	}

	/**
	 * 设置颜色持续多少帧
	 * @param step
	 */
	public void setStep(int step) {
		this.step = step;
	}

	@Override
	protected void onDrawStart(int textureId) {
		super.onDrawStart(textureId);

		// 激活纹理单元GL_TEXTURE0
		GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
		// 绑定外部纹理到纹理单元GL_TEXTURE0
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureId);

		aPosition = GLES20.glGetAttribLocation(getProgram(), "aPosition");
		aTextureCoordinate = GLES20.glGetAttribLocation(getProgram(), "aTextureCoordinate");
		uInputTexture = GLES20.glGetUniformLocation(getProgram(), "uInputTexture");
		uColor = GLES20.glGetUniformLocation(getProgram(), "uColor");

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

//		if( index++ % this.step == 0) {
//			// 填充着色器
//			int num = rnd.nextInt() % 5;
//			rndNum = num;
//		}
//		GLES20.glUniform1i(uColor, rndNum);
	}

	@Override
	protected int onDrawFrame(int textureId) {
		int newTextureId = super.onDrawFrame(textureId);

		// 绘制
		GLES20.glDrawArrays(GLES20.GL_TRIANGLES, 0, 6);

		return newTextureId;
	}

	@Override
	protected void onDrawFinish(int textureId) {
		// 取消着色器参数绑定
		GLES20.glDisableVertexAttribArray(aPosition);
		GLES20.glDisableVertexAttribArray(aTextureCoordinate);

		// 解除纹理绑定
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);

		super.onDrawFinish(textureId);
	}
}
