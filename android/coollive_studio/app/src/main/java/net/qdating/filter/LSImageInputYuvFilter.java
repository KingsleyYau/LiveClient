package net.qdating.filter;

import java.nio.ByteBuffer;

import android.opengl.GLES20;
import net.qdating.LSConfig;
import net.qdating.utils.Log;

import static net.qdating.filter.LSImageShader.ledChar;

/**
 * YUV输入滤镜
 */
public class LSImageInputYuvFilter extends LSImageBufferFilter {
	/**
	 * vec2 v = vec2(10., 20.);
	 * mat2 m = mat2(1., 2.,  3., 4.);
	 * vec2 w = m * v; // = vec2(1. * 10. + 3. * 20., 2. * 10. + 4. * 20.)
	 * 
	 * vec2 v = vec2(10., 20.);
	 * mat2 m = mat2(1., 2.,  3., 4.);
	 * vec2 w = v * m; // = vec2(1. * 10. + 2. * 20., 3. * 10. + 4. * 20.)
	 */
	public static String yuvPixelVertexShaderString = ""
			+ "// YUV顶点着色器 \n"
			+ "// 纹理坐标(输入) \n"
			+ "attribute vec4 aPosition; \n"
			+ "// 自定义屏幕坐标(输入) \n"
			+ "attribute vec4 aTextureCoordinate; \n"
			+ "// 片段着色器(输出)\n"
			+ "varying vec2 vTextureCoordinate; \n"
			+ "void main() { \n"
			+ "		vTextureCoordinate = aTextureCoordinate.xy; \n"
			+ "		gl_Position = aPosition; \n"
			+ "}\n";
	
	public static String yuvPixelFragmentShaderString = "" 
			+ "// YUV颜色着色器 \n"
			+ "precision mediump float; \n"
			+ "uniform int uFormat; \n"
			+ "uniform sampler2D uInputTextureY; \n"
			+ "uniform sampler2D uInputTextureU; \n"
			+ "uniform sampler2D uInputTextureV; \n"
			+ "uniform sampler2D uInputTextureUV; \n"
			+ "// 片段着色器(输入) \n"
			+ "varying highp vec2 vTextureCoordinate; \n"
			+ ledChar
			+ "void main() { \n"
			+ "		vec3 yuv; \n"
			+ "		yuv.x = texture2D(uInputTextureY, vTextureCoordinate).r - .0625; \n"
			+ "		if( uFormat == 1 ) { \n"
			+ "			// YUV420P \n"
            + "			yuv.y = texture2D(uInputTextureU, vTextureCoordinate).r - 0.5; \n"
            + "			yuv.z = texture2D(uInputTextureV, vTextureCoordinate).r - 0.5; \n"
			+ "		} else if ( uFormat == 2 ) { \n"
			+ "			// YUV420SP \n"
			+ "			yuv.yz = texture2D(uInputTextureUV, vTextureCoordinate).ra - vec2(0.5, 0.5); \n"
			+ "		} \n"
            + "		vec3 rgb; \n"
            + "		rgb = mat3(1.0, 		1.0, 		1.0, "
            + "			  	   0.0, 		-0.39465, 	2.03211, "
            + "           	   1.13983, 	-0.58060, 	0.0"
            + "			 	   ) * yuv; \n"
			+ "		gl_FragColor = vec4(rgb, 1.0); \n"
			+ "		// 输出采样格式 \n"
			+ "		ledChar(uFormat, 0.0, 0.07, 0.9, 0.1, vTextureCoordinate); \n"
//			+ " 	if( uFormat == 1 ) { \n"
//			+ "			ledChar(4, 0.0, 0.07, 0.9, 0.1, vTextureCoordinate); \n"
//			+ "			ledChar(2, 0.08, 0.07, 0.9, 0.1, vTextureCoordinate); \n"
//			+ "			ledChar(0, 0.16, 0.07, 0.9, 0.1, vTextureCoordinate); \n"
//			+ "			ledChar(45, 0.24, 0.07, 0.9, 0.1, vTextureCoordinate); \n"
//			+ "			ledChar(80, 0.32, 0.07, 0.9, 0.1, vTextureCoordinate); \n"
//			+ "		} else if ( uFormat == 2 ) { \n"
//			+ "			ledChar(4, 0.0, 0.07, 0.9, 0.1, vTextureCoordinate); \n"
//			+ "			ledChar(2, 0.08, 0.07, 0.9, 0.1, vTextureCoordinate); \n"
//			+ "			ledChar(0, 0.16, 0.07, 0.9, 0.1, vTextureCoordinate); \n"
//			+ "			ledChar(45, 0.24, 0.07, 0.9, 0.1, vTextureCoordinate); \n"
//			+ "			ledChar(83, 0.32, 0.07, 0.9, 0.1, vTextureCoordinate); \n"
//			+ "			ledChar(80, 0.40, 0.07, 0.9, 0.1, vTextureCoordinate); \n"
//			+ "		} \n"
			+ "} \n";

