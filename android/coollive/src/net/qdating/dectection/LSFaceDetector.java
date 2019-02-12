package net.qdating.dectection;

import android.os.Handler;
import android.os.Looper;
import android.os.Message;

import net.qdating.LSConfig;
import net.qdating.utils.Log;

public class LSFaceDetector {
    private class DetectorThread extends Thread {
        public volatile Handler handler;
        public void run() {
            Looper.prepare();
            handler = new Handler() {
                public void handleMessage(Message msg) {
                }
            };
            Looper.loop();
        }
    }

    private DetectorThread detectorThreads[] = new DetectorThread[3];
    private int detectorThreadIndex;
    private LSFaceDetectorJni detectors[] = new LSFaceDetectorJni[3];

    private ILSFaceDetectorStatusCallback callback = null;

    public LSFaceDetector() {

    }

    public void setCallback(ILSFaceDetectorStatusCallback callback) {
        this.callback = callback;
    }

    public boolean start() {
        Log.i(LSConfig.TAG, String.format("LSFaceDetector::start( this : 0x%x )", hashCode()));

        boolean bFlag = true;

        for(int i = 0; i < detectorThreads.length; i++) {
            detectorThreads[i] = new DetectorThread();
            detectorThreads[i].start();

            detectors[i] = new LSFaceDetectorJni();
            detectors[i].Create(new ILSFaceDetectorCallback() {
                @Override
                public void onDetectedFace(LSFaceDetectorJni detector, int x, int y, int width, int height) {
                    Log.i(LSConfig.TAG, String.format("LSFaceDetector::onDetectedFace( x : %d, y : %d, width : %d, height : %d )", x, y, width, height));
                    if( callback != null ) {
                        callback.onDetectedFace(x, y, width, height);
                    }
                }
            });
        }
        detectorThreadIndex = 0;

        if( !bFlag ) {
            Log.e(LSConfig.TAG, String.format("LSFaceDetector::start( this : 0x%x, [Fail] )", hashCode()));
        }

        return bFlag;
    }

    public void stop() {
        Log.i(LSConfig.TAG, String.format("LSFaceDetector::stop( this : 0x%x )", hashCode()));

        for(int i = 0; i < detectorThreads.length; i++) {
            detectorThreads[i].interrupt();
        }
    }

    public void detectPicture(final byte[] data, final int width, final int height) {
        final int index = detectorThreadIndex++ % detectorThreads.length;
        detectorThreads[index].handler.post(new Runnable() {
            @Override
            public void run() {
                detectors[index].DetectPicture(width, height, data);
            }
        });
    }
}
