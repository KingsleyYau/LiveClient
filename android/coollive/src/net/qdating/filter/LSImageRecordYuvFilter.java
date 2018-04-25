package net.qdating.filter;

import android.opengl.GLES20;
import android.opengl.GLES30;

import net.qdating.LSConfig;
import net.qdating.utils.Log;

import java.nio.ByteBuffer;

/**
 * YUV录制滤镜
 * @author max
 *
 */
public class LSImageRecordYuvFilter extends LSImageBufferFilter {
	private static String vertexShaderString = ""
			+ "// YUV图像顶点着色器 \n"
			+ "// 纹理坐标(输入) \n"
			+ "attribute vec4 aPosition; \n"
			+ "// 自定义屏幕坐标(输入) \n"
			+ "attribute vec4 aTextureCoordinate; \n"
			+ "// 片段着色器(输出) \n"
			+ "varying vec2 vTextureCoordinate; \n"
			+ "void main() { \n"
			+ "vTextureCoordinate = aTextureCoordinate.xy; \n"
			+ "gl_Position = aPosition; \n"
			+ "} \n";

	private static String fragmentCommonShaderString = ""
			+ "// YUV图像颜色着色器 \n"
			+ "precision mediump float; \n"
			+ "uniform sampler2D uInputTexture; \n"
			+ "uniform float uWidth; \n"
			+ "uniform float uHeight; \n"
			+ "// 片段着色器(输入) \n"
			+ "varying highp vec2 vTextureCoordinate; \n"

			+ "// 获取采样点颜色值 \n"
			+ "float getSampleY(float x, float y) { \n"
			+ "		// 获取指定采样点Y颜色值 \n"
			+ "		vec3 rgb = texture2D(uInputTexture, vec2(x, y)).rgb; \n"
			+ "		return (rgb.r * 0.257) + (rgb.g * 0.504) + (rgb.b * 0.098) + 0.0625; \n"
			+ "} \n"
			+ "float getSampleU(float x, float y) { \n"
			+ "		// 获取指定采样点U颜色值 \n"
			+ "		vec3 rgb = texture2D(uInputTexture, vec2(x, y)).rgb; \n"
			+ "		return (rgb.r * -0.148) + (rgb.g * -0.291) + (rgb.b * 0.439) + 0.5; \n"
			+ "} \n"
			+ "float getSampleV(float x, float y) { \n"
			+ "		// 获取指定采样点V颜色值 \n"
			+ "		vec3 rgb = texture2D(uInputTexture, vec2(x, y)).rgb; \n"
			+ "		return (rgb.r * 0.439) + (rgb.g * -0.368) + (rgb.b * -0.071) + 0.5; \n"
			+ "} \n"
			+ "vec2 getSamplePos(float step, float xShift, float yStart) { \n"
			+ "		float inputX = vTextureCoordinate.x + 1. / uWidth; \n"
			+ "		float inputY = yStart; \n"
			+ "		vec2 pos = vec2(floor(inputX * uWidth), (inputY * uHeight)); \n"
			+ "		return vec2((mod(pos.x * xShift, uWidth)), ((pos.y * xShift + (pos.x * xShift / uWidth)) * step)); \n"
			+"} \n"

