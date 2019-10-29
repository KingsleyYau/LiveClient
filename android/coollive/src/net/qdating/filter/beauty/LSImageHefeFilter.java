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
public class LSImageHefeFilter extends LSImageBufferFilter {
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

			+ "uniform sampler2D uEdgeBurnTexture; \n"
			+ "uniform sampler2D uMapTexture; \n"
			+ "uniform sampler2D uGradientMapTexture; \n"
			+ "uniform sampler2D uSoftLightTexture; \n"
			+ "uniform sampler2D uMetalTexture; \n"
			+ "uniform float uStrength; \n"

			+ "void main() { \n"
			+ "		vec4 sourceColor = texture2D(uInputTexture, vTextureCoordinate); \n"
			+ "		vec3 textureColor = sourceColor.rgb; \n"
			+ "		vec3 edgeColor = texture2D(uEdgeBurnTexture, vTextureCoordinate).rgb; \n"
			+ "		textureColor = textureColor * edgeColor; \n"

			+ "		textureColor = vec3( \n"
			+ "			texture2D(uMapTexture, vec2(textureColor.r, .16666)).r, \n"
			+ "			texture2D(uMapTexture, vec2(textureColor.g, .5)).g, \n"
			+ "			texture2D(uMapTexture, vec2(textureColor.b, .83333)).b \n"
			+ "		); \n"

			+ "		vec3 luma = vec3(.30, .59, .11); \n"
			+ "		vec3 gradSample = texture2D(uGradientMapTexture, vec2(dot(luma, textureColor), .5)).rgb; \n"
			+ "		vec3 final = vec3( \n"
			+ "			texture2D(uSoftLightTexture, vec2(gradSample.r, textureColor.r)).r, \n"
			+ "			texture2D(uSoftLightTexture, vec2(gradSample.g, textureColor.g)).g, \n"
			+ "			texture2D(uSoftLightTexture, vec2(gradSample.b, textureColor.b)).b \n"
			+ "		); \n"
			+ "		vec3 metal = texture2D(uMetalTexture, vTextureCoordinate).rgb; \n"
			+ "		vec3 metaled = vec3( \n"
			+ "				texture2D(uSoftLightTexture, vec2(metal.r, textureColor.r)).r, \n"
			+ "				texture2D(uSoftLightTexture, vec2(metal.g, textureColor.g)).g, \n"
			+ "				texture2D(uSoftLightTexture, vec2(metal.b, textureColor.b)).b \n"
			+ "		); \n"

			+ "		metaled.rgb = mix(sourceColor.rgb, metaled.rgb, uStrength); \n"
			+ "		gl_FragColor = vec4(metaled, 1.0); \n"
			+ "}\n";


	private int aPosition;
	private int aTextureCoordinate;
	private int uInputTexture;

	private int[] edgeBurnTextureId;
	private int uEdgeBurnTexture;
	private Bitmap edgeBurnBitmap;

	private int[] mapTextureId;
	private int uMapTexture;
	private Bitmap mapBitmap;

	private int[] gradientMapTextureId;
	private int uGradientMapTexture;
	private Bitmap gradientMapBitmap;

	private int[] softLightTextureId;
	private int uSoftLightTexture;
	private Bitmap softLightBitmap;

	private int[] metalTextureId;
	private int uMetalTexture;
	private Bitmap metalBitmap;

	private int uStrength;

