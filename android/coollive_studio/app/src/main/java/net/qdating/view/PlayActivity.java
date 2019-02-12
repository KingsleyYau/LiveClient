package net.qdating.view;

import java.io.File;

import com.qpidnetwork.tool.CrashHandlerJni;

import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;

import net.qdating.dectection.LSFaceDetectorJni;
import net.qdating.filter.LSImageBeautyFilter;
import net.qdating.filter.LSImageColorFilter;
import net.qdating.filter.LSImageFilter;
import net.qdating.filter.LSImageFlipFilter;
import net.qdating.filter.LSImageGroupFilter;
import net.qdating.filter.LSImageMosaicFilter;
import net.qdating.filter.LSImageVibrateFilter;
import net.qdating.filter.LSImageWaterMarkFilter;
import net.qdating.player.ILSPlayerStatusCallback;
import net.qdating.publisher.ILSPublisherStatusCallback;
import net.qdating.utils.Log;

import android.provider.MediaStore;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;

import net.qdating.LSConfig;
import net.qdating.LSPlayer;
import net.qdating.LSPublisher;
import net.qdating.R;
import net.qdating.LSConfig.FillMode;
import net.qdating.utils.CrashHandler;

public class PlayActivity extends Activity implements ILSPlayerStatusCallback, ILSPublisherStatusCallback {
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
//		"rtmp://52.196.96.7:8899/play_standard/fansi_CM46054718_17710?token=A582892#uid#8WOK1IC5_1530000959125&deviceid=358074081011879",
//		"rtmp://172.25.32.133:7474/test_flash/samson",
//		"rtmp://172.25.32.133:7474/test_flash/samson",
//	};
	private LSPlayer[] players = null;
	private GLSurfaceView[] surfaceViews = null;
	private boolean[] surfaceViewsScale = null;
	private LSImageFilter[] imageFilters = null;
	private EditText editText = null;
	private int playerRunningCount = 0;
	private Object playerRunningCountLock = new Object();

	// 推送相关
	private String publishUrl = "rtmp://172.25.32.17:19351/live/maxa";
//	private String publishUrl = "rtmp://172.25.32.133:7474/test_flash/max";
//	private String publishUrl = "rtmp://172.25.32.17:1937/speex/maxbb";
	private LSPublisher publisher = null;
	private GLSurfaceView surfaceViewPublish = null;
	private EditText editTextPublish = null;
	
	private Handler handler = null;

	private boolean supportPublish = false;

	// 自定义滤镜
	private LSImageGroupFilter groupFilter = new LSImageGroupFilter();
	private LSImageFlipFilter flipFilter = null;
	private LSImageVibrateFilter vibrateFilter = null;
	private LSImageBeautyFilter beautyFilter = null;
	private LSImageWaterMarkFilter waterMarkFilter = null;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_play);

		LSConfig.DEBUG = false;
		LSConfig.LOG_LEVEL = android.util.Log.INFO;
		LSConfig.LOGDIR = LSConfig.TAG;

		File path = Environment.getExternalStorageDirectory();
		filePath = path.getAbsolutePath() + "/" + LSConfig.LOGDIR;
		File logDir = new File(filePath);
		deleteAllFiles(logDir);

//		CrashHandler.newInstance(PlayActivity.this);
//		CrashHandlerJni.SetCrashLogDirectory(filePath);

		handler = new Handler();
		
		editText = (EditText) this.findViewById(R.id.editText);
		editText.setText(playerUrls[0]);
		
		editTextPublish = (EditText) this.findViewById(R.id.editTextPublish);
		editTextPublish.setText(publishUrl);

		// 播放相关
		surfaceViews = new GLSurfaceView[3];
		imageFilters = new LSImageFilter[surfaceViews.length];;
		surfaceViews[0] = (GLSurfaceView) this.findViewById(R.id.surfaceView0);
		imageFilters[0] = new LSImageVibrateFilter();
		surfaceViews[1] = (GLSurfaceView) this.findViewById(R.id.surfaceView1);
		imageFilters[1] = new LSImageMosaicFilter(0.3f);
		surfaceViews[2] = (GLSurfaceView) this.findViewById(R.id.surfaceView2);
		imageFilters[2] = new LSImageColorFilter();
		surfaceViewsScale = new boolean[surfaceViews.length];

		players = new LSPlayer[surfaceViews.length];
		for(int i = 0; i < surfaceViews.length; i++) {
			surfaceViewsScale[i] = false;
			surfaceViews[i].setKeepScreenOn(true);

			players[i] = new LSPlayer();
			players[i].init(surfaceViews[i], FillMode.FillModeAspectRatioFill, this);
			players[i].setCustomFilter(imageFilters[i]);
			players[i].playUrl(playerUrls[i], "", playH264File[i], playAACFile[i]);
		}
