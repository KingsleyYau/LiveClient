package net.qdating.filter;

import android.opengl.GLES20;

import net.qdating.LSConfig;
import net.qdating.utils.Log;

/**
 * 美颜滤镜
 * @author max
 *
 */
public class LSImageBeautyFilter extends LSImageBufferFilter {
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
			+ "uniform highp vec2 uSingleStepOffset; \n"
			+ "uniform highp vec4 uParams; \n"
			+ "uniform highp float uBrightness; \n"
			+ "// 片段着色器(输入) \n"
			+ "varying highp vec2 vTextureCoordinate; \n"

			+ "highp float hardLight(highp float color) { \n"
			+ "		if (color <= 0.5) \n"
			+ "			color = color * color * 2.0; \n"
			+ "		else \n"
			+ "			color = 1.0 - ((1.0 - color)*(1.0 - color) * 2.0); \n"
			+ "		return color; \n"
			+ "} \n"

			+ "void main() { \n"
			+ "highp vec3 centralColor = texture2D(uInputTexture, vTextureCoordinate).rgb; \n"

			+ "highp vec2 blurCoordinates[24]; \n"
			+ "blurCoordinates[0] = vTextureCoordinate.xy + uSingleStepOffset * vec2(0.0, -10.0); \n"
			+ "blurCoordinates[1] = vTextureCoordinate.xy + uSingleStepOffset * vec2(0.0, 10.0); \n"
			+ "blurCoordinates[2] = vTextureCoordinate.xy + uSingleStepOffset * vec2(-10.0, 0.0); \n"
			+ "blurCoordinates[3] = vTextureCoordinate.xy + uSingleStepOffset * vec2(10.0, 0.0); \n"
			+ "blurCoordinates[4] = vTextureCoordinate.xy + uSingleStepOffset * vec2(5.0, -8.0); \n"
			+ "blurCoordinates[5] = vTextureCoordinate.xy + uSingleStepOffset * vec2(5.0, 8.0); \n"
			+ "blurCoordinates[6] = vTextureCoordinate.xy + uSingleStepOffset * vec2(-5.0, 8.0); \n"
			+ "blurCoordinates[7] = vTextureCoordinate.xy + uSingleStepOffset * vec2(-5.0, -8.0); \n"
			+ "blurCoordinates[8] = vTextureCoordinate.xy + uSingleStepOffset * vec2(8.0, -5.0); \n"
			+ "blurCoordinates[9] = vTextureCoordinate.xy + uSingleStepOffset * vec2(8.0, 5.0); \n"
			+ "blurCoordinates[10] = vTextureCoordinate.xy + uSingleStepOffset * vec2(-8.0, 5.0); \n"
			+ "blurCoordinates[11] = vTextureCoordinate.xy + uSingleStepOffset * vec2(-8.0, -5.0); \n"
			+ "blurCoordinates[12] = vTextureCoordinate.xy + uSingleStepOffset * vec2(0.0, -6.0); \n"
			+ "blurCoordinates[13] = vTextureCoordinate.xy + uSingleStepOffset * vec2(0.0, 6.0); \n"
			+ "blurCoordinates[14] = vTextureCoordinate.xy + uSingleStepOffset * vec2(6.0, 0.0); \n"
			+ "blurCoordinates[15] = vTextureCoordinate.xy + uSingleStepOffset * vec2(-6.0, 0.0); \n"
			+ "blurCoordinates[16] = vTextureCoordinate.xy + uSingleStepOffset * vec2(-4.0, -4.0); \n"
			+ "blurCoordinates[17] = vTextureCoordinate.xy + uSingleStepOffset * vec2(-4.0, 4.0); \n"
			+ "blurCoordinates[18] = vTextureCoordinate.xy + uSingleStepOffset * vec2(4.0, -4.0); \n"
			+ "blurCoordinates[19] = vTextureCoordinate.xy + uSingleStepOffset * vec2(4.0, 4.0); \n"
			+ "blurCoordinates[20] = vTextureCoordinate.xy + uSingleStepOffset * vec2(-2.0, -2.0); \n"
			+ "blurCoordinates[21] = vTextureCoordinate.xy + uSingleStepOffset * vec2(-2.0, 2.0); \n"
			+ "blurCoordinates[22] = vTextureCoordinate.xy + uSingleStepOffset * vec2(2.0, -2.0); \n"
			+ "blurCoordinates[23] = vTextureCoordinate.xy + uSingleStepOffset * vec2(2.0, 2.0); \n"

			+ "highp float sampleColor = centralColor.g * 22.0; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[0]).g; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[1]).g; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[2]).g; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[3]).g; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[4]).g; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[5]).g; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[6]).g; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[7]).g; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[8]).g; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[9]).g; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[10]).g; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[11]).g; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[12]).g * 2.0; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[13]).g * 2.0; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[14]).g * 2.0; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[15]).g * 2.0; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[16]).g * 2.0; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[17]).g * 2.0; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[18]).g * 2.0; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[19]).g * 2.0; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[20]).g * 3.0; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[21]).g * 3.0; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[22]).g * 3.0; \n"
			+ "sampleColor += texture2D(uInputTexture, blurCoordinates[23]).g * 3.0; \n"
			+ "sampleColor = sampleColor / 62.0; \n"