	public LSImageHefeFilter(Context context) {
		super(vertexShaderString, fragmentShaderString, LSImageVertex.filterVertex_0);
		// TODO Auto-generated constructor stub
		try {
			InputStream edgeInputStream = context.getAssets().open("filters/hefe/edgeburn.png");
			edgeBurnBitmap = BitmapFactory.decodeStream(edgeInputStream);
			edgeInputStream.close();

			InputStream mapInputStream = context.getAssets().open("filters/hefe/map.png");
			mapBitmap = BitmapFactory.decodeStream(mapInputStream);
			mapInputStream.close();

			InputStream gradientInputStream = context.getAssets().open("filters/hefe/gradient.png");
			gradientMapBitmap = BitmapFactory.decodeStream(gradientInputStream);
			gradientInputStream.close();

			InputStream softLightInputStream = context.getAssets().open("filters/hefe/softlight.png");
			softLightBitmap = BitmapFactory.decodeStream(softLightInputStream);
			softLightInputStream.close();

			InputStream metalInputStream = context.getAssets().open("filters/hefe/metal.png");
			metalBitmap = BitmapFactory.decodeStream(metalInputStream);
			metalInputStream.close();

		} catch (IOException e) {
			e.printStackTrace();
		}

		if ( edgeBurnBitmap == null || mapBitmap == null || gradientMapBitmap == null || softLightBitmap == null  || metalBitmap == null ) {
			Log.e(LSConfig.TAG, String.format("LSImageHefeFilter::LSImageHefeFilter( this : 0x%x, [Input Image is null] )", this.hashCode()));
		}
	}

	@Override
	public void init() {
		super.init();

		uEdgeBurnTexture = GLES20.glGetUniformLocation(getProgram(), "uEdgeBurnTexture");
		edgeBurnTextureId = LSImageFilter.genPixelTexture();
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, edgeBurnTextureId[0]);
		GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, edgeBurnBitmap, 0);

		uMapTexture = GLES20.glGetUniformLocation(getProgram(), "uMapTexture");
		mapTextureId = LSImageFilter.genPixelTexture();
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, mapTextureId[0]);
		GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, mapBitmap, 0);

		uGradientMapTexture = GLES20.glGetUniformLocation(getProgram(), "uGradientMapTexture");
		gradientMapTextureId = LSImageFilter.genPixelTexture();
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, gradientMapTextureId[0]);
		GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, gradientMapBitmap, 0);

		uSoftLightTexture = GLES20.glGetUniformLocation(getProgram(), "uSoftLightTexture");
		softLightTextureId = LSImageFilter.genPixelTexture();
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, softLightTextureId[0]);
		GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, softLightBitmap, 0);

		uMetalTexture = GLES20.glGetUniformLocation(getProgram(), "uMetalTexture");
		metalTextureId = LSImageFilter.genPixelTexture();
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, metalTextureId[0]);
		GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, metalBitmap, 0);
	}

	@Override
	public void uninit() {
		super.uninit();

		if ( edgeBurnBitmap != null ) {
			edgeBurnBitmap.recycle();
			edgeBurnBitmap = null;
		}

		if ( mapBitmap != null ) {
			mapBitmap.recycle();
			mapBitmap = null;
		}

		if ( gradientMapBitmap != null ) {
			gradientMapBitmap.recycle();
			gradientMapBitmap = null;
		}

		if ( softLightBitmap != null ) {
			softLightBitmap.recycle();
			softLightBitmap = null;
		}

		if ( metalBitmap != null ) {
			metalBitmap.recycle();
			metalBitmap = null;
		}
	}

	@Override
	protected void onDrawStart(int textureId) {
		super.onDrawStart(textureId);

		// 绑定图像纹理
        GLES20.glActiveTexture(GLES20.GL_TEXTURE1);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, edgeBurnTextureId[0]);
		GLES20.glUniform1i(uEdgeBurnTexture, 1);

        GLES20.glActiveTexture(GLES20.GL_TEXTURE2);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, mapTextureId[0]);
		GLES20.glUniform1i(uMapTexture, 2);

		GLES20.glActiveTexture(GLES20.GL_TEXTURE3);
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, gradientMapTextureId[0]);
		GLES20.glUniform1i(uGradientMapTexture, 3);

		GLES20.glActiveTexture(GLES20.GL_TEXTURE4);
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, softLightTextureId[0]);
		GLES20.glUniform1i(uSoftLightTexture, 4);

		GLES20.glActiveTexture(GLES20.GL_TEXTURE5);
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, metalTextureId[0]);
		GLES20.glUniform1i(uMetalTexture, 5);

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
