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
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Rect;
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
    
    private Matrix matrix = new Matrix();
    
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
	public void init(SurfaceHolder holder, int viewWidth, int viewHeight) {
		this.surfaceHolder = holder;
        this.viewWidth = viewWidth;
        this.viewHeight = viewHeight;
        if( surfaceHolder != null ) {
            surfaceHolder.addCallback(this);
        }
        changeVideoFrameSize(640, 480);
	}
	
	/**
	 * 解除界面绑定，停止渲染
	 */
	public void uninit() {
		viewWidth = 0;
		viewHeight = 0;
		
		if( surfaceHolder != null ) {
			surfaceHolder.removeCallback(this);
			surfaceHolder = null;
		}
		
		if( byteBuffer != null ) {
			byteBuffer.clear();
			byteBuffer = null;
		}
		if( bitmap != null ) {
			bitmap.recycle();
			bitmap = null;
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
	public void clean() {
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
        Log.d(LSConfig.TAG, String.format("LSVideoPlayer::surfaceChanged( width : %d, height : %d )", width, height));
        changeDestRect(width, height);
    }

    public void surfaceCreated(SurfaceHolder holder) {
    	Log.d(LSConfig.TAG, String.format("LSVideoPlayer::surfaceCreated()"));
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
    }
    
    private ByteBuffer createOrResetBuffer(int width, int height) {
    	int newByteBufferSize = width * height * 4;
    	
    	Log.d(LSConfig.TAG, String.format("LSVideoPlayer::createOrResetBuffer( width : %d, height : %d, newByteBufferSize : %d )", width, height, newByteBufferSize));
		
    	if( byteBufferSize < newByteBufferSize ) {
    		byteBufferSize = newByteBufferSize;
        	if(byteBuffer != null) {
        		byteBuffer.clear();
        	}
        	byteBuffer = ByteBuffer.allocateDirect(byteBufferSize);
    	}
    	
    	bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.RGB_565);
    	
    	Log.d(LSConfig.TAG, String.format("LSVideoPlayer::createOrResetBuffer( width : %d, height : %d, byteBufferSize : %d )", width, height, byteBufferSize));
    	
    	return byteBuffer;
    	
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

    public void DrawBitmap(ByteBuffer buffer) {
        if( bitmap == null )
            return;

        bitmap.copyPixelsFromBuffer(buffer);
        
        if( debug ) {
        	// The follow line is for debug only
        	saveBitmapToJPEG(videoStreamWidth, videoStreamHeight);
        }
        
        Canvas canvas = surfaceHolder.lockCanvas();
        if(canvas != null) {
        	if( viewHeight > 0 && viewWidth > 0 && 
        			videoStreamHeight > 0 && videoStreamWidth > 0 ) {
//            	Matrix matrix = new Matrix();
            	float scale = 0.0f;
            	float widthScale = ((float)viewWidth) / videoStreamWidth;
            	float heightScale = ((float)viewHeight) / videoStreamHeight;
            	scale = widthScale > heightScale?widthScale:heightScale;
            	float dx = -(float)(videoStreamWidth * scale - viewWidth) / 2;
            	float dy = -(float)(videoStreamHeight * scale - viewHeight) / 2;
        		
            	matrix.reset();
            	matrix.postScale(scale, scale);
            	matrix.postTranslate(dx, dy);
            	
            	canvas.drawColor(Color.BLACK);
                canvas.drawBitmap(bitmap, matrix, null);
        	}
        	surfaceHolder.unlockCanvasAndPost(canvas);
        }
    }

	public void changeVideoFrameSize(int width, int height) {
		// TODO Auto-generated method stub
		if(videoStreamWidth != width
				|| videoStreamHeight != height) {
			Log.d(LSConfig.TAG, String.format("LSVideoPlayer::changeVideoFrameSize( "
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
//		Log.d(LSConfig.TAG, String.format("LSVideoPlayer::playVideoFrame( size : %d, byteBufferSize : %d )", data.length, byteBufferSize));
		if ( byteBuffer != null && data.length <= byteBufferSize ) {
			byteBuffer.put(data, 0, data.length);
	        byteBuffer.rewind();
	        DrawBitmap(byteBuffer);
	        byteBuffer.clear();
	        
		} else {
			Log.d(LSConfig.TAG, String.format("LSVideoPlayer::playVideoFrame( [DrawFrame Error], size : %d, byteBufferSize : %d ", data.length, byteBufferSize));
		}
	}

	@Override
	public void renderVideoFrame(byte[] data, int width, int height) {
		// TODO Auto-generated method stub
		changeVideoFrameSize(width, height);
		playVideoFrame(data);
	}
}
