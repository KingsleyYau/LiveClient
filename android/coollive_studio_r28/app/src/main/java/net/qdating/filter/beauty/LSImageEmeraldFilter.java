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
public class LSImageEmeraldFilter extends LSImageBufferFilter {
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
			+ "uniform float uStrength; \n"

			+ "vec3 RGBtoHSL(vec3 c) { \n"
			+ "		vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0); \n"
			+ "		vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g)); \n"
			+ "		vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r)); \n"

			+ "		float d = q.x - min(q.w, q.y); \n"
			+ "		float e = 1.0e-10; \n"
			+ "		return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x); \n"
			+ "} \n"

			+ "vec3 HSLtoRGB(vec3 c) { \n"
			+ "		vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0); \n"
			+ "		vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www); \n"
			+ "		return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y); \n"
			+ "} \n"

			+ "void main() { \n"
			+ "		highp vec4 sourceColor = texture2D(uInputTexture, vTextureCoordinate.xy); \n"
			+ "		highp vec4 textureColor = sourceColor; \n"
			+ "		highp float redCurveValue = texture2D(uCurveTexture, vec2(textureColor.r, 0.0)).r; \n"
			+ "		highp float greenCurveValue = texture2D(uCurveTexture, vec2(textureColor.g, 0.0)).g; \n"
			+ "		highp float blueCurveValue = texture2D(uCurveTexture, vec2(textureColor.b, 0.0)).b; \n"
			+ "		vec3 tColor = vec3(redCurveValue, greenCurveValue, blueCurveValue); \n"
			+ "		tColor = RGBtoHSL(tColor); \n"
			+ "		tColor = clamp(tColor, 0.0, 1.0); \n"
			+ "		tColor.g = tColor.g * 1.5; \n"
			+ "		float dStrength = 1.0; \n"
			+ "		float dSatStrength = 0.15; \n"
			+ "		float dHueStrength = 0.08; \n"
			+ "		float dGap = 0.0; \n"

			+ "		if( tColor.r >= 0.625 && tColor.r <= 0.708) { \n"
			+ "			tColor.r = tColor.r - (tColor.r * dHueStrength); \n"
			+ "			tColor.g = tColor.g + (tColor.g * dSatStrength); \n"
			+ "		} \n"
			+ "		else if( tColor.r >= 0.542 && tColor.r < 0.625) { \n"
			+ "		dGap = abs(tColor.r - 0.542); \n"
			+ "			dStrength = (dGap / 0.0833); \n"
			+ "			tColor.r = tColor.r + (tColor.r * dHueStrength * dStrength); \n"
			+ "			tColor.g = tColor.g + (tColor.g * dSatStrength * dStrength); \n"
			+ "		} \n"
			+ "		else if( tColor.r > 0.708 && tColor.r <= 0.792) { \n"
			+ "			dGap = abs(tColor.r - 0.792); \n"
			+ "			dStrength = (dGap / 0.0833); \n"
			+ "			tColor.r = tColor.r + (tColor.r * dHueStrength * dStrength); \n"
			+ "			tColor.g = tColor.g + (tColor.g * dSatStrength * dStrength); \n"
			+ "		} \n"

			+ "		tColor = HSLtoRGB(tColor); \n"
			+ "		tColor = clamp(tColor, 0.0, 1.0); \n"
			+ "		redCurveValue = texture2D(uCurveTexture, vec2(tColor.r, 1.0)).r; \n"
			+ "		greenCurveValue = texture2D(uCurveTexture, vec2(tColor.g, 1.0)).r; \n"
			+ "		blueCurveValue = texture2D(uCurveTexture, vec2(tColor.b, 1.0)).r; \n"
			+ "		redCurveValue = texture2D(uCurveTexture, vec2(redCurveValue, 1.0)).g; \n"
			+ "		greenCurveValue = texture2D(uCurveTexture, vec2(greenCurveValue, 1.0)).g; \n"
			+ "		blueCurveValue = texture2D(uCurveTexture, vec2(blueCurveValue, 1.0)).g; \n"
			+ "		textureColor = vec4(redCurveValue, greenCurveValue, blueCurveValue, 1.0); \n"
			+ "		gl_FragColor = mix(sourceColor, textureColor, uStrength); \n"

			+ "}\n";


	private int aPosition;
	private int aTextureCoordinate;
	private int uInputTexture;

	private int[] curveTextureId;
	private int uCurveTexture;
	private Bitmap curveBitmap;

	private int uStrength;

	public LSImageEmeraldFilter(Context context) {
		super(vertexShaderString, fragmentShaderString, LSImageVertex.filterVertex_0);
		// TODO Auto-generated constructor stub
		try {
			InputStream curveInputStream = context.getAssets().open("filters/emerald/curve.png");
			curveBitmap = BitmapFactory.decodeStream(curveInputStream);
			curveInputStream.close();

		} catch (IOException e) {
			e.printStackTrace();
		}

		if ( curveBitmap == null ) {
			Log.e(LSConfig.TAG, String.format("LSImageEmeraldFilter::LSImageEmeraldFilter( this : 0x%x, curveBitmap == null )", this.hashCode()));
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
