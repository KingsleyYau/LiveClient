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
	private String h264File = "";//"/sdcard/coollive/play.h264";
	private String aacFile = "";//"/sdcard/coollive/play.aac";
	
	// 播放相关
	private LSPlayer player = new LSPlayer();
	private SurfaceView surfaceView = null;
	private EditText editText = null;
	
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
		editText.setText(url);
		
		surfaceView = (SurfaceView) this.findViewById(R.id.surfaceView);
		surfaceViewPublish = (SurfaceView) this.findViewById(R.id.surfaceViewPublish);
		
		// 播放相关
		player.init(surfaceView, null);
		// 推送相关
		publisher.init(surfaceViewPublish, null);
		
		Button playButton = (Button) this.findViewById(R.id.button1);
		playButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				if( editText.length() > 0 ) {
					url = editText.getText().toString();
				}
				
				surfaceView.setVisibility(View.VISIBLE);
				surfaceViewPublish.setVisibility(View.GONE);
				player.playUrl(url, "", h264File, aacFile);
			}
		});

		Button pubilsherButton = (Button) this.findViewById(R.id.button2);
		pubilsherButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				surfaceView.setVisibility(View.GONE);
				surfaceViewPublish.setVisibility(View.VISIBLE);
				publisher.publisherUrl(url, h264File, aacFile);
			}
		});

		Button beautyButton = (Button) this.findViewById(R.id.button3);
		beautyButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
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
//		}, 5000);    
    }
}
