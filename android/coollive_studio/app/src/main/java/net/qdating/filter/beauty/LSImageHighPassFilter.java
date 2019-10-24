package net.qdating.filter.beauty;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.opengl.GLES20;
import android.opengl.GLUtils;

import net.qdating.filter.LSImageBufferFilter;
import net.qdating.filter.LSImageFilter;
import net.qdating.filter.LSImageVertex;

import java.io.File;

/**
 * 高通滤波滤镜
 * @author max
 *
 */
public class LSImageHighPassFilter extends LSImageBufferFilter {
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
			+ "uniform sampler2D uBlurTexture; \n"
			+ "const float intensity = 24.0; // 强光程度 \n"
			+ "// 片段着色器(输入) \n"
			+ "varying highp vec2 vTextureCoordinate; \n"
			+ "void main() { \n"
			+ "		lowp vec4 textureColor = texture2D(uInputTexture, vTextureCoordinate); \n"
			+ "		lowp vec4 blurColor = texture2D(uBlurTexture, vTextureCoordinate); \n"
			+ "		// 高通滤波之后的颜色值 \n "
			+ "		highp vec4 highPassColor = textureColor - blurColor; \n"
			+ "		// 对应混合模式中的强光模式(color = 2.0 * color1 * color2)，对于高反差的颜色来说，color1 和color2 是同一个 \n"
			+ "		highPassColor.r = clamp(2.0 * highPassColor.r * highPassColor.r * intensity, 0.0, 1.0); \n"
			+ "		highPassColor.g = clamp(2.0 * highPassColor.g * highPassColor.g * intensity, 0.0, 1.0); \n"
			+ "		highPassColor.b = clamp(2.0 * highPassColor.b * highPassColor.b * intensity, 0.0, 1.0); \n"
			+ "		// 输出的是把痘印等过滤掉 \n"
			+ "		gl_FragColor = vec4(highPassColor.rgb, 1.0); \n"
			+ "}\n";

	private int aPosition;
	private int aTextureCoordinate;
	private int uInputTexture;

	private int blurTextureId;
	private int uBlurTexture;

	public LSImageHighPassFilter() {
		super(vertexShaderString, fragmentShaderString, LSImageVertex.filterVertex_0);
		// TODO Auto-generated constructor stub
	}

	public void setBlurTexture(int textureId) {
		blurTextureId = textureId;
	}

	@Override
	public void init() {
		super.init();

		uBlurTexture = GLES20.glGetUniformLocation(getProgram(), "uBlurTexture");
	}

	@Override
	protected void onDrawStart(int textureId) {
		super.onDrawStart(textureId);

		// 绑定图像纹理
        GLES20.glActiveTexture(GLES20.GL_TEXTURE1);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, blurTextureId);
		GLES20.glUniform1i(uBlurTexture, 1);

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