			+ "highp float highPass = centralColor.g - sampleColor + 0.5; \n"
			+ "for (int i = 0;  i < 5; i++) { \n"
			+ "		highPass = hardLight(highPass); \n"
			+ "} \n"

			+ " // RGB转YUV \n"
			+ "const highp vec3 v3RGB = vec3(0.299, 0.587, 0.114); \n"
			+ " // 转换后的YUV \n"
			+ "highp float lumance = dot(centralColor, v3RGB); \n"
			+ " // 计算出新的alpha \n"
			+ "highp float alpha = pow(lumance, uParams.r); \n"
			+ " // 开始磨皮(模糊) \n"
			+ "highp vec3 smoothColor = centralColor + (centralColor - vec3(highPass)) * alpha * 0.1; \n"

			+ " // 因为坐标可能是(-1~1), clamp来保证为(0~1) \n"
			+ "smoothColor.r = clamp(pow(smoothColor.r, uParams.g), 0.0, 1.0); \n"
			+ "smoothColor.g = clamp(pow(smoothColor.g, uParams.g), 0.0, 1.0); \n"
			+ "smoothColor.b = clamp(pow(smoothColor.b, uParams.g), 0.0, 1.0); \n"

			+ "highp vec3 lvse = vec3(1.0) - (vec3(1.0) - smoothColor) * (vec3(1.0) - centralColor); \n"
			+ "highp vec3 bianliang = max(smoothColor, centralColor); \n"
			+ "highp vec3 rouguang = 2.0 * centralColor * smoothColor + centralColor*centralColor - 2.0 * centralColor*centralColor * smoothColor; \n"

			+ "gl_FragColor = vec4(mix(centralColor, lvse, alpha), 1.0); \n"
			+ "gl_FragColor.rgb = mix(gl_FragColor.rgb, bianliang, alpha); \n"
			+ "gl_FragColor.rgb = mix(gl_FragColor.rgb, rouguang, uParams.b); \n"

			+ "const highp mat3 saturateMatrix = mat3( \n"
			+ "		1.1102, -0.0598, -0.061, \n"
			+ "		-0.0774, 1.0826, -0.1186, \n"
			+ "		-0.0228, -0.0228, 1.1772 \n"
			+ "); \n"

			+ "highp vec3 satcolor = gl_FragColor.rgb * saturateMatrix; \n"
			+ "gl_FragColor.rgb = mix(gl_FragColor.rgb, satcolor, uParams.a); \n"
			+ "gl_FragColor.rgb = vec3(gl_FragColor.rgb + vec3(uBrightness)); \n"

			+ "}\n";

	private float toneLevel = 0.5f;
	private float beautyLevel = 0.5f;
	private float brightLevel = 0.5f;

	private int aPosition;
	private int aTextureCoordinate;
	private int uInputTexture;
	private int uSingleStepOffset;
	private int uParams;
	private int uBrightness;

	public LSImageBeautyFilter() {
		super(vertexShaderString, fragmentShaderString, LSImageVertex.filterVertex_0);
		// TODO Auto-generated constructor stub
	}

	/*
	* @param beautyLevel 美颜等级
	* @param brightLevel 亮度等级
	* */
	public LSImageBeautyFilter(float beautyLevel) {
		super(vertexShaderString, fragmentShaderString, LSImageVertex.filterVertex_0);
		// TODO Auto-generated constructor stub
		this.beautyLevel = beautyLevel;
	}

	/**
	 * 设置美颜等级
	 * @param beautyLevel
	 */
	public void setBeautyLevel(float beautyLevel) {
		Log.d(LSConfig.TAG,
				String.format("LSImageBeautyFilter::setBeautyLevel( "
								+ "beautyLevel : %f "
								+ ")",
						beautyLevel
				)
		);

	    this.beautyLevel = beautyLevel;
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

		uSingleStepOffset = GLES20.glGetUniformLocation(getProgram(), "uSingleStepOffset");
		uBrightness = GLES20.glGetUniformLocation(getProgram(), "uBrightness");
		uParams = GLES20.glGetUniformLocation(getProgram(), "uParams");

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
		// 填充着色器
		float offset[] = {2.0f / viewPointWidth, 2.0f / viewPointHeight};
		GLES20.glUniform2f(uSingleStepOffset, offset[0], offset[1]);
		GLES20.glUniform1f(uBrightness, 0.6f * (-0.5f + brightLevel));
		float params[] = {1.0f - 0.6f * beautyLevel, 1.0f - 0.3f * beautyLevel, 0.1f + 0.3f * toneLevel, 0.1f + 0.3f * toneLevel};
		GLES20.glUniform4f(uParams, params[0], params[1], params[2], params[3]);
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
