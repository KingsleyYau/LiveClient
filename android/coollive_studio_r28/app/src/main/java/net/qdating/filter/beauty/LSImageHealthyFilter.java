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

import java.io.File;
import java.io.IOException;
import java.io.InputStream;

/**
 * 滤镜
 * @author max
 *
 */
public class LSImageHealthyFilter extends LSImageBufferFilter {
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

			+ "uniform sampler2D uCurveTexture; \n"
			+ "uniform sampler2D uMaskTexture; \n"
			+ "uniform float uStrength; \n"

			+ "vec4 level0c(vec4 color, sampler2D sampler) { \n"
			+ "		color.r = texture2D(sampler, vec2(color.r, 0.)).r; \n"
			+ "		color.g = texture2D(sampler, vec2(color.g, 0.)).r; \n"
			+ "		color.b = texture2D(sampler, vec2(color.b, 0.)).r; \n"
			+ "		return color; \n"
			+ "} \n"

			+ "vec4 level1c(vec4 color, sampler2D sampler) { \n"
			+ "		color.r = texture2D(sampler, vec2(color.r, 0.)).g; \n"
			+ "		color.g = texture2D(sampler, vec2(color.g, 0.)).g; \n"
			+ "		color.b = texture2D(sampler, vec2(color.b, 0.)).g; \n"
			+ "		return color; \n"
			+ "} \n"

			+ "vec4 level2c(vec4 color, sampler2D sampler) { \n"
			+ "		color.r = texture2D(sampler, vec2(color.r,0.)).b; \n"
			+ "		color.g = texture2D(sampler, vec2(color.g,0.)).b; \n"
			+ "		color.b = texture2D(sampler, vec2(color.b,0.)).b; \n"
			+ "		return color; \n"
			+ "} \n"

			+ "vec3 rgb2hsv(vec3 c) { \n"
			+ "		vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0); \n"
			+ "		vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g)); \n"
			+ "		vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r)); \n"
			+ "		float d = q.x - min(q.w, q.y); \n"
			+ "		float e = 1.0e-10; \n"
			+ "		return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x); \n"
			+ "} \n"

			+ "vec3 hsv2rgb(vec3 c) { \n"
			+ "		vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0); \n"
			+ "		vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www); \n"
			+ "		return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y); \n"
			+ "} \n"

			+ "vec4 normal(vec4 c1, vec4 c2, float alpha) { \n"
			+ "		return (c2-c1) * alpha + c1; \n"
			+ "} \n"

			+ "vec4 multiply(vec4 c1, vec4 c2) { \n"
			+ "		return c1 * c2 * 1.01; \n"
			+ "} \n"

			+ "vec4 overlay(vec4 c1, vec4 c2) { \n"
			+ "		vec4 color = vec4(0.,0.,0.,1.); \n"
			+ "		color.r = c1.r < 0.5 ? 2.0*c1.r*c2.r : 1.0 - 2.0*(1.0-c1.r)*(1.0-c2.r); \n"
			+ "		color.g = c1.g < 0.5 ? 2.0*c1.g*c2.g : 1.0 - 2.0*(1.0-c1.g)*(1.0-c2.g); \n"
			+ "		color.b = c1.b < 0.5 ? 2.0*c1.b*c2.b : 1.0 - 2.0*(1.0-c1.b)*(1.0-c2.b); \n"
			+ "		return color; \n"
			+ "} \n"

			+ "vec4 screen(vec4 c1, vec4 c2) { \n"
			+ "		return vec4(1.) - ((vec4(1.) - c1) * (vec4(1.) - c2)); \n"
			+ "} \n"

