package net.qdating.view;

import java.io.File;

import com.qpidnetwork.tool.CrashHandlerJni;

import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.app.Activity;
import android.content.Intent;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import net.qdating.LSConfig;
import net.qdating.LSPlayer;
import net.qdating.LSPublisher;
import net.qdating.R;
import net.qdating.LSConfig.FillMode;
import net.qdating.utils.CrashHandler;

public class PlayActivity extends Activity {
	String filePath = "/sdcard";
	private String[] playH264File = {
			"",//"/sdcard/coollive/play0.h264",
			"",//"/sdcard/coollive/play1.h264",
			"",//"/sdcard/coollive/play2.h264",
	};
	private String[] playAACFile = {
			"",//"/sdcard/coollive/play0.aac",
			"",//"/sdcard/coollive/play1.aac",
			"",//"/sdcard/coollive/play2.aac",
	};
	
	private String publishH264File = "";//"/sdcard/coollive/publish.h264";
	private String publishAACFile = "";//"/sdcard/coollive/publish.aac";
	
	// 播放相关
	private String[] playerUrls = {
		"rtmp://172.25.32.17:19351/live/max0",
		"rtmp://172.25.32.17:19351/live/max1",
		"rtmp://172.25.32.17:19351/live/max2",
	};
//	private String[] playerUrls = {
//		"rtmp://172.25.32.133:7474/test_flash/samson",
//		"rtmp://172.25.32.133:7474/test_flash/samson",
//		"rtmp://172.25.32.133:7474/test_flash/samson",
//	};
	private LSPlayer[] players = null;
	private GLSurfaceView[] surfaceViews = null;
	private boolean[] surfaceViewsScale = null;
	private EditText editText = null;
	private int playerRunningCount = 0;
	private Object playerRunningCountLock = new Object();
	
	// 推送相关
	private String publishUrl = "rtmp://172.25.32.17:19351/live/maxa";
//	private String publishUrl = "rtmp://172.25.32.133:7474/test_flash/samson_publish";
//	private String publishUrl = "rtmp://172.25.32.133:7474/test_flash/samson_user";
	private LSPublisher publisher = null;
	private GLSurfaceView surfaceViewPublish = null;
	private EditText editTextPublish = null;
	
	private Handler handler = null;
	
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
		
		handler = new Handler();
		
		editText = (EditText) this.findViewById(R.id.editText);
		editText.setText(playerUrls[0]);
		
		editTextPublish = (EditText) this.findViewById(R.id.editTextPublish);
		editTextPublish.setText(publishUrl);
		
		// 播放相关
		surfaceViews = new GLSurfaceView[3];
		surfaceViews[0] = (GLSurfaceView) this.findViewById(R.id.surfaceView0);
		surfaceViews[1] = (GLSurfaceView) this.findViewById(R.id.surfaceView1);
		surfaceViews[2] = (GLSurfaceView) this.findViewById(R.id.surfaceView2);
		surfaceViewsScale = new boolean[surfaceViews.length];
		players = new LSPlayer[surfaceViews.length];
		for(int i = 0; i < surfaceViews.length; i++) {
			surfaceViewsScale[i] = false;
			surfaceViews[i].setKeepScreenOn(true);
			
			players[i] = new LSPlayer();
			players[i].init(surfaceViews[i], FillMode.FillModeAspectRatioFill, null);
		}
		
		// 推送相关
		surfaceViewPublish = (GLSurfaceView) this.findViewById(R.id.surfaceViewPublish);
		surfaceViewPublish.setKeepScreenOn(true);
		int rotation = getWindowManager().getDefaultDisplay()
	             .getRotation();
		publisher = new LSPublisher();
		publisher.init(this, surfaceViewPublish, rotation, FillMode.FillModeAspectRatioFill, null);
		
		// 初始化界面缩放
		initAnimation();
		
		Button playButton = (Button) this.findViewById(R.id.button1);
		playButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				for(int i = 0; i < players.length; i++) {
					players[i].playUrl(playerUrls[i], "", playH264File[i], playAACFile[i]);
				}
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

