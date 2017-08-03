/**
 * Copyright (c) 2016 The Camshare project authors. All Rights Reserved.
 */
package net.qdating.player;

// The following four imports are needed saveBitmapToJPEG which
// is for debug only
import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.ImageFormat;
import android.graphics.Matrix;
import android.graphics.Rect;
import android.graphics.YuvImage;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import net.qdating.LSConfig;

public class LSVideoPlayer implements Callback, ILSVideoRendererJni {
    // the bitmap used for drawing.
    private Bitmap bitmap = null;
    private ByteBuffer byteBuffer = null;
    private SurfaceHolder surfaceHolder;
    public boolean debug = false;
    
    private int viewWidth = 0;
    private int viewHeight = 0;
    private int videoStreamWidth = 0;
    private int videoStreamHeight = 0;
    private int byteBufferSize = 0;
    
    private boolean isStartRender = false;
    
	/**
	 * 日志路径
	 */
	private String logFilePath = "";
	
	public LSVideoPlayer(){
		
	}
	
	/**
	 * 绑定界面元素
	 * @param view
	 * @param viewWidth
	 * @param viewHeight
	 */
	public void init(SurfaceHolder holder, int viewWidth, int viewHeight){
		surfaceHolder = holder;
        this.viewWidth = viewWidth;
        this.viewHeight = viewHeight;
        if(surfaceHolder == null)
            return;
        surfaceHolder.addCallback(this);
        isStartRender = true;
        
//        surfaceHolder.setFormat(PixelFormat.TRANSLUCENT);
	}
	
	/**
	 * 解除界面绑定，停止渲染
	 */
	public void uninit() {
		this.viewWidth = 0;
		this.viewHeight = 0;
		isStartRender = false;
		if(surfaceHolder != null) {
			surfaceHolder.removeCallback(this);
		}
	}
	
	/**
	 * 设置是否Debug模式
	 * @param debug
	 */
	public void setDebug(boolean debug){
		this.debug = debug;
	}
	
	/**
	 * 清除缓存
	 */
	public void clean(){
		videoStreamWidth = 0;
		videoStreamHeight = 0;
		byteBuffer = null;
		bitmap = null;
	}

	/**
	 * 设置日志路径
	 * @param logFilePath	日志路径
	 */
	public void setLogDirPath(String logFilePath) {
		this.logFilePath = logFilePath;
	}
	
    // surfaceChanged and surfaceCreated share this function
    private void changeDestRect(int dstWidth, int dstHeight) {
    	viewWidth = dstWidth;
    	viewHeight = dstHeight;
    }

    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
        Log.i(LSConfig.TAG, String.format("LSVideoPlayer::surfaceChanged( width : %d, height : %d )", width, height));
        changeDestRect(width, height);
    }

    public void surfaceCreated(SurfaceHolder holder) {
    	Log.i(LSConfig.TAG, String.format("LSVideoPlayer::surfaceCreated()"));
    	isStartRender = true;
        Canvas canvas = surfaceHolder.lockCanvas();
        if(canvas != null) {
            Rect dst = surfaceHolder.getSurfaceFrame();
            if(dst != null) {
                changeDestRect(dst.right - dst.left, dst.bottom - dst.top);
            }
            surfaceHolder.unlockCanvasAndPost(canvas);
        }
    }

    public void surfaceDestroyed(SurfaceHolder holder) {
    	isStartRender = false;
    }
    
    private ByteBuffer createOrResetBuffer(int width, int height) {
    	Log.i(LSConfig.TAG, String.format("LSVideoPlayer::createOrResetBuffer( width : %d, height : %d )", width, height));
    	if(byteBuffer != null) {
    		byteBuffer.clear();
    	}
    	byteBufferSize = width * height * 4;
    	byteBuffer = ByteBuffer.allocateDirect(byteBufferSize);
    	bitmap = createBitmap(width, height);
    	
    	Log.i(LSConfig.TAG, String.format("LSVideoPlayer::createOrResetBuffer( width : %d, height : %d, byteBufferSize : %d )", width, height, byteBufferSize));
    	
    	return byteBuffer;
    	
    }
    
    private Bitmap createBitmap(int width, int height) {
        Log.i(LSConfig.TAG, String.format("LSVideoPlayer::createBitmap( width : %d, height : %d )", width, height));
        if (bitmap == null) {
            try {
                android.os.Process.setThreadPriority(
                    android.os.Process.THREAD_PRIORITY_DISPLAY);
            }
            catch (Exception e) {
            }
        }
        bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.RGB_565);
