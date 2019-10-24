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
 * 美颜滤镜
 * @author max
 *
 */
public class LSImageComplexionFilter extends LSImageBufferFilter {
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
			+ "uniform sampler2D uGrayTexture; \n"
			+ "uniform sampler2D uLookupTexture; \n"

			+ "// 片段着色器(输入) \n"
			+ "varying highp vec2 vTextureCoordinate; \n"

			+ "void main() { \n"
			+ "		lowp vec3 textureColor = texture2D(uInputTexture, vTextureCoordinate).rgb; \n"
			+ "		textureColor = clamp((textureColor - vec3(0.01960784, 0.01960784, 0.01960784)) * 1.040816, 0.0, 1.0); \n"
			+ "		textureColor.r = texture2D(uGrayTexture, vec2(textureColor.r, 0.5)).r; \n"
			+ "		textureColor.g = texture2D(uGrayTexture, vec2(textureColor.g, 0.5)).g; \n"
			+ "		textureColor.b = texture2D(uGrayTexture, vec2(textureColor.b, 0.5)).b; \n"
			+ "		mediump float blueColor = textureColor.b * 15.0; \n"
			+ "		mediump vec2 quad1; \n"
			+ "		quad1.y = floor(blueColor / 4.0); \n"
			+ "		quad1.x = floor(blueColor) - (quad1.y * 4.0); \n"
			+ "		mediump vec2 quad2; \n"
			+ "		quad2.y = floor(ceil(blueColor) / 4.0); \n"
			+ "		quad2.x = ceil(blueColor) - (quad2.y * 4.0); \n"
			+ "		highp vec2 texPos1; \n"
			+ "		texPos1.x = (quad1.x * 0.25) + 0.5 / 64.0 + ((0.25 - 1.0 / 64.0) * textureColor.r); \n"
			+ "		texPos1.y = (quad1.y * 0.25) + 0.5 / 64.0 + ((0.25 - 1.0 / 64.0) * textureColor.g); \n"
			+ "		highp vec2 texPos2; \n"
			+ "		texPos2.x = (quad2.x * 0.25) + 0.5 / 64.0 + ((0.25 - 1.0 / 64.0) * textureColor.r); \n"
			+ "		texPos2.y = (quad2.y * 0.25) + 0.5 / 64.0 + ((0.25 - 1.0 / 64.0) * textureColor.g); \n"
			+ "		lowp vec4 newColor1 = texture2D(uLookupTexture, texPos1); \n"
			+ "		lowp vec4 newColor2 = texture2D(uLookupTexture, texPos2); \n"
			+ "		lowp vec3 newColor = mix(newColor1.rgb, newColor2.rgb, fract(blueColor)); \n"
			+ "		textureColor = mix(textureColor, newColor, 1.0); \n"
			+ "		gl_FragColor = vec4(textureColor, 1.0); \n"
			+ "}\n";


	private int aPosition;
	private int aTextureCoordinate;
	private int uInputTexture;

	private int[] grayTextureId;
	private int uGrayTexture;
	private Bitmap grayBitmap;

	private int[] lookupTextureId;
	private int uLookupTexture;
	private Bitmap lookupBitmap;

	public LSImageComplexionFilter(Context context) {
		super(vertexShaderString, fragmentShaderString, LSImageVertex.filterVertex_0);
		// TODO Auto-generated constructor stub
		try {
			InputStream grayInputStream = context.getAssets().open("filters/beauty/skin_gray.png");
			grayBitmap = BitmapFactory.decodeStream(grayInputStream);
			grayInputStream.close();

			InputStream lookupInputStream = context.getAssets().open("filters/beauty/skin_lookup.png");
			lookupBitmap = BitmapFactory.decodeStream(lookupInputStream);
			lookupInputStream.close();

		} catch (IOException e) {
			e.printStackTrace();
		}

		if ( grayBitmap == null || lookupBitmap == null ) {
			Log.e(LSConfig.TAG, String.format("LSImageComplexionFilter::LSImageComplexionFilter( this : 0x%x, grayBitmap == null || lookupBitmap == null )", this.hashCode()));
		}
	}

	@Override
	public void init() {
		super.init();

		uGrayTexture = GLES20.glGetUniformLocation(getProgram(), "uGrayTexture");
		uLookupTexture = GLES20.glGetUniformLocation(getProgram(), "uLookupTexture");

		grayTextureId = LSImageFilter.genPixelTexture();
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, grayTextureId[0]);
		GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, grayBitmap, 0);

		lookupTextureId = LSImageFilter.genPixelTexture();
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, lookupTextureId[0]);
		GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, lookupBitmap, 0);
	}

	@Override
	public void uninit() {
		super.uninit();

		if ( grayBitmap != null ) {
			grayBitmap.recycle();
			grayBitmap = null;
		}

		if ( lookupBitmap != null ) {
			lookupBitmap.recycle();
			lookupBitmap = null;
		}
	}

	@Override
	protected void onDrawStart(int textureId) {
		super.onDrawStart(textureId);

		// 绑定图像纹理
        GLES20.glActiveTexture(GLES20.GL_TEXTURE1);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, grayTextureId[0]);
		GLES20.glUniform1i(uGrayTexture, 1);
        GLES20.glActiveTexture(GLES20.GL_TEXTURE2);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, lookupTextureId[0]);
		GLES20.glUniform1i(uLookupTexture, 2);

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