			+ "// 生成填充点颜色值 \n"
			+ "vec4 createYColor() { \n"
			+ "		// 获取Y分量 \n"
			+ "		vec4 color = vec4(0); \n"
			+ "		// 采样起始点对应图片的位置 \n"
			+ "		vec2 samplePos = getSamplePos(1., 4., vTextureCoordinate.y);\n"
			+ "		float sampleX = samplePos.x; \n"
			+ "    	float sampleY = samplePos.y / uHeight; \n"
			+ "		color.r = getSampleY((sampleX + 0.) / uWidth, sampleY); \n"
			+ "		color.g = getSampleY((sampleX + 1.) / uWidth, sampleY); \n"
			+ "		color.b = getSampleY((sampleX + 2.) / uWidth, sampleY); \n"
			+ "		color.a = getSampleY((sampleX + 3.) / uWidth, sampleY); \n"
			+ "		return color;"
			+ "} \n"
			+ "vec4 createUColor() { \n"
			+ "		// 获取U分量 \n"
			+ "		vec4 color = vec4(0); \n"
			+ "		// 采样起始点对应图片的位置 \n"
			+ "		vec2 samplePos = getSamplePos(2., 8., vTextureCoordinate.y - 0.2500);\n"
			+ "		float sampleX = samplePos.x; \n"
			+ "    	float sampleY = samplePos.y / uHeight; \n"
			+ "		color.r = getSampleU((sampleX + 0.) / uWidth, sampleY); \n"
			+ "		color.g = getSampleU((sampleX + 2.) / uWidth, sampleY); \n"
			+ "		color.b = getSampleU((sampleX + 4.) / uWidth, sampleY); \n"
			+ "		color.a = getSampleU((sampleX + 6.) / uWidth, sampleY); \n"
			+ "		return color;"
			+ "} \n"
			+ "vec4 createVColor() { \n"
			+ "		// 获取V分量 \n"
			+ "		vec4 color = vec4(0); \n"
			+ "		// 采样起始点对应图片的位置 \n"
			+ "		vec2 samplePos = getSamplePos(2., 8., vTextureCoordinate.y - 0.3125);\n"
			+ "		float sampleX = samplePos.x; \n"
			+ "    	float sampleY = samplePos.y / uHeight; \n"
			+ "		color.r = getSampleV((sampleX + 0.) / uWidth, sampleY); \n"
			+ "		color.g = getSampleV((sampleX + 2.) / uWidth, sampleY); \n"
			+ "		color.b = getSampleV((sampleX + 4.) / uWidth, sampleY); \n"
			+ "		color.a = getSampleV((sampleX + 6.) / uWidth, sampleY); \n"
			+ "		return color;"
			+ "} \n"
			+ "vec4 createUVColor() { \n"
			+ "		// 获取V分量 \n"
			+ "		vec4 color = vec4(0); \n"
			+ "		// 采样起始点对应图片的位置 \n"
			+ "		vec2 samplePos = getSamplePos(2., 4., vTextureCoordinate.y - 0.2500);\n"
			+ "		float sampleX = samplePos.x; \n"
			+ "    	float sampleY = samplePos.y / uHeight; \n"
			+ "		color.r = getSampleU((sampleX + 0.) / uWidth, sampleY); \n"
			+ "		color.g = getSampleV((sampleX + 0.) / uWidth, sampleY); \n"
			+ "		color.b = getSampleU((sampleX + 2.) / uWidth, sampleY); \n"
			+ "		color.a = getSampleV((sampleX + 2.) / uWidth, sampleY); \n"
			+ "		return color;"
			+ "} \n"
			+ "vec4 createVUColor() { \n"
			+ "		// 获取V分量 \n"
			+ "		vec4 color = vec4(0); \n"
			+ "		// 采样起始点对应图片的位置 \n"
			+ "		vec2 samplePos = getSamplePos(2., 4., vTextureCoordinate.y - 0.2500);\n"
			+ "		float sampleX = samplePos.x; \n"
			+ "    	float sampleY = samplePos.y / uHeight; \n"
			+ "		color.r = getSampleV((sampleX + 0.) / uWidth, sampleY); \n"
			+ "		color.g = getSampleU((sampleX + 0.) / uWidth, sampleY); \n"
			+ "		color.b = getSampleV((sampleX + 2.) / uWidth, sampleY); \n"
			+ "		color.a = getSampleU((sampleX + 2.) / uWidth, sampleY); \n"
			+ "		return color;"
			+ "} \n";

	private static String fragment420PShaderString = ""
			+ "void main() { \n"
			+ "		// Y分量只占用1/4 \n"
			+ "		if( vTextureCoordinate.y < 0.2500 ) { \n"
			+ "			gl_FragColor = createYColor(); \n"
			+ " 	} else if ( vTextureCoordinate.y < 0.3125 ) { \n"
			+ "			gl_FragColor = createUColor(); \n"
			+ " 	} else if ( vTextureCoordinate.y < 0.3750 ) { \n"
			+ "			gl_FragColor = createVColor(); \n"
			+ " 	} else { \n"
			+ "			gl_FragColor = vec4(0., 0. ,0. ,0.); \n"
			+ " 	} \n"
			+ "} \n";

	private static String fragment420SPShaderString = ""
			+ "void main() { \n"
			+ "		// Y分量只占用1/4 \n"
			+ "		if( vTextureCoordinate.y < 0.2500 ) { \n"
			+ "			gl_FragColor = createYColor(); \n"
			+ " 	} else if ( vTextureCoordinate.y < 0.3750 ) { \n"
			+ "			gl_FragColor = createUVColor(); \n"
			+ " 	} else { \n"
			+ "			gl_FragColor = vec4(0., 0. ,0. ,0.); \n"
			+ " 	} \n"
			+ "} \n";

	private int aPosition;
	private int aTextureCoordinate;
	private int uInputTexture;
	private int uWidth;
	private int uHeight;

	/**
	 * Pixel Buffer Object
	 */
	private int[] glPBOBuffers = null;
	private int glPBOCount = 2;

	private int glPBOIndex = 0;
	private int glPBONextIndex = 1;

	/**
	 * 输出的图像Buffer
	 */
	private byte[] pixelBufferArray = null;
	private int pixelBufferSize = 0;

	/**
	 * 录制回调
	 */
	private LSImageRecordFilterCallback callback = null;

