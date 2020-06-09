package net.qdating.filter;

import android.opengl.GLES20;

import net.qdating.LSConfig;
import net.qdating.utils.Log;

import java.util.Random;

/**
 * 抖音滤镜
 * @author max
 *
 */
public class LSImageVibrateFilter extends LSImageBufferFilter {
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
			+ "uniform lowp vec2 uImagePixel; \n"
			+ "uniform lowp vec2 uOffet; \n"
			+ "// 片段着色器(输入) \n"
			+ "varying highp vec2 vTextureCoordinate; \n"
			+ "void main() { \n"
			+ "		// 绿和蓝右下偏移 \n"
			+ "		vec4 right = texture2D(uInputTexture, vTextureCoordinate + uImagePixel * uOffet); \n"
			+ "		// 红左上偏移 \n"
			+ "		vec4 left = texture2D(uInputTexture, vTextureCoordinate - uImagePixel * uOffet); \n"
			+ "		gl_FragColor = vec4(left.r, right.g, right.b, 1.0); \n"
			+ "} \n";

	private int aPosition;
	private int aTextureCoordinate;
	private int uInputTexture;
	private int uImagePixel;
	private int uOffet;

	private float uvImagePixel[] = new float[2];

	private Random rnd = new Random();

	static private int VIBRATE_OFFSET_MAX = 10;
	private int vibrateOffset = 5;

	public LSImageVibrateFilter() {
		super(vertexShaderString, fragmentShaderString, LSImageVertex.filterVertex_0);
		// TODO Auto-generated constructor stub
	}

	public LSImageVibrateFilter(double level) {
		super(vertexShaderString, fragmentShaderString, LSImageVertex.filterVertex_0);
		// TODO Auto-generated constructor stub
		this.vibrateOffset = (int)(level * VIBRATE_OFFSET_MAX);
	}

	/**
	 * 设置抖动等级
	 * @param level 0.0 ~ 1.0
	 */
	public void setlevel(double level) {
		Log.d(LSConfig.TAG,
				String.format("LSImageVibrateFilter::setlevel( "
								+ "level : %f "
								+ ")",
						level
				)
		);

		this.vibrateOffset = (int)(level * VIBRATE_OFFSET_MAX);
	}

	@Override
	protected ImageSize changeInputSize(int inputWidth, int inputHeight) {
		ImageSize imageSize = super.changeInputSize(inputWidth, inputHeight);

		if( imageSize.bChange ) {
			uvImagePixel[0] = 1.0f / inputWidth;
			uvImagePixel[1] = 1.0f / inputHeight;
		}

		return imageSize;
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
		uImagePixel = GLES20.glGetUniformLocation(getProgram(), "uImagePixel");
		uOffet = GLES20.glGetUniformLocation(getProgram(), "uOffet");

		// 填充着色器-顶点采样器
		if( getVertexBuffer() != null ) {
			// 顶点每次读取2个值, 每4个元素,[跨过2个着色器](4 * 4byte = 16byte)为下一组顶点开始
			getVertexBuffer().position(0);
			GLES20.glVertexAttribPointer(aPosition, 2, GLES20.GL_FLOAT, false, 16, getVertexBuffer());
			GLES20.glEnableVertexAttribArray(aPosition);

			// 填充着色器-纹理坐标
			// 纹理坐标每次读取2个值, 每4个元素,[跨过2个着色器](4 * 4byte = 16byte)为下一组纹理坐标开始
			getVertexBuffer().position(2);
			GLES20.glVertexAttribPointer(aTextureCoordinate, 2, GLES20.GL_FLOAT, false, 16, getVertexBuffer());
			GLES20.glEnableVertexAttribArray(aTextureCoordinate);
		}

		// 填充着色器-颜色采样器, 将纹理单元GL_TEXTURE0绑元定到采样器
		GLES20.glUniform1i(uInputTexture, 0);

		// 填充着色器
		GLES20.glUniform2f(uImagePixel, uvImagePixel[0], uvImagePixel[1]);

		int num = rnd.nextInt() % vibrateOffset;
		float uvOffset[] = {num, num};
		GLES20.glUniform2f(uOffet, uvOffset[0], uvOffset[1]);
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
