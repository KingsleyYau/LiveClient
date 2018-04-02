package net.qdating.filter;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;

import android.content.Context;
import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import net.qdating.LSConfig;
import net.qdating.LSConfig.FillMode;
import net.qdating.utils.Log;

public abstract class LSImageFilter {
	/**
	 * 渲染模式
	 */
	public FillMode fillMode = FillMode.FillModeAspectRatioFill;
	
	/**
	 * 没有纹理
	 */
	static public int INVALID_TEXTUREID = 0;
	/**
	 * 无效的着色器程序
	 */
	static private int INVALID_PROGRAM = 0;
	/**
	 * 无效的着色器
	 */
	static private int INVALID_SHADER = 0;
	
	/**
	 * Android上下文
	 */
	protected Context context = null;
	/**
	 * 着色器程序
	 */
	private int glProgram = INVALID_PROGRAM;
	/**
	 * 顶点着色器
	 */
	private int glVertexShader = INVALID_SHADER;
	private String vertexShaderString = "";
	/**
	 * 颜色着色器
	 */
	private int glFragmentShader = INVALID_SHADER;
	private String fragmentShaderString = "";
	/**
	 * 顶点着色器Buffer
	 */
	private FloatBuffer glVertexBuffer = null;
	
	/**
	 * 是否初始化成功
	 */
	private boolean bInit = false;
	/**
	 * 下一个滤镜
	 */
	private LSImageFilter filter = null;
	
	/**
	 * 输入宽
	 */
	protected int inputWidth = 0;
	/**
	 * 输入高
	 */
	protected int inputHeight = 0;
	/**
	 * 预览宽
	 */
	protected int viewPointWidth = 0;
	/**
	 * 预览高
	 */
	protected int viewPointHeight = 0;
	
	protected class ImageSize {
		public boolean bChange;
		public int width;
		public int height;
		
		public ImageSize() {
			
		}
	}
	
	/**
	 * 创建纹理
	 * @return
	 */
	public static int[] genPixelTexture() {
		// 创建新纹理
		int textureId[] = new int[1];
		GLES20.glGenTextures(1, textureId, 0);
		
	    // 绑定纹理
	    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureId[0]);
	    
