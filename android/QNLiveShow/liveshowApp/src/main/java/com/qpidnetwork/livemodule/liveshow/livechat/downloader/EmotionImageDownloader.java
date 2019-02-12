package com.qpidnetwork.livemodule.liveshow.livechat.downloader;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.livechat.LCEmotionItem;
import com.qpidnetwork.livemodule.livechat.LCMessageItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerEmotionListener;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener;
import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigItem;

import java.io.File;

public class EmotionImageDownloader implements LiveChatManagerEmotionListener {
	
	private LiveChatManager mLiveChatManager;
	private ImageView emotionPane;
	private ProgressBar pbDownload;
	private String emotionId;
	
	public EmotionImageDownloader(){
		mLiveChatManager = LiveChatManager.getInstance();
	}
	
	public void displayEmotionImage(ImageView emotionPane, ProgressBar pbDownload, String emotionId){
		this.emotionId = emotionId;
		/*设置默认图标，防止滚动过程中，由于view重用导致显示错误*/
		emotionPane.setImageResource(R.drawable.ic_default_live_preminum_emotion_grey_56dp);
		
		LCEmotionItem item = mLiveChatManager.GetEmotionInfo(emotionId);
		if ((!TextUtils.isEmpty(item.imagePath))
				&& (new File(item.imagePath).exists())) {
			/* 有缩略图，直接使用 */
			Bitmap thumb = BitmapFactory.decodeFile(item.imagePath);
			emotionPane.setImageBitmap(thumb);
			if(pbDownload != null){
				pbDownload.setVisibility(View.GONE);
			}
		} else {
			this.emotionPane = emotionPane;
			this.pbDownload = pbDownload;
			if(pbDownload != null){
				pbDownload.setVisibility(View.VISIBLE);
			}
			mLiveChatManager.RegisterEmotionListener(this);
			boolean success = mLiveChatManager.GetEmotionImage(emotionId);
			if(!success){
				if(pbDownload != null){
					pbDownload.setVisibility(View.GONE);
				}
				mLiveChatManager.UnregisterEmotionListener(EmotionImageDownloader.this);
			}
		}
	}
	
	@SuppressLint("HandlerLeak")
	private Handler handler = new Handler(){
		public void handleMessage(Message msg) {
			LCEmotionItem item = (LCEmotionItem)msg.obj;
			if(item.emotionId.equals(emotionId)){
				mLiveChatManager.UnregisterEmotionListener(EmotionImageDownloader.this);
				if(pbDownload != null){
					pbDownload.setVisibility(View.GONE);
				}
			
				if ((!TextUtils.isEmpty(item.imagePath))
						&& (new File(item.imagePath).exists())) {
					/* 有缩略图，直接使用 */
					Bitmap thumb = BitmapFactory.decodeFile(item.imagePath);
					emotionPane.setImageBitmap(thumb);
					if(pbDownload != null){
						pbDownload.setVisibility(View.GONE);
					}
				}	
			}
		}
	};

	@Override
	public void OnGetEmotionConfig(boolean success, String errno, String errmsg,
			OtherEmotionConfigItem item) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnSendEmotion(LiveChatClientListener.LiveChatErrType errType, String errmsg,
							  LCMessageItem item) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnRecvEmotion(LCMessageItem item) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnGetEmotionImage(boolean success,
			LCEmotionItem emotionItem) {
		Message msg = Message.obtain();
		if(success){
			msg.obj = emotionItem;
			handler.sendMessage(msg);
		}
		
	}

	@Override
	public void OnGetEmotionPlayImage(boolean success,
			LCEmotionItem emotionItem) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void OnGetEmotion3gp(boolean success, LCEmotionItem emotionItem) {
		// TODO Auto-generated method stub
		
	}

}