	// 着色器顶点输入句柄
	private int aPosition;
	// 着色器坐标输入句柄
	private int aTextureCoordinate;
	// 着色器采样格式
	private int uFormat;

	private enum GL_YUV_Format {
		GL_YUV_Format_UNKNOW,
		GL_YUV_Format_420P,
		GL_YUV_Format_420SP
	};
	// 采样格式
	private GL_YUV_Format format = GL_YUV_Format.GL_YUV_Format_UNKNOW;

	// 纹理句柄
	private int[] textureIdY;
	private int[] textureIdU;
	private int[] textureIdV;
	private int[] textureIdUV;

	// 着色器采样输入句柄
	private int uInputTextureY;
	private int uInputTextureU;
	private int uInputTextureV;
	private int uInputTextureUV;

	// 着色器采样数据Buffer
	private ByteBuffer bufferY;
	private ByteBuffer bufferU;
	private ByteBuffer bufferV;
	private ByteBuffer bufferUV;

	public LSImageInputYuvFilter() {
		super(yuvPixelVertexShaderString, yuvPixelFragmentShaderString, LSImageVertex.filterVertex_180);
	}

	public void updateYuv420PFrame(
			byte [] byteArrayY, int byteSizeY,
			byte [] byteArrayU, int byteSizeU,
			byte [] byteArrayV, int byteSizeV
	) {
		format = GL_YUV_Format.GL_YUV_Format_420P;

		bufferY = resetBuffer(bufferY, byteSizeY);
		bufferY.clear();
		bufferY.put(byteArrayY, 0, byteSizeY);
		bufferY.rewind();

		bufferU = resetBuffer(bufferU, byteSizeU);
		bufferU.clear();
		bufferU.put(byteArrayU, 0, byteSizeU);
		bufferU.rewind();

		bufferV = resetBuffer(bufferV, byteSizeV);
		bufferV.clear();
		bufferV.put(byteArrayV, 0, byteSizeV);
		bufferV.rewind();
	}

	public void updateYuv420SPFrame(
			byte [] byteArrayY, int byteSizeY,
			byte [] byteArrayUV, int byteSizeUV
	) {
		format = GL_YUV_Format.GL_YUV_Format_420SP;

		bufferY = resetBuffer(bufferY, byteSizeY);
		bufferY.clear();
		bufferY.put(byteArrayY, 0, byteSizeY);
		bufferY.rewind();

		bufferUV = resetBuffer(bufferUV, byteSizeUV);
		bufferUV.clear();
		bufferUV.put(byteArrayUV, 0, byteSizeUV);
		bufferUV.rewind();

	}

	@Override
	public void init() {
		super.init();
		
		createGLTexture();
	}

	@Override
	protected void onDrawStart(int textureId) {
		// TODO Auto-generated method stub
		super.onDrawStart(textureId);

		aPosition = GLES20.glGetAttribLocation(getProgram(), "aPosition");
		aTextureCoordinate = GLES20.glGetAttribLocation(getProgram(), "aTextureCoordinate");
		uFormat = GLES20.glGetUniformLocation(getProgram(), "uFormat");
		uInputTextureY = GLES20.glGetUniformLocation(getProgram(), "uInputTextureY");
		uInputTextureU = GLES20.glGetUniformLocation(getProgram(), "uInputTextureU");
		uInputTextureV = GLES20.glGetUniformLocation(getProgram(), "uInputTextureV");
		uInputTextureUV = GLES20.glGetUniformLocation(getProgram(), "uInputTextureUV");
		
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
		
		if( bufferY != null ) {
			// 激活纹理单元GL_TEXTURE0
			GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
		    // 绑定Y纹理
		    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureIdY[0]);
            // 绑定Y采样数据Buffer, Y数据存在rgb字段
		    bufferY.position(0);
		    GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_LUMINANCE, inputWidth, inputHeight, 0, 
		    		GLES20.GL_LUMINANCE, GLES20.GL_UNSIGNED_BYTE, bufferY);
		    // 传入采样格式
			GLES20.glUniform1i(uFormat, format.ordinal());