		Button stopPlayButton = (Button) this.findViewById(R.id.button3);
		stopPlayButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				playerRunningCount = players.length;
				for(int i = 0; i < players.length; i++) {
					final int index = i;
					new Thread(new Runnable() {
						@Override
						public void run() {
							// TODO Auto-generated method stub
							players[index].stop();
							synchronized (playerRunningCountLock) {
								playerRunningCount--;
								Log.d(LSConfig.TAG, String.format("PlayActivity::stop( [Notify], playerRunningCount : %d )", playerRunningCount));
								playerRunningCountLock.notify();
							}
						}
					}).start();
				}
				
				synchronized (playerRunningCountLock) {
					while( playerRunningCount != 0 ) {
						Log.d(LSConfig.TAG, String.format("PlayActivity::stop( [Wait], playerRunningCount : %d )", playerRunningCount));
						try {
							playerRunningCountLock.wait();
						} catch (InterruptedException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
					}
				}
			}
		});
		
		Button stopPublishButton = (Button) this.findViewById(R.id.button4);
		stopPublishButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				publisher.stop();
			}
		});
		
		Button muteButton = (Button) this.findViewById(R.id.button5);
		muteButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				publisher.setMute(!publisher.getMute());
			}
		});

		Button rotateButton = (Button) this.findViewById(R.id.button6);
		rotateButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				publisher.rotateCamera();
			}
		});
		
		Button startCamButton = (Button) this.findViewById(R.id.button7);
		startCamButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				publisher.startPreview();
			}
		});
		
		Button stopCamButton = (Button) this.findViewById(R.id.button8);
		stopCamButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				publisher.stopPreview();
			}
		});
	}

	private void initAnimation() {
		surfaceViews[0].setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				AnimatorSet animatorSet = new AnimatorSet();
				ObjectAnimator transXAnimator = null;
				ObjectAnimator transYAnimator = null;
				ObjectAnimator scaleXAnimator = null;
				ObjectAnimator scaleYAnimator = null;
				if( !surfaceViewsScale[0] ) {
					transXAnimator = ObjectAnimator.ofFloat(surfaceViews[0], "translationX", 0f, (surfaceViews[0].getWidth()/2));
					transYAnimator = ObjectAnimator.ofFloat(surfaceViews[0], "translationY", 0f, surfaceViews[0].getHeight()/2);
					scaleXAnimator = ObjectAnimator.ofFloat(surfaceViews[0], "scaleX", 1f, 2f);
					scaleYAnimator = ObjectAnimator.ofFloat(surfaceViews[0], "scaleY", 1f, 2f);
				} else {
					transXAnimator = ObjectAnimator.ofFloat(surfaceViews[0], "translationX", (surfaceViews[0].getWidth()/2), 0);
					transYAnimator = ObjectAnimator.ofFloat(surfaceViews[0], "translationY", surfaceViews[0].getHeight()/2, 0);
					scaleXAnimator = ObjectAnimator.ofFloat(surfaceViews[0], "scaleX", 2f, 1f);
					scaleYAnimator = ObjectAnimator.ofFloat(surfaceViews[0], "scaleY", 2f, 1f);
				}

				animatorSet.playTogether(transXAnimator, transYAnimator, scaleXAnimator, scaleYAnimator);
				animatorSet.setDuration(500);
				animatorSet.start();
				
				surfaceViews[0].bringToFront();
				surfaceViewsScale[0] = !surfaceViewsScale[0];
			}
		});
