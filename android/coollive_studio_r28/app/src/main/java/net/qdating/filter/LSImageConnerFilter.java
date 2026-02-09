package net.qdating.filter;

import android.opengl.GLES20;

import net.qdating.LSConfig;
import net.qdating.utils.Log;

import java.util.Random;

/**
 * 抖音滤镜
 * @author max
 *
 */
public class LSImageConnerFilter extends LSImageBufferFilter {
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
			+ "uniform lowp vec2 uImagePixel; \n"
			+ "uniform lowp float uCornerRadius; \n"
			+ "// 片段着色器(输入) \n"
			+ "varying highp vec2 vTextureCoordinate; \n"
			+ "void main() { \n"
            + "     vec3 rgb = texture2D(uInputTexture, vTextureCoordinate).rgb;\n"

            + "     vec2 pixelPos = vTextureCoordinate * uImagePixel; \n"
            + "		vec2 topLeft = vec2(uCornerRadius, uCornerRadius); \n"
            + "		vec2 topRight = vec2(uImagePixel.x - uCornerRadius, uCornerRadius); \n"
            + "		vec2 bottomLeft = vec2(uCornerRadius, uImagePixel.y - uCornerRadius); \n"
            + "		vec2 bottomRight = vec2(uImagePixel.x - uCornerRadius, uImagePixel.y - uCornerRadius); \n"

            + "		float distTL = distance(pixelPos, topLeft);\n"
            + "		float distTR = distance(pixelPos, topRight); \n"
            + "		float distBL = distance(pixelPos, bottomLeft);\n"
            + "		float distBR = distance(pixelPos, bottomRight); \n"

            + "		if (pixelPos.x < uCornerRadius && pixelPos.y < uCornerRadius && distTL > uCornerRadius) {\n"
            + "        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);\n"
            + "		} else if (pixelPos.x > uImagePixel.x - uCornerRadius && pixelPos.y < uCornerRadius && distTR > uCornerRadius) {\n"
            + "        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);\n"
            + "		} else if (pixelPos.x < uCornerRadius && pixelPos.y > uImagePixel.y - uCornerRadius && distBL > uCornerRadius) {\n"
            + "        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);\n"
            + "		} else if (pixelPos.x > uImagePixel.x - uCornerRadius && pixelPos.y > uImagePixel.y - uCornerRadius && distBR > uCornerRadius) {\n"
            + "        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);\n"
            + "     } else { \n"
            + "        gl_FragColor = vec4(rgb.r, rgb.g, rgb.b, 1.0); \n"
            + "     }; \n"
			+ "} \n";

	private int aPosition;
	private int aTextureCoordinate;
	private int uInputTexture;
	private int uImagePixel;
	private int uCornerRadius;

	private float uvImagePixel[] = new float[2];
    private float uvCornerRadius = 30;
    private float level = 0.2f;

	public LSImageConnerFilter() {
		super(vertexShaderString, fragmentShaderString, LSImageVertex.filterVertex_0);
		// TODO Auto-generated constructor stub
	}

	public LSImageConnerFilter(double level) {
		super(vertexShaderString, fragmentShaderString, LSImageVertex.filterVertex_0);
		// TODO Auto-generated constructor stub
	}

	/**
	 * 设置抖动等级
	 * @param level 0.0 ~ 1.0
	 */
	public void setLevel(float level) {
		Log.d(LSConfig.TAG,
				String.format("LSImageConnerFilter::setLevel( "
								+ "level : %f "
								+ ")",
						level
				)
		);
		this.level = level;
	}

	@Override
	protected ImageSize changeInputSize(int inputWidth, int inputHeight) {
		ImageSize imageSize = super.changeInputSize(inputWidth, inputHeight);

		if( imageSize.bChange ) {
            uvImagePixel[0] = inputWidth;
            uvImagePixel[1] = inputHeight;

            this.uvCornerRadius = this.level * Math.min(inputWidth, inputHeight);
		}

		return imageSize;
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
		uImagePixel = GLES20.glGetUniformLocation(getProgram(), "uImagePixel");
        uCornerRadius = GLES20.glGetUniformLocation(getProgram(), "uCornerRadius");

		// 填充着色器-顶点采样器
		if( getVertexBuffer() != null ) {
			// 顶点每次读取2个值, 每4个元素,[跨过2个着色器](4 * 4byte = 16byte)为下一组顶点开始
			getVertexBuffer().position(0);
			GLES20.glVertexAttribPointer(aPosition, 2, GLES20.GL_FLOAT, false, 16, getVertexBuffer());
			GLES20.glEnableVertexAttribArray(aPosition);

			// 填充着色器-纹理坐标
			// 纹理坐标每次读取2个值, 每4个元素,[跨过2个着色器](4 * 4byte = 16byte)为下一组纹理坐标开始
			getVertexBuffer().position(2);
			GLES20.glVertexAttribPointer(aTextureCoordinate, 2, GLES20.GL_FLOAT, false, 16, getVertexBuffer());
			GLES20.glEnableVertexAttribArray(aTextureCoordinate);
		}

		// 填充着色器-颜色采样器, 将纹理单元GL_TEXTURE0绑元定到采样器
		GLES20.glUniform1i(uInputTexture, 0);

		// 填充着色器
		GLES20.glUniform2f(uImagePixel, uvImagePixel[0], uvImagePixel[1]);
		GLES20.glUniform1f(uCornerRadius, uvCornerRadius);
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