//		players[0].playUrl(playerUrls[0], "", playH264File[0], playAACFile[0]);

		// 推送相关
		surfaceViewPublish = (GLSurfaceView) this.findViewById(R.id.surfaceViewPublish);
		supportPublish = LSPublisher.checkDeviceSupport(this);
		if( supportPublish ) {
			surfaceViewPublish.setKeepScreenOn(true);
			int rotation = getWindowManager().getDefaultDisplay()
					.getRotation();
			publisher = new LSPublisher();
			publisher.init(
					this,
					surfaceViewPublish,
					rotation,
					FillMode.FillModeAspectRatioFill,
					this,
					LSConfig.VideoConfigType.VideoConfigType240x240,
					12,
					12,
					400 * 1000
			);

			beautyFilter = new LSImageBeautyFilter(1.0f);
			vibrateFilter = new LSImageVibrateFilter();
			waterMarkFilter = new LSImageWaterMarkFilter();
			File imgFile = new File("/sdcard/input/watermark.png");
			if(imgFile.exists()) {
				Bitmap bitmap = BitmapFactory.decodeFile(imgFile.getAbsolutePath());
				waterMarkFilter.updateBmpFrame(bitmap);
			}
			waterMarkFilter.setWaterMarkRect(0.05f, 0.75f, 0.2f, 0.2f);

			groupFilter.addFilter(beautyFilter);
			groupFilter.addFilter(vibrateFilter);
			groupFilter.addFilter(waterMarkFilter);

			publisher.setCustomFilter(groupFilter);
//			publisher.publisherUrl(publishUrl, publishH264File, publishAACFile);
		} else {
			surfaceViewPublish.setVisibility(View.INVISIBLE);
		}

		// 初始化界面缩放
		initAnimation();
		// 初始化静音按钮
		initItemButtons();
		
		Button playButton = (Button) this.findViewById(R.id.button1);
		playButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// TODO Auto-generated method stub
			for(int i = 0; i < players.length; i++) {
				if( players[i] != null ) {
					players[i].playUrl(playerUrls[i], "", playH264File[i], playAACFile[i]);
				}
			}
			}
		});

		Button pubilsherButton = (Button) this.findViewById(R.id.button2);
		pubilsherButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// TODO Auto-generated method stub
			if( publisher != null && supportPublish ) {
				String publishUrl = editTextPublish.getText().toString();
				publisher.publisherUrl(publishUrl, publishH264File, publishAACFile);
			}
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
						if( players[index] != null ) {
							players[index].stop();
						}

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
			if( publisher != null && supportPublish ) {
				publisher.stop();
			}
			}
		});

		Button startCamButton = (Button) this.findViewById(R.id.button7);
		startCamButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// TODO Auto-generated method stub
			if( publisher != null && supportPublish ) {
				publisher.startPreview();
			}
			}
		});
		
		Button stopCamButton = (Button) this.findViewById(R.id.button8);
		stopCamButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// TODO Auto-generated method stub
			if( publisher != null && supportPublish ) {
				publisher.stopPreview();
			}
			}
		});

		Button testButton = (Button) this.findViewById(R.id.button9);
		testButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// TODO Auto-generated method stub
