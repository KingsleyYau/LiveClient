package net.qdating.view;

import java.io.File;
import java.io.IOException;

import com.qpidnetwork.tool.CrashHandlerJni;

import android.app.ActionBar.LayoutParams;
import android.app.Activity;
import android.app.Fragment;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.SurfaceView;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.TextView;
import net.qdating.LSPlayer;
import net.qdating.R;

public class MainActivity extends Activity {
//	private String url = "rtmp://192.168.88.17/live/5-5601";
//	private String url = "rtmp://172.25.32.17/live/livestream";
//	private String url = "rtmp://172.25.32.17/live/samson_test";
//	private String url = "rtmp://172.25.32.17/live/max";
	private String url = "rtmp://172.25.32.17:1936/aac/max";
	
	String filePath = "/sdcard";
	private String h264File = "";//"/sdcard/livestream/play.h264";
	private String aacFile = "";//"/sdcard/livestream/play.aac";
	
	private String h264FilePublish = "";//"/sdcard/livestream/publish.h264";
	private String aacFilePublish = "";//"/sdcard/livestream/publish.aac";
	
	// 播放相关
	private LSPlayer player = new LSPlayer();
	private SurfaceView surfaceView = null;
	private EditText editText = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		File path = Environment.getExternalStorageDirectory();
		filePath = path.getAbsolutePath() + "/livestream";
		File livestream = new File(filePath);
		deleteAllFiles(livestream);

		CrashHandlerJni.SetCrashLogDirectory(filePath);
		
		editText = (EditText) this.findViewById(R.id.editText);
		editText.setText(url);
		
		surfaceView = (SurfaceView) this.findViewById(R.id.surfaceView);
		player.init(surfaceView, null);
		
		Button playButton = (Button) this.findViewById(R.id.button1);
		playButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				if( editText.length() > 0 ) {
					url = editText.getText().toString();
				}
				
				boolean bFlag = player.playUrl(url, "", h264File, aacFile);
			}
		});

		Button pubilsherButton = (Button) this.findViewById(R.id.button2);
		pubilsherButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
//				boolean bFlag = publisher.PublishUrl(url, h264FilePublish, aacFilePublish);
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
	
//    @Override
//    protected void onPause() {
//        super.onPause();
//        // The following call pauses the rendering thread.
//        // If your OpenGL application is memory intensive,
//        // you should consider de-allocating objects that
//        // consume significant memory here.
//        surfaceView.onPause();
//    }
//
//    @Override
//    protected void onResume() {
//        super.onResume();
//        // The following call resumes a paused rendering thread.
//        // If you de-allocated graphic objects for onPause()
//        // this is a good place to re-allocate them.
//        surfaceView.onResume();
//    }
}
