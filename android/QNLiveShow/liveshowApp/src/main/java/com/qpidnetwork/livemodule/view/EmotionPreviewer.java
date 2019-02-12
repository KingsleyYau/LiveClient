package com.qpidnetwork.livemodule.view;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.widget.PopupWindow;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.livechat.LCEmotionItem;
import com.qpidnetwork.livemodule.livechat.LCMessageItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.LiveChatManagerEmotionListener;
import com.qpidnetwork.livemodule.livechat.jni.LiveChatClientListener;
import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigEmotionItem;
import com.qpidnetwork.livemodule.livechathttprequest.item.OtherEmotionConfigItem;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;

public class EmotionPreviewer extends PopupWindow implements LiveChatManagerEmotionListener {
	
	private static int SUCCESS = -1;
	private static int FAILED = 0;
	
	private Context context;
	public View contentView;
	
	private TextView price;
	private MaterialProgressBar progress;
	public EmotionPlayer emotionPlayer;
	private LiveChatManager mLiveChatManager;
	private OtherEmotionConfigEmotionItem emotionItem;
	private ArrayList<String> images;
	
	
	public EmotionPreviewer(Context context){
		super(context);
		this.context = context;
		this.setHeight(LayoutParams.MATCH_PARENT);
		this.setWidth(LayoutParams.MATCH_PARENT);
		this.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
		this.setTouchable(true);
		this.setFocusable(true);
		mLiveChatManager = LiveChatManager.getInstance();
		
		
		
		setContentView(createWindow());
		
	}
	
	@SuppressLint("InflateParams")
	private View createWindow(){
		contentView = LayoutInflater.from(context).inflate(R.layout.view_live_emotion_previewer_lc, null);
		emotionPlayer = (EmotionPlayer)contentView.findViewById(R.id.emotionPlayer);
		price = (TextView)contentView.findViewById(R.id.price);
		progress = (MaterialProgressBar)contentView.findViewById(R.id.progress);
		
		return contentView;
		
	}
	
	public void setEmotionItem(OtherEmotionConfigEmotionItem emotionItem){
		this.emotionItem = emotionItem;
		price.setText(String.format(context.getResources().getString(R.string.live_chat_emotion_preview_price), "" + emotionItem.price));
//		LCEmotionItem item = mLiveChatManager.GetEmotionInfo(emotionItem.fileName);
//		if ((item.playBigImages != null) && (item.playBigImages.size() > 0)){
//			progress.setVisibility(View.GONE);
//			images = item.playBigImages;
//			handler.sendEmptyMessage(SUCCESS);
//		}else{
			progress.setVisibility(View.VISIBLE);
			emotionPlayer.setVisibility(View.INVISIBLE);
			mLiveChatManager.RegisterEmotionListener(this);
			mLiveChatManager.GetEmotionPlayImage(emotionItem.fileName);
			Log.v("emotion file", emotionItem.fileName);
//		}
	}
	
	
	@Override public void dismiss(){
		emotionItem = null;
		mLiveChatManager.UnregisterEmotionListener(this);
		if (emotionPlayer.isPlaying()) emotionPlayer.stop();
		progress.setVisibility(View.GONE);
		super.dismiss();
	}

	@Override
	public void OnGetEmotionConfig(boolean success, String errno,
			String errmsg, OtherEmotionConfigItem item) {
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
	public void OnGetEmotionImage(boolean success, LCEmotionItem emotionItem) {
		// TODO Auto-generated method stub
		
	}

	@SuppressWarnings("unused")
	@Override
	public void OnGetEmotionPlayImage(boolean success, LCEmotionItem emotionItem) {
		// TODO Auto-generated method stub
		Log.v("emotion Id", emotionItem.emotionId);

		Log.v("is success", success + "");
		
		if (this.emotionItem == null) return;
		if (emotionItem == null) return;
		if (!success) return;
		if (!this.emotionItem.fileName.equals(emotionItem.emotionId)) return;
		images = emotionItem.playBigImages;
		handler.sendEmptyMessage((success)? SUCCESS : FAILED);
		Log.v("is success", "download ended");
	}

	@Override
	public void OnGetEmotion3gp(boolean success, LCEmotionItem emotionItem) {
		// TODO Auto-generated method stub
		
	}


	private Handler handler = new Handler(){
		@Override public void handleMessage(Message message){
			super.handleMessage(message);
			
			progress.setVisibility(View.GONE);
			if (message.what == SUCCESS){
				if (emotionPlayer.isPlaying()) emotionPlayer.stop();
				emotionPlayer.setVisibility(View.VISIBLE);
				emotionPlayer.setImageList(images);
				emotionPlayer.play();
			}else{
				emotionPlayer.setVisibility(View.INVISIBLE);
			}
		}
	};
	


}
