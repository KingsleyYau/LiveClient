package net.qdating.view;

import android.app.Activity;
import android.content.Context;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import net.qdating.filter.LSImageFilter;
import net.qdating.filter.LSImageVibrateFilter;
import net.qdating.player.ILSPlayerStatusCallback;
import net.qdating.player.LSPlayerRendererBinder;
import net.qdating.utils.Log;

import net.qdating.LSConfig;
import net.qdating.LSConfig.VideoConfigType;
import net.qdating.LSPlayer;
import net.qdating.LSPublisher;
import net.qdating.R;
import net.qdating.LSConfig.FillMode;

import java.util.Random;

public class TestActivity extends Activity implements ILSPlayerStatusCallback {
	private String playH264File = "" ;

	private LSPlayer player;
	private LSPlayerRendererBinder playerRenderderBinder;
	private LSImageFilter playerImageFilter;
	private LSPublisher publisher;

	private GLSurfaceView surfaceView;
	private GLSurfaceView surfaceViewPublish;
	private Handler handler = new Handler();
	private Context context = this;

	private WebView webView;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_test);
		
		Log.i(LSConfig.TAG, String.format("TestActivity::onCreate()"));

		surfaceView = (GLSurfaceView) this.findViewById(R.id.surfaceView1);
		surfaceView.setKeepScreenOn(true);
		surfaceViewPublish = (GLSurfaceView) this.findViewById(R.id.surfaceView0);
		surfaceViewPublish.setKeepScreenOn(true);

		// 播放相关
		player = new LSPlayer();
		player.init(this);
		playerImageFilter = new LSImageVibrateFilter();
		playerRenderderBinder = new LSPlayerRendererBinder(surfaceView, FillMode.FillModeAspectRatioFit);
		playerRenderderBinder.setCustomFilter(playerImageFilter);
		player.setRendererBinder(playerRenderderBinder);

		String playerUrl = "rtmp://172.25.32.133:4000/cdn_standard/tester0";
		player.playUrl(playerUrl, "", "", "");

		// 推送相关
		final int rotation = getWindowManager().getDefaultDisplay()
	             .getRotation();
		publisher = new LSPublisher();
		publisher.init(context, surfaceViewPublish, rotation, FillMode.FillModeAspectRatioFit, null, VideoConfigType.VideoConfigType480x640, 12, 12, 500 * 1000);
		final String publishUrl = "rtmp://172.25.32.133:4000/cdn_standard/max0";
//		publisher.publisherUrl(publishUrl, "", "");

		final Random rand = new Random();

		handler = new Handler() {
			@Override
			public void handleMessage(Message msg) {
				switch (msg.what) {
					case 0:{
						if( publisher != null ) {
							publisher.publisherUrl(publishUrl, "", "");
						}
						int millisecond = rand.nextInt(5000);
						handler.postDelayed(new Runnable() {
							@Override
							public void run() {
								// TODO Auto-generated method stub
								Message msg = Message.obtain();
								msg.what = 1;
								handler.sendMessage(msg);
							}
						}, millisecond);
					}break;
					case 1:{
						if( publisher != null ) {
							publisher.stop();
						}
						handler.postDelayed(new Runnable() {
							@Override
							public void run() {
								// TODO Auto-generated method stub
								Message msg = Message.obtain();
								msg.what = 0;
								handler.sendMessage(msg);
							}
						}, 1000);
					}break;
					default:
						break;
				}
			}
		};

		handler.post(new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				Message msg = Message.obtain();
				msg.what = 0;
				handler.sendMessage(msg);
			}
		});

		handler.postDelayed(new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				Log.i(LSConfig.TAG, String.format("TestActivity::handler( Time up )"));
				finish();
			}
		}, 30000);
	}
	
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		
		Log.i(LSConfig.TAG, String.format("TestActivity::onDestroy()"));
		handler.removeMessages(0);
		handler.removeMessages(1);
		new Thread(new Runnable() {
			@Override
			public void run() {
				if( player != null ) {
					player.stop();
					player.uninit();
					player = null;
				}

				if( publisher != null ) {
					publisher.stop();
					publisher.uninit();
					publisher = null;
				}
			}
		}).start();
//		if( player != null ) {
//			player.stop();
//			player.uninit();
//			player = null;
//		}
//
//		if( publisher != null ) {
//			publisher.stop();
//			publisher.uninit();
//			publisher = null;
//		}
	}

	@Override
	protected void onStart() {
		super.onStart();
	}

	@Override
	protected void onStop() {
		super.onStop();
	}

	@Override
    protected void onPause() {
		super.onPause();
//		surfaceView.onPause();
//		surfaceViewPublish.onPause();
//
//		surfaceView.setVisibility(View.INVISIBLE);
//		surfaceViewPublish.setVisibility(View.INVISIBLE);
    }

    @Override
    protected void onResume() {
		super.onResume();
//		surfaceView.onResume();
//		surfaceViewPublish.onResume();
    }

	@Override
	public void onConnect(LSPlayer player) {

	}

	@Override
	public void onDisconnect(LSPlayer player) {

	}
}