		    switch ( format ) {
				case GL_YUV_Format_420P:{
					if( bufferU != null && bufferV != null ) {
						// 绑定U纹理
						GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureIdU[0]);
						// 绑定U采样数据Buffer, U数据存在rgb字段
						GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_LUMINANCE, inputWidth >> 1, inputHeight >> 1, 0,
								GLES20.GL_LUMINANCE, GLES20.GL_UNSIGNED_BYTE, bufferU);

						// 绑定V纹理
						GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureIdV[0]);
						// 绑定V采样数据Buffer, V数据存在rgb字段
						bufferV.position(0);
						GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_LUMINANCE, inputWidth >> 1, inputHeight >> 1, 0,
								GLES20.GL_LUMINANCE, GLES20.GL_UNSIGNED_BYTE, bufferV);


						// 传入所有纹理
						// 填充着色器-颜色采样器, 将纹理单元GL_TEXTURE0绑元定到采样器
						GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
						// 绑定Y纹理
						GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureIdY[0]);
						GLES20.glUniform1i(uInputTextureY, 0);

						// 填充着色器-颜色采样器, 将纹理单元GL_TEXTURE1绑元定到采样器
						GLES20.glActiveTexture(GLES20.GL_TEXTURE1);
						// 绑定U纹理
						GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureIdU[0]);
						GLES20.glUniform1i(uInputTextureU, 1);

						// 填充着色器-颜色采样器, 将纹理单元GL_TEXTURE2绑元定到采样器
						GLES20.glActiveTexture(GLES20.GL_TEXTURE2);
						// 绑定V纹理
						GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureIdV[0]);
						GLES20.glUniform1i(uInputTextureV, 2);

					}
				}break;
				case GL_YUV_Format_420SP: {
					if( bufferUV != null ) {
						// 绑定UV纹理
						GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureIdUV[0]);
						// 绑定UV采样数据Buffer, U数据存在rgb字段, V数据存在a字段
						bufferUV.position(0);
						GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_LUMINANCE_ALPHA, inputWidth >> 1, inputHeight >> 1, 0,
								GLES20.GL_LUMINANCE_ALPHA, GLES20.GL_UNSIGNED_BYTE, bufferUV);


						// 传入所有纹理
						// 填充着色器-颜色采样器, 将纹理单元GL_TEXTURE0绑元定到采样器
						GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
						// 绑定Y纹理
						GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureIdY[0]);
						GLES20.glUniform1i(uInputTextureY, 0);

						// 填充着色器-颜色采样器, 将纹理单元GL_TEXTURE1绑元定到采样器
						GLES20.glActiveTexture(GLES20.GL_TEXTURE1);
						// 绑定UV纹理
						GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureIdUV[0]);
						GLES20.glUniform1i(uInputTextureUV, 1);

					}
				}break;
				default:break;
			}
		}
	}
	
	@Override
	protected int onDrawFrame(int textureId) {
		// 绘制
		GLES20.glDrawArrays(GLES20.GL_TRIANGLES, 0, 6);
		
		return super.onDrawFrame(textureId);
	}

	@Override
	protected void onDrawFinish(int textureId) {
		// TODO Auto-generated method stub
		// 取消着色器参数绑定
		GLES20.glDisableVertexAttribArray(aPosition);  
		GLES20.glDisableVertexAttribArray(aTextureCoordinate);
		
		// 解除纹理绑定
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);

		super.onDrawFinish(textureId);
	}
	
	/**
	 * 创建新FBO
	 */
	private void createGLTexture() {
		// 创建Y纹理
		textureIdY = LSImageFilter.genPixelTexture();

		// 创建U纹理
		textureIdU = LSImageFilter.genPixelTexture();

		// 创建V纹理
		textureIdV = LSImageFilter.genPixelTexture();

		// 创建UV纹理
		textureIdUV = LSImageFilter.genPixelTexture();

	    // 解除纹理绑定
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);
		
		Log.d(LSConfig.TAG, String.format("LSImageInputYuvFilter::createGLTexture( textureIdY : %d, textureIdU : %d, textureIdV : %d, textureIdUV : %d ) ", textureIdY[0], textureIdU[0], textureIdV[0], textureIdUV[0]));
	}
	
	/**
	 * 销毁纹理
	 */
	private void destroyGLTexture() {
		if( textureIdY != null ) {
			LSImageFilter.deleteTexture(textureIdY);
			textureIdY = null;
		}
		
		if( textureIdU != null ) {
            LSImageFilter.deleteTexture(textureIdU);
			textureIdU = null;
		}
		
		if( textureIdV != null ) {
            LSImageFilter.deleteTexture(textureIdV);
			textureIdV = null;
		}

		if( textureIdUV != null ) {
            LSImageFilter.deleteTexture(textureIdUV);
			textureIdUV = null;
		}
	}
	
	private ByteBuffer resetBuffer(ByteBuffer byteBuffer, int byteSize) {
		ByteBuffer newBuffer = byteBuffer;
		if( byteBuffer == null || byteBuffer.capacity() < byteSize ) {
			newBuffer = ByteBuffer.allocate(byteSize);
		}
		return newBuffer;
	}
	
}