			+ "void main() { \n"
			+ "		vec4 maskColor = texture2D(uMaskTexture, vec2(vTextureCoordinate.x, vTextureCoordinate.y)); \n"
			+ "		vec4 sourceColor = texture2D(uInputTexture, vTextureCoordinate.xy); \n"
			+ "		vec3 hsv = rgb2hsv(sourceColor.rgb); \n"
			+ "		lowp float h = hsv.x; \n"
			+ "		lowp float s = hsv.y; \n"
			+ "		lowp float v = hsv.z; \n"
			+ "		lowp float cF = 0.; \n"
			+ "		lowp float cG = 0.; \n"
			+ "		lowp float sF = 0.06; \n"
			+ "		if(h >= 0.125 && h <= 0.208) { \n"
			+ "			s = s - (s * sF); \n"
			+ "		} else if (h >= 0.208 && h < 0.292) { \n"
			+ "			cG = abs(h - 0.208); \n"
			+ "			cF = (cG / 0.0833); \n"
			+ "			s = s - (s * sF * cF); \n"
			+ "		} else if (h > 0.042 && h <=  0.125) { \n"
			+ "			cG = abs(h - 0.125); \n"
			+ "			cF = (cG / 0.0833); \n"
			+ "			s = s - (s * sF * cF); \n"
			+ "		} \n"
			+ "		hsv.y = s; \n"
			+ "		vec4 textureColor = vec4(hsv2rgb(hsv),1.); \n"
			+ "		textureColor = normal(textureColor, screen(textureColor, textureColor), 0.275); \n"
			+ "		textureColor = normal(textureColor, overlay(textureColor, vec4(1., 0.61176, 0.25098, 1.)), 0.04); \n"
			+ "		textureColor = normal(textureColor, multiply(textureColor, maskColor), 0.262); \n"
			+ "		textureColor = level1c(level0c(textureColor, uCurveTexture), uCurveTexture); \n"
			+ "		gl_FragColor = mix(sourceColor, textureColor, uStrength); \n"
			+ "} \n";

	private int aPosition;
	private int aTextureCoordinate;
	private int uInputTexture;

	private int[] curveTextureId;
	private int uCurveTexture;
	private Bitmap curveBitmap;

	private int[] maskTextureId;
	private int uMaskTexture;
	private Bitmap maskBitmap;

	private int uStrength;

	public LSImageHealthyFilter(Context context) {
		super(vertexShaderString, fragmentShaderString, LSImageVertex.filterVertex_0);
		// TODO Auto-generated constructor stub
		try {
			InputStream curveInputStream = context.getAssets().open("filters/healthy/curve.png");
			curveBitmap = BitmapFactory.decodeStream(curveInputStream);
			curveInputStream.close();

			InputStream maskInputStream = context.getAssets().open("filters/healthy/mask.png");
			maskBitmap = BitmapFactory.decodeStream(maskInputStream);
			maskInputStream.close();

		} catch (IOException e) {
			e.printStackTrace();
		}

		if ( curveBitmap == null || maskBitmap == null ) {
			Log.e(LSConfig.TAG, String.format("LSImageHealthyFilter::LSImageHealthyFilter( this : 0x%x, curveBitmap == null || maskBitmap == null )", this.hashCode()));
		}
	}

	@Override
	public void init() {
		super.init();

		uCurveTexture = GLES20.glGetUniformLocation(getProgram(), "uCurveTexture");

		curveTextureId = LSImageFilter.genPixelTexture();
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, curveTextureId[0]);
		GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, curveBitmap, 0);

		maskTextureId = LSImageFilter.genPixelTexture();
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, maskTextureId[0]);
		GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, maskBitmap, 0);
	}

	@Override
	public void uninit() {
		super.uninit();

		if ( curveBitmap != null ) {
			curveBitmap.recycle();
			curveBitmap = null;
		}

		if ( maskBitmap != null ) {
			maskBitmap.recycle();
			maskBitmap = null;
		}
	}

	@Override
	protected void onDrawStart(int textureId) {
		super.onDrawStart(textureId);

		// 绑定图像纹理
        GLES20.glActiveTexture(GLES20.GL_TEXTURE1);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, curveTextureId[0]);
		GLES20.glUniform1i(uCurveTexture, 1);
		GLES20.glActiveTexture(GLES20.GL_TEXTURE2);
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, maskTextureId[0]);
		GLES20.glUniform1i(uMaskTexture, 2);

		// 激活纹理单元GL_TEXTURE0
		GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
		// 绑定外部纹理到纹理单元GL_TEXTURE0
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureId);

		aPosition = GLES20.glGetAttribLocation(getProgram(), "aPosition");
		aTextureCoordinate = GLES20.glGetAttribLocation(getProgram(), "aTextureCoordinate");
		uInputTexture = GLES20.glGetUniformLocation(getProgram(), "uInputTexture");

		uStrength = GLES20.glGetUniformLocation(getProgram(), "uStrength");

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
