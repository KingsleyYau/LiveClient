package net.qdating.filter;

/**
 * GLES顶点定义类
 * @author max
 * 以下顶点用GL_TRIANGLES来定义
 * GL_TRIANGLES：每三个顶点构成一个三角形，即顶点 012 构成一个三角形，顶点 345 构成一个三角形，依此类推；
 * GL_TRIANGLE_STRIP：任意相邻三个顶点都构成一个三角形，即顶点 012 构成一个三角形，顶点 123 构成一个三角形，依此类推；
 * GL_TRIANGLE_FAN：首个顶点不动，后续任意相邻两个顶点与首个顶点构成一个三角形，即顶点 012 构成一个三角形，顶点 023 构成一个三角形，依此类推；
 * 
 * GLES世界坐标: 也就是绘制区域(笛卡尔坐标, 窗口中心为原点, 绘制区域)
 * GLES纹理坐标: 也就是绘制部分(左上(0,0), 左下(0,1), 右上(1,0), 右下(1,1))
 */
public class LSImageVertex {
	/**
	 * 原始整个图像输出到整个屏幕
	 */
	public static float filterVertex_0[] = {
			// GLES世界坐标	// GLES纹理坐标
			1f, 1f, 		1f, 0f,
            -1f, 1f, 		0f, 0f,
            -1f, -1f, 		0f, 1f,
            1f, 1f, 		1f, 0f,		
            -1f, -1f, 		0f, 1f,
            1f, -1f, 		1f, 1f
            }; 
	
	/**
	 * 垂直翻转
	 */
	public static float filterVertex_180[] = {
			// GLES世界坐标, 	// GLES纹理坐标
			1f, 1f, 		1f, 1 - 0f,
            -1f, 1f, 		0f, 1 - 0f,
            -1f, -1f, 		0f, 1 - 1f,
            1f, 1f, 		1f, 1 - 0f,		
            -1f, -1f, 		0f, 1 - 1f,
            1f, -1f, 		1f, 1 - 1f
            };
}
