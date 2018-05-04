package net.qdating.filter;

import net.qdating.utils.Log;
import net.qdating.LSConfig;

public class LSImageUtilJni {
	static {
		System.loadLibrary("lsimageutil");
		Log.i(LSConfig.TAG, String.format("LSImageUtilJni::static( Load Library, version : %s )", LSConfig.VERSION));
	}
	
	static public native void GLReadPixels(int x, int y, int width, int height, int format, int type);
}
