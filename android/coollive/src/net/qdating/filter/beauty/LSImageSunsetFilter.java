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
public class LSImageSunsetFilter extends LSImageBufferFilter {
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
			+ "uniform sampler2D uMask2Texture; \n"
			+ "uniform float uStrength; \n"

			+ "void main() { \n"
			+ "		vec4 sourceColor = texture2D(uInputTexture, vTextureCoordinate); \n"
			+ "		lowp vec4 textureColor = sourceColor; \n"
			+ "		vec4 grey1Color = texture2D(uMaskTexture, vTextureCoordinate); \n"
			+ "		vec4 grey2Color = texture2D(uMask2Texture, vTextureCoordinate); \n"
			+ "		highp float redCurveValue = texture2D(uCurveTexture, vec2(textureColor.r, 0.0)).r; \n"
			+ "		highp float greenCurveValue = texture2D(uCurveTexture, vec2(textureColor.g, 0.0)).g; \n"
			+ "		highp float blueCurveValue = texture2D(uCurveTexture, vec2(textureColor.b, 0.0)).b; \n"
			+ "		lowp vec4 currentColor = vec4(redCurveValue, greenCurveValue, blueCurveValue, 1.0); \n"
			+ "		textureColor = (currentColor - textureColor) * grey1Color.r + textureColor; \n"
			+ "		redCurveValue = texture2D(uCurveTexture, vec2(textureColor.r, 0.0)).a; \n"
			+ "		greenCurveValue = texture2D(uCurveTexture, vec2(textureColor.g, 0.0)).a; \n"
			+ "		blueCurveValue = texture2D(uCurveTexture, vec2(textureColor.b, 0.0)).a; \n"

			+ "		textureColor = vec4(redCurveValue, greenCurveValue, blueCurveValue, 1.0); \n"
			+ "		mediump vec4 textureColor2 = vec4(0.08627, 0.03529, 0.15294, 1.0); \n"
			+ "		textureColor2 = textureColor + textureColor2 - (2.0 * textureColor2 * textureColor); \n"
			+ "		textureColor = (textureColor2 - textureColor) * 0.6784 + textureColor; \n"
			+ "		mediump vec4 overlay = vec4(0.6431, 0.5882, 0.5803, 1.0); \n"
			+ "		mediump vec4 base = textureColor; \n"
			+ "		mediump float ra; \n"

			+ "		if (base.r < 0.5) { \n"
			+ "			ra = overlay.r * base.r * 2.0; \n"
			+ "		} else { \n"
			+ "			ra = 1.0 - ((1.0 - base.r) * (1.0 - overlay.r) * 2.0); \n"
			+ "		} \n"

			+ "		mediump float ga; \n"
			+ "		if (base.g < 0.5) { \n"
			+ "			ga = overlay.g * base.g * 2.0; \n"
			+ "		} else { \n"
			+ "			ga = 1.0 - ((1.0 - base.g) * (1.0 - overlay.g) * 2.0); \n"
			+ "		} \n"

			+ "		mediump float ba; \n"
			+ "		if (base.b < 0.5) { \n"
			+ "			ba = overlay.b * base.b * 2.0; \n"
			+ "		} else { \n"
			+ "			ba = 1.0 - ((1.0 - base.b) * (1.0 - overlay.b) * 2.0); \n"
			+ "		} \n"

			+ "		textureColor = vec4(ra, ga, ba, 1.0); \n"
			+ "		base = (textureColor - base) + base; \n"

			+ "		overlay = vec4(0.0, 0.0, 0.0, 1.0); \n"

			+ "		if (base.r < 0.5) { \n"
			+ "			ra = overlay.r * base.r * 2.0; \n"
			+ "		} else { \n"
			+ "			ra = 1.0 - ((1.0 - base.r) * (1.0 - overlay.r) * 2.0); \n"
			+ "		} \n"

