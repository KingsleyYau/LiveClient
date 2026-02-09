package net.qdating.filter.beauty;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.opengl.GLES20;
import android.opengl.GLUtils;

import net.qdating.LSConfig;
import net.qdating.filter.LSImageBufferFilter;
import net.qdating.filter.LSImageFilter;
import net.qdating.filter.LSImageVertex;
import net.qdating.utils.Log;

import java.io.File;

/**
 * 高斯模糊滤镜
 * @author max
 *
 */
public class LSImageBlurFilter extends LSImageBufferFilter {
	private static String vertexShaderString = ""
			+ "// 图像顶点着色器 \n"
			+ "// 纹理坐标(输入) \n"
			+ "attribute vec4 aPosition; \n"
			+ "// 自定义屏幕坐标(输入) \n"
			+ "attribute vec4 aTextureCoordinate; \n"
			+ "uniform highp float uTexelWidthOffset; \n"
			+ "uniform highp float uTexelHeightOffset; \n"
			+ "// 片段着色器(输出) \n"
			+ "varying vec2 vTextureCoordinate; \n"
			+ "const int SHIFT_SIZE = 5; \n"
			+ "varying vec4 blurShiftCoordinates[SHIFT_SIZE]; \n"
			+ "void main() { \n"
			+ "		vTextureCoordinate = aTextureCoordinate.xy; \n"
			+ "		gl_Position = aPosition; \n"
			+ "		// 偏移步距 \n"
			+ "		vec2 singleStepOffset = vec2(uTexelWidthOffset, uTexelHeightOffset); \n"
			+ "		// 记录偏移坐标 \n"
			+ "		for (int i = 0; i < SHIFT_SIZE; i++) { \n"
			+ "			blurShiftCoordinates[i] = vec4(vTextureCoordinate.xy - float(i + 1) * singleStepOffset, vTextureCoordinate.xy + float(i + 1) * singleStepOffset); \n"
			+ "		} \n"
			+ "} \n";

	private static String fragmentShaderString = ""
			+ "// 图像颜色着色器 \n"
            + "precision mediump float; \n"
			+ "uniform sampler2D uInputTexture; \n"
			+ "// 片段着色器(输入) \n"
			+ "varying highp vec2 vTextureCoordinate; \n"
			+ "const int SHIFT_SIZE = 5; \n"
			+ "varying vec4 blurShiftCoordinates[SHIFT_SIZE]; \n"
			+ "void main() { \n"
			+ "		vec4 textureColor = texture2D(uInputTexture, vTextureCoordinate); \n"
			+ "		mediump vec3 sum = textureColor.rgb; \n"
			+ "		// 计算偏移坐标的颜色值总和 \n"
			+ "		for (int i = 0; i < SHIFT_SIZE; i++) { \n"
			+ "			sum += texture2D(uInputTexture, blurShiftCoordinates[i].xy).rgb; \n"
			+ "			sum += texture2D(uInputTexture, blurShiftCoordinates[i].zw).rgb; \n"
			+ "		} \n"
			+ "		// 求出平均值 \n"
			+ "		gl_FragColor = vec4(sum * 1.0 / float(2 * SHIFT_SIZE + 1), textureColor.a); \n"
			+ "}\n";

	private int aPosition;
	private int aTextureCoordinate;
	private int uInputTexture;

	private int uTexelWidthOffset;
	private int uTexelHeightOffset;

	public enum FlipType {
		FlipType_Vertical,
		FlipType_Horizontal
	}
	private FlipType mFlipType = FlipType.FlipType_Horizontal;

	public LSImageBlurFilter() {
		super(vertexShaderString, fragmentShaderString, LSImageVertex.filterVertex_0);
		// TODO Auto-generated constructor stub
	}

	public LSImageBlurFilter(LSImageBlurFilter.FlipType type) {
		super(vertexShaderString, fragmentShaderString, LSImageVertex.filterVertex_0);
		// TODO Auto-generated constructor stub
		mFlipType = type;
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

		uTexelWidthOffset = GLES20.glGetUniformLocation(getProgram(), "uTexelWidthOffset");
		uTexelHeightOffset = GLES20.glGetUniformLocation(getProgram(), "uTexelHeightOffset");

		if ( mFlipType == FlipType.FlipType_Horizontal ) {
			GLES20.glUniform1f(uTexelWidthOffset, 1.0f / inputWidth);
			GLES20.glUniform1f(uTexelHeightOffset, 0);
		} else {
			GLES20.glUniform1f(uTexelWidthOffset, 0);
			GLES20.glUniform1f(uTexelHeightOffset, 1.0f / inputHeight);
		}

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
