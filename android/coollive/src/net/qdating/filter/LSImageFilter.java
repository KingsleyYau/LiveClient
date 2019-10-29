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


/**
 * 基础滤镜
 * @author max
 *
 */
public abstract class LSImageFilter {
	/**
	 * 渲染模式
	 */
	public FillMode fillMode = FillMode.FillModeStretch;
	
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

	/**
	 * 预览X坐标
	 */
	protected int viewPointX = 0;
	/**
	 * 预览Y坐标
	 */
	protected int viewPointY = 0;

	protected class ImageSize {
		public boolean bChange;
		public int width;
		public int height;
		
		public ImageSize() {

		}
	}
	
	/**
	 * 创建2D纹理
	 * 不能在非EGL环境外调用
	 * @return 纹理句柄
	 */
	public static synchronized int[] genPixelTexture() {
		// 创建新纹理
		int textureId[] = new int[1];
		GLES20.glGenTextures(1, textureId, 0);
		
	    // 绑定纹理
	    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureId[0]);

		/**
		 * GL_LINEAR 不失真, 但会模糊
		 * GL_NEAREST 失真, 但不会模糊
		 *
		 * GL_REPEAT 平铺
		 * GL_MIRRORED_REPEAT 镜像平铺
		 * GL_CLAMP_TO_EDGE 超出部分变为条纹
		 * GL_CLAMP_TO_BORDER 居中
		 */
	    // 设置纹理参数
		GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
				GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
        
        // 解除纹理绑定
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);

