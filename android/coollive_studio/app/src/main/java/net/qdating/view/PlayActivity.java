package net.qdating.view;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.SeekBar;
import android.widget.Toast;

import com.qpidnetwork.tool.CrashHandlerJni;

import net.qdating.LSConfig;
import net.qdating.LSConfig.FillMode;
import net.qdating.LSPlayer;
import net.qdating.LSPublisher;
import net.qdating.R;
import net.qdating.dectection.ILSFaceDetectorStatusCallback;
import net.qdating.dectection.LSFaceDetector;
import net.qdating.filter.LSImageFilter;
import net.qdating.filter.LSImageGroupFilter;
import net.qdating.filter.LSImageVibrateFilter;
import net.qdating.filter.LSImageWaterMarkFilter;
import net.qdating.filter.sample.LSImageSampleBeautyBaseFilter;
import net.qdating.filter.sample.LSImageSampleBeautyBaseFilterEvent;
import net.qdating.filter.sample.LSImageSampleBeautyEmeraldFilter;
import net.qdating.filter.sample.LSImageSampleBeautyHealthyFilter;
import net.qdating.filter.sample.LSImageSampleBeautyHefeFilter;
import net.qdating.filter.sample.LSImageSampleBeautyLomoFilter;
import net.qdating.filter.sample.LSImageSampleBeautySakuraFilter;
import net.qdating.filter.sample.LSImageSampleBeautySunsetFilter;
import net.qdating.filter.sample.LSImageSampleBeautyWatermarkFilter;
import net.qdating.player.ILSPlayerStatusCallback;
import net.qdating.player.LSPlayerRendererBinder;
import net.qdating.player.LSVideoPlayer;
import net.qdating.publisher.ILSPublisherStatusCallback;
import net.qdating.utils.CrashHandler;
import net.qdating.utils.Log;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;

public class PlayActivity extends Activity implements ILSPlayerStatusCallback, ILSPublisherStatusCallback, ILSFaceDetectorStatusCallback, ActivityCompat.OnRequestPermissionsResultCallback {
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
	private LSPlayerRendererBinder[] playerRenderderBinders = null;
//	private String playerUrl = "rtmp://172.25.32.17:19351/live/max";
//	private String playerUrl = "rtmp://172.25.32.133:4000/cdn_standard/max";
	private String playerUrl = "rtmp://172.25.32.133:4000/cdn_standard/max0";
	private EditText editText = null;
	private int playerRunningCount = 0;
	private Object playerRunningCountLock = new Object();

	// 推送相关
//	private String publishUrl = "rtmp://172.25.32.17:19351/live/maxa";
	private String publishUrl = "rtmp://172.25.32.133:4000/cdn_standard/max0";
//  private String publishUrl = "rtmp://52.196.96.7:4000/cdn_standard/max0";
//	private String publishUrl = "rtmp://172.25.32.133:8899/publish_standard/max0?token=ABC#123";
	private LSPublisher publisher = null;
	private GLSurfaceView surfaceViewPublish = null;
	private EditText editTextPublish = null;

	private GLSurfaceView newSurfaceView = null;
	private LSPlayerRendererBinder newRenderderBinder = null;
	// 推流预设滤镜
	private LSImageFilter[] publishFilters;
	private int publishFilterCount = 0;
	private int publishFilterIndex = 0;
	private Button filterButton;


	private Bitmap[] publishPhotos;
	private int publishPhotoCount = 0;
	private int publishPhotoIndex = 0;
	private Button photoButton;

	private Handler handler = null;
	private boolean supportPublish = false;

	// 人面识别
	private LSFaceDetector faceDetector = null;//new LSFaceDetector();
	private LSVideoPlayer previewPlayer = new LSVideoPlayer();
	private LSImageGroupFilter previewGroupFilter = new LSImageGroupFilter();
	private LSImageWaterMarkFilter previewWaterMarkFilter = null;

	private int previewWaterMarkDisappearFrame = 15;

	private SeekBar mSeekBarBeauty, mSeekBarWhite;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_play);

		LSConfig.DEBUG = false;
		LSConfig.LOG_LEVEL = android.util.Log.WARN;
		LSConfig.LOGDIR = LSConfig.TAG;
		LSConfig.decodeMode = LSConfig.DecodeMode.DecodeModeAuto;
//		LSConfig.decodeMode = LSConfig.DecodeMode.DecodeModeSoft;

		File path = Environment.getExternalStorageDirectory();
		filePath = path.getAbsolutePath() + "/" + LSConfig.LOGDIR;
		File logDir = new File(filePath);
		deleteAllFiles(logDir);

		CrashHandler.newInstance(PlayActivity.this);
		CrashHandlerJni.SetCrashLogDirectory(filePath);

