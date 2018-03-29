package net.qdating.filter;

import java.nio.ByteBuffer;

import android.opengl.GLES20;
import net.qdating.LSConfig;
import net.qdating.utils.Log;

public class LSImageRawYuvFilter extends LSImageFilter {
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
			+ "// 图像顶点着色器\n"
			+ "// 纹理坐标(输入)\n"
			+ "attribute vec4 aPosition;\n"
			+ "// 自定义屏幕坐标(输入)\n"
			+ "attribute vec4 aTextureCoordinate;\n"
			+ "// 片段着色器(输出)\n"
			+ "varying vec2 vTextureCoordinate;\n"
			+ "void main() {\n"
			+ "vTextureCoordinate = aTextureCoordinate.xy;\n"
			+ "gl_Position = aPosition;\n"
			+ "}\n";
	
	public static String yuvPixelFragmentShaderString = "" 
			+ "// 图像颜色着色器\n"
			+ "precision mediump float;\n"
			+ "uniform sampler2D uInputTextureY;\n"
			+ "uniform sampler2D uInputTextureU;\n"
			+ "uniform sampler2D uInputTextureV;\n"
			+ "// 片段着色器(输入)\n"
			+ "varying highp vec2 vTextureCoordinate;\n"
			+ "void main() {\n"
			+ "float y = texture2D(uInputTextureY, vTextureCoordinate).r - .0625;\n"
            + "float u = texture2D(uInputTextureU, vTextureCoordinate).r - .5;\n"
            + "float v = texture2D(uInputTextureV, vTextureCoordinate).r - .5;\n"
            + "vec3 yuv = vec3(y, u, v);\n"
            + "vec3 rgb;\n"
            + "rgb = mat3(1.0, 		1.0, 		1.0, "
            + "			  0.0, 		-0.39465, 	2.03211, "
            + "           1.13983, 	-0.58060, 	0.0"
            + "			 ) * yuv;\n"
			+ "gl_FragColor = vec4(rgb, 1.0);\n"
			+ "}\n";
	
//	public static String yuvPixelFragmentShaderString = "" 
//			+ "// 图像颜色着色器\n"
//			+ "precision mediump float;\n"
//			+ "uniform sampler2D uInputTextureY;\n"
//			+ "uniform sampler2D uInputTextureU;\n"
//			+ "uniform sampler2D uInputTextureV;\n"
//			+ "// 片段着色器(输入)\n"
//			+ "varying highp vec2 vTextureCoordinate;\n"
//			+ "void main() {\n"
//            + "vec4 rgba = vec4((texture2D(uInputTextureY, vTextureCoordinate).r - 0.0625) * 1.164);\n"
//            + "vec4 u = vec4(texture2D(uInputTextureU, vTextureCoordinate).r - 0.5);\n"
//            + "vec4 v = vec4(texture2D(uInputTextureV, vTextureCoordinate).r - 0.5);\n"
//            + "rgba += v * vec4(1.596, -0.813, 0, 0);\n"
//            + "rgba += u * vec4(0, -0.392, 2.017, 0);\n"
//            + "rgba.a = 1.0;\n"
//            + "gl_FragColor = rgba;\n"
//			+ "}\n";
	
//	public static String yuvPixelFragmentShaderString = ""
//			+ "// 图像颜色着色器\n"
//			+ "precision mediump float;\n"
//			+ "uniform sampler2D uInputTextureY;\n"
//			+ "uniform sampler2D uInputTextureU;\n"
//			+ "uniform sampler2D uInputTextureV;\n"
//			+ "// 片段着色器(输入)\n"
//			+ "varying highp vec2 vTextureCoordinate;\n"
//			+ "void turnYuvIntoRgb(in float y, in float u, in float v, inout float r, inout float g, inout float b) {\n" 
//			+ "y = (y - 0.0625) * 1.164;\n"
//			+ "u = u - 0.5;\n"
//			+ "v = v - 0.5;\n"
//			+ "r = y + 1.596023559570 * v;\n"
//			+ "g = y - 0.3917694091796875 * u - 0.8129730224609375 * v;\n"
//			+ "b = y + 2.017227172851563 * u;\n"
//			+ "}\n"
//			+ "\n"
//			+ "void main() {\n"
//			+ "float r, g, b;\n"
//			+ "// 因为是YUV的一个平面，所以采样后的r,g,b,a这四个参数的数值是一样的\n"
//			+ "// 因为NV12是2平面的，对于UV平面，在加载纹理时，会指定格式，让u值存在r,g,b中，v值存在a中"
//			+ "float y = (texture2D(uInputTextureY, vTextureCoordinate).r);\n"
//			+ "float u = (texture2D(uInputTextureU, vTextureCoordinate).r);\n"
//			+ "float v = (texture2D(uInputTextureV, vTextureCoordinate).r);\n"
//			+ "turnYuvIntoRgb(y, u, v, r, g, b);\n"
//            + "vec4 rgb = vec4(r, g, b, 1.0);\n"
//			+ "gl_FragColor = rgb;\n"
//			+ "}\n";
	
