package net.qdating.view;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.SurfaceView;
import net.qdating.LSConfig;
import net.qdating.LSPlayer;
import net.qdating.R;

public class TestActivity extends Activity {
	private String url = "rtmp://172.25.32.17/live/max";
	
	String filePath = "/sdcard";
	
	private LSPlayer player = new LSPlayer();
	private Handler handler = new Handler();
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_test);
		
		Log.i(LSConfig.TAG, String.format("TestActivity::onCreate()"));
		
		SurfaceView surfaceView = (SurfaceView) this.findViewById(R.id.surfaceView);
		player.init(surfaceView, null);
		player.playUrl(url, "", "", "");
		
		handler.postDelayed(new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				Log.i(LSConfig.TAG, String.format("TestActivity::onCreate( finish() )"));
				finish();
			}
		}, 5000);
	}
	
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		
		Log.i(LSConfig.TAG, String.format("TestActivity::onDestroy()"));
		
		player.stop();
		player.uninit();
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
