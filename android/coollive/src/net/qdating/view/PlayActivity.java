package net.qdating.view;

import java.io.File;

import com.qpidnetwork.tool.CrashHandlerJni;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.util.Log;
import android.view.SurfaceView;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import net.qdating.LSConfig;
import net.qdating.LSPlayer;
import net.qdating.LSPublisher;
import net.qdating.R;
import net.qdating.utils.CrashHandler;

public class PlayActivity extends Activity {
	private String url = "rtmp://172.25.32.17/live/max";
//	private String url = "rtmp://172.25.32.17:1936/aac/max";
	
	String filePath = "/sdcard";
	private String playH264File = "";//"/sdcard/coollive/play.h264";
	private String playAACFile = "";//"/sdcard/coollive/play.aac";
	
	private String publishH264File = "";//"/sdcard/coollive/publish.h264";
	private String publishAACFile = "";//"/sdcard/coollive/publish.aac";
	
	// 播放相关
	private LSPlayer player = new LSPlayer();
	private SurfaceView surfaceView = null;
	private EditText editText = null;
	private EditText editTextPublish = null;
	
	// 推送相关
	private LSPublisher publisher = new LSPublisher();
	private SurfaceView surfaceViewPublish = null;
	
	private Handler handler = new Handler();
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_play);

		File path = Environment.getExternalStorageDirectory();
		filePath = path.getAbsolutePath() + "/" + LSConfig.TAG;
		File logDir = new File(filePath);
		deleteAllFiles(logDir);

		CrashHandler.newInstance(PlayActivity.this);
		CrashHandlerJni.SetCrashLogDirectory(filePath);
		
		editText = (EditText) this.findViewById(R.id.editText);
		editText.setText(String.format("%s_mv", url));
		
		editTextPublish = (EditText) this.findViewById(R.id.editTextPublish);
		editTextPublish.setText(String.format("%s_a", url));
		
		surfaceView = (SurfaceView) this.findViewById(R.id.surfaceView);
		surfaceView.setKeepScreenOn(true);
		surfaceViewPublish = (SurfaceView) this.findViewById(R.id.surfaceViewPublish);
		surfaceViewPublish.setKeepScreenOn(true);
		
		// 播放相关
		player.init(surfaceView, null);
		// 推送相关
		int rotation = getWindowManager().getDefaultDisplay()
	             .getRotation();
		publisher.init(surfaceViewPublish, rotation, null);
		
		Button playButton = (Button) this.findViewById(R.id.button1);
		playButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				String playUrl = editText.getText().toString();
				player.playUrl(playUrl, "", playH264File, playAACFile);
			}
		});

		Button pubilsherButton = (Button) this.findViewById(R.id.button2);
		pubilsherButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				String publishUrl = editTextPublish.getText().toString();
				publisher.publisherUrl(publishUrl, publishH264File, publishAACFile);
			}
		});

		Button muteButton = (Button) this.findViewById(R.id.button3);
		muteButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				publisher.setMute(!publisher.getMute());
			}
		});

		Button stopButton = (Button) this.findViewById(R.id.button4);
		stopButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				player.stop();
				publisher.stop();
			}
		});
	}

	private void deleteAllFiles(File root) {  
        File files[] = root.listFiles();  
        if (files != null)  
            for (File f : files) {  
                if (f.isDirectory()) { // 判断是否为文件夹  
                    deleteAllFiles(f);  
                    try {  
                        f.delete();  
                    } catch (Exception e) {  
                    }  
                } else {  
                    if (f.exists()) { // 判断是否存在  
                        deleteAllFiles(f);  
                        try {  
                            f.delete();  
                        } catch (Exception e) {  
                        }  
                    }  
                }  
            }  
    } 
	
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		
		if( player != null ) {
			player.stop();
			player.uninit();
		}

		if( publisher != null ) {
			publisher.stop();
			publisher.uninit();
		}
	}
	
    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        
//		handler.postDelayed(new Runnable() {
//			@Override
//			public void run() {
//				// TODO Auto-generated method stub
//		        Intent intent = new Intent();
//		        intent.setClass(PlayActivity.this, TestActivity.class); 
//		        startActivity(intent);
//			}
//		}, 10000);    
    }
}