//        bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        return bitmap;
    }

    // It saves bitmap data to a JPEG picture, this function is for debug only.
    private void saveBitmapToJPEG(int width, int height) {
        ByteArrayOutputStream byteOutStream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, byteOutStream);

        try{
            FileOutputStream output = new FileOutputStream(String.format(
                "%s/render_%d.jpg", logFilePath, System.currentTimeMillis()));
            output.write(byteOutStream.toByteArray());
            output.flush();
            output.close();
        }
        catch (FileNotFoundException e) {
        }
        catch (IOException e) {
        }
    }

    public void DrawBitmap() {
        if(bitmap == null)
            return;

        if( debug ) {
        	// The follow line is for debug only
        	saveBitmapToJPEG(videoStreamWidth, videoStreamHeight);
        }
        
        Canvas canvas = surfaceHolder.lockCanvas();
        if(canvas != null) {
        	if( viewHeight > 0 && viewWidth > 0 && 
        			videoStreamHeight > 0 && videoStreamWidth > 0 ) {
            	Matrix matrix = new Matrix();
            	float scale = 0.0f;
            	float widthScale = ((float)viewWidth)/videoStreamWidth;
            	float heightScale = ((float)viewHeight)/videoStreamHeight;
            	scale = widthScale > heightScale?widthScale:heightScale;
            	float dx = -(videoStreamWidth*scale - viewWidth)/2;
            	float dy = -(videoStreamHeight*scale - viewHeight)/2;
            	matrix.postScale(scale, scale);
            	matrix.postTranslate(dx, dy);
                canvas.drawBitmap(bitmap, matrix, null);
        	}
        	surfaceHolder.unlockCanvasAndPost(canvas);
        }
    }

	public void changeVideoFrameSize(int width, int height) {
		// TODO Auto-generated method stub
		if(videoStreamWidth != width
				|| videoStreamHeight != height) {
			Log.i(LSConfig.TAG, String.format("LSVideoPlayer::changeVideoFrameSize( "
					+ "width : %d, "
					+ "height : %d, "
					+ "videoStreamWidth : %d, "
					+ "videoStreamHeight : %d "
					+ ")", 
					width, 
					height, 
					videoStreamWidth,
					videoStreamHeight
					)
					);
			
			videoStreamWidth = width;
			videoStreamHeight = height;
			createOrResetBuffer(width, height);
		}
	}
	
	public void playVideoFrame(byte[] data) {
		// TODO Auto-generated method stub
//		Log.i(LSConfig.TAG, String.format("LSVideoPlayer::playVideoFrame( size : %d, byteBufferSize : %d )", data.length, byteBufferSize));
		if(isStartRender) {
			if(byteBuffer != null &&
					data.length <= byteBufferSize){
				byteBuffer.put(data, 0, data.length);
				
		        if(byteBuffer == null)
		            return;
		        byteBuffer.rewind();
		        bitmap.copyPixelsFromBuffer(byteBuffer);
		        DrawBitmap();
		        byteBuffer.clear();
		        
			} else {
				Log.i(LSConfig.TAG, String.format("LSVideoPlayer::playVideoFrame( [DrawFrame Error], size : %d, byteBufferSize : %d ", data.length, byteBufferSize));
			}
			
//			bitmap = BitmapFactory.decodeByteArray(data, 0, data.length);
//			DrawBitmap();
			
//			Log.i(LSConfig.TAG, String.format("LSVideoPlayer::playVideoFrame( bitmap.getConfig() : %s ", bitmap.getConfig().toString()));
		}
	}

	@Override
	public void renderVideoFrame(byte[] data, int width, int height) {
		// TODO Auto-generated method stub
		changeVideoFrameSize(width, height);
//		byte[] rgbData = chageYUV2RGB(data, width, height);
		playVideoFrame(data);
	}

	byte[] chageYUV2RGB(byte[] data, int width, int height) {
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		YuvImage yuvImage = new YuvImage(data, ImageFormat.NV21, width, height, null);
		yuvImage.compressToJpeg(new Rect(0, 0, width, height), 50, out);
		byte[] imageBytes = out.toByteArray();
		return imageBytes;
	}
}