	static private String getShaderString(LSImageUtil.ColorFormat format) {
		String shaderString = fragmentCommonShaderString;
		switch (format) {
			case ColorFormat_YUV420P:{
				shaderString += fragment420PShaderString;
			}break;
			case ColorFormat_YUV420SP:{
				shaderString += fragment420SPShaderString;
			}break;
			default:break;
		}
		return shaderString;
	}

	public LSImageRecordYuvFilter(LSImageRecordFilterCallback callback, LSImageUtil.ColorFormat format) {
		super(vertexShaderString, getShaderString(format), LSImageVertex.filterVertex_0);
		// TODO Auto-generated constructor stub
		this.callback = callback;
	}

	@Override
	public void uninit() {
		super.uninit();
		destroyGLPBO();
	}

	@Override
	public boolean changeViewPointSize(int viewPointWidth, int viewPointHeight) {
		boolean bFlag = super.changeViewPointSize(viewPointWidth, viewPointHeight);
		if( bFlag ) {
			destroyGLPBO();
			createGLPBO();
		}
		return bFlag;
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
		uWidth = GLES20.glGetUniformLocation(getProgram(), "uWidth");
		uHeight = GLES20.glGetUniformLocation(getProgram(), "uHeight");

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
		// 填充着色器-绘制宽高
		GLES20.glUniform1f(uWidth, viewPointWidth);
		GLES20.glUniform1f(uHeight, viewPointHeight);

	}
	
	@Override
	protected int onDrawFrame(int textureId) {
		int newTextureId = super.onDrawFrame(textureId);

		// 绘制
		GLES20.glDrawArrays(GLES20.GL_TRIANGLES, 0, 6);
		// 生成录制帧
		recordFrame();
		
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
	
	private void createPixelBuffer(int newPixelBufferSize) {
		pixelBufferSize = newPixelBufferSize;
		pixelBufferArray = new byte[pixelBufferSize];
		Log.d(LSConfig.TAG, String.format("LSImageRecordYuvFilter::createPixelBuffer( pixelBufferSize : %d )", pixelBufferSize));
	}
	
	private void createGLPBO() {
        // 当前下标
		glPBOIndex = 0;
        
		// 内存Buffer大小
		int newPixelsBufferSize = viewPointWidth * viewPointHeight * 4 * 3 / 8;
		createPixelBuffer(newPixelsBufferSize);
		
		// 创建PBO
		glPBOBuffers = new int[glPBOCount];
		GLES30.glGenBuffers(glPBOCount, glPBOBuffers, 0);

		for(int i = 0; i < glPBOCount; i++) {
	        GLES30.glBindBuffer(GLES30.GL_PIXEL_PACK_BUFFER, glPBOBuffers[i]);
	        GLES30.glBufferData(GLES30.GL_PIXEL_PACK_BUFFER, newPixelsBufferSize, null, GLES30.GL_STATIC_READ);
		}

        // 解除PBO绑定
        GLES30.glBindBuffer(GLES30.GL_PIXEL_PACK_BUFFER, 0);
        
        Log.d(LSConfig.TAG, String.format("LSImageRecordYuvFilter::createGLPBO( glPBOCount : %d ) ", glPBOCount));
	}
	
	private void destroyGLPBO() {
		// 销毁PBO
	    if (glPBOBuffers != null) {
            GLES30.glDeleteBuffers(glPBOCount, glPBOBuffers, 0);
            glPBOBuffers = null;
        }
	    
	}
	
	private void recordFrame() {
		if( glPBOBuffers != null ) {
			// 绑定PBO
			GLES30.glBindBuffer(GLES30.GL_PIXEL_PACK_BUFFER, glPBOBuffers[glPBOIndex]);
			// 通过JNI调用读取Pixel, 传入NULL指针避免GPU数据到内存的复制
			LSImageUtilJni.GLReadPixels(0, 0, viewPointWidth, viewPointHeight * 3 / 8, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE);
			// 绑定下一个PBO
			GLES30.glBindBuffer(GLES30.GL_PIXEL_PACK_BUFFER, glPBOBuffers[glPBONextIndex]);
			ByteBuffer byteBuffer = (ByteBuffer) GLES30.glMapBufferRange(GLES30.GL_PIXEL_PACK_BUFFER, 0, pixelBufferSize, GLES30.GL_MAP_READ_BIT);
			GLES30.glUnmapBuffer(GLES30.GL_PIXEL_PACK_BUFFER);
			GLES30.glBindBuffer(GLES30.GL_PIXEL_PACK_BUFFER, 0);

			glPBOIndex = (glPBOIndex + 1) % 2;
			glPBONextIndex = (glPBONextIndex + 1) % 2;

			if( callback != null ) {
				if( byteBuffer != null ) {
					// 回调已经处理过的视频帧
					byteBuffer.position(0);
					int size = byteBuffer.remaining();
					byteBuffer.get(pixelBufferArray, 0, size);
					callback.onRecordFrame(pixelBufferArray, size, viewPointWidth, viewPointHeight);
				}
			}
		}
	}
}
