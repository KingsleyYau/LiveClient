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
            FileOutputStream output = new FileOutputStream(String.format("/sdcard/coollive/render_%d.jpg", System.currentTimeMillis()));
            output.write(byteOutStream.toByteArray());
            output.flush();
            output.close();
        } catch (FileNotFoundException e) {
        	Log.d(LSConfig.TAG, String.format("LSImageUtil::saveBitmapToJPEG( e : %s )", e.toString()));
        } catch (IOException e) {
        	Log.d(LSConfig.TAG, String.format("LSImageUtil::saveBitmapToJPEG( e : %s )", e.toString()));
        }
    }
}