//        Log.d(LSConfig.TAG, String.format("LSImageFilter::genPixelTexture( textureId : %d )", textureId[0]));

        String method = String.format("genPixelTexture( textureId : %d )", textureId[0]);
		checkGLError(method, null);

	    return textureId;
	}

	/**
	 * 创建OES纹理
	 * 不能在非EGL环境外调用
	 * @return 纹理句柄
	 */
	public static synchronized int[] genCameraTexture() {
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
        
//        Log.d(LSConfig.TAG, String.format("LSImageFilter::genCameraTexture( textureId : %d )", textureId[0]));

		String method = String.format("genCameraTexture( textureId : %d )", textureId[0]);
		checkGLError(method, null);

	    return textureId;
	}
	
	/**
	 * 销毁纹理
	 * 不能在非EGL环境外调用
	 * 利用GLSurface::onPause会回收资源, 不需要显示调用
	 */
	public static synchronized void deleteTexture(int[] textureId) {
		if( textureId != null ) {
			GLES20.glDeleteTextures(1, textureId, 0);
			Log.d(LSConfig.TAG, String.format("LSImageFilter::deleteTexture( textureId : %d )", textureId[0]));
			String method = String.format("deleteTexture( textureId : %d )", textureId[0]);
			checkGLError(method, null);
		}
	}

	public LSImageFilter() {
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
	 * 不能在非EGL环境外调用
	 */
	public void init() {
		Log.d(LSConfig.TAG, String.format("LSImageFilter::init( this : 0x%x, className : [%s] )", hashCode(), getClass().getName()));
		initGLShader(vertexShaderString, fragmentShaderString);
	}
	
	/**
	 * 销毁滤镜
	 * 不能在非EGL环境外调用
	 * 如果利用GLSurface::onPause会回收资源, 不需要显式调用
	 */
	public void uninit() {
		Log.d(LSConfig.TAG, String.format("LSImageFilter::uninit( this : 0x%x, className : [%s] )", hashCode(), getClass().getName()));
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
	 * @param viewPointWidth
	 * @param viewPointHeight
	 * @return 是否改变
	 */
	public boolean changeViewPointSize(int viewPointWidth, int viewPointHeight) {
		boolean bFlag = false;
		if( this.viewPointWidth != viewPointWidth || this.viewPointHeight != viewPointHeight ) {
			this.viewPointWidth = viewPointWidth;
			this.viewPointHeight = viewPointHeight;
			bFlag = true;
			
			Log.d(LSConfig.TAG,
					String.format("LSImageFilter::changeViewPointSize( "
									+ "this : 0x%x, "
									+ "viewPointWidth : %d, "
									+ "viewPointHeight : %d, "
									+ "className : [%s] "
									+ ")",
							hashCode(),
							viewPointWidth,
							viewPointHeight,
							getClass().getName()
					)
			);
		}
		return bFlag;
	}
	
	/**
	 * 绘制纹理
	 * @param textureId
	 */
	public int draw(int textureId, int width, int height) {
		if( LSConfig.DEBUG ) {
			Log.d(LSConfig.TAG, String.format("LSImageFilter::draw( this : 0x%x, textureId : %d, glProgram : %d, className : [%s] )", hashCode(), textureId, glProgram, getClass().getName()));
		}

		if( glProgram != INVALID_PROGRAM ) {
			GLES20.glUseProgram(glProgram);
		}

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
			return filter.draw(newTextureId, outputImageSize.width, outputImageSize.height);
		} else {
			return newTextureId;
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

			Log.d(LSConfig.TAG, String.format("LSImageFilter::changeInputSize( this : 0x%x, inputWidth : %d, inputHeight : %d, className : [%s] )", hashCode(), inputWidth, inputHeight, getClass().getName()));

			// 设置默认的视觉
			if( viewPointWidth == 0 || viewPointHeight == 0 ) {
				changeViewPointSize(inputWidth, inputHeight);
			}
			
			bFlag = true;
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
        	// 输入图像短边填满输出
        	if( imageHeight > 0 && outputHeight > 0 ) {
            	// 目标比例
            	double radioPreview = 1.0 * outputWidth / outputHeight;
            	// 源比例
            	double radioImage = 1.0 * imageWidth / imageHeight;
            	if( radioPreview < radioImage ) { 
            		// 剪裁左右
            		coordinateHeight = outputHeight;
            		coordinateWidth = (int)(outputHeight * radioImage);
    		        coordinateX = (outputWidth - coordinateWidth) / 2;
    		        
//    		        if( LSConfig.DEBUG ) {
//    	                Log.d(LSConfig.TAG, String.format("LSImageFilter::changeViewPoint( "
//    	                		+ "[剪裁左右], x : %d, y : %d, coordinateWidth : %d, coordinateHeight : %d, radioImage : %f, radioPreview : %f, className : [%s] ) ",
//    	                		coordinateX, coordinateY, coordinateWidth, coordinateHeight, radioImage, radioPreview, getClass().getName()));
//    		        }
                    
            	} else {
            		// 剪裁上下
            		coordinateWidth = outputWidth;
            		coordinateHeight = (int)(1.0 * outputWidth / radioImage);
    		        coordinateY = (outputHeight - coordinateHeight) / 2;
    		        
//    		        if( LSConfig.DEBUG ) {
//    	                Log.d(LSConfig.TAG, String.format("LSImageFilter::changeViewPoint( "
//    	                		+ "[剪裁上下], x : %d, y : %d, coordinateWidth : %d, coordinateHeight : %d, radioImage : %f, radioPreview : %f, className : [%s] ) ",
//    	                		coordinateX, coordinateY, coordinateWidth, coordinateHeight, radioImage, radioPreview, getClass().getName()));
//    		        }
            	}
        	}
        } else if ( fillMode == FillMode.FillModeAspectRatioFit ) {
        	// 输入图像长边内嵌输出
        	if( imageHeight > 0 && outputHeight > 0 ) {
            	// 目标比例
            	double radioPreview = 1.0 * outputWidth / outputHeight;
            	// 源比例
            	double radioImage = 1.0 * imageWidth / imageHeight;
            	if( radioPreview < radioImage ) { 
            		// 上下留黑
            		coordinateWidth = outputWidth;
            		coordinateHeight = (int)(1.0 * outputWidth / radioImage);
            		coordinateY = (outputHeight - coordinateHeight) / 2;

//					if( LSConfig.DEBUG ) {
//						Log.d(LSConfig.TAG, String.format("LSImageFilter::changeViewPoint( "
//										+ "[上下留黑], x : %d, y : %d, coordinateWidth : %d, coordinateHeight : %d, radioImage : %f, radioPreview : %f, className : [%s] ) ",
//								coordinateX, coordinateY, coordinateWidth, coordinateHeight, radioImage, radioPreview, getClass().getName()));
//					}

            	} else {
            		// 左右留黑
            		coordinateHeight = outputHeight;
            		coordinateWidth = (int)(outputHeight * radioImage);
    		        coordinateX = (outputWidth - coordinateWidth) / 2;

//					if( LSConfig.DEBUG ) {
//						Log.d(LSConfig.TAG, String.format("LSImageFilter::changeViewPoint( "
//										+ "[左右留黑], x : %d, y : %d, coordinateWidth : %d, coordinateHeight : %d, radioImage : %f, radioPreview : %f, className : [%s] ) ",
//								coordinateX, coordinateY, coordinateWidth, coordinateHeight, radioImage, radioPreview, getClass().getName()));
//					}
            	}
        	}
        	
        } else {
        	// 输入图像拉伸填满输出
        	coordinateWidth = outputWidth;
        	coordinateHeight = outputHeight;

			if( LSConfig.DEBUG ) {
//				Log.d(LSConfig.TAG, String.format("LSImageFilter::changeViewPoint( "
//								+ "[拉伸填满], x : %d, y : %d, coordinateWidth : %d, coordinateHeight : %d, className : [%s] ) ",
//						coordinateX, coordinateY, coordinateWidth, coordinateHeight, getClass().getName()));
			}
        }

        // 记录预览起始坐标
		viewPointX = coordinateX;
		viewPointY = coordinateY;

        // 开始设定视觉
    	GLES20.glViewport(coordinateX, coordinateY, coordinateWidth, coordinateHeight);
	}

	/**
	 * 获取这色器程序句柄
	 * @return
	 */
	protected int getProgram() {
		return glProgram;
	}

	/**
	 * 更新着色器顶点坐标
	 * @param filterVertex 顶点坐标
	 */
	protected void updateVertexBuffer(float filterVertex[]) {
		if( filterVertex != null ) {
		    // 创建着色器内存
			glVertexBuffer.clear();
			glVertexBuffer.put(filterVertex, 0, filterVertex.length);
			glVertexBuffer.position(0);
		}
	}

	/**
	 * 获取着色器顶点坐标Buffer
	 * @return 顶点坐标Buffer
	 */
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
	 * 不能在非EGL环境外调用
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
			Log.e(LSConfig.TAG, String.format("LSImageFilter::initGLShader( this : 0x%x, [Fail], glProgram : %d, glError : 0x%x, className : [%s] )", hashCode(), GLES20.glGetError(), getClass().getName()));
			uninitGLShader();
		}
	}
	 
	/**
	 * 销毁着色器
	 * 不能在非EGL环境外调用
	 */
	private void uninitGLShader() {
		Log.d(LSConfig.TAG,
				String.format("LSImageFilter::uninitGLShader( "
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

		if( glProgram != INVALID_PROGRAM ) {
			// 卸载着色器
			if( glVertexShader != INVALID_SHADER ) {
				GLES20.glDetachShader(glProgram, glVertexShader);
				String method = String.format("glDetachShader( glVertexShader : %d )", glVertexShader);
				checkGLError(method, this);
			}
			if( glFragmentShader != INVALID_SHADER ) {
				GLES20.glDetachShader(glProgram, glFragmentShader);
				String method = String.format("glDetachShader( glFragmentShader : %d )", glFragmentShader);
				checkGLError(method, this);
			}

			// 销毁着色器程序
			GLES20.glDeleteProgram(glProgram);
			String method = String.format("glDeleteProgram( glProgram : %d )", glProgram);
			checkGLError(method, this);
			glProgram = INVALID_PROGRAM;
		}

		if( glVertexShader != INVALID_SHADER ) {
			GLES20.glDeleteShader(glVertexShader);
			String method = String.format("glDeleteShader( glVertexShader : %d )", glVertexShader);
			checkGLError(method, this);
			glVertexShader = INVALID_SHADER;
		}
		
		if( glFragmentShader != INVALID_SHADER ) {
			GLES20.glDeleteShader(glFragmentShader);
			String method = String.format("glDeleteShader( glFragmentShader : %d )", glFragmentShader);
			checkGLError(method, this);
			glFragmentShader = INVALID_SHADER;
		}
	}
	
	/**
	 * 编译着色器
	 * 不能在非EGL环境外调用
	 * @param type 类型(GLES20.GL_VERTEX_SHADER / GLES20.GL_FRAGMENT_SHADER)
	 * @param shaderString 源码
	 * @return 着色器
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

	static protected void checkGLError(String method, Object obj) {
		int glError = GLES20.glGetError();
		if( glError != 0 ) {
			String logString = "";
			String className = "";
			if( obj != null ) {
				className = obj.getClass().getName();
				logString = String.format("LSImageFilter::checkGLError( "
								+ "this : 0x%x, "
								+ "method : [%s], "
								+ "glError : 0x%x, "
								+ "className : [%s] "
								+ ")",
						obj.hashCode(),
						method,
						glError,
						className
				);
			} else {
				logString = String.format("LSImageFilter::checkGLError( "
								+ "method : [%s], "
								+ "glError : 0x%x "
								+ ")",
						method,
						glError
				);
			}
			Log.e(LSConfig.TAG, logString);
		}
	}
}