	private int aPosition;
	private int aTextureCoordinate;
	
	private int[] textureIdY;
	private int[] textureIdU;
	private int[] textureIdV;
	
	private int uInputTextureY;
	private int uInputTextureU;
	private int uInputTextureV;
	
	private ByteBuffer bufferY;
	private ByteBuffer bufferU;
	private ByteBuffer bufferV;
	
	public LSImageRawYuvFilter() {
		super(yuvPixelVertexShaderString, yuvPixelFragmentShaderString, LSImageVertex.filterVertex_0);
	}

	public void updateYuvFrame(			
			byte [] byteArrayY, int byteSizeY,
			byte [] byteArrayU, int byteSizeU,
			byte [] byteArrayV, int byteSizeV
			) {
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
	
	@Override
	public void init() {
		super.init();
		
		createGLTexture();
	}
	
	@Override
	public void uninit() {
		super.uninit();
		
		destroyGLTexture();
	}
	
	@Override
	protected void onDrawStart(int textureId) {
		// TODO Auto-generated method stub
		aPosition = GLES20.glGetAttribLocation(getProgram(), "aPosition");
		aTextureCoordinate = GLES20.glGetAttribLocation(getProgram(), "aTextureCoordinate");
		uInputTextureY = GLES20.glGetUniformLocation(getProgram(), "uInputTextureY");
		uInputTextureU = GLES20.glGetUniformLocation(getProgram(), "uInputTextureU");
		uInputTextureV = GLES20.glGetUniformLocation(getProgram(), "uInputTextureV");
		
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
		
		if( bufferY != null && bufferU != null && bufferV != null ) {
		    // 绑定Y纹理
		    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureIdY[0]);
	        // 绑定Y纹理
		    bufferY.position(0);
		    GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_LUMINANCE, inputWidth, inputHeight, 0, 
		    		GLES20.GL_LUMINANCE, GLES20.GL_UNSIGNED_BYTE, bufferY);
		    
		    // 绑定U纹理
		    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureIdU[0]);
	        // 绑定U纹理
			bufferU.position(0);
		    GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_LUMINANCE, inputWidth >> 1, inputHeight >> 1, 0, 
		    		GLES20.GL_LUMINANCE, GLES20.GL_UNSIGNED_BYTE, bufferU);
		    
		    // 绑定V纹理
		    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureIdV[0]);
	        // 绑定V纹理
			bufferV.position(0);
		    GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_LUMINANCE, inputWidth >> 1, inputHeight >> 1, 0, 
		    		GLES20.GL_LUMINANCE, GLES20.GL_UNSIGNED_BYTE, bufferV);
		    
		}
	}
	
	@Override
	protected int onDrawFrame(int textureId) {
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
	}
	
	/**
	 * 创建新FBO
	 */
	private void createGLTexture() {
		// 创建Y纹理
		textureIdY = new int[1];
		GLES20.glGenTextures(1, textureIdY, 0);
		
	    // 绑定Y纹理
	    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureIdY[0]);
	    // 设置纹理参数
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
        
		// 创建U纹理
		textureIdU = new int[1];
		GLES20.glGenTextures(1, textureIdU, 0);
		
	    // 绑定U纹理
	    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureIdU[0]);
	    // 设置纹理参数
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
        
		// 创建V纹理
		textureIdV = new int[1];
		GLES20.glGenTextures(1, textureIdV, 0);
		
	    // 绑定V纹理
	    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureIdV[0]);
	    // 设置纹理参数
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
        
	    // 解除纹理绑定
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);
		
		Log.d(LSConfig.TAG, String.format("LSImageRawYuvFilter::createGLTexture( textureIdY : %d, textureIdU : %d, textureIdV : %d ) ", textureIdY[0], textureIdU[0], textureIdV[0]));
	}
	
	/**
	 * 销毁纹理
	 */
	private void destroyGLTexture() {
		if( textureIdY != null ) {
			GLES20.glDeleteTextures(1, textureIdY, 0);
			textureIdY = null;
		}
		
		if( textureIdU != null ) {
			GLES20.glDeleteTextures(1, textureIdU, 0);
			textureIdU = null;
		}
		
		if( textureIdV != null ) {
			GLES20.glDeleteTextures(1, textureIdV, 0);
			textureIdV = null;
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