//			Intent intent = new Intent();
//			intent.setClass(PlayActivity.this, TestActivity.class);
//			startActivity(intent);

			Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
			startActivityForResult(intent, 1);
			}
		});
	}

	private void initItemButtons() {
		Button muteButton100 = (Button) this.findViewById(R.id.button100);
		muteButton100.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// TODO Auto-generated method stub
			if( players[0] != null ) {
				players[0].setMute(!players[0].getMute());
			}
			}
		});
		Button filterButton101 = (Button) this.findViewById(R.id.button101);
        filterButton101.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// TODO Auto-generated method stub
			if( players[0] != null ) {
				if( players[0].getCustomFilter() == null ) {
					players[0].setCustomFilter(imageFilters[0]);
				} else {
					players[0].setCustomFilter(null);
				}
			}
			}
		});

		Button muteButton200 = (Button) this.findViewById(R.id.button200);
		muteButton200.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// TODO Auto-generated method stub
			if( players[1] != null ) {
				players[1].setMute(!players[1].getMute());
			}
			}
		});

		Button filterButton201 = (Button) this.findViewById(R.id.button201);
		filterButton201.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// TODO Auto-generated method stub
			if( players[1] != null ) {
				if( players[1].getCustomFilter() == null ) {
					players[1].setCustomFilter(imageFilters[1]);
				} else {
					players[1].setCustomFilter(null);
				}
			}
			}
		});

		Button muteButton300 = (Button) this.findViewById(R.id.button300);
		muteButton300.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// TODO Auto-generated method stub
			if( players[2] != null ) {
				players[2].setMute(!players[2].getMute());
			}
			}
		});

		Button fliterButton301 = (Button) this.findViewById(R.id.button301);
		fliterButton301.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// TODO Auto-generated method stub
			if( players[2].getCustomFilter() == null ) {
				players[2].setCustomFilter(imageFilters[2]);
			} else {
				players[2].setCustomFilter(null);
			}
			}
		});

		Button muteButton400 = (Button) this.findViewById(R.id.button400);
		muteButton400.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// TODO Auto-generated method stub
			if( publisher != null && supportPublish ) {
				publisher.setMute(!publisher.getMute());
			}
			}
		});

		Button rotateButton401 = (Button) this.findViewById(R.id.button401);
		rotateButton401.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// TODO Auto-generated method stub
			if( publisher != null && supportPublish ) {
				publisher.rotateCamera();
			}
			}
		});

		Button fliterButton402 = (Button) this.findViewById(R.id.button402);
		fliterButton402.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// TODO Auto-generated method stub
			if( publisher.getCustomFilter() == null ) {
				publisher.setCustomFilter(groupFilter);
			} else {
				publisher.setCustomFilter(null);
			}
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
        if (files != null) {
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
    } 
	
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		
		for(int i = 0; i < players.length; i++) {
			if( players[i] != null ) {
				players[i].stop();
				players[i].uninit();
			}

		}

		if( publisher != null ) {
			publisher.stop();
			publisher.uninit();
		}
	}
	
    @Override
    protected void onPause() {
        super.onPause();

		Log.w(LSConfig.TAG, String.format("PlayActivity::onPause()"));
//        if( surfaceView != null ) {
//        	surfaceView.onPause();
//        }
    }

    @Override
    protected void onResume() {
        super.onResume();

		Log.w(LSConfig.TAG, String.format("PlayActivity::onResume()"));
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
//		}, 5000);
    }

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		switch (requestCode) {
			case 1:
				if (resultCode == RESULT_OK) {
					Bundle pBundle = data.getExtras();

					if (pBundle != null) {
						Bitmap pBitmap = (Bitmap) pBundle.get("data");
						if (pBitmap != null) {
						}
					}
				}
				break;

		}
	}

	@Override
	public void onConnect(LSPlayer player) {
		Log.w(LSConfig.TAG, String.format("PlayActivity::onConnect( player : 0x%x )", player.hashCode()));
//		handler.postDelayed(new Runnable() {
//			@Override
//			public void run() {
//				// TODO Auto-generated method stub
//				players[0].stop();
//			}
//		}, 5000);
	}

	@Override
	public void onDisconnect(LSPlayer player) {
		Log.w(LSConfig.TAG, String.format("PlayActivity::onDisconnect( player : 0x%x )", player.hashCode()));
//		handler.postDelayed(new Runnable() {
//			@Override
//			public void run() {
//				// TODO Auto-generated method stub
//				players[0].playUrl(playerUrls[0], "", playH264File[0], playAACFile[0]);
//			}
//		}, 5000);
	}

	@Override
	public void onConnect(LSPublisher publisher) {
		Log.w(LSConfig.TAG, String.format("PlayActivity::onConnect( publisher : 0x%x )", publisher.hashCode()));
	}

	@Override
	public void onDisconnect(LSPublisher publisher) {
		Log.w(LSConfig.TAG, String.format("PlayActivity::onDisconnect( publisher : 0x%x )", publisher.hashCode()));
	}

	@Override
	public void onVideoCaptureError(LSPublisher publisher, int error) {
		Log.e(LSConfig.TAG, String.format("PlayActivity::onVideoCaptureError( publisher : 0x%x, error : %d )", publisher.hashCode(), error));
	}
}
