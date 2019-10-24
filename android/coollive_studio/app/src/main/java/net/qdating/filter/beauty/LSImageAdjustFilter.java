package net.qdating.filter.beauty;

import android.opengl.GLES20;

import net.qdating.LSConfig;
import net.qdating.filter.LSImageBufferFilter;
import net.qdating.filter.LSImageVertex;
import net.qdating.utils.Log;

/**
 * 美颜滤镜
 * @author max
 *
 */
public class LSImageAdjustFilter extends LSImageBufferFilter {
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
			+ "// 原图的高斯模糊纹理 \n"
			+ "uniform sampler2D uBlurTexture; \n"
			+ "// 高反差保留的高斯模糊纹理 \n"
			+ "uniform sampler2D uHighPassBlurTexture; \n"
			+ "// 磨皮程度 \n"
			+ "uniform lowp float uBeautyLevel; \n"
			+ "// 片段着色器(输入) \n"
			+ "varying highp vec2 vTextureCoordinate; \n"
			+ "void main() { \n"
			+ "		lowp vec4 textureColor = texture2D(uInputTexture, vTextureCoordinate); \n"
			+ "		lowp vec4 blurColor = texture2D(uBlurTexture, vTextureCoordinate); \n"
			+ "		lowp vec4 highPassBlurColor = texture2D(uHighPassBlurTexture, vTextureCoordinate); \n"
			+ "		// 调节蓝色通道值 \n"
			+ "		mediump float value = clamp((min(textureColor.b, blurColor.b) - 0.2) * 5.0, 0.0, 1.0); \n"
			+ "		// 找到模糊之后RGB通道的最大值 \n"
			+ "		mediump float maxChannelColor = max(max(highPassBlurColor.r, highPassBlurColor.g), highPassBlurColor.b); \n"
			+ "		// 计算当前的强度 \n"
			+ "		mediump float currentIntensity = (1.0 - maxChannelColor / (maxChannelColor + 0.2)) * value * uBeautyLevel; \n"
			+ "		// 混合输出结果 \n"
			+ "		lowp vec3 resultColor = mix(textureColor.rgb, blurColor.rgb, currentIntensity); \n"
			+ "		// 输出颜色 \n"
			+ "		gl_FragColor = vec4(resultColor, 1.0); \n"
			+ "}\n";

	private int aPosition;
	private int aTextureCoordinate;
	private int uInputTexture;

	private int blurTextureId;
	private int uBlurTexture;

	private int highPassBlurTextureId;
	private int uHighPassBlurTexture;

	private int uBeautyLevel;

	public LSImageAdjustFilter() {
		super(vertexShaderString, fragmentShaderString, LSImageVertex.filterVertex_0);
		// TODO Auto-generated constructor stub
	}

	private float beautyLevel = 1.0f;

	/**
	 * 设置美颜等级
	 * @param beautyLevel [0.0, 1.0]
	 */
	public void setBeautyLevel(float beautyLevel) {
		Log.d(LSConfig.TAG,
				String.format("LSImageAdjustFilter::setBeautyLevel( "
								+ "beautyLevel : %f "
								+ ")",
						beautyLevel
				)
		);

		this.beautyLevel = beautyLevel;
	}

	public void setBlurTexture(int blurTextureId, int highPassBlurTextureId) {
		blurTextureId = blurTextureId;
		highPassBlurTextureId = highPassBlurTextureId;
	}

	@Override
	public void init() {
		super.init();

		uBlurTexture = GLES20.glGetUniformLocation(getProgram(), "uBlurTexture");
		uHighPassBlurTexture = GLES20.glGetUniformLocation(getProgram(), "uHighPassBlurTexture");
	}

	@Override
	protected void onDrawStart(int textureId) {
		super.onDrawStart(textureId);

		// 绑定图像纹理
        GLES20.glActiveTexture(GLES20.GL_TEXTURE1);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, blurTextureId);
		GLES20.glUniform1i(uBlurTexture, 1);

		// 绑定图像纹理
		GLES20.glActiveTexture(GLES20.GL_TEXTURE2);
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, highPassBlurTextureId);
		GLES20.glUniform1i(uHighPassBlurTexture, 2);

		// 激活纹理单元GL_TEXTURE0
		GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
		// 绑定外部纹理到纹理单元GL_TEXTURE0
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureId);

		aPosition = GLES20.glGetAttribLocation(getProgram(), "aPosition");
		aTextureCoordinate = GLES20.glGetAttribLocation(getProgram(), "aTextureCoordinate");
		uInputTexture = GLES20.glGetUniformLocation(getProgram(), "uInputTexture");

		uBeautyLevel = GLES20.glGetUniformLocation(getProgram(), "uBeautyLevel");

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

		GLES20.glUniform1f(uBeautyLevel, beautyLevel);

		// 填充着色器-颜色采样器, 将纹理单元GL_TEXTURE0绑元定到采样器
		GLES20.glUniform1i(uInputTexture, 0);
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
