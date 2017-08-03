package net.qdating;

import java.io.File;

import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.view.SurfaceView;
import net.qdating.publisher.ILSPublisherCallback;
import net.qdating.publisher.ILSPublisherStatusCallback;
import net.qdating.publisher.ILSVideoCaptureCallback;
import net.qdating.publisher.LSPublisherJni;
import net.qdating.publisher.LSVideoCapture;
import net.qdating.publisher.LSVideoEncoder;
import net.qdating.utils.Log;

/**
 * RTMP流推流器
 * @author max
 * @version 1.0.0
 */
public class LSPublisher implements ILSPublisherCallback, ILSVideoCaptureCallback {
	/**
	 * RTMP模块
	 */
	private LSPublisherJni publisher = new LSPublisherJni();
	/**
	 * 视频采集
	 */
	private LSVideoCapture videoCapture = new LSVideoCapture();
	/**
	 * 视频解码器
	 */
	private LSVideoEncoder videoEncoder = new LSVideoEncoder();
	/**
	 * 状态回调接口
	 */
	private ILSPublisherStatusCallback statusCallback;
	/**
	 * 主线程消息处理
	 */
	private Handler handler = new Handler();
	/**
	 * 是否已经启动
	 */
	private boolean start = false;
	/**
	 * 流推送地址
	 */
	private String url;
	/**
	 * H264录制绝对路径
	 */
	private String recordH264FilePath;
	/**
	 * AAC录制绝对路径
	 */
	private String recordAACFilePath; 
	
	/***
	 * 初始化流推送器
	 * @param surfaceView	显示界面
	 * @param statusCallback 状态回调接口
	 * @return
	 */
	public boolean init(SurfaceView surfaceView, ILSPublisherStatusCallback statusCallback) {
		boolean bFlag = false;
		
		File path = Environment.getExternalStorageDirectory();
		String filePath = path.getAbsolutePath() + "/" + LSConfig.TAG + "/";
		Log.initFileLog(filePath);
		Log.setWriteFileLog(true);
		
		// 初始化状态回调
		this.statusCallback = statusCallback;
		// 初始化视频采集
		videoCapture.init(surfaceView.getHolder(), this);
		// 初始化播放器
		publisher.Create(this, videoEncoder);
		
		handler = new Handler() {
			@Override
			public void handleMessage(Message msg) {      
				Log.i(LSConfig.TAG, String.format("LSPublisher::handleMessage( "
						+ "[Connect], "
						+ "start : %s "
						+ ")", 
						start?"true":"false"
						)
						);
				synchronized (this) {
					if( start ) {
						// 非手动停止, 准备重连
						boolean bFlag = start();
						if( !bFlag ) {
							// 重连失败, 1秒后重连
							Log.i(LSConfig.TAG, String.format("LSPublisher::handleMessage( "
									+ "[Connect Fail, Reconnect After %d Seconds] ",
									LSConfig.RECONNECT_SECOND
									)
									);
							handler.sendEmptyMessageDelayed(0, LSConfig.RECONNECT_SECOND);
						}
					}
				}
			}
		};
		
		return bFlag;
	}
	
	public void uninit() {
		// 销毁推流器
		publisher.Destroy();
		// 销毁视频采集
		videoCapture.uninit();
	}
	
	/**
	 * 开始流推送
	 * @see	主线程调用
	 * @param url					流推送地址
	 * @param recordH264FilePath	H264录制绝对路径
	 * @param recordAACFilePath		AAC录制绝对路径
	 * @return
	 */
	public boolean publisherUrl(String url, String recordH264FilePath, String recordAACFilePath) {
		boolean bFlag = false;
		
		Log.i(LSConfig.TAG, String.format("LSPublisher::publisherUrl( "
				+ "url : %s "
				+ ")",
				url
				)
				);

	    synchronized (this) {
	    	if( !start ) {
	    		start = true;
	    		
	    	    this.url = url;
	    	    this.recordH264FilePath = recordH264FilePath;
	    	    this.recordAACFilePath = recordAACFilePath;
	    	    
	    		// 开始视频采集
	    		videoCapture.start();
	    		
	    	    // 开始消息队列
	    		handler.post(new Runnable() {
	    			@Override
	    			public void run() {
	    				// TODO Auto-generated method stub
	    				handler.sendEmptyMessage(0);
	    			}
	    		});
	    	}
	    }
	    
		Log.i(LSConfig.TAG, String.format("LSPublisher::publisherUrl( "
				+ "[Finish], "
				+ "url : %s, "
				+ "bFlag : %s "
				+ ")",
				url,
				bFlag?"true":"false"
				)
				);
		
		return bFlag;
	}
	
	/**
	 * 停止推送
	 * @see	主线程调用
	 */
	public void stop() {
		Log.i(LSConfig.TAG, String.format("LSPublisher::stop()"));
		
		synchronized(this) {
			start = false;
		}
		
		// 取消事件
		handler.removeMessages(0);
    	// 停止流推送器
    	publisher.Stop();
		// 停止视频采集
    	videoCapture.stop();
    	
		Log.i(LSConfig.TAG, String.format("LSPublisher::stop( [Finish] )"));
	}

	/**
	 * 开始推送
	 * @see	主线程调用
	 * @return 成功失败
	 */
	private boolean start() {
		boolean bFlag = true;
		
		Log.i(LSConfig.TAG, String.format("LSPublisher::start( "
				+ "url : %s "
				+ ")",
				url
				)
				);
		
    	bFlag = publisher.PublishUrl(url, recordH264FilePath, recordAACFilePath);
		if( !bFlag ) {
			publisher.Stop();
		}
		
		Log.i(LSConfig.TAG, String.format("LSPublisher::start( "
				+ "[Finish], "
				+ "url : %s, "
				+ "bFlag : %s "
				+ ")",
				url,
				bFlag?"true":"false"
				)
				);
		
		return bFlag;
	}
	
	@Override
	public void onDisconnect(LSPublisherJni publisher) {
		// TODO Auto-generated method stub
		Log.i(LSConfig.TAG, String.format("LSPublisher::onDisconnect()"));
		
		// 通知外部监听
		if( statusCallback != null ) {
			statusCallback.onDisconnect(this);
		}

		synchronized (this) {
			if( start ) {
				// 非手动断开, 发送重连消息
				handler.sendEmptyMessageDelayed(0, LSConfig.RECONNECT_SECOND);
			}
		}
		
		Log.i(LSConfig.TAG, String.format("LSPublisher::onDisconnect( [Finish] )"));
	}

	@Override
	public void onVideoCapture(byte[] data, int width, int height) {
		// TODO Auto-generated method stub
		publisher.PushVideoFrame(data);
	}
	
}
