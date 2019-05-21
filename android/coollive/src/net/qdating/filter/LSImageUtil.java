package net.qdating.filter;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;

import android.content.Context;
import android.graphics.Bitmap;
import net.qdating.LSConfig;
import net.qdating.utils.Log;

/**
 * 工具类
 * @author max
 *
 */
public class LSImageUtil {
	/**
	 * 目标格式
	 */
	public enum ColorFormat {
		ColorFormat_ARGB8888,
		ColorFormat_YUV420P,
		ColorFormat_YUV420SP
	}

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
    static public void saveBitmapToJPEG(String name, Bitmap bitmap) {
        ByteArrayOutputStream byteOutStream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, byteOutStream);

        try {
            FileOutputStream output = new FileOutputStream(String.format("/sdcard/coollive/%s_%d.jpg", name, System.currentTimeMillis()));
            output.write(byteOutStream.toByteArray());
            output.flush();
            output.close();
        } catch (FileNotFoundException e) {
        	Log.d(LSConfig.TAG, String.format("LSImageUtil::saveBitmapToJPEG( e : %s )", e.toString()));
        } catch (IOException e) {
        	Log.d(LSConfig.TAG, String.format("LSImageUtil::saveBitmapToJPEG( e : %s )", e.toString()));
        }
    }

	static public void saveRgbToFile(String name, ByteBuffer byteBuffer, int width, int height, Bitmap.Config config) {
		byteBuffer.position(0);
		Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
		bitmap.copyPixelsFromBuffer(byteBuffer);
		saveBitmapToJPEG(name, bitmap);
		byteBuffer.position(0);
	}

	static public void saveYuvToFile(String name, byte[] data, int size) {
	    FileOutputStream outStream;
        try {
			outStream = new FileOutputStream(String.format("/sdcard/coollive/%s_%d.yuv", name, System.currentTimeMillis()));
			outStream.write(data, 0, size);
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
