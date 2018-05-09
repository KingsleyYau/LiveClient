package net.qdating.view;

import android.app.Activity;
import android.content.Context;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Handler;
import net.qdating.utils.Log;

import net.qdating.LSConfig;
import net.qdating.LSConfig.VideoConfigType;
import net.qdating.LSPlayer;
import net.qdating.LSPublisher;
import net.qdating.R;
import net.qdating.LSConfig.FillMode;

public class TestActivity extends Activity {
	private String playH264File = "/sdcard/coollive/play0.h264" ;
	private String url = "rtmp://172.25.32.17:19351/live/max0";
	
	private LSPlayer player;
	private LSPublisher publisher;

	private GLSurfaceView surfaceView;
	private GLSurfaceView surfaceViewPublish;
	private Handler handler = new Handler();
	private Context context = this;
	private boolean test = false;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_test);
		
		Log.i(LSConfig.TAG, String.format("TestActivity::onCreate()"));

		surfaceView = (GLSurfaceView) this.findViewById(R.id.surfaceView);
		surfaceView.setKeepScreenOn(true);
		surfaceViewPublish = (GLSurfaceView) this.findViewById(R.id.surfaceViewPublish);
		surfaceViewPublish.setKeepScreenOn(true);
		
		// 播放相关
		player = new LSPlayer();
		player.init(surfaceView, FillMode.FillModeAspectRatioFill, null);
		player.playUrl(String.format("%s", url), "", playH264File, "");
		
		// 推送相关
		final int rotation = getWindowManager().getDefaultDisplay()
	             .getRotation();
		publisher = new LSPublisher();
		publisher.init(context, surfaceViewPublish, rotation, FillMode.FillModeAspectRatioFill, null, VideoConfigType.VideoConfigType240x240, 12, 12, 500 * 1000);
		publisher.publisherUrl(String.format("rtmp://172.25.32.17:19351/live/maxa"), "", "");

//		handler.postDelayed(new Runnable() {
//			@Override
//			public void run() {
//				// TODO Auto-generated method stub
//				Log.i(LSConfig.TAG, String.format("TestActivity::handler( time up )"));
//				test = true;
//				finish();
//			}
//		}, 10000);
	}
	
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		
		Log.i(LSConfig.TAG, String.format("TestActivity::onDestroy()"));

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

	@Override
	protected void onStart() {
		super.onStart();

//		surfaceViewPublish.onResume();
	}

	@Override
	protected void onStop() {
		super.onStop();

//		surfaceViewPublish.onPause();
	}

//	@Override
//    protected void onPause() {
//		super.onPause();
//
//
//    }
//
//    @Override
//    protected void onResume() {
//		super.onResume();
//		if( test ) {
////			finish();
//		}
//    }
}