			+ "		if (base.g < 0.5) { \n"
			+ "			ga = overlay.g * base.g * 2.0; \n"
			+ "		} else { \n"
			+ "			ga = 1.0 - ((1.0 - base.g) * (1.0 - overlay.g) * 2.0); \n"
			+ "		} \n"

			+ "		if (base.b < 0.5) { \n"
			+ "			ba = overlay.b * base.b * 2.0; \n"
			+ "		} else { \n"
			+ "			ba = 1.0 - ((1.0 - base.b) * (1.0 - overlay.b) * 2.0); \n"
			+ "		} \n"

			+ "		textureColor = vec4(ra, ga, ba, 1.0); \n"
			+ "		textureColor = (textureColor - base) * (grey2Color * 0.549) + base; \n"
			+ "		gl_FragColor = mix(sourceColor, textureColor, uStrength); \n"
			+ "}\n";

	private int aPosition;
	private int aTextureCoordinate;
	private int uInputTexture;

	private int[] curveTextureId;
	private int uCurveTexture;
	private Bitmap curveBitmap;

	private int[] maskTextureId;
	private int uMaskTexture;
	private Bitmap maskBitmap;

	private int[] mask2TextureId;
	private int uMask2Texture;
	private Bitmap mask2Bitmap;

	private int uStrength;

	public LSImageSunsetFilter(Context context) {
		super(vertexShaderString, fragmentShaderString, LSImageVertex.filterVertex_0);
		// TODO Auto-generated constructor stub
		try {
			InputStream curveInputStream = context.getAssets().open("filters/sunset/curve.png");
			curveBitmap = BitmapFactory.decodeStream(curveInputStream);
			curveInputStream.close();

			InputStream maskInputStream = context.getAssets().open("filters/sunset/mask.png");
			maskBitmap = BitmapFactory.decodeStream(maskInputStream);
			maskInputStream.close();

			InputStream mask2InputStream = context.getAssets().open("filters/sunset/mask2.png");
			mask2Bitmap = BitmapFactory.decodeStream(mask2InputStream);
			mask2InputStream.close();

		} catch (IOException e) {
			e.printStackTrace();
		}

		if ( curveBitmap == null || maskBitmap == null || mask2Bitmap == null ) {
			Log.e(LSConfig.TAG, String.format("LSImageSunsetFilter::LSImageSunsetFilter( this : 0x%x, [Input Image is null] )", this.hashCode()));
		}
	}

	@Override
	public void init() {
		super.init();

		uCurveTexture = GLES20.glGetUniformLocation(getProgram(), "uCurveTexture");
		curveTextureId = LSImageFilter.genPixelTexture();
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, curveTextureId[0]);
		GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, curveBitmap, 0);

		uMaskTexture = GLES20.glGetUniformLocation(getProgram(), "uMaskTexture");
		maskTextureId = LSImageFilter.genPixelTexture();
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, maskTextureId[0]);
		GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, maskBitmap, 0);

		uMask2Texture = GLES20.glGetUniformLocation(getProgram(), "uMask2Texture");
		mask2TextureId = LSImageFilter.genPixelTexture();
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, mask2TextureId[0]);
		GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, mask2Bitmap, 0);
	}

	@Override
	public void uninit() {
		super.uninit();

		deleteTexture(curveTextureId);
		if ( curveBitmap != null ) {
			curveBitmap.recycle();
			curveBitmap = null;
		}

		deleteTexture(maskTextureId);
		if ( maskBitmap != null ) {
			maskBitmap.recycle();
			maskBitmap = null;
		}

		deleteTexture(mask2TextureId);
		if ( mask2Bitmap != null ) {
			mask2Bitmap.recycle();
			mask2Bitmap = null;
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

		GLES20.glActiveTexture(GLES20.GL_TEXTURE3);
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, mask2TextureId[0]);
		GLES20.glUniform1i(uMask2Texture, 3);

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