//		surfaceViews[1].setOnClickListener(new OnClickListener() {
//			@Override
//			public void onClick(View v) {
//				// TODO Auto-generated method stub
//				AnimatorSet animatorSet = new AnimatorSet();
//				ObjectAnimator transXAnimator = null;
//				ObjectAnimator transYAnimator = null;
//				ObjectAnimator scaleXAnimator = null;
//				ObjectAnimator scaleYAnimator = null;
//				if( !surfaceViewsScale[1] ) {
//					transXAnimator = ObjectAnimator.ofFloat(surfaceViews[1], "translationX", 0f, -(surfaceViews[1].getWidth()/2));
//					transYAnimator = ObjectAnimator.ofFloat(surfaceViews[1], "translationY", 0f, surfaceViews[1].getHeight()/2);
//					scaleXAnimator = ObjectAnimator.ofFloat(surfaceViews[1], "scaleX", 1f, 2f);
//					scaleYAnimator = ObjectAnimator.ofFloat(surfaceViews[1], "scaleY", 1f, 2f);
//				} else {
//					transXAnimator = ObjectAnimator.ofFloat(surfaceViews[1], "translationX", -(surfaceViews[1].getWidth()/2), 0);
//					transYAnimator = ObjectAnimator.ofFloat(surfaceViews[1], "translationY", surfaceViews[1].getHeight()/2, 0);
//					scaleXAnimator = ObjectAnimator.ofFloat(surfaceViews[1], "scaleX", 2f, 1f);
//					scaleYAnimator = ObjectAnimator.ofFloat(surfaceViews[1], "scaleY", 2f, 1f);
//				}
//
//				animatorSet.playTogether(transXAnimator, transYAnimator, scaleXAnimator, scaleYAnimator);
//				animatorSet.setDuration(500);
//				animatorSet.start();
//				
//				surfaceViews[1].bringToFront();
//				surfaceViewsScale[1] = !surfaceViewsScale[1];
//			}
//		});
//		surfaceViews[2].setOnClickListener(new OnClickListener() {
//			@Override
//			public void onClick(View v) {
//				// TODO Auto-generated method stub
//				AnimatorSet animatorSet = new AnimatorSet();
//				ObjectAnimator transXAnimator = null;
//				ObjectAnimator transYAnimator = null;
//				ObjectAnimator scaleXAnimator = null;
//				ObjectAnimator scaleYAnimator = null;
//				if( !surfaceViewsScale[2] ) {
//					transXAnimator = ObjectAnimator.ofFloat(surfaceViews[2], "translationX", 0f, (surfaceViews[2].getWidth()/2));
//					transYAnimator = ObjectAnimator.ofFloat(surfaceViews[2], "translationY", 0f, -surfaceViews[2].getHeight()/2);
//					scaleXAnimator = ObjectAnimator.ofFloat(surfaceViews[2], "scaleX", 1f, 2f);
//					scaleYAnimator = ObjectAnimator.ofFloat(surfaceViews[2], "scaleY", 1f, 2f);
//				} else {
//					transXAnimator = ObjectAnimator.ofFloat(surfaceViews[2], "translationX", (surfaceViews[2].getWidth()/2), 0);
//					transYAnimator = ObjectAnimator.ofFloat(surfaceViews[2], "translationY", -surfaceViews[2].getHeight()/2, 0);
//					scaleXAnimator = ObjectAnimator.ofFloat(surfaceViews[2], "scaleX", 2f, 1f);
//					scaleYAnimator = ObjectAnimator.ofFloat(surfaceViews[2], "scaleY", 2f, 1f);
//				}
//
//				animatorSet.playTogether(transXAnimator, transYAnimator, scaleXAnimator, scaleYAnimator);
//				animatorSet.setDuration(500);
//				animatorSet.start();
//				
//				surfaceViews[2].bringToFront();
//				surfaceViewsScale[2] = !surfaceViewsScale[2];
//			}
//		});
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
		
		for(int i = 0; i < players.length; i++) {
			players[i].stop();
			players[i].uninit();
		}

		if( publisher != null ) {
			publisher.stop();
			publisher.uninit();
		}
	}
	
    @Override
    protected void onPause() {
        super.onPause();
//        if( surfaceView != null ) {
//        	surfaceView.onPause();
//        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        
//        if( surfaceView != null ) {
//        	surfaceView.onResume();
//        }
        
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
