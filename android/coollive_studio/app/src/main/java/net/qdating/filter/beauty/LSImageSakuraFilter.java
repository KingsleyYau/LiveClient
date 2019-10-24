package net.qdating.filter.beauty;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.opengl.GLES20;
import android.opengl.GLUtils;

import net.qdating.LSConfig;
import net.qdating.filter.LSImageBufferFilter;
import net.qdating.filter.LSImageFilter;
import net.qdating.filter.LSImageVertex;
import net.qdating.utils.Log;

import java.io.IOException;
import java.io.InputStream;

/**
 * 滤镜
 * @author max
 *
 */
public class LSImageSakuraFilter extends LSImageBufferFilter {
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

			+ "// 片段着色器(输入) \n"
			+ "varying highp vec2 vTextureCoordinate; \n"

			+ "uniform sampler2D uMapTexture; \n"
			+ "uniform sampler2D uCurveTexture; \n"

			+ "uniform float uTexelWidthOffset; \n"
			+ "uniform float uTexelHeightOffset; \n"
			+ "uniform float uStrength; \n"

			+ "vec4 gaussianBlur(sampler2D sampler) { \n"
			+ "		lowp float strength = 1.; \n"
			+ "		vec4 color = vec4(0.); \n"
			+ "		vec2 step  = vec2(0.); \n"
			+ "		color += texture2D(sampler, vTextureCoordinate)* 0.25449 ; \n"
			+ "		step.x = 1.37754 * uTexelWidthOffset  * uStrength; \n"
			+ "		step.y = 1.37754 * uTexelHeightOffset * uStrength; \n"
			+ "		color += texture2D(sampler, vTextureCoordinate + step) * 0.24797; \n"
			+ "		color += texture2D(sampler, vTextureCoordinate - step) * 0.24797; \n"
			+ "		step.x = 3.37754 * uTexelWidthOffset  * uStrength; \n"
			+ "		step.y = 3.37754 * uTexelHeightOffset * uStrength; \n"
			+ "		color += texture2D(sampler, vTextureCoordinate + step) * 0.09122; \n"
			+ "		color += texture2D(sampler, vTextureCoordinate - step) * 0.09122; \n"
			+ "		step.x = 5.37754 * uTexelWidthOffset  * uStrength; \n"
			+ "		step.y = 5.37754 * uTexelHeightOffset * uStrength; \n"
			+ "		color += texture2D(sampler, vTextureCoordinate + step) * 0.03356; \n"
			+ "		color += texture2D(sampler, vTextureCoordinate - step) * 0.03356; \n"
			+ "		return color; \n"
			+ "} \n"

			+ "vec4 overlay(vec4 c1, vec4 c2) { \n"
			+ "vec4 r1 = vec4(0.,0.,0.,1.); \n"
			+ "		r1.r = c1.r < 0.5 ? 2.0*c1.r*c2.r : 1.0 - 2.0*(1.0-c1.r)*(1.0-c2.r); \n"
			+ "		r1.g = c1.g < 0.5 ? 2.0*c1.g*c2.g : 1.0 - 2.0*(1.0-c1.g)*(1.0-c2.g); \n"
			+ "		r1.b = c1.b < 0.5 ? 2.0*c1.b*c2.b : 1.0 - 2.0*(1.0-c1.b)*(1.0-c2.b); \n"
			+ "return r1; \n"
			+ "} \n"

			+ "vec4 level0c(vec4 color, sampler2D sampler) { \n"
			+ "		color.r = texture2D(sampler, vec2(color.r, 0.)).r; \n"
			+ "		color.g = texture2D(sampler, vec2(color.g, 0.)).r; \n"
			+ "		color.b = texture2D(sampler, vec2(color.b, 0.)).r; \n"
			+ "		return color; \n"
			+ "} \n"

			+ "vec4 normal(vec4 c1, vec4 c2, float alpha) { \n"
			+ "		return (c2-c1) * alpha + c1; \n"
			+ "} \n"

			+ "vec4 screen(vec4 c1, vec4 c2) { \n"
			+ "		vec4 r1 = vec4(1.) - ((vec4(1.) - c1) * (vec4(1.) - c2)); \n"
			+ "		return r1; \n"
			+ "} \n"

			+ "void main() { \n"
			+ "		vec4 sourceColor = texture2D(uInputTexture, vTextureCoordinate); \n"
			+ "		lowp vec4 blurColor = gaussianBlur(uInputTexture); \n"
			+ "		lowp vec4 overlayColor = overlay(sourceColor, level0c(blurColor, uCurveTexture)); \n"
			+ "		lowp vec4 textureColor = normal(sourceColor, overlayColor, 0.15); \n"
			+ "		gl_FragColor = mix(sourceColor, textureColor, uStrength); \n"
			+ "}\n";


	private int aPosition;
	private int aTextureCoordinate;
	private int uInputTexture;

	private int[] curveTextureId;
	private int uCurveTexture;
	private Bitmap curveBitmap;

	private int uTexelWidthOffset;
	private int uTexelHeightOffset;
	private int uStrength;

	public LSImageSakuraFilter(Context context) {
		super(vertexShaderString, fragmentShaderString, LSImageVertex.filterVertex_0);
		// TODO Auto-generated constructor stub
		try {
			InputStream curveInputStream = context.getAssets().open("filters/sakura/curve.png");
			curveBitmap = BitmapFactory.decodeStream(curveInputStream);
			curveInputStream.close();

		} catch (IOException e) {
			e.printStackTrace();
		}

		if ( curveBitmap == null ) {
			Log.e(LSConfig.TAG, String.format("LSImageSakuraFilter::LSImageSakuraFilter( this : 0x%x, [Input Image is null] )", this.hashCode()));
		}
	}

	@Override
	public void init() {
		super.init();

		uCurveTexture = GLES20.glGetUniformLocation(getProgram(), "uCurveTexture");
		curveTextureId = LSImageFilter.genPixelTexture();
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, curveTextureId[0]);
		GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, curveBitmap, 0);
	}

	@Override
	public void uninit() {
		super.uninit();

		deleteTexture(curveTextureId);
		if ( curveBitmap != null ) {
			curveBitmap.recycle();
			curveBitmap = null;
		}
	}

	@Override
	protected void onDrawStart(int textureId) {
		super.onDrawStart(textureId);

		// 绑定图像纹理
        GLES20.glActiveTexture(GLES20.GL_TEXTURE1);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, curveTextureId[0]);
		GLES20.glUniform1i(uCurveTexture, 1);

		// 激活纹理单元GL_TEXTURE0
		GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
		// 绑定外部纹理到纹理单元GL_TEXTURE0
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureId);

		aPosition = GLES20.glGetAttribLocation(getProgram(), "aPosition");
		aTextureCoordinate = GLES20.glGetAttribLocation(getProgram(), "aTextureCoordinate");
		uInputTexture = GLES20.glGetUniformLocation(getProgram(), "uInputTexture");

		uTexelWidthOffset = GLES20.glGetUniformLocation(getProgram(), "uTexelWidthOffset");
		uTexelHeightOffset = GLES20.glGetUniformLocation(getProgram(), "uTexelHeightOffset");

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

		GLES20.glUniform1f(uStrength, 1.0f);

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
