package com.qpidnetwork.livemodule.liveshow.livechat.voice;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;

import java.io.File;
import java.io.IOException;

public class VoicePlayerManager {

	private boolean isPlaying = false; //是否正在播放
	private int currMsgId = -1; //当前播放的Message id
	private MediaPlayer player; // 播放器
	
	private View v; //当前正在播放的View，用于控制图标变换
	private Context mContext;
	
	private static VoicePlayerManager mVoicePlayerManager;
	
	public static VoicePlayerManager getInstance(Context context){
		if(mVoicePlayerManager == null){
			mVoicePlayerManager = new VoicePlayerManager(context);
		}
		return mVoicePlayerManager;
	}
	
	private VoicePlayerManager(Context context){
		isPlaying = false;
		currMsgId = -1;
		mContext = context.getApplicationContext();
	}
	
	/**
	 * 播放语音
	 * 
	 * @param v
	 * @param filePath
	 */
	public boolean startPlayVoice(View v, int msgId, String filePath) {
		boolean isPlay = false;
		if(currMsgId == msgId){
			if(isPlaying){
				stopPlaying();
			}else{
				this.v = v;
				if((filePath != null) && (new File(filePath).exists())){
					/*本地文件存在开始播放*/
					isPlay = startPlaying(filePath);
				}
			}
		}else{
			currMsgId = msgId;
			if(isPlaying){
				stopPlaying();
			}
			this.v = v;
			if((filePath != null) && (new File(filePath).exists())){
				/*本地文件存在开始播放*/
				isPlay = startPlaying(filePath);
			}
		}
		return isPlay;
	}
	
	/**
	 * 开启播放
	 */
	private boolean startPlaying(String filePath) {
		boolean isPlay = false;
		player = new MediaPlayer();
		try {
			player.setOnCompletionListener(new OnCompletionListener() {
				@Override
				public void onCompletion(MediaPlayer mp) {
					/*自动播放结束*/
					onStopUIUpdate();
				}
			});
			player.setDataSource(filePath);
			player.setAudioStreamType(AudioManager.STREAM_MUSIC);
			player.prepare();
			player.start();
			onStartUIUpdate();
			isPlay = true;
		} catch (IOException e) {
			onStopUIUpdate();
			e.printStackTrace();
			isPlay = false;
		}
		return isPlay;
	}

/**
	 * 停止播放
	 */
	public void stopPlaying() {
		onStopUIUpdate();
		if (player != null) {
			player.stop();
			player.release();
			player = null;
		}
	}
	
	/**
	 * 异常或手动停止及异常播放，状态及界面修改
	 */
	@SuppressWarnings("deprecation")
	private void onStopUIUpdate(){
		isPlaying = false;
		if(v != null){
			TextView text =(TextView) v.findViewById(R.id.chat_sound_time);
			
			Drawable drawable= mContext.getResources().getDrawable(R.drawable.ic_play_circle_outline_white_24dp);
			drawable.setBounds(0, 0, drawable.getMinimumWidth(), drawable.getMinimumHeight());
			text.setCompoundDrawables(drawable,null,null,null);
		}
	}
	
	/**
	 * 正式开始播放，界面修改
	 */
	@SuppressWarnings("deprecation")
	private void onStartUIUpdate(){
		isPlaying = true;
		if(v != null){
			TextView text =(TextView) v.findViewById(R.id.chat_sound_time);
			Drawable drawable= mContext.getResources().getDrawable(R.drawable.ic_pause_circle_outline_white_24dp);
			drawable.setBounds(0, 0, drawable.getMinimumWidth(), drawable.getMinimumHeight());
			text.setCompoundDrawables(drawable,null,null,null);
			
			ImageView imgRead = (ImageView)v.findViewById(R.id.img_isread);
			imgRead.setVisibility(View.GONE);
		}
	}
	
}