//		LSUtilTesterJni utilTestJni = new LSUtilTesterJni();
//		utilTestJni.Test();

		handler = new Handler();

		// 初始化按钮
		initItemButtons();

		checkPermission();

		editText = (EditText) this.findViewById(R.id.editText);
		editText.setText(playerUrl);

		editTextPublish = (EditText) this.findViewById(R.id.editTextPublish);
		editTextPublish.setText(publishUrl);

		// 播放相关
		surfaceViews = new GLSurfaceView[2];
		imageFilters = new LSImageFilter[surfaceViews.length];
		playerRenderderBinders = new LSPlayerRendererBinder[surfaceViews.length];

		surfaceViews[0] = (GLSurfaceView) this.findViewById(R.id.surfaceView0);
		imageFilters[0] = new LSImageVibrateFilter();

		surfaceViews[1] = (GLSurfaceView) this.findViewById(R.id.surfaceView1);
//		imageFilters[1] = new LSImageMosaicFilter(0.2f);
		imageFilters[1] = new LSImageSampleBeautyEmeraldFilter(this);

		surfaceViewsScale = new boolean[surfaceViews.length];

		players = new LSPlayer[surfaceViews.length];
		for(int i = 0; i < surfaceViews.length; i++) {
//		for(int i = 0; i < surfaceViews.length - 1; i++) { // 人面识别测试
			surfaceViewsScale[i] = false;
			surfaceViews[i].setKeepScreenOn(true);

			players[i] = new LSPlayer();

			playerRenderderBinders[i] = new LSPlayerRendererBinder(surfaceViews[i], FillMode.FillModeAspectRatioFit);
			playerRenderderBinders[i].setCustomFilter(imageFilters[i]);
			players[i].init(this);

			players[i].setRendererBinder(playerRenderderBinders[i]);
//			players[i].playUrl(playerUrls[i], "", playH264File[i], playAACFile[i]);

//			String url = String.format("%s%d", editText.getText().toString(), i);
			String url = "rtmp://172.25.32.133:4000/cdn_standard/max0";
//			players[i].playUrl(url, "", playH264File[i], playAACFile[i]);
		}
		play();

//		RelativeLayout layoutVideo1 = (RelativeLayout)this.findViewById(R.id.layoutVideo1);
//		newSurfaceView = new GLSurfaceView(this);
//		RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(540, 540);
//		lp.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
//		lp.addRule(RelativeLayout.ALIGN_PARENT_TOP);
//		newSurfaceView.setLayoutParams(lp);
//		newSurfaceView.setId(1);
//		layoutVideo1.addView(newSurfaceView);
//		layoutVideo1.setVisibility(View.VISIBLE);
//		newRenderderBinder = new LSPlayerRendererBinder(newSurfaceView, FillMode.FillModeAspectRatioFill);

