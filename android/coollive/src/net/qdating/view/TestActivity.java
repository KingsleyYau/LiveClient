package net.qdating.view;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.SurfaceView;
import net.qdating.LSConfig;
import net.qdating.LSPlayer;
import net.qdating.LSPublisher;
import net.qdating.R;

public class TestActivity extends Activity {
	private String url = "rtmp://172.25.32.17/live/max";
	
	String filePath = "/sdcard";
	
	private LSPlayer player = new LSPlayer();
	private LSPublisher publisher = new LSPublisher();
	private Handler handler = new Handler();
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_test);
		
		Log.i(LSConfig.TAG, String.format("TestActivity::onCreate()"));
		
		SurfaceView surfaceView = (SurfaceView) this.findViewById(R.id.surfaceView);
		surfaceView.setKeepScreenOn(true);
		SurfaceView surfaceViewPublish = (SurfaceView) this.findViewById(R.id.surfaceViewPublish);
		surfaceViewPublish.setKeepScreenOn(true);
		
		// 播放相关
		player.init(surfaceView, null);
		player.playUrl(String.format("%s_i", url), "", "", "");
		
		// 推送相关
		int rotation = getWindowManager().getDefaultDisplay()
	             .getRotation();
		publisher.init(surfaceViewPublish, rotation, null);
		publisher.publisherUrl(String.format("%s_a2", url), "", "");
		
		handler.postDelayed(new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				finish();
			}
		}, 10000);
	}
	
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		
		Log.i(LSConfig.TAG, String.format("TestActivity::onDestroy()"));
		
		player.stop();
		player.uninit();
		
		publisher.stop();
		publisher.uninit();
	}
	
    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }
}
