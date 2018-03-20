package net.qdating.filter;

import android.util.Log;
import net.qdating.LSConfig;

public class LSImageUtilJni {
	static {
		System.loadLibrary("lsimageutil");
		Log.i(LSConfig.TAG, "LSImageUtilJni::static( Load Library )");
	}
	
	static public native void GLReadPixels(int x, int y, int width, int height, int format, int type);
}
