package net.qdating.utils;

public class LSUtilTesterJni {
    static {
        try {
            System.loadLibrary("lsutiltester");
        } catch(Exception e) {
            e.printStackTrace();
        }
    }

    public native void Test();
}