	    // 设置纹理参数
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_REPEAT);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_REPEAT);
        
        // 解除纹理绑定
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);
        
        Log.d(LSConfig.TAG, String.format("LSImageFilter::genPixelTexture( textureId : %d )", textureId[0]));
        
	    return textureId;
	}
	
	public static int[] genCameraTexture() {
		// 创建新纹理
		int textureId[] = new int[1];
	    GLES20.glGenTextures(1, textureId, 0);
        // 开始绑定纹理
	    GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textureId[0]);
	    
	    /**
	     * GL_LINEAR 不失真, 但会模糊
	     * GL_NEAREST 失真, 但不会模糊
	     * 
	     * GL_REPEAT 平铺
	     * GL_MIRRORED_REPEAT 镜像平铺
	     * GL_CLAMP_TO_EDGE 超出部分变为条纹(OSE纹理只能用这个)
	     * GL_CLAMP_TO_BORDER 居中
	     */
	    // 设定纹理过滤参数
	    GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST);
	    GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
	    GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
	    GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
	    
	    // 解除纹理绑定
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, 0);
        
        Log.d(LSConfig.TAG, String.format("LSImageFilter::genCameraTexture( textureId : %d )", textureId[0]));
        
	    return textureId;
	}
	
	/**
	 * 销毁纹理
	 */
	public static void deleteTexture(int[] textureId) {
		if( textureId != null ) {
			Log.d(LSConfig.TAG, String.format("LSImageFilter::deleteTexture( textureId : %d )", textureId[0]));
			GLES20.glDeleteTextures(1, textureId, 0);
		}
	}
	
	public LSImageFilter(String vertexShaderString, String fragmentShaderString, float filterVertex[]) {
		this.vertexShaderString = vertexShaderString;
		this.fragmentShaderString = fragmentShaderString;
		initFilterVertexBuffer(filterVertex);
	}
	
	public LSImageFilter(Context context, int vertexShaderId, int fragmentShaderId, float filterVertex[]) {
		// 从资源加载着色器代码
		this.vertexShaderString = LSImageUtil.loadShaderString(context, vertexShaderId);
		this.fragmentShaderString = LSImageUtil.loadShaderString(context, fragmentShaderId);
		initFilterVertexBuffer(filterVertex);
	}
	
	/**
	 * 初始化滤镜
	 * @return 返回纹理Id
	 */
	public void init() {
		// 加载着色器
		initGLShader(vertexShaderString, fragmentShaderString);
	}
	
	/**
	 * 销毁滤镜
	 */
	public void uninit() {
		uninitGLShader();
	}
	
	/**
	 * 设置下一个滤镜
	 */
	public void setFilter(LSImageFilter filter) {
		this.filter = filter;
	}
	
	/**
	 * 改变滤镜输出大小
	 * @param inputWidth
	 * @param inputHeight
	 * @return 是否改变
	 */
	public boolean changeViewPointSize(int viewPointWidth, int viewPointHeight) {
		boolean bFlag = false;
		if( this.viewPointWidth != viewPointWidth || this.viewPointHeight != viewPointHeight ) {
			this.viewPointWidth = viewPointWidth;
			this.viewPointHeight = viewPointHeight;
			bFlag = true;
			
			Log.d(LSConfig.TAG, String.format("LSImageFilter::changeViewPointSize( viewPointWidth : %d, viewPointHeight : %d, className : [%s] )", viewPointWidth, viewPointHeight, getClass().getName()));
		}
		return bFlag;
	}
	
	/**
	 * 绘制纹理
	 * @param textureId
	 */
	public void draw(int textureId, int width, int height) {
//		if( LSConfig.debug ) {
//			Log.d(LSConfig.TAG, String.format("LSImageFilter::draw( textureId : %d, glProgram : %d, className : [%s] )", textureId, glProgram, getClass().getName()));
//		}
		
		GLES20.glUseProgram(glProgram);
		
		// 更新输入大小
		ImageSize outputImageSize = changeInputSize(width, height);
		// 更新滤镜后的大小
		changeViewPoint(outputImageSize.width, outputImageSize.height, viewPointWidth, viewPointHeight);
		
		// 绑定自定义参数
		onDrawStart(textureId);
		// 自定义绘制
		int newTextureId = onDrawFrame(textureId);
		// 解绑自定义参数
		onDrawFinish(textureId);
		
		// 绘制下一个滤镜
		if( filter != null ) {
			filter.draw(newTextureId, outputImageSize.width, outputImageSize.height);
		}
	}
	
	/**
	 * 绘制纹理开始(子类重载)
	 * @param textureId
	 */
	protected abstract void onDrawStart(int textureId);
	
	/**
	 * 绘制纹理过程(子类重载)
	 * @param textureId 绘制完新的纹理Id
	 */
	protected int onDrawFrame(int textureId) {
		return textureId;
	}
	
	/**
	 * 绘制纹理结束(子类重载)
	 * @param textureId
	 */
	protected abstract void onDrawFinish(int textureId);
	
	/**
	 * 改变滤镜输入大小
	 * @param inputWidth
	 * @param inputHeight
	 * @return 是否改变
	 */
	protected ImageSize changeInputSize(int inputWidth, int inputHeight) {
		ImageSize imageSize = new ImageSize();
		
		boolean bFlag = false;
		if( this.inputWidth != inputWidth || this.inputHeight != inputHeight ) {
			this.inputWidth = inputWidth;
			this.inputHeight = inputHeight;
			
			// 设置默认的视觉
			if( viewPointWidth == 0 || viewPointHeight == 0 ) {
				changeViewPointSize(inputWidth, inputHeight);
			}
			
			bFlag = true;
			
			Log.d(LSConfig.TAG, String.format("LSImageFilter::changeInputSize( this : 0x%x, inputWidth : %d, inputHeight : %d, className : [%s] )", hashCode(), inputWidth, inputHeight, getClass().getName()));
		}
		
		imageSize.bChange = bFlag;
		imageSize.width = this.inputWidth;
		imageSize.height = this.inputHeight;
		
		return imageSize;
	}
	
	/**
	 * 设定视觉
	 */
	protected void changeViewPoint(int imageWidth, int imageHeight, int viewWidth, int viewHeight) {
        // 设定视觉为窗口大小, GLES纹理坐标
        int coordinateX = 0;
        int coordinateY = 0;
        int coordinateWidth = 0;
        int coordinateHeight = 0;
        
        int outputWidth = viewWidth;
        int outputHeight = viewHeight;
        
        if( fillMode == FillMode.FillModeAspectRatioFill ) {
        	// 长边填满
        	if( inputHeight > 0 && outputHeight > 0 ) {
            	// 目标比例
            	double radioPreview = 1.0 * outputWidth / outputHeight;
            	// 源比例
            	double radioImage = 1.0 * imageWidth / imageHeight;
            	if( radioPreview < radioImage ) { 
            		// 剪裁左右
            		coordinateHeight = outputHeight;
            		coordinateWidth = (int)(outputHeight * radioImage);
    		        coordinateX = (outputWidth - coordinateWidth) / 2;
    		        
//    		        if( LSConfig.debug ) {
//    	                Log.d(LSConfig.TAG, String.format("LSImageFilter::changeViewPoint( "
//    	                		+ "[剪裁左右], x : %d, y : %d, coordinateWidth : %d, coordinateHeight : %d, radioImage : %f, radioPreview : %f ) ", 
//    	                		coordinateX, coordinateY, coordinateWidth, coordinateHeight, radioImage, radioPreview));
//    		        }
                    
            	} else {
            		// 剪裁上下
            		coordinateWidth = outputWidth;
            		coordinateHeight = (int)(1.0 * outputWidth / radioImage);
    		        coordinateY = (outputHeight - coordinateHeight) / 2;
    		        
//    		        if( LSConfig.debug ) {
//    	                Log.d(LSConfig.TAG, String.format("LSImageFilter::changeViewPoint( "
//    	                		+ "[剪裁上下], x : %d, y : %d, coordinateWidth : %d, coordinateHeight : %d, radioImage : %f, radioPreview : %f ) ", 
//    	                		coordinateX, coordinateY, coordinateWidth, coordinateHeight, radioImage, radioPreview));
//    		        }
            	}
        	}
        } else if ( fillMode == FillMode.FillModeAspectRatioFit ) {
        	// 短边内嵌
        	if( inputHeight > 0 && outputHeight > 0 ) {
            	// 目标比例
            	double radioPreview = 1.0 * outputWidth / outputHeight;
            	// 源比例
            	double radioImage = 1.0 * imageWidth / imageHeight;
            	if( radioPreview < radioImage ) { 
            		// 上下留黑
            		coordinateWidth = outputWidth;
            		coordinateHeight = (int)(1.0 * outputWidth / radioImage);
            		coordinateY = (outputHeight - coordinateHeight) / 2;
            	} else {
            		// 左右留黑
            		coordinateHeight = outputHeight;
            		coordinateWidth = (int)(outputHeight * radioImage);
    		        coordinateX = (outputWidth - coordinateWidth) / 2;
            	}
        	}
        	
        } else {
        	// 拉伸填满
        	coordinateWidth = outputWidth;
        	coordinateHeight = outputHeight;
        }
        
        // 开始设定视觉
    	GLES20.glViewport(coordinateX, coordinateY, coordinateWidth, coordinateHeight);
	}
	
	protected int getProgram() {
		return glProgram;
	}
	
	protected void updateVertexBuffer(float filterVertex[]) {
		if( filterVertex != null ) {
		    // 创建着色器内存
			glVertexBuffer.position(0);
			glVertexBuffer.put(filterVertex, 0, filterVertex.length);
		}
	}
	
	protected FloatBuffer getVertexBuffer() {
		return glVertexBuffer;
	}
	
	/**
	 * 初始化顶点坐标Buffer
	 * @param filterVertex
	 */
	private void initFilterVertexBuffer(float filterVertex[]) {
		if( filterVertex != null ) {
		    // 创建着色器内存
			glVertexBuffer = ByteBuffer.allocateDirect(4 * filterVertex.length)
					.order(ByteOrder.nativeOrder())
	                .asFloatBuffer();
			glVertexBuffer.put(filterVertex, 0, filterVertex.length);
			glVertexBuffer.position(0);
		}
	}
	
	/**
	 * 加载着色器
	 * @param vertexShaderString 顶点着色器
	 * @param fragmentShaderString 颜色着色器
	 */
	private void initGLShader(String vertexShaderString, String fragmentShaderString) {
		glProgram = GLES20.glCreateProgram();
		if( glProgram != 0 ) {
			// 加载着色器
			glVertexShader = loadGLShader(GLES20.GL_VERTEX_SHADER, vertexShaderString);
			glFragmentShader = loadGLShader(GLES20.GL_FRAGMENT_SHADER, fragmentShaderString);
			
			Log.d(LSConfig.TAG,
					String.format("LSImageFilter::initGLShader( "
									+ "this : 0x%x, "
									+ "glProgram : %d, "
									+ "glVertexShader : %d, "
									+ "glFragmentShader : %d, "
									+ "className : [%s] " +
									")",
							hashCode(),
							glProgram,
							glVertexShader,
							glFragmentShader,
							getClass().getName()
					)
			);

			if( glVertexShader != INVALID_SHADER && 
					glFragmentShader != INVALID_SHADER ) {
				// 链接着色器程序
				GLES20.glAttachShader(glProgram, glVertexShader);
				GLES20.glAttachShader(glProgram, glFragmentShader);
				GLES20.glLinkProgram(glProgram);
				// 初始化成功
				bInit = true;
			}
		}
		
		if( !bInit ) {
			Log.e(LSConfig.TAG, String.format("LSImageFilter::initGLShader( this : 0x%x, [Fail], glProgram : %d, glError : %d, className : [%s] )", hashCode(), GLES20.glGetError(), getClass().getName()));
			uninitGLShader();
		}
	}
	 
	/**
	 * 销毁着色器
	 */
	private void uninitGLShader() {
		if( glProgram != INVALID_PROGRAM ) {
			GLES20.glDeleteProgram(glProgram);
			glProgram = INVALID_PROGRAM;
		}
		if( glVertexShader != INVALID_SHADER ) {
			GLES20.glDeleteShader(glVertexShader);
			glVertexShader = INVALID_SHADER;
		}
		
		if( glFragmentShader != INVALID_SHADER ) {
			GLES20.glDeleteShader(glFragmentShader);
			glFragmentShader = INVALID_SHADER;
		}
	}
	
	/**
	 * 编译着色器
	 * @param type 类型(GLES20.GL_VERTEX_SHADER / GLES20.GL_FRAGMENT_SHADER)
	 * @param shaderString 源码
	 * @return
	 */
	private int loadGLShader(int type, String shaderString) {
		int shader = INVALID_SHADER;
		// 1. Load Shader source code (in string)
		if( shaderString != null ) {
			shader = GLES20.glCreateShader(type);
			GLES20.glShaderSource(shader, shaderString);
			// 2. Compile Shader
			GLES20.glCompileShader(shader);
			
			int[] compiled = new int[1];
			GLES20.glGetShaderiv(shader, GLES20.GL_COMPILE_STATUS, compiled, 0);
	        if ( compiled[0] == 0 ) {
	        	Log.e(LSConfig.TAG, String.format("LSImageFilter::loadGLShader( this : 0x%x, [Compile Shader Failed] : %s, shaderString : %s )", hashCode(), GLES20.glGetShaderInfoLog(shader), shaderString));
	        	shader = -1;
	        } else {
//	        	Log.d(LSConfig.TAG, String.format("LSImageFilter::loadShader(\n%s\n) ", shaderString));
			}
	        
		} else {
			Log.e(LSConfig.TAG, String.format("LSImageFilter::loadGLShader( this : 0x%x, [Load Shader String Failed] )", hashCode()));
		}

		return shader;
	}
}