//		// 人面识别测试
//		previewWaterMarkFilter = new LSImageWaterMarkFilter();
//		File previewImgFile = new File("/sdcard/face_dectected/face.png");
//		if(previewImgFile.exists()) {
//			Bitmap bitmap = BitmapFactory.decodeFile(previewImgFile.getAbsolutePath());
//			previewWaterMarkFilter.updateBmpFrame(bitmap);
//		}
//		previewWaterMarkFilter.setWaterMarkRect(0f, 0f, 0f, 0f);
//		previewGroupFilter.addFilter(previewWaterMarkFilter);
//		playerRenderderBinders[2] = new LSPlayerRendererBinder(surfaceViews[2], FillMode.FillModeAspectRatioFill, LSConfig.DecodeMode.DecodeModeSoft);
//		playerRenderderBinders[2].setCustomFilter(previewGroupFilter);
//		previewPlayer.setRendererBinder(playerRenderderBinders[2]);
//		faceDetector.setCallback(this);

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
					FillMode.FillModeAspectRatioFit,
					this,
					LSConfig.VideoConfigType.VideoConfigType480x640,
					12,
					12,
					600 * 1000
			);

			publishFilterCount = 8;
			publishFilterIndex = 0;
			if ( publishFilterCount > 0 ) {
				publishFilters = new LSImageFilter[publishFilterCount];

				publishFilters[0] = new LSImageSampleBeautyEmeraldFilter(this);
				publishFilters[1] = new LSImageSampleBeautyHealthyFilter(this);
				publishFilters[2] = new LSImageSampleBeautyHefeFilter(this);
				publishFilters[3] = new LSImageSampleBeautyLomoFilter(this);
				publishFilters[4] = new LSImageSampleBeautySakuraFilter(this);
				publishFilters[5] = new LSImageSampleBeautySunsetFilter(this);
				publishFilters[6] = new LSImageSampleBeautyWatermarkFilter(this);
				LSImageGroupFilter filters = new LSImageGroupFilter();
				filters.addFilter(new LSImageSampleBeautyBaseFilter(this));
				filters.addFilter(new LSImageVibrateFilter());
				publishFilters[7] = filters;
				publishFilterIndex = 7;

				publisher.setCustomFilter(publishFilters[publishFilterIndex]);
				String filterName = String.format("F%d", publishFilterIndex);
				filterButton.setText(filterName);
			}

			try {
				publishPhotoCount = 3;
				publishPhotoIndex = 0;
				if ( publishPhotoCount > 0 ) {
					publishPhotos = new Bitmap[publishPhotoCount];
					for (int i = 0; i < publishPhotoCount; i++) {
						String photoName = String.format("demo/%d.png", i);
						InputStream demoInputStream = getAssets().open(photoName);
						Bitmap demoBitmap = BitmapFactory.decodeStream(demoInputStream);
						demoInputStream.close();
						publishPhotos[i] = demoBitmap;
					}

//					publishPhotoIndex = 1;
//					publisher.setCaptureBitmap(publishPhotos[publishPhotoIndex]);
//					String buttonName = String.format("P%d", publishPhotoIndex);
//					photoButton.setText(buttonName);

				}
			} catch (IOException e) {
				e.printStackTrace();
			}

			publishPhotoIndex = publishPhotoCount;
			String buttonName = String.format("C");
			photoButton.setText(buttonName);
			publisher.setCaptureBitmap(null);
			publisher.publisherUrl(publishUrl, publishH264File, publishAACFile);

		} else {
			surfaceViewPublish.setVisibility(View.INVISIBLE);
		}


		handler = new Handler() {
			@Override
			public void handleMessage(Message msg) {
				switch (msg.what) {
					case 0:{
						String freeMemory = Runtime.getRuntime().freeMemory() / 1024 + " K";
						String totalMemory = Runtime.getRuntime().totalMemory() / 1024 + " K";
						String maxMemory = Runtime.getRuntime().maxMemory() / 1024 + " K";

						Log.w(LSConfig.TAG, String.format("PlayActivity::check( "
										+ "freeMemory : %s, "
										+ "totalMemory : %s, "
										+ "maxMemory : %s "
										+ ")",
								freeMemory,
								totalMemory,
								maxMemory
								)
						);

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
//		handler.post(new Runnable() {
//			@Override
//			public void run() {
//				// TODO Auto-generated method stub
//				Message msg = Message.obtain();
//				msg.what = 0;
//				handler.sendMessage(msg);
//			}
//		});

		Button playButton = (Button) this.findViewById(R.id.button1);
		playButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// TODO Auto-generated method stub
				play();
			}
		});

		Button pubilsherButton = (Button) this.findViewById(R.id.button2);
		pubilsherButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// TODO Auto-generated method stub
			if( publisher != null && supportPublish ) {
				String publishUrl = editTextPublish.getText().toString();
				if ( faceDetector != null ) {
					faceDetector.start();
				}
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
				if( faceDetector != null ) {
					faceDetector.stop();
				}
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
			Intent intent = new Intent();
			intent.setClass(PlayActivity.this, TestActivity.class);
			startActivity(intent);

//			Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
//			startActivityForResult(intent, 1);
			}
		});

		// TODO: 2019/10/29 Hardy
		mSeekBarBeauty = (SeekBar)findViewById(R.id.seekBar_beauty);
		mSeekBarWhite = (SeekBar)findViewById(R.id.seekBar_white);
		mSeekBarBeauty.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
			@Override
			public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
				handlerProgressChange(progress, true);
			}

			@Override
			public void onStartTrackingTouch(SeekBar seekBar) {

			}

			@Override
			public void onStopTrackingTouch(SeekBar seekBar) {

			}
		});

		mSeekBarWhite.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
			@Override
			public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
				handlerProgressChange(progress,false);
			}

			@Override
			public void onStartTrackingTouch(SeekBar seekBar) {

			}

			@Override
			public void onStopTrackingTouch(SeekBar seekBar) {

			}
		});

	}

	private void play() {
//		for(int i = 0; i < players.length; i++) {
//			if( players[i] != null ) {
//				String url = String.format("%s%d", editText.getText().toString(), i);
////				String url = "rtmp://172.25.32.133:4000/cdn_standard/max0";
//				players[i].playUrl(url, "", playH264File[i], playAACFile[i]);
//			}
//		}
		String url = "rtmp://172.25.32.133:4000/cdn_standard/max0";
		players[0].playUrl(url, "", playH264File[0], playAACFile[0]);
	}

	// TODO: 2019/10/29
	private void handlerProgressChange(int progress,boolean isBeautyChange){
		float scale = progress * 1.0f / 100;
		Log.i("info", "--------scale: "+scale);

		LSImageSampleBeautyBaseFilterEvent filter = (LSImageSampleBeautyBaseFilterEvent) publishFilters[publishFilterIndex];
		if (isBeautyChange) {
			filter.setBeautyLevel(scale);
		}else {
			filter.setStrength(scale);
		}
	}

	private void initItemButtons() {
		Button playButton10 = (Button) this.findViewById(R.id.button10);
		playButton10.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// TODO Auto-generated method stub
			int i = 0;
			if( players[i] != null ) {
				String url = String.format("%s%d", editText.getText().toString(), i);
				players[i].playUrl(url, "", playH264File[i], playAACFile[i]);
			}
			}
		});

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
			if( playerRenderderBinders[0] != null ) {
				if( playerRenderderBinders[0].getCustomFilter() == null ) {
					playerRenderderBinders[0].setCustomFilter(imageFilters[0]);
				} else {
					playerRenderderBinders[0].setCustomFilter(null);
				}
			}
			}
		});

		Button playButton20 = (Button) this.findViewById(R.id.button20);
		playButton20.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// TODO Auto-generated method stub
			int i = 1;
			if( players[i] != null ) {
				String url = String.format("%s%d", editText.getText().toString(), i);
				players[i].playUrl(url, "", playH264File[i], playAACFile[i]);
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
			if( playerRenderderBinders[1] != null ) {
				if( playerRenderderBinders[1].getCustomFilter() == null ) {
					playerRenderderBinders[1].setCustomFilter(imageFilters[1]);
				} else {
					playerRenderderBinders[1].setCustomFilter(null);
				}
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
				publisher.setCustomFilter(publishFilters[publishFilterIndex]);
			} else {
				publisher.setCustomFilter(null);
			}
			}
		});

		Button nextFliterButton403 = (Button) this.findViewById(R.id.button403);
		nextFliterButton403.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
			// TODO Auto-generated method stub
				publishFilterIndex = ++publishFilterIndex % publishFilterCount;
				if ( publishFilters[publishFilterIndex] != null ) {
					String buttonName = String.format("F%d", publishFilterIndex);
					filterButton.setText(buttonName);
					publisher.setCustomFilter(publishFilters[publishFilterIndex]);
				}
			}
		});
		filterButton = nextFliterButton403;

		Button photoButton404 = (Button) this.findViewById(R.id.button404);
		photoButton404.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				publishPhotoIndex = ++publishPhotoIndex % (publishPhotoCount + 1);
				if ( publishPhotoIndex < publishPhotoCount && publishFilters[publishPhotoIndex] != null ) {
					String buttonName = String.format("P%d", publishPhotoIndex);
					photoButton.setText(buttonName);
					publisher.setCaptureBitmap(publishPhotos[publishPhotoIndex]);
				} else {
					String buttonName = String.format("C");
					photoButton.setText(buttonName);
					publisher.setCaptureBitmap(null);
				}
			}
		});
		photoButton = photoButton404;

