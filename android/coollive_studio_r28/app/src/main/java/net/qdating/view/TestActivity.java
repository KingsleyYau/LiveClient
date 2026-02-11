package net.qdating.view;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.webkit.WebView;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import net.qdating.LSConfig;
import net.qdating.LSConfig.FillMode;
import net.qdating.LSConfig.VideoConfigType;
import net.qdating.LSPlayer;
import net.qdating.LSPublisher;
import net.qdating.coollive_studio.R;
import net.qdating.filter.LSImageConnerFilter;
import net.qdating.filter.LSImageFilter;
import net.qdating.filter.LSImageGroupFilter;
import net.qdating.filter.LSImageVibrateFilter;
import net.qdating.player.ILSPlayerStatusCallback;
import net.qdating.player.LSPlayerRendererBinder;
import net.qdating.utils.Log;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;

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
        LSConfig.decodeMode = LSConfig.DecodeMode.DecodeModeAuto;
        LSConfig.LOG_LEVEL = android.util.Log.WARN;

        // 1. 获取播放器日志目录（私有外部文件目录）
        File logDir = getExternalPrivateFilesDir("log");
        LSConfig.LOGDIR = logDir.getAbsolutePath();
        Log.w(LSConfig.TAG, String.format("TestActivity::onCreate(), LSConfig.LOGDIR:%s", LSConfig.LOGDIR));

		surfaceViewPublish = (GLSurfaceView) this.findViewById(R.id.surfaceView0);
        surfaceViewPublish.setEGLConfigChooser(8, 8, 8, 8, 16, 0); // R:8, G:8, B:8, A:8, 深度:16
        surfaceViewPublish.setBackgroundColor(Color.TRANSPARENT); // 设置Surface背景为透明
        surfaceViewPublish.setZOrderOnTop(true);
		surfaceViewPublish.setKeepScreenOn(true);
        surfaceViewPublish.setVisibility(View.VISIBLE);
        surfaceViewPublish.getHolder().setFormat(PixelFormat.TRANSLUCENT);

        surfaceView = (GLSurfaceView) this.findViewById(R.id.surfaceView1);
        surfaceView.setKeepScreenOn(true);
        surfaceView.setVisibility(View.VISIBLE);
        surfaceView.setEGLConfigChooser(8, 8, 8, 8, 16, 0); // R:8, G:8, B:8, A:8, 深度:16
        surfaceView.setBackgroundColor(Color.TRANSPARENT); // 设置Surface背景为透明
        surfaceView.setZOrderOnTop(true);
        surfaceView.getHolder().setFormat(PixelFormat.TRANSLUCENT);

		// 播放相关
		player = new LSPlayer();
		player.init(this);

        LSImageGroupFilter playerFilterGroup = new LSImageGroupFilter();
//        playerFilterGroup.addFilter(new LSImageBufferEmptyFilter());
        playerFilterGroup.addFilter(new LSImageConnerFilter());

		playerRenderderBinder = new LSPlayerRendererBinder(surfaceView, FillMode.FillModeAspectRatioFill);
		playerRenderderBinder.setCustomFilter(playerFilterGroup);
		player.setRendererBinder(playerRenderderBinder);
        surfaceView.requestRender();

		String playerUrl = "rtmp://demo-cam.meetromance.com:8899/play_standard/MM1?userId=MM888&siteId=8";
		player.playUrl(playerUrl, "", "", "");

		// 推送相关
		final int rotation = getWindowManager().getDefaultDisplay()
	             .getRotation();
		publisher = new LSPublisher();
		publisher.init(context, surfaceViewPublish, rotation, FillMode.FillModeAspectRatioFit, null, VideoConfigType.VideoConfigType480x640, 12, 12, 500 * 1000);
        publisher.setCustomFilter(new LSImageVibrateFilter(0.1));
        publisher.setCustomPreviewFilter(new LSImageConnerFilter());

        String photoName = String.format("demo/1.png");
        InputStream demoInputStream = null;
        try {
            demoInputStream = getAssets().open(photoName);
            Bitmap demoBitmap = BitmapFactory.decodeStream(demoInputStream);
            demoInputStream.close();
            publisher.setCaptureBitmap(demoBitmap);
        } catch (IOException e) {

        }

        final String publishUrl = "rtmp://demo-cam.meetromance.com:8899/publish_standard/MM1?userId=MM1&siteId=8";
		publisher.publisherUrl(publishUrl, "", "");
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
    /**
     * 获取应用私有外部存储 - 文件目录（持久化存储，比如播放器配置、日志）
     * 路径：/storage/emulated/0/Android/data/包名/files/xxx/
     * @param subDir 子目录（比如"lsplayer/log"、"lsplayer/cache"）
     * @return 子目录File对象
     */
    private File getExternalPrivateFilesDir(String subDir) {
        File externalFilesDir = getExternalFilesDir(null);
        if (externalFilesDir == null) {
            // 异常处理：设备无外部存储（极少情况），降级到应用内部存储
            externalFilesDir = getFilesDir();
        }
        File targetDir = new File(externalFilesDir, subDir);
        // 确保目录存在，不存在则创建（多层目录用mkdirs()，单层用mkdir()）
        if (!targetDir.exists()) {
            targetDir.mkdirs();
        }
        return targetDir;
    }
}
