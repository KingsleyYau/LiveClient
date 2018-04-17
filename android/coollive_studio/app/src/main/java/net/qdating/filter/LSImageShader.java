package net.qdating.filter;

import net.qdating.LSConfig;

public class LSImageShader {
	private static final String emptyLedChar = "void ledChar(int n, float xa, float xb, float ya, float yb, vec2 vTC) {} \n";
	private static final String debugLedChar = ""
			+ "// 构造LED字符 \n"
			+ "precision mediump float;\n"
			+ "void ledChar(int c, float xa, float xb, float ya, float yb, vec2 vTC) { \n"
			+ "float x = vTC.x; \n"
			+ "float y = vTC.y; \n"
			+ "float x1 = xa; \n"
			+ "float x2 = xa + xb; \n"
			+ "float y1 = ya; \n"
			+ "float y2 = ya + yb; \n"
			+ "float ox = (x2 + x1) / 2.0; \n"
			+ "float oy = (y2 + y1) / 2.0; \n"
			+ "float dx = min(yb, xb) / 10.0; \n"
			+ "float dy = min(yb, xb) / 10.0; \n"
			+ "// 设定调试区显示范围\n"
			+ "if(x >= x1 && x <= x2 && y >= y1 && y <= y2) { \n"
			+ "// 设置调试区背景色为半透明的蓝色 \n"
			+ "gl_FragColor = vec4(0, 0, 1.0, 0.3); \n"
			+ "	// 分别绘制出LED形式的字符 \n"
			+ "	if("
			+ " (c==1 && (x > x2-dx)) || "
			+ "	(c==2 && ((y < y1+dy) || (x > x2-dx && y < oy) || (y > oy-dy/2.0 && y < oy+dy/2.0) || (x < x1+dx && y > oy) || (y > y2-dy))) || "
			+ "	(c==3 && ((y < y1+dy) || (y > oy-dy/2.0 && y < oy+dy/2.0) ||  (y > y2-dy) || (x > x2-dx))) || "
			+ "	(c==4 && ((x < x1+dx && y < oy) || (y > oy-dy/2.0 && y < oy+dy/2.0) || (x > x2-dx))) || "
			+ "	(c==5 && ((y < y1+dy) || (x < x1+dx && y < oy) || (y > oy-dy/2.0 && y < oy+dy/2.0) || (x > x2-dx && y > oy) || (y > y2-dy))) || "
			+ "	(c==6 && ((y < y1+dy) || (x < x1+dx) || (y > oy-dy/2.0 && y < oy+dy/2.0) || (x > x2-dx && y > oy) || (y > y2-dy))) || "
			+ "	(c==7 && ((y < y1+dy) || (x > x2-dx))) || "
			+ "	(c==8 && ((y < y1+dy) || (x < x1+dx) || (y > oy-dy/2.0 && y < oy+dy/2.0) || (x>x2-dx) || (y > y2-dy))) || "
			+ "	(c==9 && ((y < y1+dy) || (x < x1+dx && y < oy) || (y > oy-dy/2.0 && y < oy+dy/2.0) || (x > x2-dx) || (y > y2-dy))) || "
			+ "	(c==0 && ((y < y1+dy) || (x < x1+dx) || (x > x2-dx) || (y > y2-dy/2.0))) || "

			+ "	(c==45 && ((y > oy-dy/2.0 && y < oy+dy/2.0))) || " // -
			+ "	(c==80 && ((y < y1+dy) || (x < x1+dx) || (y > oy-dy/2.0 && y < oy+dy/2.0) || (x > x2-dx && y < oy))) || " // P
			+ "	(c==83 && ((y < y1+dy) || (x < x1+dx && y < oy) || (y > oy-dy/2.0 && y < oy+dy/2.0) || (x > x2-dx && y > oy) || (y > y2-dy))) " // S
			+ " )\n"
			+ "		{\n"
			+ "			// 设置数字颜色为红色 \n"
			+ "			gl_FragColor = vec4(1, 0, 0, 1); \n"
			+ "		}\n"
			+ "	} \n"
			+ "} \n";

	public static String ledChar = LSConfig.DEBUG?debugLedChar:emptyLedChar;

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