//		SeekBar seekBar = (SeekBar) findViewById(R.id.seekBar);
//		seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
//			@Override
//			public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
//				float level = 1.0f * progress / 100;
////				Log.w(LSConfig.TAG, String.format("PlayActivity::onProgressChanged( beauty : %f )", level));
//				LSImageSampleBeautyBaseFilter filter = (LSImageSampleBeautyBaseFilter)publishFilters[7];
//				filter.setBeautyLevel(level);
//			}
//
//			@Override
//			public void onStartTrackingTouch(SeekBar seekBar) {
//
//			}
//
//			@Override
//			public void onStopTrackingTouch(SeekBar seekBar) {
//
//			}
//		});
//		SeekBar seekBar2 = (SeekBar) findViewById(R.id.seekBar2);
//		seekBar2.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
//			@Override
//			public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
//				float level = 1.0f * progress / 100;
////				Log.w(LSConfig.TAG, String.format("PlayActivity::onProgressChanged( strength : %f )", level));
//				LSImageSampleBeautyBaseFilter filter = (LSImageSampleBeautyBaseFilter)publishFilters[7];
//				filter.setStrength(level);
//			}
//
//			@Override
//			public void onStartTrackingTouch(SeekBar seekBar) {
//
//			}
//
//			@Override
//			public void onStopTrackingTouch(SeekBar seekBar) {
//
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

