package net.qdating.filter;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import android.content.Context;
import android.graphics.Bitmap;
import net.qdating.LSConfig;
import net.qdating.utils.Log;

public class LSImageUtil {
	static public String ledChar = ""
			+ "// 构造LED数字 \n"
			+ "precision mediump float;\n"
			+ "void ledChar(int n, float xa, float xb, float ya, float yb, vec2 vTC) { \n"
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
    		+ "int num = n; \n"
    		+ "// 设定调试区显示范围\n"
    		+ "if(x >= x1 && x <= x2 && y >= y1 && y <= y2) { \n"
    		+ "// 设置调试区背景色为半透明的蓝色 \n"
    		+ "gl_FragColor = vec4(0, 0, 1.0, 0.3); \n"
    		+ "	// 分别绘制出 LED 形式的数字 1~0 \n"
    		+ "	if("
    		+ " (num==1 && (x > x2-dx)) || "
    		+ "	(num==2 && ((y < y1+dy) || (x > x2-dx && y < oy) || (y > oy-dy/2.0 && y < oy+dy/2.0) || (x < x1+dx && y > oy) || (y > y2-dy))) || "
    		+ "	(num==3 && ((y < y1+dy) || (y > oy-dy/2.0 && y < oy+dy/2.0) ||  (y > y2-dy) || (x > x2-dx))) || "
    		+ "	(num==4 && ((x < x1+dx && y < oy) || (y > oy-dy/2.0 && y < oy+dy/2.0) || (x > x2-dx))) || "
    		+ "	(num==5 && ((y < y1+dy) || (x < x1+dx && y < oy-dy/2.0) || (y > oy-dy/2.0 && y < oy+dy/2.0) || (x > x2-dx && y > oy) || (y > y2-dy))) || "
    		+ "	(num==6 && ((y < y1+dy) || (x < x1+dx) || (y > oy-dy/2.0 && y < oy+dy/2.0) || (x > x2-dx && y > oy) || (y > y2-dy))) || "
    		+ "	(num==7 && ((y < y1+dy) || (x > x2-dx))) || "
    		+ "	(num==8 && ((y < y1+dy) || (x < x1+dx) || (y > oy-dy/2.0 && y < oy+dy/2.0) || (x>x2-dx) || (y > y2-dy))) || "
    		+ "	(num==9 && ((y < y1+dy) || (x < x1+dx && y < oy) || (y > oy-dy/2.0 && y < oy+dy/2.0) || (x > x2-dx) || (y > y2-dy))) || "
    		+ "	(num==0 && ((y < y1+dy) || (x < x1+dx) || (x > x2-dx) || (y > y2-dy)))"
    		+ " )\n"
    		+ "		{\n"
    		+ "			// 设置数字颜色为红色 \n"
    		+ "			gl_FragColor = vec4(1, 0, 0, 1); \n"
    		+ "		}\n"
			+ "	} \n"
			+ "} \n";
	
	/**
	 * 从资源加载着色器代码
	 * @param context
	 * @param rawId
	 * @return
	 */
	static public String loadShaderString(Context context, int rawId) {
		InputStream is = context.getResources().openRawResource(rawId);
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		byte[] buf = new byte[1024];
		int len;
		
		boolean bFlag = true;
		try {
			while( (len = is.read(buf)) != -1 ){
				baos.write(buf, 0, len);
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			bFlag = false;
		}
		
		String result = null;
		if( bFlag ) {
			result = baos.toString();
		}
		
		return result;
	}
	
	/**
	 * 保存Bitmap到jpg文件
	 * @param bitmap
	 */
    static public void saveBitmapToJPEG(Bitmap bitmap) {
        ByteArrayOutputStream byteOutStream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, byteOutStream);

        try {
            FileOutputStream output = new FileOutputStream(String.format("/sdcard/coollive/test_%d.jpg", System.currentTimeMillis()));
            output.write(byteOutStream.toByteArray());
            output.flush();
            output.close();
        } catch (FileNotFoundException e) {
        	Log.d(LSConfig.TAG, String.format("LSImageUtil::saveBitmapToJPEG( e : %s )", e.toString()));
        } catch (IOException e) {
        	Log.d(LSConfig.TAG, String.format("LSImageUtil::saveBitmapToJPEG( e : %s )", e.toString()));
        }
    }
    
	static public void saveYuvToFile(String name, byte[] data) {
	    FileOutputStream outStream;
        try {
			outStream = new FileOutputStream(String.format("/sdcard/coollive/%s_%d.yuv", name, System.currentTimeMillis()));
			outStream.write(data);
			outStream.close();
	        
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			Log.d(LSConfig.TAG, String.format("LSImageUtil::saveYuvToFile( e : %s )", e.toString()));
		} catch (IOException e) {
			// TODO Auto-generated catch block
			Log.d(LSConfig.TAG, String.format("LSImageUtil::saveYuvToFile( e : %s )", e.toString()));
		}
	}
	
	static public void dumpYuvToFile(byte[] dataY, byte[] dataU, byte[] dataV) {
        try {
        	long time = System.currentTimeMillis();
        	FileOutputStream outStreamY = new FileOutputStream(String.format("/sdcard/coollive/%d_Y.dump", time));
			outStreamY.write(dataY);
			outStreamY.close();
			
        	FileOutputStream outStreamU = new FileOutputStream(String.format("/sdcard/coollive/%d_U.dump", time));
        	outStreamU.write(dataU);
        	outStreamU.close();
			
        	FileOutputStream outStreamV = new FileOutputStream(String.format("/sdcard/coollive/%d_V.dump", time));
        	outStreamV.write(dataV);
        	outStreamV.close();
	        
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			Log.d(LSConfig.TAG, String.format("LSImageUtil::saveYuvToFile( e : %s )", e.toString()));
		} catch (IOException e) {
			// TODO Auto-generated catch block
			Log.d(LSConfig.TAG, String.format("LSImageUtil::saveYuvToFile( e : %s )", e.toString()));
		}
	}
}
