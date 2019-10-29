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
public class LSImageLomoFilter extends LSImageBufferFilter {
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
			+ "uniform sampler2D uVignetteTexture; \n"
			+ "uniform float uStrength; \n"

			+ "void main() { \n"
			+ "		vec4 sourceColor = texture2D(uInputTexture, vTextureCoordinate); \n"
			+ "		vec3 textureColor = sourceColor.rgb; \n"
			+ "		vec2 red = vec2(textureColor.r, 0.16666); \n"
			+ "		vec2 green = vec2(textureColor.g, 0.5); \n"
			+ "		vec2 blue = vec2(textureColor.b, 0.83333); \n"
			+ "		textureColor.rgb = vec3( \n"
			+ "			texture2D(uMapTexture, red).r, \n"
			+ "			texture2D(uMapTexture, green).g, \n"
			+ "			texture2D(uMapTexture, blue).b \n"
			+ "		); \n"
			+ "		vec2 tc = (2.0 * vTextureCoordinate) - 1.0; \n"
			+ "		float d = dot(tc, tc); \n"
			+ "		vec2 lookup = vec2(d, textureColor.r); \n"
			+ "		textureColor.r = texture2D(uVignetteTexture, lookup).r; \n"
			+ "		lookup.y = textureColor.g; \n"
			+ "		textureColor.g = texture2D(uVignetteTexture, lookup).g; \n"
			+ "		lookup.y = textureColor.b; \n"
			+ "		textureColor.b	= texture2D(uVignetteTexture, lookup).b; \n"
			+ "		textureColor.rgb = mix(sourceColor.rgb, textureColor.rgb, uStrength); \n"
			+ "		gl_FragColor = vec4(textureColor, 1.0); \n"
			+ "}\n";


	private int aPosition;
	private int aTextureCoordinate;
	private int uInputTexture;

	private int[] mapTextureId;
	private int uMapTexture;
	private Bitmap mapBitmap;

	private int[] vignetteTextureId;
	private int uVignetteTexture;
	private Bitmap vignetteBitmap;

	private int uStrength;

	public LSImageLomoFilter(Context context) {
		super(vertexShaderString, fragmentShaderString, LSImageVertex.filterVertex_0);
		// TODO Auto-generated constructor stub
		try {
			InputStream mapInputStream = context.getAssets().open("filters/lomo/map.png");
			mapBitmap = BitmapFactory.decodeStream(mapInputStream);
			mapInputStream.close();

			InputStream vignetteInputStream = context.getAssets().open("filters/lomo/vignette.png");
			vignetteBitmap = BitmapFactory.decodeStream(vignetteInputStream);
			vignetteInputStream.close();

		} catch (IOException e) {
			e.printStackTrace();
		}

		if ( mapBitmap == null || vignetteBitmap == null ) {
			Log.e(LSConfig.TAG, String.format("LSImageLomoFilter::LSImageLomoFilter( this : 0x%x, [Input Image is null] )", this.hashCode()));
		}
	}

	@Override
	public void init() {
		super.init();

		uMapTexture = GLES20.glGetUniformLocation(getProgram(), "uMapTexture");
		mapTextureId = LSImageFilter.genPixelTexture();
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, mapTextureId[0]);
		GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, mapBitmap, 0);

		uVignetteTexture = GLES20.glGetUniformLocation(getProgram(), "uVignetteTexture");
		vignetteTextureId = LSImageFilter.genPixelTexture();
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, vignetteTextureId[0]);
		GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, vignetteBitmap, 0);
	}

	@Override
	public void uninit() {
		super.uninit();

		deleteTexture(mapTextureId);
		if ( mapBitmap != null ) {
			mapBitmap.recycle();
			mapBitmap = null;
		}

		deleteTexture(vignetteTextureId);
		if ( vignetteBitmap != null ) {
			vignetteBitmap.recycle();
			vignetteBitmap = null;
		}
	}

	@Override
	protected void onDrawStart(int textureId) {
		super.onDrawStart(textureId);

		// 绑定图像纹理
        GLES20.glActiveTexture(GLES20.GL_TEXTURE1);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, mapTextureId[0]);
		GLES20.glUniform1i(uMapTexture, 1);

		GLES20.glActiveTexture(GLES20.GL_TEXTURE2);
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, vignetteTextureId[0]);
		GLES20.glUniform1i(uVignetteTexture, 2);

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
