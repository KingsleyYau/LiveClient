package net.qdating.filter;

public class LSImageShader {
	public static String defaultPixelVertexShaderString = ""
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
	public static String dafaultPixelFragmentShaderString = ""
			+ "// 图像颜色着色器\n"
			+ "uniform sampler2D uInputTexture;\n"
			+ "// 片段着色器(输入)\n"
			+ "varying highp vec2 vTextureCoordinate;\n"
			+ "void main() {\n"
			+ "gl_FragColor = texture2D(uInputTexture, vTextureCoordinate);\n"
			+ "}\n";
}