//		Log.i(LSConfig.TAG, String.format("PlayActivity::onPause()"));
//        if( surfaceView != null ) {
//        	surfaceView.onPause();
//        }
    }

    @Override
    protected void onResume() {
        super.onResume();

		Log.i(LSConfig.TAG, String.format("PlayActivity::onResume()"));

//		handler.postDelayed(new Runnable() {
//			@Override
//			public void run() {
//				// TODO Auto-generated method stub
//		        Intent intent = new Intent();
//		        intent.setClass(PlayActivity.this, TestActivity.class);
//		        startActivity(intent);
//			}
//		}, 3000);
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
//		Log.i(LSConfig.TAG, String.format("PlayActivity::onConnect( player : 0x%x )", player.hashCode()));
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
//		Log.i(LSConfig.TAG, String.format("PlayActivity::onDisconnect( player : 0x%x )", player.hashCode()));
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
//		Log.i(LSConfig.TAG, String.format("PlayActivity::onConnect( publisher : 0x%x )", publisher.hashCode()));
	}

	@Override
	public void onDisconnect(LSPublisher publisher) {
//		Log.i(LSConfig.TAG, String.format("PlayActivity::onDisconnect( publisher : 0x%x )", publisher.hashCode()));
	}

	@Override
	public void onVideoCaptureError(LSPublisher publisher, int error) {
		Log.e(LSConfig.TAG, String.format("PlayActivity::onVideoCaptureError( publisher : 0x%x, error : %d )", publisher.hashCode(), error));
	}

	@Override
	public void onError(LSPublisher publisher, String code, final String description) {
		Log.e(LSConfig.TAG, String.format("PlayActivity::onError( publisher : 0x%x, code : %s, description : %s )", publisher.hashCode(), code, description));

		final Context context = this;
		handler.post(new Runnable() {
			@Override
			public void run() {
				Toast.makeText(context, description, Toast.LENGTH_SHORT).show();
			}
		});
	}

//	@Override
//	public void onVideoCapture(LSPublisher publisher, final byte[] data, int size, final int width, final int height) {
////		previewPlayer.renderVideoFrame(data, size, width, height);
//		faceDetector.detectPicture(data, size, width, height);
//	}

	@Override
	public void onDetectedFace(byte[] data, int size, int x, int y, int width, int height) {
		synchronized (this) {
			if( width > 0 && height > 0 ) {
				previewWaterMarkDisappearFrame = 3;
				previewWaterMarkFilter.setWaterMarkRect(x / 240f, y / 240f, width / 240f, height / 240f);
			} else {
				previewWaterMarkDisappearFrame--;
				if( previewWaterMarkDisappearFrame <= 0 ) {
					previewWaterMarkFilter.setWaterMarkRect(x / 240f, y / 240f, width / 240f, height / 240f);
				}
			}
			previewPlayer.renderVideoFrame(data, size, 240, 240);
		}
	}

	public void checkPermission() {
		int status = ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA);
		Log.e(LSConfig.TAG, String.format("PlayActivity::checkPermission( CAMERA, status : %d )", status));
		if ( status != PackageManager.PERMISSION_GRANTED ) {
			ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CAMERA}, 1);
		}

		status = ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO);
		Log.e(LSConfig.TAG, String.format("PlayActivity::checkPermission( RECORD_AUDIO, status : %d )", status));
		if ( status != PackageManager.PERMISSION_GRANTED ) {
			ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.RECORD_AUDIO}, 1);
		}

		status = ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO);
		Log.e(LSConfig.TAG, String.format("PlayActivity::checkPermission( INTERNET, status : %d )", status));
		if ( status != PackageManager.PERMISSION_GRANTED ) {
			ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.INTERNET}, 1);
		}

		status = ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE);
		Log.e(LSConfig.TAG, String.format("PlayActivity::checkPermission( WRITE_EXTERNAL_STORAGE, status : %d )", status));
		if ( status != PackageManager.PERMISSION_GRANTED ) {
			ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, 1);
		}
	}

	public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
		Log.e(LSConfig.TAG, String.format("PlayActivity::onRequestPermissionsResult( requestCode : %d )", requestCode));
		for(int i = 0; i < permissions.length; i++) {
			Log.e(LSConfig.TAG, String.format("PlayActivity::onRequestPermissionsResult( %s:%d )", permissions[i], grantResults[i]));
		}
	}
}
